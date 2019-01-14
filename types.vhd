library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

package types is

    type data_t is record
        peak : std_logic_vector(17 downto 0);
        len  : std_logic_vector(7 downto 0);
    end record;

    type chain_t is record
        root : std_logic_vector(9 downto 0);
        peak : std_logic_vector(17 downto 0);
        len  : std_logic_vector(7 downto 0);
    end record;

    type chains4_t is array(0 to 3) of chain_t;
    type chains6_t is array(0 to 5) of chain_t;

    type chain_addr_t is record
        root : std_logic_vector(9 downto 0);
        addr : std_logic_vector(8 downto 0);
        peak : std_logic_vector(17 downto 0);
        len  : std_logic_vector(7 downto 0);
    end record;
    type chain4_addr_t is array(0 to 3) of chain_addr_t;

 end package types;
