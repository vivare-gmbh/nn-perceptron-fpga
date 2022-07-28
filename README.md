# nn-perceptron-fpga
Neural Net Perceptron for Pattern Recognition  on FPGA

## Features

- Perceptron type Neural Net for pattern recognition
- Bipolar s:t input data for training - Readout signed data for data sets and
results after testing of pattern
- Read from and write to any memory space (s, t, w matrix, bias and y)
- Built-in training module with user configurable Max Epochs Counter
- Threshold and Bias register for fine tuning of training
- Signed data types on the Wishbone data bus without masking

- Full synthesizable VHDL core for FPGA with on-chip memory
- Wishbone compatible (V.B4)
- User specific pre-configurable on-chip memory configuration
- On-the-fly memory windowing within pre-configured memory space
- No multiplications or DSP blocks - Only Add and Sub functions are used
- Auto-adjusting memory Wait State generator for Reading and Writing
- Enable/Disable Hardware Interrupt

## **QUALITY**:
- All VHDL modules were verified by executing the sample application
described in specification "Appendix B". All numerical results were
compared against results of a test bench written in C.

## **History**:  
- Specification Revision 1.1 22-July-2022 

 (Threshold value for Sample Project corrected from 0x25 to 0x20.
  Documented results of training and testing also corrected. Simulation scripts
  also corrected for new test bench version v05)

- IP Core Revision 3.0 21-July-2022  
- Specification Revision 1.0 20-July-2022  
