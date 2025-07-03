library ieee;
use ieee.std_logic_1164.all;

package myTypes is

	type aluOp is (
		NOP, ALU_AND, ALU_NAND, ALU_OR, ALU_NOR, ALU_XOR, ALU_XNOR, ALU_ADD, ALU_SUB, MUL, LLS, LRS, ALS, ARS, RR, RL
			);

end myTypes;

