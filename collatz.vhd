library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.types.all;

ENTITY collatz IS
	PORT
	(
		clk :  IN  std_logic := '0';
		clk_count :  OUT  std_logic_vector(31 downto 0) := (others => '0');
		top4 :  OUT  chains4_t := (others => ((others => '0'), (others => '0'), (others => '0')))
	);
END collatz;

ARCHITECTURE bdf_type OF collatz IS

COMPONENT climb
	PORT(clk : IN STD_LOGIC;
		 data_a : IN data_t;
		 go_a : IN STD_LOGIC;
		 hit_a : IN STD_LOGIC;
		 root_a : IN std_logic_vector(9 downto 0);
		 addr_a : OUT std_logic_vector(8 downto 0); -- 保存先は偶数をスキップ
		 done_a : OUT STD_LOGIC;
		 len_a : OUT std_logic_vector(7 downto 0);
		 peak_a : OUT std_logic_vector(17 downto 0)
	);
END COMPONENT;

COMPONENT control
	PORT(clk : IN STD_LOGIC;
		 addr_a : IN std_logic_vector(8 downto 0);
		 done_a : IN STD_LOGIC;
		 len_a : IN std_logic_vector(7 downto 0);
		 peak_a : IN std_logic_vector(17 downto 0);
		 addr_b : IN std_logic_vector(8 downto 0);
		 done_b : IN STD_LOGIC;
		 len_b : IN std_logic_vector(7 downto 0);
		 peak_b : IN std_logic_vector(17 downto 0);
		 pend_root_out_a : IN std_logic_vector(9 downto 0);
		 pend_root_out_b : IN std_logic_vector(9 downto 0);
		 pend_addr_out_a : IN std_logic_vector(8 downto 0); -- 追加
		 pend_addr_out_b : IN std_logic_vector(8 downto 0); -- 追加
		 pend_len_out_a : IN std_logic_vector(7 downto 0);
		 pend_len_out_b : IN std_logic_vector(7 downto 0);
		 pend_peak_out_a : IN std_logic_vector(17 downto 0);
		 pend_peak_out_b : IN std_logic_vector(17 downto 0);
		 pend_climb_go_a : IN STD_LOGIC;
		 pend_climb_go_b : IN STD_LOGIC;
		 pend_go_a : OUT STD_LOGIC;
		 pend_go_b : OUT STD_LOGIC;
		 pend_root_in : OUT std_logic_vector(9 downto 0);
		 pend_addr_in : OUT std_logic_vector(8 downto 0); -- 追加
 		 pend_len_in : OUT std_logic_vector(7 downto 0);
 		 pend_peak_in : OUT std_logic_vector(17 downto 0);
 		 pend_write_enable : OUT STD_LOGIC;
 		 pend_start : OUT STD_LOGIC;
		 root_a : OUT std_logic_vector(9 downto 0);
		 root_b : OUT std_logic_vector(9 downto 0);
		 ram_addr_a : OUT std_logic_vector(8 downto 0);
		 ram_addr_b : OUT std_logic_vector(8 downto 0);
		 ram_data_in_a : OUT data_t;
		 ram_data_in_b : OUT data_t;
		 write_enable_a : OUT STD_LOGIC;
		 write_enable_b : OUT STD_LOGIC;
		 sort_data_a : OUT chain_t;
		 sort_data_b : OUT chain_t;
		 go_a : OUT STD_LOGIC;
		 go_b : OUT STD_LOGIC

	);
END COMPONENT;

COMPONENT count_clk
	PORT(clk : IN STD_LOGIC;
		 all_done : IN STD_LOGIC;
		 clk_count : OUT std_logic_vector(31 downto 0)
	);
END COMPONENT;

COMPONENT pending
	PORT(pend_root_in : IN std_logic_vector(9 downto 0);
		pend_addr_in : IN std_logic_vector(8 downto 0); -- 追加
		pend_len_in : IN std_logic_vector(7 downto 0);
		pend_peak_in : IN std_logic_vector(17 downto 0);
		pend_write_enable : IN STD_LOGIC;
		pend_start : IN STD_LOGIC;
		pend_go_a : IN STD_LOGIC;
		pend_go_b : IN STD_LOGIC;
		clk : IN STD_LOGIC;
		pend_root_out_a : OUT std_logic_vector(9 downto 0);
		pend_root_out_b : OUT std_logic_vector(9 downto 0);
		pend_addr_out_a : OUT std_logic_vector(8 downto 0); -- 追加
		pend_addr_out_b : OUT std_logic_vector(8 downto 0); -- 追加
		pend_len_out_b : OUT std_logic_vector(7 downto 0);
		pend_len_out_a : OUT std_logic_vector(7 downto 0);
		pend_peak_out_a : OUT std_logic_vector(17 downto 0);
		pend_peak_out_b : OUT std_logic_vector(17 downto 0);
		pend_climb_go_a : OUT STD_LOGIC;
		pend_climb_go_b : OUT STD_LOGIC;
		all_pend_done : OUT STD_LOGIC
	);
