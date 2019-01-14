library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.types.all;

--  Entity Declaration

ENTITY count_clk IS
PORT
(
    clk : IN STD_LOGIC := '0';
    all_done : IN STD_LOGIC := '0';
    clk_count : OUT std_logic_vector(31 downto 0) := (others => '0')
);

END count_clk;



--  Architecture Body

ARCHITECTURE count_clk_architecture OF count_clk IS
    signal clk_count_reg : std_logic_vector(31 downto 0) := (others => '0');

BEGIN
    clk_count <= clk_count_reg;

    process(clk, all_done)
    begin
        if rising_edge(clk) and all_done = '0' then
            clk_count_reg <= clk_count_reg + 1;
        end if;
    end process;

END count_clk_architecture;
