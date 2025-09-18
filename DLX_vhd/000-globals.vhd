library ieee;
use ieee.std_logic_1164.all;

package myTypes is
	subtype aluOp is std_logic_vector(4 downto 0);
	constant NOP     : aluOp := "00000"; --  0
	constant ALU_AND : aluOp := "00001"; --  1
	constant ALU_NAND: aluOp := "00010"; --  2
	constant ALU_OR  : aluOp := "00011"; --  3
	constant ALU_NOR : aluOp := "00100"; --  4
	constant ALU_XOR : aluOp := "00101"; --  5
	constant ALU_XNOR: aluOp := "00110"; --  6
	constant ALU_ADD : aluOp := "00111"; --  7
	constant ALU_SUB : aluOp := "01000"; --  8
	constant MULT    : aluOp := "01001"; --  9
	constant LLS     : aluOp := "01010"; -- 10  (logical shift left)
	constant LRS     : aluOp := "01011"; -- 11  (logical shift right)
	constant ALS     : aluOp := "01100"; -- 12  (arithmetic left shift)
	constant ARS     : aluOp := "01101"; -- 13  (arithmetic right shift)
	constant RR      : aluOp := "01110"; -- 14  (rotate right)
	constant RL      : aluOp := "01111"; -- 15  (rotate left)
	constant SGE     : aluOp := "10000"; -- 16  (signed >=)
	constant SLE     : aluOp := "10001"; -- 17  (signed <=)
	constant SNE     : aluOp := "10010"; -- 18  (signed !=)
	constant ADDU    : aluOp := "10011"; -- 19  (unsigned add)
	constant SUBU    : aluOp := "10100"; -- 20  (unsigned sub)
	constant SEQ     : aluOp := "10101"; -- 21  (==)
	constant SGEU    : aluOp := "10110"; -- 22  (unsigned >=)
	constant SGT     : aluOp := "10111"; -- 23  (signed >)
	constant SGTU    : aluOp := "11000"; -- 24  (unsigned >)
	constant SLT     : aluOp := "11001"; -- 25  (signed <)
	constant SLTU    : aluOp := "11010"; -- 26  (unsigned <)
	constant A       : aluOp := "11011"; -- 27  (pass A)
	constant B       : aluOp := "11100"; -- 28  (pass B)
end myTypes;

