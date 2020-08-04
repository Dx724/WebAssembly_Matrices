fetch("wasm.wasm").then(wasm => {wasm.arrayBuffer().then((wasm) => {
    startTime = performance.now();

    importObject = {
        console: {
            log: (value) => console.log(value)
        },
        js: {
            mem: new WebAssembly.Memory({initial: 32767}),
            global: new WebAssembly.Global({value: "i32", mutable: true}, 0)
        }
    };

    WebAssembly.instantiate(wasm, importObject).then(obj => {
        obj.instance.exports.runCode();
        var endTime = performance.now();
        console.log("Total Time: " + (endTime - startTime) + " milliseconds");
    });
})});