# Convolutional VAE Computing Unit
This is a simple CVAE Computing design for the FPGA project.
Authors:\
NguyenVan Luu: nluu1784@gmail.com \
NguyenThuy Linh: linhlinh@gmail.com

## Design requirements
Detailed requirements are under `./Document/CVAE.pdf`, the following lists some main requests:
* Programming Language: Python >= 3.8
* Frameworks & Libraries: PyTorch >= 1.10 (for neural network operations), NumPy >= 1.21 (for numerical computations)
* Tool: Iveirilog and Gtkwave(if you need), to install it let run the command below:
```sh
sudo apt-get install iverilog
sudo apt install gtkwave 
```
* If you use other EDA tools like Cadence or Synopsys, please rewrite your makefile to fit the tool as usual because we do not use any other special frameworks.

## Design Architecture and Verification Environment Overview
![Picture1](https://github.com/user-attachments/assets/ffabb259-c742-42b4-a577-ffc195eb0779)

Để mô phỏng lớp tích chập: 

```sh
cd ./rtl/tb_CONV
make run
```

Để mô phỏng IP PRNG: 
```sh
cd ./rtl/PRNG
make run

```
Để mô phỏng IP Convolution Tranpose: 
```sh
cd ./rtl/tb_conv_tranpose
make run

