library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity comparator is
    generic(
        DATA_WIDTH: integer:=32
    );
    port(
        cout 					: in std_logic;		
		sum 					: in std_logic_vector(DATA_WIDTH-1 downto 0);
        A_gt_or_eq_B                : out std_logic;
        A_gt_B                : out std_logic;
        A_lt_or_eq_B                : out std_logic;
        A_lt_B                : out std_logic;
        A_eq_B                : out std_logic
    );
end comparator;

architecture struct of comparator is
    function or_reduce(v: std_logic_vector) return std_logic is
		variable res: std_logic := '0';
	  begin
		for i in v'range loop
		  res := res or v(i);
		end loop;
		return res;
	  end function;
    signal reduced_sum: STD_LOGIC;
    begin
        reduced_sum<=not(or_reduce(sum));
        A_gt_or_eq_B<=cout;
        A_gt_B<=cout and (not (reduced_sum));
        A_lt_or_eq_B<=(not(cout)) or reduced_sum;
        A_lt_B<=not(cout);
        A_eq_B<=reduced_sum;
end struct;