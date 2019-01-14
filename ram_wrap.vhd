library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.types.all;

--  Entity Declaration

ENTITY ram_wrap IS
PORT
(
    clk : IN STD_LOGIC := '0';
    ram_addr_a : IN std_logic_vector(8 downto 0) := (others => '0');
    ram_addr_b : IN std_logic_vector(8 downto 0) := (others => '0');
    ram_data_in_a : IN data_t := ((others => '0'), (others => '0'));
    ram_data_in_b : IN data_t := ((others => '0'), (others => '0'));
    write_enable_a : IN STD_LOGIC := '0';
    write_enable_b : IN STD_LOGIC := '0';
    ram_data_out_a : OUT data_t := ((others => '0'), (others => '0'));
    ram_data_out_b : OUT data_t := ((others => '0'), (others => '0'));
    hit_a : OUT STD_LOGIC := '0';
    hit_b : OUT STD_LOGIC := '0'
);

END ram_wrap;


--  Architecture Body

ARCHITECTURE ram_wrap_architecture OF ram_wrap IS

    component ram_2_port
        port (
            address_a		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
    		address_b		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
    		clock		: IN STD_LOGIC;
    		data_a		: IN STD_LOGIC_VECTOR (26 DOWNTO 0);
    		data_b		: IN STD_LOGIC_VECTOR (26 DOWNTO 0);
    		wren_a		: IN STD_LOGIC;
    		wren_b		: IN STD_LOGIC;
    		q_a		: OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
    		q_b		: OUT STD_LOGIC_VECTOR (26 DOWNTO 0)
        );
    end component;

    signal data_a : std_logic_vector(26 downto 0) := (others => '0');
    signal data_b : std_logic_vector(26 downto 0) := (others => '0');
    signal q_a    : std_logic_vector(26 downto 0) := (others => '0');
    signal q_b    : std_logic_vector(26 downto 0) := (others => '0');



BEGIN
    ram_2_port_inst : ram_2_port port map (
        address_a => ram_addr_a,
        address_b => ram_addr_b,
        clock   => clk,
        data_a    => data_a,
        data_b    => data_b,
        wren_a    => write_enable_a,
        wren_b    => write_enable_b,
        q_a       => q_a,
        q_b       => q_b
    );

    data_a <= write_enable_a & ram_data_in_a.peak & ram_data_in_a.len;
    data_b <= write_enable_b & ram_data_in_b.peak & ram_data_in_b.len;

    hit_a <= q_a(26);
    hit_b <= q_b(26);
    ram_data_out_a.peak <= q_a(25 downto 8);
    ram_data_out_b.peak <= q_b(25 downto 8);
    ram_data_out_a.len  <= q_a(7 downto 0);
    ram_data_out_b.len  <= q_b(7 downto 0);

END ram_wrap_architecture;
