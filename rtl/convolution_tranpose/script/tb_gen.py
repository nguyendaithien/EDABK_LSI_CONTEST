import torch
import torch.nn as nn
import numpy as np

# Thông số đầu vào
ic = 3   # Số kênh đầu vào
ih = 14  # Chiều cao đầu vào
iw = 14  # Chiều rộng đầu vào

# Thông số đầu ra
oc = 2  # Số kênh đầu ra
oh = 16  # Chiều cao đầu ra
ow = 16  # Chiều rộng đầu ra

# Kích thước kernel
kk = 3

# Tạo lớp ConvTranspose2d
conv_transpose2d = nn.ConvTranspose2d(
in_channels=ic,       # Số kênh đầu vào
out_channels=oc,      # Số kênh đầu ra
kernel_size=kk,       # Kích thước kernel
stride=1,             # Bước di chuyển
padding=0,            # Padding
output_padding=0,     # Padding đầu ra
bias=False            # Không sử dụng bias
)

# Kích hoạt ReLU
relu = nn.ReLU(inplace=False)

# Khởi tạo input feature map (IFM) ngẫu nhiên
ifm = torch.rand(1, ic, ih, iw) * 20 - 3
ifm = torch.round(ifm)  # Làm tròn giá trị IFM

# Khởi tạo trọng số (kernel) ngẫu nhiên
weight = torch.rand(ic, oc, kk, kk) * 20 - 3  # Kích thước trọng số cho ConvTranspose2d là (in_channels, out_channels, kernel_size, kernel_size)
weight = torch.round(weight)

# Đặt trọng số của ConvTranspose2d
conv_transpose2d.weight = nn.Parameter(weight)

# Tính toán đầu ra (OFM)
ofm = conv_transpose2d(ifm)
ofm_relu = relu(ofm)

# Chuyển dữ liệu sang NumPy để xử lý tiếp
ifm_np = ifm.data.numpy().astype(int)
weight_np = weight.data.numpy().astype(int)
ofm_np = ofm_relu.data.numpy().astype(int)

# In ra kết quả để kiểm tra
print("Input Feature Map (IFM):", ifm_np.shape)
print("Weight Shape:", weight_np.shape)
print("Output Feature Map (OFM):", ofm_np.shape)

# Write IFM as 2's complement binary representation
with open("ifm_bin_c%dxh%dxw%d.txt" % (ic, ih, iw), "w") as f:
    for i in range(ic):
        for j in range(ih):
            for k in ifm_np[0, i, j, :]:  # Loop through width
                s = np.binary_repr(k, 8) + " "
                f.write(s)
            f.write("\n")
        f.write("\n")

# Write OFM as 2's complement binary representation
with open("ofm_bin_c%dxh%dxw%d.txt" % (oc, oh, ow), "w") as f:
    for i in range(oc):
        for j in range(oh):
            for k in ofm_np[0, i, j, :]:  # Loop through width
                s = np.binary_repr(k, 16) + " "
                f.write(s)
            f.write("\n")
        f.write("\n")

# Write weight as 2's complement binary representation
with open("weight_bin_ci%dxco%dxk%dxk%d.txt" % (ic, oc, kk, kk), "w") as f:
    for i in range(ic):  # Loop through input channels
        for j in range(oc):  # Loop through output channels
            for k in range(kk):  # Loop through kernel height
                for l in weight_np[i, j, k, :]:  # Loop through kernel width
                    s = np.binary_repr(l, 8) + " "
                    f.write(s)
                f.write("\n")
            f.write("\n")
        f.write("\n")

# Write IFM as decimal values
with open("ifm_dec_c%dxh%dxw%d.txt" % (ic, ih, iw), "w") as f:
    for i in range(ic):
        for j in range(ih):
            for k in ifm_np[0, i, j, :]:
                s = str(k) + "\t "
                f.write(s)
            f.write("\n")
        f.write("\n")

# Write OFM as decimal values
with open("ofm_dec_c%dxh%dxw%d.txt" % (oc, oh, ow), "w") as f:
    for i in range(oc):
        for j in range(oh):
            for k in ofm_np[0, i, j, :]:
                s = str(k) + ","
                f.write(s)
            f.write("\n")
        f.write("\n")

# Write weight as decimal values
with open("weight_dec_ci%dxco%dxk%dxk%d.txt" % (ic, oc, kk, kk), "w") as f:
    for i in range(ic):  # Loop through input channels
        for j in range(oc):  # Loop through output channels
            for k in range(kk):  # Loop through kernel height
                for l in weight_np[i, j, k, :]:  # Loop through kernel width
                    s = str(l) + " "
                    f.write(s)
                f.write("\n")
            f.write("\n")
        f.write("\n")



