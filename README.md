# I2C Multi-Device System – Project Summary

This project implements a compact but complete I²C communication system in Verilog, including:

- **I2C Master**
- **Two I2C Slaves**
- **Translator Module** (modifies SDA with a bit-mask)
- **Clock Divider**
- **Top-Level Integration Module**
- **Testbench**

---

## 📌 Project Overview

### **1. i2c_master.v**
Implements the I²C master:
- Generates START/STOP
- Sends 7-bit address + R/W
- Transmits or receives data
- Handles ACK/NACK
- Uses internal clock enable from `clk_divider`

---

### **2. i2c_slave.v**
Implements a basic I²C slave device:
- Detects START and STOP
- Receives address and matches it
- Reads or writes data depending on the R/W bit
- Sends ACK
- Drives SDA using tri-state logic

---

### **3. fpga_translator.v**
Routes SDA and SCL signals to two slaves:
- SCL forwarded directly
- SDA forwarded differently:
  - Slave 1 receives SDA normally
  - Slave 2 receives SDA XOR mask (bit-masked bus)
- Selects slave based on received address

Useful for:
- Address manipulation
- Multi-slave bus simulations
- Debugging complex I²C systems

---

### **4. clk_divider.v**
Generates slow clock pulses for the master:
- Parameterizable width
- Adjustable max count
- Generates `tick` signal every N cycles

---

### **5. i2c_top.v**
Top-level integration module:
- Connects master → translator → slaves
- Exposes SDA/SCL externally
- Manages translated bus signals

---

### **6. i2c_top_tb.v**
Verification testbench:
- Generates 400 KHz clock
- Applies reset
- Performs:
  - Read cycle
  - Write cycle
- Dumps a `.vcd` waveform file for GTKWave
- Prints state changes inside the master FSM

---

## 🧪 Test Flow Summary

1. Apply reset  
2. Enable master  
3. Send address = 49  
4. Perform **read**  
5. Perform **write**  
6. Translator applies SDA bit-mask for Slave 2  
7. Observe SDA/SCL transitions in waveform  
8. Confirm ACK, data flow, and state transitions  

---

## 📂 Files Included

| File | Description |
|------|-------------|
| `i2c_master.v`      | Master controller |
| `i2c_slave.v`       | Basic I²C slave |
| `fpga_translator.v` | Manipulates SDA routing |
| `clk_divider.v`     | Clock divider |
| `i2c_top.v`         | System integration |
| `i2c_top_tb.v`      | Testbench |
| `README.md`         | Documentation |

---

## 🚀 Running Simulation

### **EDA Playground**
  https://edaplayground.com/x/tDYi

Example using **Icarus Verilog**:

```sh
iverilog -o sim.out *.v
vvp sim.out
gtkwave i2c_top_tb.vcd

