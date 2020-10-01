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

env.webglViewport = (x, y, w, h) => gl.viewport(x, y, w, h);
env.webglClearColor = (r, g, b, a) => gl.clearColor(r, g, b, a);
env.webglClear = (mask) => gl.clear(mask);
env.webglDrawArrays = (mode, first, count) => gl.drawArrays(mode, first, count);

//
// Instantiate WASM
//

(async () => {
  const response = await fetch('main.wasm');
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
})();
