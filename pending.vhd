library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use work.types.all;

--  Entity Declaration

ENTITY pending IS
PORT
(
    pend_root_in : IN std_logic_vector(9 downto 0) := (others => '0');
    pend_addr_in : IN std_logic_vector(8 downto 0) := (others => '0');
    pend_len_in : IN std_logic_vector(7 downto 0) := (others => '0');
    pend_peak_in : IN std_logic_vector(17 downto 0) := (others => '0');
    pend_write_enable : IN STD_LOGIC := '0';
    pend_start : IN STD_LOGIC := '0';
    pend_go_a : IN STD_LOGIC := '0';
    pend_go_b : IN STD_LOGIC := '0';
    clk : IN STD_LOGIC := '0';
    pend_root_out_a : OUT std_logic_vector(9 downto 0) := (others => '0');
    pend_root_out_b : OUT std_logic_vector(9 downto 0) := (others => '0');
    pend_addr_out_a : OUT std_logic_vector(8 downto 0) := (others => '0');
    pend_addr_out_b : OUT std_logic_vector(8 downto 0) := (others => '0');
    pend_len_out_b : OUT std_logic_vector(7 downto 0) := (others => '0');
    pend_len_out_a : OUT std_logic_vector(7 downto 0) := (others => '0');
    pend_peak_out_a : OUT std_logic_vector(17 downto 0) := (others => '0');
    pend_peak_out_b : OUT std_logic_vector(17 downto 0) := (others => '0');
    pend_climb_go_a : OUT STD_LOGIC := '0';
    pend_climb_go_b : OUT STD_LOGIC := '0';
    all_pend_done : OUT STD_LOGIC := '0'
);

END pending;


--  Architecture Body

ARCHITECTURE pending_architecture OF pending IS
    signal all_pend_done_reg : std_logic := '0';
    signal write_flag : std_logic_vector(3 downto 0) := (others => '0');
    signal pending_list : chain4_addr_t := (others => ((others => '0'), (others => '0'), (others => '0'), (others => '0')));

    signal pend_root_out_a_reg : std_logic_vector(9 downto 0) := (others => '0');
    signal pend_root_out_b_reg : std_logic_vector(9 downto 0) := (others => '0');
    signal pend_addr_out_a_reg : std_logic_vector(8 downto 0) := (others => '0');
    signal pend_addr_out_b_reg : std_logic_vector(8 downto 0) := (others => '0');
    signal pend_len_out_a_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal pend_len_out_b_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal pend_peak_out_a_reg : std_logic_vector(17 downto 0) := (others => '0');
    signal pend_peak_out_b_reg : std_logic_vector(17 downto 0) := (others => '0');
    signal pend_climb_go_a_reg : std_logic := '0';
    signal pend_climb_go_b_reg : std_logic := '0';

BEGIN

    all_pend_done <= all_pend_done_reg;
    pend_root_out_a <= pend_root_out_a_reg;
    pend_root_out_b <= pend_root_out_b_reg;
    pend_addr_out_a <= pend_addr_out_a_reg;
    pend_addr_out_b <= pend_addr_out_b_reg;
    pend_len_out_a <= pend_len_out_a_reg;
    pend_len_out_b <= pend_len_out_b_reg;
    pend_peak_out_b <= pend_peak_out_b_reg;
    pend_climb_go_a <= pend_climb_go_a_reg;
    pend_climb_go_b <= pend_climb_go_b_reg;

    -- 衝突時に書き込み
    process(clk)
    variable  write_done : std_logic := '0';

    begin
        if rising_edge(clk) then
            if pend_write_enable = '1' then
                write_done := '0';

                for I in 0 to 3 loop

                    if write_done = '1' then
                        exit;
                    end if;

                    -- pending_listに書き込みが無ければ保存
                    if pending_list(I).root = 0 then
                        pending_list(I).root <= pend_root_in;
                        pending_list(I).addr <= pend_addr_in;
                        pending_list(I).len <= pend_len_in;
                        pending_list(I).peak <= pend_peak_in;
                        write_flag(I) <= '1';
                        write_done := '1';
                    end if;

                end loop;
            end if;
        end if;
    end process;


    process(clk)
    variable write_flag_valid : std_logic_vector(3 downto 0) := (others => '0');

    begin
        if rising_edge(clk) then
            pend_climb_go_a_reg <= '0';
            pend_climb_go_b_reg <= '0';
            if pend_start = '1' then

                if pend_go_a = '1' then
                    for I in 0 to 3 loop
                        if write_flag(I) = '1' and write_flag_valid(I) ='0' then
                            pend_root_out_a_reg <= pending_list(I).root;
                            pend_addr_out_a_reg <= pending_list(I).addr;
                            pend_len_out_a_reg <= pending_list(I).len;
                            pend_peak_out_a_reg <= pending_list(I).peak;
                            pend_climb_go_a_reg <= '1';
                            write_flag_valid(I) := '1';
                            exit;
                        end if;
                    end loop;
                else
                    pend_climb_go_a_reg <= '0';
                end if;

                if pend_go_b = '1' then
                    for I in 0 to 3 loop
                        if write_flag(I) = '1' and write_flag_valid(I) ='0' then
                            pend_root_out_b_reg <= pending_list(I).root;
                            pend_addr_out_b_reg <= pending_list(I).addr;
                            pend_len_out_b_reg <= pending_list(I).len;
                            pend_peak_out_b_reg <= pending_list(I).peak;
                            pend_climb_go_b_reg <= '1';
                            write_flag_valid(I) := '1';
                            exit;
                        end if;
                    end loop;
                else
                    pend_climb_go_b_reg <= '0';
                end if;

                if write_flag = write_flag_valid then
                    all_pend_done_reg <= '1';
                end if;

            end if;
        end if;
    end process;


END pending_architecture;
