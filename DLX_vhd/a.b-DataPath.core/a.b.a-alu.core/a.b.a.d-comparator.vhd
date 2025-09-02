library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparator is
    generic(
        DATA_WIDTH: integer := 32
    );
    port(
        cout : in  std_logic;   
        A : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        B : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        sum : in  std_logic_vector(DATA_WIDTH-1 downto 0); 
        A_gt_or_eq_B: out std_logic;  
        A_gt_B : out std_logic;  
        A_lt_or_eq_B: out std_logic;  
        A_lt_B: out std_logic;  
        A_eq_B: out std_logic;  
        A_ge_u: out std_logic;  
        A_gt_u: out std_logic;  
        A_le_u: out std_logic;  
        A_lt_u: out std_logic   
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

    signal zero_flag: std_logic; 
    signal A_s, B_s, R_s: std_logic; 
    signal overflow: std_logic; 
    signal signed_less: std_logic; 
begin
    zero_flag <= not(or_reduce(sum));
    A_s <= A(DATA_WIDTH-1);
    B_s <= B(DATA_WIDTH-1);
    R_s <= sum(DATA_WIDTH-1);
    overflow <= (A_s xor B_s) and (R_s xor A_s);
    signed_less <= R_s xor overflow;

    A_lt_B       <= signed_less;
    A_lt_or_eq_B <= signed_less or zero_flag;
    A_gt_or_eq_B <= not signed_less;
    A_gt_B       <= not (signed_less or zero_flag);
    A_eq_B       <= zero_flag;

    A_ge_u <= cout;
    A_gt_u <= cout and (not zero_flag);
    A_le_u <= (not cout) or zero_flag;
    A_lt_u <= not cout;
end struct;