END COMPONENT;


COMPONENT ram_wrap
	PORT(clk : IN STD_LOGIC;
		 ram_addr_a : IN std_logic_vector(8 downto 0);
		 ram_addr_b : IN std_logic_vector(8 downto 0);
		 ram_data_in_a : IN data_t;
		 ram_data_in_b : IN data_t;
		 write_enable_a : IN STD_LOGIC;
		 write_enable_b : IN STD_LOGIC;
		 ram_data_out_a : OUT data_t;
		 ram_data_out_b : OUT data_t;
		 hit_a : OUT STD_LOGIC;
		 hit_b : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT sort
	PORT(clk   : in  std_logic;
		 sort_data_a : IN chain_t;
		 sort_data_b : IN chain_t;
		 top4 : OUT chains4_t
	);
END COMPONENT;

-- 各モジュールの入出力ポートをつなぐwireを定義
SIGNAL	hit_a_wire :  STD_LOGIC;
SIGNAL	root_a_wire:  std_logic_vector(9 downto 0);
SIGNAL	hit_b_wire :  STD_LOGIC;
SIGNAL	root_b_wire :  std_logic_vector(9 downto 0);
SIGNAL	addr_a_wire :  std_logic_vector(8 downto 0);
SIGNAL	done_a_wire :  STD_LOGIC;
SIGNAL	len_a_wire :  std_logic_vector(7 downto 0);
SIGNAL	peak_a_wire :  std_logic_vector(17 downto 0);
SIGNAL	addr_b_wire :  std_logic_vector(8 downto 0);
SIGNAL	done_b_wire :  STD_LOGIC;
SIGNAL	len_b_wire :  std_logic_vector(7 downto 0);
SIGNAL	peak_b_wire :  std_logic_vector(17 downto 0);
SIGNAL	pend_root_out_a_wire :  std_logic_vector(9 downto 0);
SIGNAL	pend_root_out_b_wire :  std_logic_vector(9 downto 0);
SIGNAL	pend_addr_out_a_wire :  std_logic_vector(8 downto 0);
SIGNAL	pend_addr_out_b_wire :  std_logic_vector(8 downto 0);
SIGNAL	pend_len_out_a_wire :  std_logic_vector(7 downto 0);
SIGNAL	pend_len_out_b_wire :  std_logic_vector(7 downto 0);
SIGNAL	pend_peak_out_a_wire :  std_logic_vector(17 downto 0);
SIGNAL	pend_peak_out_b_wire :  std_logic_vector(17 downto 0);
SIGNAL	pend_climb_go_a_wire :  STD_LOGIC;
SIGNAL	pend_climb_go_b_wire :  STD_LOGIC;
SIGNAL	pend_go_a_wire :  STD_LOGIC;
SIGNAL	all_done_wire :  STD_LOGIC;
SIGNAL	pend_go_b_wire :  STD_LOGIC;
SIGNAL	ram_addr_a_wire :  std_logic_vector(8 downto 0);
SIGNAL	ram_addr_b_wire :  std_logic_vector(8 downto 0);
SIGNAL	ram_data_in_a_wire :  data_t;
SIGNAL	ram_data_in_b_wire :  data_t;
SIGNAL	write_enable_a_wire :  STD_LOGIC;
SIGNAL	write_enable_b_wire :  STD_LOGIC;
SIGNAL	sort_data_a_wire :  chain_t;
SIGNAL	sort_data_b_wire :  chain_t;
SIGNAL	pend_root_in_wire :  std_logic_vector(9 downto 0);
SIGNAL	pend_addr_in_wire :  std_logic_vector(8 downto 0);
SIGNAL	pend_len_in_wire :  std_logic_vector(7 downto 0);
SIGNAL	pend_peak_in_wire :  std_logic_vector(17 downto 0);
SIGNAL	pend_write_enable_wire :  STD_LOGIC;
SIGNAL	pend_start_wire :  STD_LOGIC;
SIGNAL	ram_data_out_a_wire :  data_t;
SIGNAL	ram_data_out_b_wire :  data_t;
SIGNAL	go_a_wire :  STD_LOGIC;
SIGNAL	go_b_wire :  STD_LOGIC;

BEGIN


-- モジュールのインスタンス化
climb_a : climb
PORT MAP(clk => clk,
		 hit_a => hit_a_wire,
		 root_a => root_a_wire,
		 addr_a => addr_a_wire,
		 done_a => done_a_wire,
		 len_a => len_a_wire,
		 peak_a => peak_a_wire,
		 data_a => ram_data_out_a_wire,
		 go_a => go_a_wire);


climb_b : climb
PORT MAP(clk => clk,
		 hit_a => hit_b_wire,
		 root_a => root_b_wire,
		 addr_a => addr_b_wire,
		 done_a => done_b_wire,
		 len_a => len_b_wire,
		 peak_a => peak_b_wire,
		 data_a => ram_data_out_b_wire,
		 go_a => go_b_wire);


control_inst : control
PORT MAP(clk => clk,
		 addr_a => addr_a_wire,
		 done_a => done_a_wire,
		 len_a => len_a_wire,
		 peak_a => peak_a_wire,
		 addr_b => addr_b_wire,
		 done_b => done_b_wire,
		 len_b => len_b_wire,
		 peak_b => peak_b_wire,
		 pend_root_out_a => pend_root_out_a_wire,
		 pend_root_out_b => pend_root_out_b_wire,
		 pend_addr_out_a => pend_addr_out_a_wire,
		 pend_addr_out_b => pend_addr_out_b_wire,
		 pend_len_out_a => pend_len_out_a_wire,
		 pend_len_out_b => pend_len_out_b_wire,
		 pend_peak_out_a => pend_peak_out_a_wire,
		 pend_peak_out_b => pend_peak_out_b_wire,
		 pend_climb_go_a => pend_climb_go_a_wire,
		 pend_climb_go_b => pend_climb_go_b_wire,
		 pend_go_a => pend_go_a_wire,
		 pend_go_b => pend_go_b_wire,
		 root_a => root_a_wire,
		 root_b => root_b_wire,
		 ram_addr_a => ram_addr_a_wire,
		 ram_addr_b => ram_addr_b_wire,
		 ram_data_in_a => ram_data_in_a_wire,
		 ram_data_in_b => ram_data_in_b_wire,
		 write_enable_a => write_enable_a_wire,
		 write_enable_b => write_enable_b_wire,
		 sort_data_a => sort_data_a_wire,
		 sort_data_b => sort_data_b_wire,

		 pend_root_in => pend_root_in_wire,
		 pend_addr_in => pend_addr_in_wire,
		 pend_len_in => pend_len_in_wire,
		 pend_peak_in => pend_peak_in_wire,
		 pend_write_enable => pend_write_enable_wire,
		 pend_start => pend_start_wire,

		 go_a => go_a_wire,
		 go_b => go_b_wire
		 );

count_clk_inst : count_clk
PORT MAP(clk => clk,
		 all_done => all_done_wire,
		 clk_count => clk_count);


pending_inst : pending
PORT MAP(pend_go_a => pend_go_a_wire,
		 pend_go_b => pend_go_b_wire,
		 clk => clk,
		 pend_root_out_a => pend_root_out_a_wire,
		 pend_root_out_b => pend_root_out_b_wire,
		 pend_addr_out_a => pend_addr_out_a_wire,
		 pend_addr_out_b => pend_addr_out_b_wire,
		 pend_len_out_b => pend_len_out_b_wire,
		 pend_len_out_a => pend_len_out_a_wire,
		 pend_peak_out_a => pend_peak_out_a_wire,
		 pend_peak_out_b => pend_peak_out_b_wire,
		 pend_climb_go_a => pend_climb_go_a_wire,
		 pend_climb_go_b => pend_climb_go_b_wire,

		 pend_root_in => pend_root_in_wire,
		 pend_addr_in => pend_addr_in_wire,
		 pend_len_in => pend_len_in_wire,
		 pend_peak_in => pend_peak_in_wire,
		 pend_write_enable => pend_write_enable_wire,
		 pend_start => pend_start_wire,

		 all_pend_done => all_done_wire
		 );


ram_wrap_inst : ram_wrap
PORT MAP(clk => clk,
		 ram_addr_a => ram_addr_a_wire,
		 ram_addr_b => ram_addr_b_wire,
		 ram_data_in_a => ram_data_in_a_wire,
		 ram_data_in_b => ram_data_in_b_wire,
		 write_enable_a => write_enable_a_wire,
		 write_enable_b => write_enable_b_wire,
		 hit_a => hit_a_wire,
		 hit_b => hit_b_wire,
		 ram_data_out_a => ram_data_out_a_wire,
		 ram_data_out_b => ram_data_out_b_wire);


sort_inst : sort
PORT MAP(clk => clk,
		 sort_data_a => sort_data_a_wire,
		 sort_data_b => sort_data_b_wire,
		 top4 => top4);


END bdf_type;
