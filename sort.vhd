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


            if chains(4).peak > chains(1).peak then
                if chains(4).peak > chains(0).peak then
                    -- 0番目
                    chains(1 to 3) := chains(0 to 2);
                    chains(0) := chains(4);
                else
                    -- 1番目
                    chains(2 to 3) := chains(1 to 2);
                    chains(1) := chains(4);
                end if;
            else
                if chains(4).peak > chains(2).peak then
                    -- 2番目
                    chains(3) := chains(2);
                    chains(2) := chains(4);
                else
                    if chains(4).peak > chains(3).peak then
                        -- 3番目
                        chains(3) := chains(4);
                    end if;
                end if;
            end if;


            if chains(5).peak > chains(1).peak then
                if chains(5).peak > chains(0).peak then
                    -- 0番目
                    chains(1 to 3) := chains(0 to 2);
                    chains(0) := chains(5);
                else
                    -- 1番目
                    chains(2 to 3) := chains(1 to 2);
                    chains(1) := chains(5);
                end if;
            else
                if chains(5).peak > chains(2).peak then
                    -- 2番目
                    chains(3) := chains(2);
                    chains(2) := chains(5);
                else
                    if chains(5).peak > chains(3).peak then
                        -- 3番目
                        chains(3) := chains(5);
                    end if;
                end if;
            end if;


            for i in 0 to 3 loop
                top4_reg(i) <= chains(i);
            end loop;
        end if;
    end process;


END sort_architecture;
