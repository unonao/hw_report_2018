library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.types.all;

--  Entity Declaration

ENTITY control IS
PORT
(
    clk : IN STD_LOGIC := '0';
    addr_a : IN std_logic_vector(8 downto 0) := (others => '0');
    done_a : IN STD_LOGIC := '0';
    len_a : IN std_logic_vector(7 downto 0) := (others => '0');
    peak_a : IN std_logic_vector(17 downto 0) := (others => '0');
    addr_b : IN std_logic_vector(8 downto 0) := (others => '0');
    done_b : IN STD_LOGIC := '0';
    len_b : IN std_logic_vector(7 downto 0) := (others => '0');
    peak_b : IN std_logic_vector(17 downto 0) := (others => '0');
    pend_root_out_a : IN std_logic_vector(9 downto 0) := (others => '0');
    pend_root_out_b : IN std_logic_vector(9 downto 0) := (others => '0');
    pend_addr_out_a : IN std_logic_vector(8 downto 0) := (others => '0');
    pend_addr_out_b : IN std_logic_vector(8 downto 0) := (others => '0');
    pend_len_out_a : IN std_logic_vector(7 downto 0) := (others => '0');
    pend_len_out_b : IN std_logic_vector(7 downto 0) := (others => '0');
    pend_peak_out_a : IN std_logic_vector(17 downto 0) := (others => '0');
    pend_peak_out_b : IN std_logic_vector(17 downto 0) := (others => '0');
    pend_climb_go_a : IN STD_LOGIC := '0';
    pend_climb_go_b : IN STD_LOGIC := '0';
    pend_go_a : OUT STD_LOGIC := '0';
    pend_go_b : OUT STD_LOGIC := '0';
    pend_root_in : OUT std_logic_vector(9 downto 0) := (others => '0');
    pend_addr_in : OUT std_logic_vector(8 downto 0) := (others => '0');
    pend_len_in : OUT std_logic_vector(7 downto 0) := (others => '0');
    pend_peak_in : OUT std_logic_vector(17 downto 0) := (others => '0');
    pend_write_enable : OUT STD_LOGIC := '0';
    pend_start : OUT STD_LOGIC := '0';
    root_a : OUT std_logic_vector(9 downto 0) := (others => '0');
    root_b : OUT std_logic_vector(9 downto 0) := (others => '0');
    ram_addr_a : OUT std_logic_vector(8 downto 0) := (others => '0');
    ram_addr_b : OUT std_logic_vector(8 downto 0) := (others => '0');
    ram_data_in_a : OUT data_t := ((others => '0'), (others => '0'));
    ram_data_in_b : OUT data_t := ((others => '0'), (others => '0'));
    write_enable_a : OUT STD_LOGIC := '0';
    write_enable_b : OUT STD_LOGIC := '0';
    sort_data_a : OUT chain_t := ((others => '0'), (others => '0'), (others => '0'));
    sort_data_b : OUT chain_t := ((others => '0'), (others => '0'), (others => '0'));
    go_a : OUT STD_LOGIC := '0';
    go_b : OUT STD_LOGIC := '0'
);
END control;


--  Architecture Body

ARCHITECTURE control_architecture OF control IS

    signal done_a_reg : std_logic_vector(1 downto 0) := (others => '0');
    signal done_b_reg : std_logic_vector(1 downto 0) := (others => '0');
    signal done_a_temp : std_logic_vector(1 downto 0) := (others => '0');



    -- climbへ
    signal root_a_reg : std_logic_vector(8 downto 0) := (others => '0');
    signal root_b_reg : std_logic_vector(8 downto 0) := "111111111";

    -- ramへ
    signal write_enable_a_reg : std_logic := '0';
    signal write_enable_b_reg : std_logic := '0';
    -- sortへ
    signal sort_data_a_reg : chain_t := ((others => '0'), (others => '0'), (others => '0'));
    signal sort_data_b_reg : chain_t := ((others => '0'), (others => '0'), (others => '0'));
    -- pendingへ
    signal pend_start_reg : std_logic := '0';
    signal pend_go_a_reg : STD_LOGIC := '0';
    signal pend_go_b_reg : STD_LOGIC := '0';
    signal pend_root_in_reg : std_logic_vector(9 downto 0) := (others => '0');
    signal pend_addr_in_reg : std_logic_vector(8 downto 0) := (others => '0');
    signal pend_len_in_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal pend_peak_in_reg : std_logic_vector(17 downto 0) := (others => '0');
    signal pend_write_enable_reg : STD_LOGIC := '0';

    signal ram_addr_a_reg :  std_logic_vector(8 downto 0) := (others => '0');
    signal ram_addr_b_reg :  std_logic_vector(8 downto 0) := (others => '0');
