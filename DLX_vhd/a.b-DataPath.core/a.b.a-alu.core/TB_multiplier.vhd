library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_multiplier is
end entity tb_multiplier;

architecture tb of tb_multiplier is
    constant NBIT : integer := 16;
    constant H : integer := NBIT/2; 
    constant PIPE_LATENCY : integer := NBIT/4-1;
    constant MIN_VAL : integer := - (2**(H-1)); 
    constant MAX_VAL : integer :=   2**(H-1) - 1; 

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal A_sig : std_logic_vector(H-1 downto 0) := (others => '0');
    signal B_sig : std_logic_vector(H-1 downto 0) := (others => '0');
    signal P_sig : std_logic_vector(NBIT-1 downto 0);

begin

    uut: entity work.multiplier
        generic map (NBIT => NBIT)
        port map (
            CLK => clk,
            rst => rst,
            A => A_sig,
            B => B_sig,
            P => P_sig
        );

    clk_proc: process
    begin
        while true loop
            clk <= '0'; wait for 5 ns;
            clk <= '1'; wait for 5 ns;
        end loop;
    end process clk_proc;

    stim_proc: process
        constant DEPTH : integer := PIPE_LATENCY + 4;
        type buf_t is array (0 to DEPTH-1) of signed(NBIT-1 downto 0);
        variable buf : buf_t := (others => (others => '0'));

        variable write_ptr : integer := 0;
        variable read_ptr  : integer := 0;
        variable cycles_sent : integer := 0; 
        variable ia, ib : integer;
        variable expected_v : signed(NBIT-1 downto 0);
        variable got_v      : signed(NBIT-1 downto 0);
        variable pass_count : integer := 0;
        variable fail_count : integer := 0;
        variable i : integer;
    begin
        rst <= '1';
        A_sig <= (others => '0');
        B_sig <= (others => '0');
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;

        for ia in MIN_VAL to MAX_VAL loop
            for ib in MIN_VAL to MAX_VAL loop

                expected_v := resize( to_signed(ia, H) * to_signed(ib, H), NBIT );
                A_sig <= std_logic_vector( to_signed(ia, H) );
                B_sig <= std_logic_vector( to_signed(ib, H) );

                wait until rising_edge(clk);

                buf(write_ptr) := expected_v;
                write_ptr := (write_ptr + 1) mod DEPTH;
                cycles_sent := cycles_sent + 1;

                if cycles_sent > PIPE_LATENCY then
                    got_v := signed(P_sig); 
                    if buf(read_ptr) /= got_v then
                        fail_count := fail_count + 1;
                        report "Mismatch: sent A=" & integer'image(ia - ((ib - MIN_VAL) mod (MAX_VAL-MIN_VAL+1)))
                            & " expected=" & integer'image(to_integer(buf(read_ptr)))
                            & " got=" & integer'image(to_integer(got_v))
                            severity error;
                    else
                        pass_count := pass_count + 1;
                    end if;
                    read_ptr := (read_ptr + 1) mod DEPTH;
                end if;
            end loop;
        end loop;
        for i in 1 to PIPE_LATENCY loop
            wait until rising_edge(clk);
            got_v := signed(P_sig);
            if buf(read_ptr) /= got_v then
                fail_count := fail_count + 1;
                report "Flush-Mismatch: expected=" & integer'image(to_integer(buf(read_ptr)))
                    & " got=" & integer'image(to_integer(got_v)) severity error;
            else
                pass_count := pass_count + 1;
            end if;
            read_ptr := (read_ptr + 1) mod DEPTH;
        end loop;

        report "TEST COMPLETE. Passed=" & integer'image(pass_count) & " Failed=" & integer'image(fail_count) severity note;
        if fail_count = 0 then
            report "ALL PIPELINED TESTS PASSED" severity note;
        else
            report "SOME PIPELINED TESTS FAILED" severity failure;
        end if;
        wait;
    end process stim_proc;

end architecture tb;
