# DLX Pipelined Datapath — VHDL Implementation

This repository contains an implementation of a pipelined DLX-style processor datapath described in VHDL, including the control logic and mechanisms required to handle pipeline hazards.

---

## Project overview

* Implementation targets a classic five-stage pipeline: **IF (Instruction Fetch)**, **ID (Instruction Decode / Register Read)**, **EX (Execute / ALU)**, **MEM (Memory access)**, and **WB (Write-back)**.
* Key features include:

  * Register file, ALU, and pipeline registers between stages.
  * Control unit that generates control signals for each pipeline stage.
  * Hazard detection unit to resolve data hazards.
  * BTB to optimize branches.

---

### Architecture diagram


![DLX architecture](./DLX_vhd\report\images\dlx.png)

