//With thanks to Francois Beaufort for a very helpful post (https://developers.google.com/web/updates/2019/08/get-started-with-gpu-compute-on-the-web)
import glslang from "https://unpkg.com/@webgpu/glslang@0.0.8/dist/web-devel/glslang.js";

async function matmult(m1, m2, cols1, cols2) {
    // Get WebGPU interfaces
    const adapter = await navigator.gpu.requestAdapter();
    const device = await adapter.requestDevice();

    //Load first matrix into GPU memory
    const mat1 = new Float32Array([cols1, m1.length/cols1, ...m1]);
    const [gpuBuffer_m1, arrayBuffer_m1] = device.createBufferMapped({
        size: mat1.byteLength,
        usage: GPUBufferUsage.STORAGE
    });
    new Float32Array(arrayBuffer_m1).set(mat1);
    gpuBuffer_m1.unmap();

    //Load second matrix into GPU memory
    const mat2 = new Float32Array([cols2, m2.length/cols2, ...m2]);
    const [gpuBuffer_m2, arrayBuffer_m2] = device.createBufferMapped({
        size: mat2.byteLength,
        usage: GPUBufferUsage.STORAGE
    });
    new Float32Array(arrayBuffer_m2).set(mat2);
    gpuBuffer_m2.unmap();

    //Create result matrix
    const resultBufSize = Float32Array.BYTES_PER_ELEMENT * (m1.length / cols1 * cols2);
    const resultBuffer = device.createBuffer({
        size: resultBufSize,
        usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC
    });

    //Define the bind group layout (input/output interface)
    // Note that this can technically be inferred from the shader
    const bindGroupLayout = device.createBindGroupLayout({
        entries: [
            {
                binding: 0,
                visibility: GPUShaderStage.COMPUTE,
                type: "readonly-storage-buffer"
            },
            {
                binding: 1,
                visibility: GPUShaderStage.COMPUTE,
                type: "readonly-storage-buffer"
            },
            {
                binding: 2,
                visibility: GPUShaderStage.COMPUTE,
                type: "storage-buffer"
            }
        ]
    });

    //Create bind group (associating buffers to entries)
    const bindGroup = device.createBindGroup({
        layout: bindGroupLayout,
        entries: [
            {
                binding: 0,
                resource: {
                    buffer: gpuBuffer_m1
                }
            },
            {
                binding: 1,
                resource: {
                    buffer: gpuBuffer_m2
                }
            },
            {
                binding: 2,
                resource: {
                    buffer: resultBuffer
                }
            }
        ]
    });

    //Write shader in GLSL, note that a modified algorithm is used so that the calculation can be applied on a per-cell basis, allowing for parallelization.
    const glslShaderCode = `#version 450
        layout(std430, set=0, binding=0) readonly buffer Matrix1 {
            vec2 dim;
            float vals[];
        } matrix1;
        layout(std430, set=0, binding=1) readonly buffer Matrix2 {
            vec2 dim;
            float vals[];
        } matrix2;
        layout(std430, set=0, binding=2) buffer ResultMatrix {
            float vals[];
        } res;

        void main() {
            ivec2 rPos = ivec2(gl_GlobalInvocationID.x, gl_GlobalInvocationID.y);
            float tRes = 0.0;
            for (int d = 0; d < matrix1.dim.x; d++) {
                tRes += (matrix1.vals[int(rPos.y * matrix1.dim.x + d)] * matrix2.vals[int(rPos.x + matrix2.dim.x * d)]);
            }
            res.vals[rPos.x + rPos.y * int(matrix2.dim.x)] = tRes;
        }
    `;

    //Compile module and build pipeline
    const glslangInstance = await glslang();
    const computePipeline = device.createComputePipeline({
        layout: device.createPipelineLayout({
            bindGroupLayouts: [bindGroupLayout]
        }),
        computeStage: {
            module: device.createShaderModule({
                code: glslangInstance.compileGLSL(glslShaderCode, "compute")
            }),
            entryPoint: "main"
        }
    });

    //Run the shader
    const cmdEnc = device.createCommandEncoder();
    const passEnc = cmdEnc.beginComputePass();
    passEnc.setPipeline(computePipeline);
    passEnc.setBindGroup(0, bindGroup);
    passEnc.dispatch(cols2, m1.length/cols1); //Run the shader for a result matrix of this size
    passEnc.endPass();

    //Use another buffer the read results from GPU
    const resReadBuffer = device.createBuffer({
        size: resultBufSize,
        usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ
    });
    cmdEnc.copyBufferToBuffer(resultBuffer, 0, resReadBuffer, 0, resultBufSize);

    //Submit to GPU
    const gpuCmds = cmdEnc.finish();
    device.defaultQueue.submit([gpuCmds]);

    //Read result
    const resArrayBuf = await resReadBuffer.mapReadAsync();
    return new Float32Array(resArrayBuf);
}

var mat1 = [1, 2, 3, 4, 5, 6, 7, 8, 9];
var mat2 = [7, 2, 3, 1 ,5, 3, 6, 4, 3, 6, 3, 2];
matmult(mat1, mat2, 3, 4).then(console.log);