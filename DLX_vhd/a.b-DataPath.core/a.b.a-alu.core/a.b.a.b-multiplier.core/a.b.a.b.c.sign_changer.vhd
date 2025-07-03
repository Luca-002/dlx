library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity SIGNCHANGER is 
	generic (N: INTEGER :=16);
	Port (	A:	In	std_logic_vector(N-1 downto 0);
		Y:	Out	std_logic_vector(N-1 downto 0));
end SIGNCHANGER; 

architecture STRUCTURAL of SIGNCHANGER is

  signal number : std_logic_vector(N-1 downto 0);
  signal number_negated : std_logic_vector(N-1 downto 0);
  signal flip_flag : std_logic_vector(N-1 downto 0);
  signal result : std_logic_vector(N-1 downto 0);

  component xor_gate 
	Port (	A:	In	std_logic;
          B: In std_logic;
		Y:	Out	std_logic);
  end component;

  component and_gate is
	Port (	A,B:	In	std_logic;
		Y:	Out	std_logic);
  end component;

  component IV is
	Port (	A:	In	std_logic;
		Y:	Out	std_logic);
  end component;


begin

  number <= A; 
  Y <= result;
  
  negators: for i in 0 to N-1 generate
    NG : IV  
	  Port Map (number(i),number_negated(i)); -- (1)inizialmente tutti i bit vengono negati
  end generate;


  flip_flag(0) <= '1'; 
  flip_flag(1) <= number_negated(0);

  first_zero_pos_encoder : and_gate 
  Port Map (number_negated(0),number_negated(1),flip_flag(2)); --(2)poi si trova la posizione del primo zero partendo dal lsb

  other_zero_pos_encoders: for i in 3 to N-1 generate 
    zero_pos_encoder : and_gate
    Port Map (flip_flag(i-1),number_negated(i-1),flip_flag(i)); 
  end generate;

  xors: for i in 0 to N-1 generate 
    xorgate : xor_gate 
    Port Map (flip_flag(i), number_negated(i), result(i)); --(3)e vengono negati tutti i bit dall'lsb fino alla posizione trovata
  end generate;  

end STRUCTURAL; --le operazioni (2) e (3) equaivalgono a sommare 1, avendo pero un riporto molto piu breve rispetto ad una catena di full adder o half adder.