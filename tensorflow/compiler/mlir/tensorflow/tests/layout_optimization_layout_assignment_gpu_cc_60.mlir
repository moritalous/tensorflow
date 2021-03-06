// RUN: tf-opt %s -tf-layout-assignment -verify-diagnostics | FileCheck %s --dump-input=always

module attributes {
  tf.devices = {"/device:GPU:0" = {cc_major = 6 : i32, cc_minor = 0 : i32}}
} {

// CHECK-LABEL: func @transposeConv2D_3x3_f16
func @transposeConv2D_3x3_f16(%input: tensor<1x28x28x64xf16>, %filter: tensor<3x3x64x64xf16>) -> tensor<1x28x28x64xf16> {
  // cuDNN prefers NCHW data format for spatial convolutions in f16 before
  // compute capability 7.0 (NVIDIA Tensor Cores).

  // CHECK: "tf.Conv2D"(%[[INPUT_TRANSPOSE:[0-9]*]], %arg1)
  // CHECK-SAME: data_format = "NCHW"
  %0 = "tf.Conv2D"(%input, %filter)
       {
         data_format = "NHWC",
         padding = "VALID",
         strides = [1, 1, 1, 1]
       } : (tensor<1x28x28x64xf16>, tensor<3x3x64x64xf16>)
        -> tensor<1x28x28x64xf16>

  return %0 : tensor<1x28x28x64xf16>
}

}
