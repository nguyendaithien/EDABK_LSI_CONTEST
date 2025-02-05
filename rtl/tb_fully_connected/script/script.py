#import torch
#import numpy as np
#import torch.nn as nn
#
## Kích thước đầu vào và đầu ra
#ifm_size = 1992
#ofm_size = 20
#
## Khởi tạo lớp Fully Connected
#fc = nn.Linear(in_features=ifm_size, out_features=ofm_size, bias=False)
#relu = nn.ReLU()
#
## Tạo đầu vào ngẫu nhiên
#ifm = torch.rand(1, ifm_size) * 20 - 10
#ifm = torch.round(ifm)
#
## Tạo trọng số ngẫu nhiên
#weight = torch.rand(ofm_size, ifm_size) * 20 - 10
#weight = torch.round(weight)
#
## Đặt trọng số vào FC layer
#fc.weight = nn.Parameter(weight)
#
## Tính toán đầu ra
#ofm = fc(ifm)
#ofm_relu = relu(ofm)
#
## Chuyển đổi sang numpy
#ifm_np = ifm.numpy().astype(int)
#weight_np = weight.numpy().astype(int)
#ofm_np = ofm_relu.detach().numpy().astype(int)
#
## Ghi dữ liệu ra file dạng nhị phân (2's complement) và thập nary(file_name, data, bit_width):
#def write_binary(file_name, data, bit_width):
#	    with open(file_name, "w") as f:
#				        for row in data:
#									            f.write(" ".join(np.binary_repr(x, bit_width) for x in row) + "\n")
## Ghi đầu vào
#write_binary("ifm_bin_%d.txt" % ifm_size, ifm_np, 8)
#
## Ghi trọng số
#write_binary("weight_bin_%dx%d.txt" % (ofm_size, ifm_size), weight_np, 8)
#
## Ghi đầu ra
#write_binary("ofm_bin_%d.txt" % ofm_size, ofm_np, 25)
#
## Ghi dữ liệu dạng thập phân
#def write_decimal(file_name, data):
#    with open(file_name, "w") as f:
#        for row in data:
#            f.write(" ".join(map(str, row)) + "\n")
#
#write_decimal("ifm_dec_%d.txt" % ifm_size, ifm_np)
#write_decimal("weight_dec_%dx%d.txt" % (ofm_size, ifm_size), weight_np)
#write_decimal("ofm_dec_%d.txt" % ofm_size, ofm_np)
#import torch
#import numpy as np
#import torch.nn as nn
#
## Kích thước đầu vào và đầu ra
#ifm_size = 1992
#ofm_size = 20
#
## Khởi tạo lớp Fully Connected
#fc = nn.Linear(in_features=ifm_size, out_features=ofm_size, bias=False)
#relu = nn.ReLU()
#
## Tạo đầu vào ngẫu nhiên
#ifm = torch.rand(1, ifm_size) * 20 - 10
#ifm = torch.round(ifm)
#
## Tạo trọng số ngẫu nhiên
#weight = torch.rand(ofm_size, ifm_size) * 20 - 10
#weight = torch.round(weight)
#
## Đặt trọng số vào FC layer
#fc.weight = nn.Parameter(weight)
#
## Tính toán đầu ra
#ofm = fc(ifm)
#ofm_relu = relu(ofm)
#
## Chuyển đổi sang numpy
#ifm_np = ifm.numpy().astype(int)
#weight_np = weight.numpy().astype(int)
#ofm_np = ofm_relu.detach().numpy().astype(int)
#
## Ghi dữ liệu ra file dạng nhị phân (2's complement) và thập phân
#def write_binary(file_name, data, bit_width):
#    with open(file_name, "w") as f:
#        for row in data:
#            f.write(" ".join(np.binary_repr(x, bit_width) for x in row) + "\n")
#
#def write_weight_binary(file_name, data, bit_width):
#    with open(file_name, "w") as f:
#        for row in data:
#            for i in range(0, len(row), 8):
#                f.write("".join(np.binary_repr(x, bit_width) for x in row[i:i+8]) + "\n")
#
## Ghi đầu vào
#write_binary(f"ifm_bin_{ifm_size}.txt", ifm_np, 8)
#
## Ghi trọng số với 8 giá trị mỗi hàng nối liền nhau
#write_weight_binary(f"weight_bin_{ofm_size}x{ifm_size}.txt", weight_np, 8)
#
## Ghi đầu ra
#write_binary(f"ofm_bin_{ofm_size}.txt", ofm_np, 25)
#
## Ghi dữ liệu dạng thập phân
#def write_decimal(file_name, data):
#    with open(file_name, "w") as f:
#        for row in data:
#            f.write(" ".join(map(str, row)) + "\n")
#
#write_decimal(f"ifm_dec_{ifm_size}.txt", ifm_np)
#write_decimal(f"weight_dec_{ofm_size}x{ifm_size}.txt", weight_np)
#write_decimal(f"ofm_dec_{ofm_size}.txt", ofm_np)

import torch
import numpy as np
import torch.nn as nn

# Kích thước đầu vào và đầu ra
ifm_size = 1992
ofm_size = 512

# Khởi tạo lớp Fully Connected
fc = nn.Linear(in_features=ifm_size, out_features=ofm_size, bias=False)
relu = nn.ReLU()

# Tạo đầu vào ngẫu nhiên
ifm = torch.rand(1, ifm_size) * 20 - 10
ifm = torch.round(ifm)

# Tạo trọng số ngẫu nhiên
weight = torch.rand(ofm_size, ifm_size) * 20 - 10
weight = torch.round(weight)

# Đặt trọng số vào FC layer
fc.weight = nn.Parameter(weight)

# Tính toán đầu ra
ofm = fc(ifm)
ofm_relu = relu(ofm)

# Chuyển đổi sang numpy
ifm_np = ifm.numpy().astype(int)
weight_np = weight.numpy().astype(int)
ofm_np = ofm_relu.detach().numpy().astype(int)

# Ghi dữ liệu ra file dạng nhị phân (2's complement) và thập phân
def write_binary(file_name, data, bit_width):
    with open(file_name, "w") as f:
        for row in data:
            f.write(" ".join(np.binary_repr(x, bit_width) for x in row) + "\n")

def write_weight_binary(file_name, data, bit_width):
    with open(file_name, "w") as f:
        for group in range(0, ofm_size, 8):  # Xử lý từng nhóm 8 bộ filter
            for i in range(ifm_size):  # Duyệt qua tất cả các giá trị của ifm_size (1992 hàng)
                row_values = [data[group + j, i] for j in range(8)]  # Lấy 8 giá trị từ 8 filter
                f.write("".join(np.binary_repr(x, bit_width) for x in row_values) + "\n")

# Ghi đầu vào
write_binary(f"ifm_bin_{ifm_size}.txt", ifm_np, 8)

# Ghi trọng số với mỗi hàng chứa 8 bộ filter khác nhau theo từng nhóm 8 bộ filter
write_weight_binary(f"weight_bin_{ofm_size}x{ifm_size}.txt", weight_np, 8)

# Ghi đầu ra
write_binary(f"ofm_bin_{ofm_size}.txt", ofm_np, 25)

# Ghi dữ liệu dạng thập phân
def write_decimal(file_name, data):
    with open(file_name, "w") as f:
        for row in data:
            f.write(" ".join(map(str, row)) + "\n")

write_decimal(f"ifm_dec_{ifm_size}.txt", ifm_np)
write_decimal(f"weight_dec_{ofm_size}x{ifm_size}.txt", weight_np)
write_decimal(f"ofm_dec_{ofm_size}.txt", ofm_np)

