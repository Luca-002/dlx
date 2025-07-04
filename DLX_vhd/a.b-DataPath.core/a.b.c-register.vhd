library IEEE;
use IEEE.std_logic_1164.all;

entity single_register is
    Generic(
        N : integer := 32  
    );
    Port (
        D     : in  std_logic_vector(N-1 downto 0); 
        CK    : in  std_logic;                       
        RESET : in  std_logic;                      
        EN    : in  std_logic;                      
        Q     : out std_logic_vector(N-1 downto 0)  
    );
end single_register;

architecture async of single_register is
begin
    PASYNCH: process(CK, RESET)
    begin
        if RESET = '1' then
            Q <= (others => '0');
        elsif rising_edge(CK) then
            if EN = '1' then
                Q <= D;
            end if;
        end if;
    end process PASYNCH;

end async;