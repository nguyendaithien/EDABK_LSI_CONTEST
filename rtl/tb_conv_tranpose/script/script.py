import torch
import torch.nn as nn
import numpy as np

# Số kênh đầu vào (CI) và số kênh đầu ra (CO)
CI = 3  # 3 kênh đầu vào
CO = 2  # 2 kênh đầu ra

# Random input CI kênh, kích thước (1, CI, 14, 14), giá trị trong [-5, 10]
input_tensor = torch.randint(-5, 11, (1, CI, 14, 14), dtype=torch.float32)

# Định nghĩa ConvTranspose2d với CI kênh đầu vào, CO kênh đầu ra, kernel size 3x3, stride=1, padding=0
conv_transpose = nn.ConvTranspose2d(in_channels=CI, out_channels=CO, kernel_size=3, stride=1, padding=0, bias=False)

# Random kernel trong khoảng [-5, 10], kích thước (CI, CO, 3, 3)
conv_transpose.weight.data = torch.randint(-5, 11, (CI, CO, 3, 3), dtype=torch.float32)

# Thực hiện phép chập chuyển vị
output_tensor = conv_transpose(input_tensor)

# Chuyển tensor về NumPy để in ra
input_array = input_tensor.squeeze().int().numpy()  # Mảng input 2D (số nguyên)
kernel_array = conv_transpose.weight.int().numpy()  # Kernel (CI, CO, 3, 3) (số nguyên)
output_array = output_tensor.squeeze().int().numpy()  # Mảng output 2D (số nguyên)

# In kết quả
print("🔹 Mảng đầu vào (CI kênh, mỗi kênh kích thước 14x14):")
for c in range(CI):
    print(f"Kênh {c+1}:")
    print(input_array[c])

print("\n🔹 Kernel (CIxCO bộ lọc, mỗi bộ lọc có 3x3):")
for co in range(CO):
    print(f"\nBộ lọc {co+1} (đầu ra {co+1}):")
    for ci in range(CI):
        print(f"Kênh {ci+1} (ứng với IFM kênh {ci+1}):")
        print(kernel_array[ci, co])  # In các kernel tương ứng

print("\n🔹 Mảng đầu ra (CO kênh, mỗi kênh kích thước 16x16):")
for co in range(CO):
    print(f"Kênh {co+1}:")
    print(output_array[co])

print("\nKích thước đầu vào:", input_array.shape)  # (CI, 14, 14)
print("Kích thước kernel:", kernel_array.shape)  # (CI, CO, 3, 3)
print("Kích thước đầu ra:", output_array.shape)  # (CO, 16, 16)

# Ghi dữ liệu vào file nhị phân (bù 2)
with open("ifm_bin_c%dxh%dxw%d.txt" % (CI, 14, 14), "w") as f:
    for i in range(CI):
        for j in range(14):
            for k in input_array[i, j, :]:
                s = np.binary_repr(k, width=8) + " "
                f.write(s)
            f.write("\n")
        f.write("\n")

with open("ofm_bin_c%dxh%dxw%d.txt" % (CO, 16, 16), "w") as f:
    for i in range(CO):
        for j in range(16):
            for k in output_array[i, j, :]:
                s = np.binary_repr(k, width=25) + " "
                f.write(s)
            f.write("\n")
        f.write("\n")

with open("weight_bin_co%dxci%dxk%dxk%d.txt" % (CO, CI, 3, 3), "w") as f:
    for i in range(CO):
        for j in range(CI):
            for k in range(3):
                for l in kernel_array[j, i, k, :]:
                    s = np.binary_repr(l, width=8) + " "
                    f.write(s)
                f.write("\n")
            f.write("\n")
        f.write("\n")

# Ghi dữ liệu vào file thập phân
with open("ifm_dec_%dxh%dxw%d.txt" % (CI, 14, 14), "w") as f:
    for i in range(CI):
        for j in range(14):
            for k in input_array[i, j, :]:
                s = str(k) + "\t"
                f.write(s)
            f.write("\n")
        f.write("\n")

with open("ofm_dec_%dxh%dxw%d.txt" % (CO, 16, 16), "w") as f:
    for i in range(CO):
        for j in range(16):
            for k in output_array[i, j, :]:
                s = str(k) + "\t"
                f.write(s)
            f.write("\n")
        f.write("\n")

with open("weight_dec_co%dxci%dxk%dxk%d.txt" % (CO, CI, 3, 3), "w") as f:
    for i in range(CO):
        for j in range(CI):
            for k in range(3):
                for l in kernel_array[j, i, k, :]:
                    s = str(l) + "\t"
                    f.write(s)
                f.write("\n")
            f.write("\n")
        f.write("\n")

print("🔹 Đã ghi mảng đầu vào (IFM), mảng đầu ra (OFM) và mảng trọng số (Weight) vào các file.")

