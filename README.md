**5-Stage Pipelined MIPS Processor in Verilog**  
Computer Architecture Lab – Computer Assignment 4 (CA4)  
   
 Processor: **FUM-MIPS** (32-bit MIPS-style CPU, built on the single-cycle design from CA3)  
   
 Authors: Asiye Bahrami, Ghazal Bangash  
**Background: the CA3 single-cycle processor**  
CA3 asked for a single-cycle **FUM-MIPS** processor in Verilog. FUM-MIPS is a 32-bit processor with a register file of 32 × 32-bit registers and an ISA that follows MIPS. The CA3 handout supplied four building blocks (ALU, register file, instruction memory, data memory), and the work was to:  
1. Study and verify those four modules. The ALU had to be extended with SLT and with the lt / gt outputs (set when data1 > data2 and data1 < data2). Data memory is at most 128 × 32-bit words, and instruction memory is at most 256 × 32-bit words.  
2. Add the control unit, PC and the remaining modules to complete the processor, and write a testbench showing that every instruction in the table below works.  
3. Write a program that finds the largest value, the smallest value and the average of a 10-element array of 32-bit values, and run it on the processor.  
Instructions required in CA3 (and kept in CA4):  
| | | |  
|-|-|-|  
| **R-type** | **I-type** | **J-type** |   
| add, sub, and, or, slt | lw, sw, addi, slti, andi, ori, beq, bne | j |   
   
In the single-cycle design, every instruction passes through fetch, decode, execute, memory and write-back within one clock cycle. The PC feeds the instruction memory, and a PC + 1 adder, a branch-target adder and a jump-address path feed two muxes that choose the next PC.  
**Overview**  
This project converts that single-cycle processor into a **classic 5-stage pipelined processor**, modeled in Verilog. The ISA, the ALU, the register file, the memories and the control unit are the same as in CA3. The change is that the datapath is cut into stages by pipeline registers.  
The project can be done by one or two people. The level that is submitted decides the grade: Level 1 is mandatory, and Levels 2 and 3 give extra marks (see below). The datapath is split into the usual stages:  
| | | |  
|-|-|-|  
| **Stage** | **Name** | **Work done** |   
| IF | Instruction Fetch | Read instruction memory at PC, compute PC + 1 |   
| ID | Instruction Decode | Control decoding, register-file read, sign extension |   
| EX | Execute | ALU operation, branch-target adder |   
| MEM | Memory Access | Data-memory read/write |   
| WB | Write Back | Select ALU result or loaded data, write to register file |   
   
