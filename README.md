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
The verification framework evaluates the Convolutional Variational Autoencoder (VAE) IP using the following process:
1. **Generating Input Data**  
   - Input data is randomly generated using **PyTorch**, ensuring diverse test cases.  
   - This input data is then used to stimulate both the **Device Under Test (DUT)** and the reference model.  

2. **Execution in Two Environments**  
   - **DUT (Convolutional VAE IP in hardware)**: The input data is fed into the hardware IP, where computations are performed to produce the **RTL Output**.  
   - **Reference Model (Golden Model - PyTorch)**: The same input data is also processed by the PyTorch-based Convolutional VAE model, generating the **Golden Output**.  

3. **Comparison of Results**  
   - The **RTL Output** from the hardware IP is compared with the **Golden Output** from the PyTorch model.  
   - A **comparison module** evaluates the differences between the two outputs to verify the accuracy of the IP.  

4. **Accuracy Validation**  
   - If the **RTL Output** and **Golden Output** are sufficiently similar within an acceptable error margin, the IP is considered correct (**Pass**).  
   - If significant deviations are found, the verification process reports an error (**No Pass**) for further debugging and hardware design adjustments.
   - 
![Picture1](https://github.com/user-attachments/assets/ffabb259-c742-42b4-a577-ffc195eb0779)

## Main Contributions

## Usage
### Convolution Accelerator
First, you need to run the Python script to generate the input feature map, weights, and golden output in integer format.
If you want to modify the parameters of the convolutional layer, update the following parameters in the file:
```sh
cd ./script
Open file script.py
```
```sh
In file script.py
ic: number of input channel
ih: height of input feature map
iw: width of input feature map
oc: number of output channel (=number of filter)
oh: height of output feature map
ow: width of output feature map
kk: kernel zise

In file tb.v
parameter KERNEL_SIZE : kernel size
parameter STRIDE : stride size
parameter PAD : apply padding size
parameter RELU : apply relu activation
parameter CI : input channel
parameter CO : output channel
parameter PADDING_SIZE : padding size
parameter IFM_SIZE : IFM size
```

RTL Simulation 

```sh
cd ./rtl/tb_CONV
make run
```
If the simulation is successful, the screen will display as follows: 
```sh
 Computing channel:             1
 Computing channel:             2
 Computing channel:             3
 End filter:                    1
 \\\\\\\\\\\\\\\\\\\\\\\\\\
 Computing channel:             1
 Computing channel:             2
 Computing channel:             3
 End filter:                    2
 \\\\\\\\\\\\\\\\\\\\\\\\\\
 Computing channel:             1
 Computing channel:             2
 Computing channel:             3
 End filter:                    3
 \\\\\\\\\\\\\\\\\\\\\\\\\\
 Computing channel:             1
 Computing channel:             2
 Computing channel:             3
 End filter:                    4
 \\\\\\\\\\\\\\\\\\\\\\\\\\
 Computing channel:             1
 Computing channel:             2
 Computing channel:             3
 End filter:                    5
 \\\\\\\\\\\\\\\\\\\\\\\\\\
 Computing channel:             1
 Computing channel:             2
 Computing channel:             3
 End filter:                    6
 \\\\\\\\\\\\\\\\\\\\\\\\\\
 Computing channel:             1
 Computing channel:             2
 Computing channel:             3
 End filter:                    7
 \\\\\\\\\\\\\\\\\\\\\\\\\\
 Computing channel:             1
 Computing channel:             2
 Computing channel:             3
 End filter:                    8
 \\\\\\\\\\\\\\\\\\\\\\\\\\
██████╗  █████╗ ███████╗███████╗    ████████╗███████╗███████╗████████╗                                                                               
██╔══██╗██╔══██╗██╔════╝██╔════╝    ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝                                                                               
██████╔╝███████║███████╗███████╗       ██║   █████╗  ███████    ██║
██║     ██║  ██║╚════██║╚════██║       ██║   ██║          ██║   ██║  
██║     ██║  ██║███████║███████║       ██║   ███████╗███████╗   ██║                                          
╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝       ╚═╝   ╚══════╝╚══════╝   ╚═╝
```
### PRNG module
```sh
cd ./rtl/PRNG
make run
```
This is the random number generation module. In the case of **CVAE**, this module will generate two random numbers within the range [0:1]. Below is the simulation result if the run is successful:
```sh
the random number generated in the range [0:1] is 0.174923
the random number generated in the range [0:1] is 0.489334
```
The two random numbers generated depend on the initial **SEED** value set in the **PRNG.v** file. After each random number generation, the state vectors will be updated to ensure that the next number generated will be different from the previous one. If you want to see this, you can modify the **SEED** value in the module or trigger a re_start signal in the testbench.

### Convolution Tranpose module
```sh
cd ./rtl/tb_conv_tranpose
make run
```
To change the input size parameters, please follow the instructions as provided in the Convolution IP.
If the simulation is successful, the screen will display as follows: 
```sh
 \\\\\\\\\\\\\
 Compute channel    1
 \\\\\\\\\\\\\
 Compute channel    2
 \\\\\\\\\\\\\
 End filter    1
 \\\\\\\\\\\\\
 Compute channel    1
 \\\\\\\\\\\\\
 Compute channel    2
 \\\\\\\\\\\\\
 End filter    2
 END CONVOLUTION TRANPOSE
██████╗  █████╗ ███████╗███████╗    ████████╗███████╗███████╗████████╗                                                                               
██╔══██╗██╔══██╗██╔════╝██╔════╝    ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝                                                                               
██████╔╝███████║███████╗███████╗       ██║   █████╗  ███████    ██║
██║     ██║  ██║╚════██║╚════██║       ██║   ██║          ██║   ██║  
██║     ██║  ██║███████║███████║       ██║   ███████╗███████╗   ██║                                          
╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝       ╚═╝   ╚══════╝╚══════╝   ╚═╝
```

