//
// WASM memory interaction
//

let memory;

const utf8Decoder = new TextDecoder('utf-8');
const readUTF8 = (ptr, len) => utf8Decoder.decode(new Uint8Array(memory.buffer, ptr, len));

//
// Exports to WASM
//

const env = {};

// Console

env.consoleLog = (msgPtr, msgLen) => console.log(readUTF8(msgPtr, msgLen));

// GL

const gl = document.querySelector('#canvas').getContext('webgl');

const glObjs = {};
let nextGlObjId = 0;
const addGlObj = (obj) => {
  const id = nextGlObjId++;
  glObjs[id] = obj;
  return id;
};
const removeGlObj = (id) => {
  const obj = glObjs[id];
  delete glObjs[id];
  return obj;
};

env.myglSetupShader = (type, sourcePtr, sourceLen) => {
  const shader = gl.createShader(type);
  gl.shaderSource(shader, readUTF8(sourcePtr, sourceLen));
  gl.compileShader(shader);
  if (gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    return addGlObj(shader);
  }
  console.log(gl.getShaderInfoLog(shader));
  gl.deleteShader(shader);
};
env.webglDeleteShader = (shaderId) => gl.deleteShader(removeGlObj[shaderId]);

env.myglSetupProgram = (vertId, fragId) => {
  const program = gl.createProgram();
  gl.attachShader(program, glObjs[vertId]);
  gl.attachShader(program, glObjs[fragId]);
  gl.linkProgram(program);
  if (gl.getProgramParameter(program, gl.LINK_STATUS)) {
    return addGlObj(program);
  }
  console.log(gl.getProgramInfoLog(program));
  gl.deleteProgram(program);
};
env.webglDeleteProgram = (programId) => gl.deleteProgram(glObjs[programId]);
env.webglUseProgram = (programId) => gl.useProgram(glObjs[programId]);

env.webglCreateBuffer = () => addGlObj(gl.createBuffer());
env.webglBindBuffer = (target, bufferId) => gl.bindBuffer(target, glObjs[bufferId]);
env.webglBufferData = (target, dataPtr, dataLen, usage) =>
  gl.bufferData(target, new Float32Array(memory.buffer, dataPtr, dataLen), usage);
env.webglDeleteBuffer = (bufferId) => gl.deleteBuffer(glObjs[bufferId]);

env.webglGetAttribLocation = (programId, namePtr, nameLen) =>
  gl.getAttribLocation(glObjs[programId], readUTF8(namePtr, nameLen));
env.webglEnableVertexAttribArray = (index) => gl.enableVertexAttribArray(index);
env.webglDisableVertexAttribArray = (index) => gl.disableVertexAttribArray(index);
env.webglVertexAttribPointer = (index, size, type, normalize, stride, offset) =>
  gl.vertexAttribPointer(index, size, type, normalize, stride, offset);

env.myglSetupViewport = () => {
  const w = gl.canvas.clientWidth;
  const h = gl.canvas.clientHeight;
  if (gl.canvas.width != w || gl.canvas.height != h) {
    gl.canvas.width = w;
    gl.canvas.height = h;
  }
  gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);
};
env.webglClearColor = (r, g, b, a) => gl.clearColor(r, g, b, a);
env.webglClear = (mask) => gl.clear(mask);
env.webglDrawArrays = (mode, first, count) => gl.drawArrays(mode, first, count);

// UI

env.uiElemOpenStart = (tagPtr, tagLen) => IncrementalDOM.elementOpenStart(readUTF8(tagPtr, tagLen));
env.uiElemOpenStartKeyInt = (tagPtr, tagLen, key) =>
  IncrementalDOM.elementOpenStart(readUTF8(tagPtr, tagLen), key);
env.uiElemOpenStartKeyStr = (tagPtr, tagLen, keyPtr, keyLen) =>
  IncrementalDOM.elementOpenStart(readUTF8(tagPtr, tagLen), readUTF8(keyPtr, keyLen));

env.uiElemOpenEnd = () => IncrementalDOM.elementOpenEnd();

env.uiElemClose = (tagPtr, tagLen) => IncrementalDOM.elementClose(readUTF8(tagPtr, tagLen));

env.uiAttrInt = (namePtr, nameLen, value) => IncrementalDOM.attr(readUTF8(namePtr, nameLen), value);
env.uiAttrFloat = (namePtr, nameLen, value) =>
  IncrementalDOM.attr(readUTF8(namePtr, nameLen), value);
env.uiAttrStr = (namePtr, nameLen, valuePtr, valueLen) =>
  IncrementalDOM.attr(readUTF8(namePtr, nameLen), readUTF8(valuePtr, valueLen));
env.uiAttrClass = (classPtr, classLen) =>
  IncrementalDOM.attr('class', readUTF8(classPtr, classLen));

env.uiText = (valuePtr, valueLen) => IncrementalDOM.text(readUTF8(valuePtr, valueLen));

let uiEventCounts = new WeakMap();
const handler = (e) => {
  const target = e.target;
  let counts = uiEventCounts.get(target);
  if (counts === undefined) {
    counts = {};
    uiEventCounts.set(target, counts);
  }
  const count = counts[e.type];
  if (count === undefined) {
    counts[e.type] = 1;
  } else {
    counts[e.type] = count + 1;
  }
};
env.uiEvents = (typePtr, typeLen) => {
  const type = readUTF8(typePtr, typeLen);
  const target = IncrementalDOM.currentElement();
  if (!target.__UIHandlerRegistered) {
    target.addEventListener(type, handler);
    target.__UIHandlerRegistered = true;
  }
  const counts = uiEventCounts.get(target);
  if (counts === undefined) {
    return 0;
  }
  const count = counts[type];
  if (count === undefined) {
    return 0;
  }
  return count;
};

//
// Instantiate WASM
//

(async () => {
  const response = await fetch('main.wasm?ts=' + new Date().getTime());
  const bytes = await response.arrayBuffer();
  const { instance } = await WebAssembly.instantiate(bytes, { env });

  memory = instance.exports.memory;

  if (instance.exports.init) {
    instance.exports.init();
  }

  if (instance.exports.frame) {
    const frame = (t) => {
      if (document.hasFocus()) {
        instance.exports.frame(t);
      }
      requestAnimationFrame(frame);
    };
    requestAnimationFrame(frame);
  }

  if (instance.exports.uiSide) {
    const side = document.getElementById('side');
    const uiSide = () => {
      if (document.hasFocus()) {
        IncrementalDOM.patch(side, () => {
          instance.exports.uiSide();
        });
        uiEventCounts = new WeakMap();
      }
      requestAnimationFrame(uiSide);
    };
    requestAnimationFrame(uiSide);
  }
})();
