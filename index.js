//
// Reading WASM memory
//

let memory;

const utf8Decoder = new TextDecoder('utf-8');
const fromUTF8 = (ptr, len) => {
  return utf8Decoder.decode(new Uint8Array(memory.buffer, ptr, len));
};

//
// Exports to WASM
//

const JS_print = (msgPtr, msgLen) => {
  console.log(fromUTF8(msgPtr, msgLen));
};

const exportsToWASM = {
  JS_print,
};

//
// Instantiate WASM
//

(async () => {
  const response = await fetch('main.wasm');
  const bytes = await response.arrayBuffer();
  const { instance } = await WebAssembly.instantiate(bytes, { env: exportsToWASM });

  memory = instance.exports.memory;

  if (instance.exports.init) {
    instance.exports.init();
  }

  if (instance.exports.frame) {
    const frame = (t) => {
      instance.exports.frame(t);
      requestAnimationFrame(frame);
    };
    requestAnimationFrame(frame);
  }
})();
