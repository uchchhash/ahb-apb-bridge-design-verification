# AHB-APB Bridge: RTL Design and UVM-Based Verification

This project implements a **functional AHB-to-APB bridge** design and its **UVM-based testbench** for simulation and verification purposes. The bridge includes asynchronous FIFO buffers and dual-clock domain handling. Note that this project focuses on **functional correctness only** — synthesis, timing closure, and FPGA implementation were **not within the scope**.

---

## 📌 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Design Architecture](#design-architecture)
- [RTL Modules](#rtl-modules)
- [Verification Environment](#verification-environment)
- [How to Run Simulation](#how-to-run-simulation)
- [Test Plan](#test-plan)
- [Directory Structure](#directory-structure)
- [Future Work](#future-work)
- [License](#license)
- [Acknowledgments](#acknowledgments)

---

## 📖 Overview

The **AHB-APB Bridge** serves as a protocol converter in a system-on-chip (SoC), enabling communication between:
- **AHB (Advanced High-Performance Bus)** – high-speed master interfaces
- **APB (Advanced Peripheral Bus)** – low-speed peripheral interfaces

This project simulates asynchronous interaction between AHB and APB using **FIFO-based clock domain crossing (CDC)**. The RTL is written for functional simulation purposes and is **not constrained for synthesis**.

---

## 🚀 Key Features

- ✅ Functional RTL design of AHB-APB bridge
- ✅ Dual-clock asynchronous FIFO implementation
- ✅ Clock domain crossing with two-stage synchronizers
- ✅ Modular UVM environment with drivers, monitors, sequences
- ✅ Fully reusable and layered testbench structure
- ✅ No synthesis/timing or hardware dependencies

---

## 🧩 Design Architecture

The bridge uses **three asynchronous FIFOs**:

| FIFO           | Write Clock | Read Clock | Purpose                                       |
|----------------|-------------|------------|-----------------------------------------------|
| Control FIFO   | AHB clk     | APB clk    | Buffers control signals from AHB to APB       |
| AHB Data FIFO  | AHB clk     | APB clk    | Buffers write data from AHB to APB            |
| APB Data FIFO  | APB clk     | AHB clk    | Buffers read data from APB to AHB             |

Each FIFO uses:
- Dual-port memory (simulation only)
- Write/read pointers
- Full/empty flags
- Two-stage pointer synchronization

---

## 🏗️ RTL Modules

| File                    | Description                          |
|-------------------------|--------------------------------------|
| `ahb_apb_bridge_top.sv` | Top module integrating FSMs and FIFOs |
| `ahb_fsm.v`             | AHB-side state machine controller    |
| `apb_fsm.sv`            | APB-side state machine controller    |
| `apb_slave.sv`          | Dummy APB slave model                |
| `fifo_top.sv`           | Asynchronous FIFO logic              |
| `define.sv`             | Parameters and macros                |

⚠️ These RTL files are intended for **simulation only** and are **not guaranteed to be synthesizable**.

---

## 🧪 Verification Environment (UVM)

- UVM-compliant testbench
- Layered architecture: agent, monitor, driver, sequencer, scoreboard
- Configurable tests via sequences and parameters
- Clock and reset control
- Waveform observation enabled

### Example Testcases:
| Test Case               | Description                             |
|------------------------|-----------------------------------------|
| `single_write_read`    | Basic functional check                  |
| `user_defined_pattern` | Customized write/read test pattern      |
| `reset_sequence`       | Verifies correct behavior on reset      |
| `ahb_write_sequence`   | Pushes burst writes into AHB FIFO       |
| `ahb_read_sequence`    | Validates APB read return through bridge|

---

## ▶️ How to Run Simulation

1. Enter the project directory:
   ```bash
   cd ahb-apb-bridge-design-verification


Launch simulation:

bash
Copy
Edit
./run.sh
Outputs:

transcript, vsim.wlf, waveform files (.svwf)

Coverage and result logs

🧪 Test Plan Summary
Feature Tested	Methodology
AHB to APB Write Path	Directed + Random Tests
APB to AHB Read Path	Directed + Random Tests
FIFO Status Flags	Assertion Checks
Clock Domain Crossing	Simulation via async FIFO
Reset Behavior	Base and corner tests

📁 Directory Structure
bash
Copy
Edit
ahb-apb-bridge-design-verification/
├── rtl/
│   ├── *.sv / *.v         # RTL modules
├── tb/
│   ├── interfaces/        # Interface definitions
│   ├── environment/       # env, config, scoreboard
│   ├── agents/            # AHB/APB agent components
│   ├── sequences/         # Transaction sequences
│   ├── tests/             # Testcases
│   └── tb_top.sv          # Top testbench
├── sim/
│   ├── run.sh             # Simulation script
│   ├── filelist.f         # File list for VCS/ModelSim
│   └── *.svwf, *.cmd      # Waveform configs
├── docs/
│   └── testplan.xlsx      # Optional test documentation
└── README.md
🔭 Future Work
Add SystemVerilog Assertions (SVA) for FIFO and protocol checks

Extend testbench with coverage collection

Integrate error injection and corner-case tests

(Optional) Redesign RTL for synthesis and FPGA prototyping

📜 License
This project is licensed under the MIT License.
Use and adapt it freely for academic or non-commercial purposes.

🙌 Acknowledgments
Developed as part of functional design and verification learning.
Inspired by standard AMBA AHB/APB protocol references and UVM methodology.