The assignment defines three levels. Each level is a separate, self-contained source file:  
| | | | |  
|-|-|-|-|  
| **Level** | **File** | **Status** | **Description** |   
| 1 (mandatory) | project-1.v | Implemented | Ideal 5-stage pipeline. No hazard handling. Correct only for programs with no branches and no data dependencies. |   
| 2 (optional, +0.6) | project-2.v | Implemented | Level 1 plus **data-hazard handling by stalling** (hazard detection unit). Programs with data dependencies but no branches. |   
| 3 (optional, +1.2) | project-3.v | Implemented (see [Known limitations)](#anchor-1 "#anchor-1") | Level 2 plus **control-hazard handling**: branches and jumps resolved early in ID, with an IF/ID flush. |   
   
Each file is complete on its own. A higher level is the lower level plus the additions described below.  
**Supported instructions**  
| | |  
|-|-|  
| **Type** | **Instructions** |   
| R-type | ADD, SUB, AND, OR, SLT (selected by funct; any other funct falls back to ADD) |   
| I-type | ADDI, SLTI, ANDI, ORI, LW, SW, BEQ, BNE |   
| J-type | J |   
   
The ALU also implements XOR, but the control unit does not currently decode it.  
**Architecture**  
**Modules**  
| | |  
|-|-|  
| **Module** | **Role** |   
| ALU | 32-bit ALU (ADD, SUB, AND, OR, XOR, SLT) with zero, lt, gt flags |   
| RegFile | 32 × 32-bit register file, two read ports, one write port; registers initialized to regfile[i] = i |   
| IMemBank | 256-word instruction memory, holds the test program |   
| DMemBank | 128-word data memory, initialized to mem[i] = i |   
| Control | Main control unit (decodes opcode / funct) |   
| MUX32, MUX5 | 32-bit and 6-bit 2-to-1 multiplexers (MUX5 carries the 5-bit register index) |   
| SE, SE1, SL2 | Sign extenders (16-bit, 26-bit) and shift-left-2 |   
| Adder | PC increment and branch-target adder |   
| checkStall | *(Levels 2, 3)* Hazard detection unit |   
| Equal | *(Level 3)* Register comparator used to resolve branches in ID |   
| single | Top-level module: pipeline registers, stage wiring, clock generator |   
   
**Pipeline registers**  
All pipeline registers are updated on the rising clock edge in the top module single:  
- **IF/ID**: FDNPC, FDinstr  
- **ID/EX**: control signals (DEmemRead, DEmemWrite, DEmemToReg, DEregWrite, DEALUSrc, DEALUOp, …), operands DEA, DEB, DEimm, destination register DEwriteRegister  
- **EX/MEM**: EMALUOut, EMB, EMwriteRegister, memory/write-back control, EMzero  
- **MEM/WB**: MWreadData, MWALUOut, MWwriteRegister, MWregWrite, MWmemToReg  
The full instruction word is also carried through every stage (FDinstr → DEinstr → EMinstr → MWinstr). This is used by the hazard detection unit and is useful for waveform debugging.  
**Memory and clock**  
- The PC is 8 bits wide and word-addressed (it increments by 1). Execution starts at address 1.  
- The clock toggles every 1000 time units (period = 2000).  
**Level 1: ideal pipeline**  
A straightforward five-stage pipeline with no hazard logic. The branch decision is made in the MEM stage (EMzero & EMbranch selects the branch target EMNPC), and the branch target is computed in EX (DENPC + DEimm).  
Because no hazards are handled, it only gives correct results for instruction sequences that have **no data dependencies and no branches/jumps**.  
**Level 2: data hazards by stalling**  
Level 2 adds the checkStall hazard detection unit. It compares the source registers (rs, rt) of the instruction in ID with the destination register of the instructions in the **ID/EX, EX/MEM and MEM/WB** stages. If there is a match (RAW hazard), stallBit is raised, and:  
- PC and the IF/ID register are **frozen**, so the dependent instruction is held in ID.  
- A **bubble** (all-zero NOP, with write and memory controls cleared) is inserted into ID/EX.  
The pipeline resumes once the producing instruction has left WB and its result is in the register file. This implements stalling only; there is no forwarding.  
**Level 3: control hazards**  
Level 3 builds on Level 2 and resolves control flow early to cut the branch penalty:  
- **Branch resolution in ID.** The Equal comparator checks the two register values read in ID. The branch target is computed in ID by adding FDNPC and the offset field (FDinstr[7:0]). The PC mux selects the target directly (zero & branch).  
- **Jump handling.** A jump signal from the control unit redirects the PC through a second mux (tmp1PC).  
- **Flush.** When a branch is taken or a jump is executed, the IF/ID register is cleared (FDinstr = 0, FDNPC = 0), so the wrongly fetched instruction becomes a NOP.  
- **Branch data hazards.** Since branches now read their operands in ID, checkStall also treats BEQ/BNE as readers of rs and rt.  
**How to run**  
1. Open the desired level (project-1.v, project-2.v or project-3.v) in ModelSim/Questa (or any Verilog simulator).  
2. Compile the file and simulate the top module **single**. It contains its own clock generator, so no separate testbench is needed.  
3. Add the pipeline registers (FDinstr, DEinstr, EMinstr, MWinstr), PC, stallBit and regFile.regfile to the waveform window.  
4. Run for a few clock periods (one period = 2000 time units).  
To test a different program, edit the initial block in IMemBank. Instructions are placed starting at mem_array[1], and a few earlier test programs are kept there as comments.  
***Simulator note:*** * * *ALU* * uses the literal * *0'b0* * in the SLT case. ModelSim accepts it, but stricter tools (e.g. Icarus Verilog) reject it. Change it to * *1'b0* * if needed.*  
**Test programs and results**  
Registers are initialized to their own index ($r5 = 5, and so on).  
**Levels 1 and 2** run a short program with a read-after-write dependency:  
mem[1]:  r3 = r5 + r2      // 5 + 2 = 7  
 mem[2]:  r5 = r3 + r4      // depends on r3 from the previous instruction  
   
| | | | |  
|-|-|-|-|  
| **Level** | **Final ** **r3** | **Final ** **r5** | **Explanation** |   
| 1 | 7 | 7 | Hazard not handled: the second instruction read the old r3 (3), so r5 = 3 + 4 = 7. This shows why hazard handling is needed. |   
| 2 | 7 | **11** | The dependent instruction is stalled until r3 is written back, so r5 = 7 + 4 = 11. Correct. |   
   
**Level 3** runs the same two instructions followed by a J instruction, to exercise the jump path and the IF/ID flush.  
**CA3 array program (max / min search).** The CA3 program is kept as a comment block in IMemBank. It loops over the 10 words at data-memory address 100, with the base address in r4. In CA3 the register file was initialized with r4 = 100 and data memory with mem[i] = i * 10 for i = 100…109. The CA4 files initialize regfile[i] = i and mem[i] = i instead, so restore the CA3 initial values before running this program. It uses slti, beq, lw, slt and j, and keeps the running maximum in r5 and the running minimum in r6. It is a good full-program test for Level 3, because it needs both data-hazard and control-hazard handling. The single-cycle version of this program does not compute the average; if the average is part of your deliverable, add a sum and a divide-by-10 step.  
**Known limitations**  
These are issues found while simulating the three files. They are listed here so they can be fixed or taken into account when grading.  
1. **Hazard detection for I-type instructions (Levels 2 and 3).** In checkStall, several checks compare the whole 32-bit instruction word against a 6-bit opcode (for example FDinstr == 6'b100011) instead of FDinstr[31:26]. Those comparisons are never true, so RAW hazards involving LW, ADDI, SLTI, ANDI, ORI (as producers) and BEQ/BNE (as consumers) are not detected. R-type producers and consumers and SW are handled correctly.  
2. **Jump target (Level 3).** The jump target is taken from instr[7:0] (the instruction currently being fetched) rather than from the jump instruction in ID (FDinstr). In simulation, J 5 at address 3 sends the PC to 0 instead of 5. Using FDinstr[7:0] for the jump target should fix this.  
3. **Branch condition (Level 3).** The Equal module drives zero high when the operands are *different*, so a branch is taken when rs != rt. This matches BNE but not BEQ. The control unit also treats BEQ and BNE identically.  
4. **No forwarding.** Data hazards are resolved only by stalling, which is permitted by the assignment.  
5. **BNE** ** in the control unit.**BEQ and BNE produce identical control signals (same ALU SUB, branch = 1). The branch is taken when the ALU zero flag is set, so BNE is not distinguished from BEQ in Levels 1 and 2 (and in the CA3 single-cycle design). Separating them needs a BNE flag in the control unit and a condition check on zero.  
6. The ALU's lt/gt flags are not assigned when the operands are equal, and they are unused by the datapath.  
**Repository layout**  
.  
 ├── single.v       # CA3: single-cycle FUM-MIPS (starting point)  
 ├── project-1.v    # Level 1: ideal 5-stage pipeline  
 ├── project-2.v    # Level 2: + data-hazard stalling  
 ├── project-3.v    # Level 3: + control-hazard handling  
 └── README.md  
   
