import torch
import torch.nn as nn
import numpy as np

ic = 3  # số kênh đầu vào
ih = 64  # chiều cao đầu vào
iw = 64  # chiều rộng đầu vào

oc = 8  # số kênh đầu ra
oh = 66  # chiều cao đầu ra (sửa lại cho phù hợp với ConvTranspose2d)
ow = 66  # chiều rộng đầu ra (sửa lại cho phù hợp với ConvTranspose2d)

kk = 3  # kích thước kernel

# Sửa lại in_channels cho phù hợp với số kênh đầu vào của bạn
conv_transpose2d = nn.ConvTranspose2d(in_channels=ic, out_channels=oc, kernel_size=kk, stride=1, padding=0, output_padding=1, bias=False)
relu = nn.ReLU(inplace=False)

# randomize input feature map
ifm = torch.rand(1, ic, ih, iw) * 15 - 5
ifm = torch.round(ifm)

# randomize weight
weight = torch.rand(oc, ic, kk, kk) * 15 - 6
weight = torch.round(weight)

# setting the kernel of conv_transpose2d as weight
conv_transpose2d.weight = nn.Parameter(weight)

# computing output feature
ofm = conv_transpose2d(ifm)
ofm_relu = relu(ofm)

ifm_np = ifm.data.numpy().astype(int)
weight_np = weight.data.numpy().astype(int)
ofm_np = ofm_relu.data.numpy().astype(int)

# write data as a 2's complement binary representation type
with open("ifm_bin_c%dxh%dxw%d.txt" % (ic, ih, iw), "w") as f:
    for i in range(ic):
        for j in range(ih):
            for k in ifm_np[0, i, j, :]:
                s = np.binary_repr(k, 8) + " "
                f.write(s)
            f.write("\n")
        f.write("\n")


with open("ofm_bin_c%dxh%dxw%d.txt" % (oc, oh, ow), "w") as f:
    for i in range(oc):
        for j in range(oh):
            for k in ofm_np[0, i, j, :]:
                s = np.binary_repr(k, 25) + " "
                f.write(s)
            f.write("\n")
        f.write("\n")


with open("weight_bin_co%dxci%dxk%dxk%d.txt" % (oc, ic, kk, kk), "w") as f:
    for i in range(oc):
        for j in range(ic):
            for k in range(kk):
                for l in weight_np[i, j, k, :]:
                    s = np.binary_repr(l, 8) + " "
                    f.write(s)
                f.write("\n")
            f.write("\n")
        f.write("\n")


# write out data as decimal type
with open("ifm_dec_%dxh%dxw%d.txt" % (ic, ih, iw), "w") as f:
    for i in range(ic):
        for j in range(ih):
            for k in ifm_np[0, i, j, :]:
                s = str(k) + "\t "
                f.write(s)
            f.write("\n")
        f.write("\n")

with open("ofm_dec_c%dxh%dxw%d.txt" % (oc, oh, ow), "w") as f:
    for i in range(oc):
        for j in range(oh):
            for k in ofm_np[0, i, j, :]:
                s = str(k) + ","
                f.write(s)
            f.write("\n")
        f.write("\n")

with open("weight_dec_co%dxci%dxk%dxk%d.txt" % (oc, ic, kk, kk), "w") as f:
    for i in range(oc):
        for j in range(ic):
            for k in range(kk):
                for l in weight_np[i, j, k, :]:
                    s = str(l) + " "
                    f.write(s)
                f.write("\n")
            f.write("\n")
        f.write("\n")