BEGIN

    -- climbへ
    root_a   <= root_a_reg & '1' when pend_start_reg = '0' else pend_addr_out_a & '1';
    root_b   <= root_b_reg & '1' when pend_start_reg = '0' else pend_addr_out_b & '1';

    -- ramへ
    write_enable_a <= write_enable_a_reg;
    write_enable_b <= write_enable_b_reg;
    ram_data_in_a <= (peak_a, len_a);
    ram_data_in_b <= (peak_b, len_b);

    ram_addr_a_reg <= root_a_reg - 1 when write_enable_a_reg = '1' else addr_a;
    ram_addr_b_reg <= root_b_reg + 1 when write_enable_b_reg = '1' else addr_b;

    ram_addr_a <= ram_addr_a_reg;
    ram_addr_b <= ram_addr_b_reg;

    -- sortへ
    sort_data_a <= sort_data_a_reg;
    sort_data_b <= sort_data_b_reg;
    -- pendingへ
    pend_start <= pend_start_reg;
    pend_go_a <= pend_go_a_reg;
    pend_go_b <= pend_go_b_reg;
    pend_root_in <= pend_root_in_reg;
    pend_addr_in <= pend_addr_in_reg;
    pend_len_in <= pend_len_in_reg;
    pend_peak_in <= pend_peak_in_reg;
    pend_write_enable <= pend_write_enable_reg;



    -- tmp で循環構造を防ぐ
    done_a_reg(0) <= '0' when (ram_addr_a_reg = ram_addr_b_reg) and done_b_reg = "01" else done_a;
    done_b_reg(0) <= '0' when (ram_addr_a_reg = ram_addr_b_reg) and done_a_temp = "01" else done_b;
    process(clk)
    begin
     if rising_edge(clk) then
         done_a_temp <= done_a_reg;
     end if;
    end process;



    process(clk)
    -- sortへ
    variable sort_data_a_var : chain_t := ((others => '0'), (others => '0'), (others => '0'));
    variable sort_data_b_var : chain_t := ((others => '0'), (others => '0'), (others => '0'));
    variable peak_var_a : std_logic_vector(17 downto 0) := (others => '0');
    variable peak_var_b : std_logic_vector(17 downto 0) := (others => '0');
    variable len_var_a  : std_logic_vector(7 downto 0) := (others => '0');
    variable len_var_b  : std_logic_vector(7 downto 0) := (others => '0');
    variable go_a_reg   : std_logic := '1';
    variable go_b_reg   : std_logic := '1';

    begin


        if rising_edge(clk) and pend_start_reg = '0' then
            if done_a_reg = "01" then
                sort_data_a_var := (root_a_reg & '1', peak_a, len_a);
                write_enable_a_reg <= '1';
                root_a_reg <= root_a_reg + 1;
                go_a_reg := '1';
            else
                write_enable_a_reg <= '0';
                go_a_reg := '0';
            end if;

            if done_b_reg = "01" then
                sort_data_b_var := (root_b_reg & '1', peak_b, len_b);
                write_enable_b_reg <= '1';
                root_b_reg <= root_b_reg - 1;
                go_b_reg := '1';
            else
                write_enable_b_reg <= '0';
                go_b_reg := '0';
            end if;

            if root_a_reg > root_b_reg then
                pend_start_reg <= '1';
                pend_go_a_reg <= '1';
                pend_go_b_reg <= '1';

            end if;

            done_a_reg(1) <= done_a_reg(0);
            done_b_reg(1) <= done_b_reg(0);

        -- pending_listからデータを受け取って計算
        elsif rising_edge(clk) and pend_start_reg = '1' then
            if pend_climb_go_a = '1' then
                go_a <= '1';
            elsif done_a_reg = "01" then
                if peak_a < pend_peak_out_a then
                    peak_var_a := pend_peak_out_a;
                else
                    peak_var_a := peak_a;
                end if;
                len_var_a := pend_len_out_a + len_a;

                sort_data_a_var := (pend_root_out_a, peak_var_a, len_var_a);
                pend_go_a_reg <= '1';
            else
                pend_go_a_reg <= '0';
                go_a <= '0';
            end if;

            if pend_climb_go_b = '1' then
                go_b <= '1';
            elsif done_b_reg = "01" then
                if peak_b < pend_peak_out_b then
                    peak_var_b := pend_peak_out_b;
                else
                    peak_var_b := peak_b;
                end if;
                len_var_b := pend_len_out_b + len_b;

                sort_data_b_var := (pend_root_out_b, peak_var_b, len_var_b);
                pend_go_b_reg <= '1';
            else
                pend_go_b_reg <= '0';
                go_b <= '0';
            end if;
        end if;


        sort_data_a_reg <= sort_data_a_var;
        sort_data_b_reg <= sort_data_b_var;
        go_a <= go_a_reg;
        go_b <= go_b_reg;
    end process;



    -- pending listへの保存
    process(clk)

    begin
        if rising_edge(clk) then
            if pend_start_reg = '0' and (ram_addr_a_reg = ram_addr_b_reg) and ram_addr_a_reg /= 0 then
                if done_a_reg = "01" then
                    pend_root_in_reg <= root_b_reg & '1';
                    pend_addr_in_reg <= addr_b;
                    pend_len_in_reg <= len_b;
                    pend_peak_in_reg <= peak_b;
                    pend_write_enable_reg <= '1';
                elsif done_b_reg = "01" then
                    pend_root_in_reg <= root_a_reg & '1';
                    pend_addr_in_reg <= addr_a;
                    pend_len_in_reg <= len_a;
                    pend_peak_in_reg <= peak_a;
                    pend_write_enable_reg <= '1';
                end if;
            else
                pend_write_enable_reg <= '0';
            end if;
        end if;
    end process;


END control_architecture;
