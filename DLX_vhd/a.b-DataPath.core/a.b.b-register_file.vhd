library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use WORK.all;

entity register_file is
	generic (
		DATA_WIDTH : integer := 32;
		ADDR_WIDTH : integer := 5
	);
 	port ( CLK: 		IN std_logic;
        RESET: 	IN std_logic;
	 	ENABLE: 	IN std_logic;
	 	RD1: 		IN std_logic;
	 	RD2: 		IN std_logic;
	 	WR: 		IN std_logic;
	 	ADD_WR: 	IN std_logic_vector(ADDR_WIDTH - 1 downto 0);
	 	ADD_RD1: 	IN std_logic_vector(ADDR_WIDTH - 1 downto 0);
	 	ADD_RD2: 	IN std_logic_vector(ADDR_WIDTH - 1 downto 0);
	 	DATAIN: 	IN std_logic_vector(DATA_WIDTH - 1 downto 0);
        OUT1: 		OUT std_logic_vector(DATA_WIDTH - 1 downto 0);
	 	OUT2: 		OUT std_logic_vector(DATA_WIDTH - 1 downto 0));
end register_file;

architecture Behavioral of register_file is

	constant NUM_REGS : integer := 2 ** ADDR_WIDTH;
    subtype REG_ADDR is natural range 0 to NUM_REGS - 1; -- using natural type
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(DATA_WIDTH - 1 downto 0); 
	signal REGISTERS : REG_ARRAY := (others => (others => '0')); 

	
begin 
	process(CLK)
	begin
		if rising_edge(CLK) and ENABLE='1' then
		if RD1 = '1' then
			if ADD_RD1 = 0 then
				OUT1 <= (others => '0');
			else
				OUT1 <= REGISTERS(conv_integer(ADD_RD1));
			end if;
		else
			OUT1 <= (others => 'Z');
		end if;

		if RD2 = '1' then
			if ADD_RD2 = 0 then
				OUT2 <= (others => '0');
			else
				OUT2 <= REGISTERS(conv_integer(ADD_RD2));
			end if;
		else
			OUT2 <= (others => 'Z');
		end if;
		end if;
	end process;


	process(CLK)
	begin
		if rising_edge(CLK) then
			if RESET = '1' then
				REGISTERS <= (others => (others => '0'));
			elsif ENABLE = '1' and WR = '1' then
				if ADD_WR /= (ADDR_WIDTH - 1 downto 0 => '0') then
					REGISTERS(conv_integer(ADD_WR)) <= DATAIN;
				end if;
			end if;
		end if;
	end process;

end Behavioral;