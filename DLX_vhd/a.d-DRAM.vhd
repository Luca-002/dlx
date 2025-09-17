library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DRAM is
    generic (
        ADDR_WIDTH : integer := 8;  
        DATA_WIDTH : integer := 32 
    );
    port (
        clk        : in  std_logic;                           
        reset      : in  std_logic; 
        BYTE             : in std_logic;                               
        we         : in  std_logic;                               
        addr       : in  std_logic_vector(ADDR_WIDTH-1 downto 0);    
        data_in : in  std_logic_vector(DATA_WIDTH-1 downto 0);       
        data_out  : out std_logic_vector(DATA_WIDTH-1 downto 0)      
    );
end entity DRAM;

architecture Behavioral of DRAM is
    type mem_type is array (0 to (2**ADDR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mem : mem_type := (others => (others => '0'));
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                mem <= (others => (others => '0'));
                data_out <= (others => '0');
            else
                if we = '1' then
                    if BYTE = '1' then
                        mem(to_integer(unsigned(addr)))(7 downto 0) <= data_in(7 downto 0);
                    else
                        mem(to_integer(unsigned(addr))) <= data_in; 
                    end if;
                end if;
                data_out <= mem(to_integer(unsigned(addr)));
            end if;
        end if;
    end process;
end architecture Behavioral;