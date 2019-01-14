library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use work.types.all;

--  Entity Declaration

ENTITY climb IS
PORT
(
    clk : IN STD_LOGIC := '0';
    data_a : IN data_t := ((others => '0'), (others => '0'));
    go_a : IN STD_LOGIC := '0';
    hit_a : IN STD_LOGIC := '0';
    root_a : IN std_logic_vector(9 downto 0) := (others => '0');
    addr_a : OUT std_logic_vector(8 downto 0) := (others => '0');
    done_a : OUT STD_LOGIC := '0';
    len_a : OUT std_logic_vector(7 downto 0) := (others => '0');
    peak_a : OUT std_logic_vector(17 downto 0) := (others => '0')
);
END climb;


--  Architecture Body

ARCHITECTURE climb_architecture OF climb IS

    signal root_reg : std_logic_vector(17 downto 0) := (others => '0');
    signal peak_reg : std_logic_vector(17 downto 0) := (others => '0');
    signal len_reg  : std_logic_vector(7 downto 0) := (others => '0');

    signal root_reg_prev : std_logic_vector(17 downto 0) := (others => '0');
    signal peak_reg_prev : std_logic_vector(17 downto 0) := (others => '0');

    signal len_reg_prev : std_logic_vector(7 downto 0) := (others => '0');

    signal valid : std_logic := '0';
    signal done_a_reg : std_logic := '0';

BEGIN

    -- 出力ポートとの接続
    peak_a <= peak_reg;
    len_a  <= len_reg;
    addr_a <= root_reg(9 downto 1); -- rootは奇数なので511以下の数と1対1対応

    process(clk)
    begin
        if rising_edge(clk) then
            -- 1024以上のルートであればRAMを確認しなくて良い。
            valid <= nor_reduce(root_reg(17 downto 10));
        end if;
    end process;

    process(clk, hit_a)
        -- クロックが変化するたびに変数の初期化
        variable root_var : std_logic_vector(17 downto 0) := (others => '0'); -- 一時的にrootが増大するので新たな変数を作る
        variable peak_var : std_logic_vector(17 downto 0) := (others => '0');
        variable len_var  : std_logic_vector(7 downto 0) := (others => '0');

        variable shift : std_logic_vector(4 downto 0) := (others => '0');

    begin

        if rising_edge(clk) then
            done_a_reg <= '0';
            if go_a = '1' then
                -- 処理開始
                root_var := "00000000" & root_a;
                peak_var := (others => '0');
                len_var  := (others => '0');


            elsif (valid = '1' and hit_a = '1' and root_reg /= 1 and root_reg_prev /=1) then
                -- RAMのデータがヒットしたとき
                root_var := "000000000000000001";

                if data_a.peak < peak_reg then
                    peak_var := peak_reg_prev;
                else
                    peak_var := data_a.peak;
                end if;

                len_var := len_reg_prev + data_a.len;


            elsif root_reg /= 1 then
                -- 3倍して1を足す。偶数は全てスキップ
                root_var := root_reg;
                peak_var := peak_reg;
                len_var  := len_reg;

                -- 3倍して1を足す
                if root_var(0) = '1' then
                    root_var := (root_var(16 downto 0) & '1') + root_var;

                    if peak_var < root_var then
                        peak_var := root_var;
                    end if;

                    len_var  := len_var + 1;
                end if;

                -- 偶数をスキップ
                -- priority encoder
                if root_var(0) = '1' then
                    shift := "00000";
                elsif root_var(1) = '1' then
                    shift := "00001";
                elsif root_var(2) = '1' then
                    shift := "00010";
                elsif root_var(3) = '1' then
                    shift := "00011";
                elsif root_var(4) = '1' then
                    shift := "00100";
                elsif root_var(5) = '1' then
                    shift := "00101";
                elsif root_var(6) = '1' then
                    shift := "00110";
                elsif root_var(7) = '1' then
                    shift := "00111";
                elsif root_var(8) = '1' then
                    shift := "01000";
                elsif root_var(9) = '1' then
                    shift := "01001";
                elsif root_var(10) = '1' then
                    shift := "01010";
                elsif root_var(11) = '1' then
                    shift := "01011";
                elsif root_var(12) = '1' then
                    shift := "01100";
                elsif root_var(13) = '1' then
                    shift := "01101";
                elsif root_var(14) = '1' then
                    shift := "01110";
                elsif root_var(15) = '1' then
                    shift := "01111";
                elsif root_var(16) = '1' then
                    shift := "10000";
                elsif root_var(17) = '1' then
                    shift := "10001";
                else
                    shift := "-----";
                end if;

                -- barrel shifter
                if shift(4) = '1' then
                    root_var := "0000000000000000" & root_var(17 downto 16);
                    len_var  := len_var + 16;
                end if;
                if shift(3) = '1' then
                    root_var := "00000000" & root_var(17 downto 8);
                    len_var  := len_var + 8;
                end if;
                if shift(2) = '1' then
                    root_var := "0000" & root_var(17 downto 4);
                    len_var  := len_var + 4;
                end if;
                if shift(1) = '1' then
                    root_var := "00" & root_var(17 downto 2);
                    len_var  := len_var + 2;
                end if;
                if shift(0) = '1' then
                    root_var := '0' & root_var(17 downto 1);
                    len_var  := len_var + 1;
                end if;

            end if;

            if root_var = 1 then
                done_a_reg <= '1';
            end if;

            root_reg_prev <= root_reg;
            peak_reg_prev <= peak_reg;
            len_reg_prev <= len_reg;
        end if;
        done_a <= done_a_reg;


        root_reg <= root_var;
        peak_reg <= peak_var;
        len_reg  <= len_var;

    end process;

END climb_architecture;
