library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use work.types.all;

--  Entity Declaration

ENTITY sort IS
PORT
(
    clk   : in  std_logic := '0';
    sort_data_a : IN chain_t := ((others => '0'), (others => '0'), (others => '0'));
    sort_data_b : IN chain_t := ((others => '0'), (others => '0'), (others => '0'));
    top4 : OUT chains4_t := (others => ((others => '0'), (others => '0'), (others => '0')))
);

END sort;


--  Architecture Body

ARCHITECTURE sort_architecture OF sort IS
    signal top4_reg : chains4_t := (others => ((others => '0'), (others => '0'), (others => '0')));

BEGIN
    top4 <= top4_reg;

    process(clk)

        variable chains : chains6_t := (others => ((others => '0'), (others => '0'), (others => '0')));

    begin
        if rising_edge(clk) then
            for i in 0 to 3 loop
                chains(i) := top4_reg(i);
            end loop;
            chains(4) := sort_data_a;
            chains(5) := sort_data_b;

            -- peakが同じものがあれば、lenの長さを考えて更新
            for i in 0 to 3 loop
                for j in 4 to 5 loop
                    if chains(i).peak = chains(j).peak then
                        if chains(i).len < chains(j).len then
                            chains(i).root := chains(j).root;
                            chains(i).len := chains(j).len;
                        end if;
                        chains(j).root := (1=>'1', others => '0');
                        chains(j).len := (others => '0');
                        chains(j).peak := (others => '0');
                    end if;
                end loop;
            end loop;

            -- bubble sort
            for flag in 0 to 4 loop
                for i in (5-flag) downto 1 loop
                    if chains(i-1).peak < chains(i).peak then
                        -- xor swap
                        chains(i).root   := chains(i-1).root xor chains(i).root;
                        chains(i-1).root := chains(i-1).root xor chains(i).root;
                        chains(i).root   := chains(i-1).root xor chains(i).root;

                        chains(i).peak   := chains(i-1).peak xor chains(i).peak;
                        chains(i-1).peak := chains(i-1).peak xor chains(i).peak;
                        chains(i).peak   := chains(i-1).peak xor chains(i).peak;

                        chains(i).len   := chains(i-1).len xor chains(i).len;
                        chains(i-1).len := chains(i-1).len xor chains(i).len;
                        chains(i).len   := chains(i-1).len xor chains(i).len;
                    end if;
                end loop;
            end loop;

            for i in 0 to 3 loop
                top4_reg(i) <= chains(i);
            end loop;
        end if;
    end process;


END sort_architecture;
