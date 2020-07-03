fetch("wasm.wasm").then(wasm => {wasm.arrayBuffer().then((wasm) => {
    //startTime = performance.now();

    var importObject = {
        console: {
            log: (value) => console.log(value)
        },
        js: {
            mem: new WebAssembly.Memory({initial: 1}),
            global: new WebAssembly.Global({value: "i32", mutable: true}, 0)
        }
    };

    WebAssembly.instantiate(wasm, importObject).then(obj => {
        obj.instance.exports.runCode();
    });

    //console.log("Total Time:" + (performance.now() - startTime));
})});