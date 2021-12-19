-- Autor: Cleber Werlang
-- Diciplina: Sistemas Embarcados II
-- Testbench do Topo do Circuito que calcula Raiz Quadrada

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity Topo_tb is
	constant n_bits		:	integer := 32;	-- Definir a quatidade de bits
	constant input		:	integer := 36; -- Definir o valor de entrada
end Topo_tb;

architecture tb of Topo_tb is
	
	signal i_input_tb 	:  	std_logic_vector(n_bits-1 downto 0) := CONV_STD_LOGIC_VECTOR(input,n_bits);
	signal i_clk      	:  	std_logic := '0';
	signal i_rst_n    	:  	std_logic;
	signal o_done     	:  	std_logic;
	signal o_res_tb   	:  	std_logic_vector((n_bits/2)-1 downto 0);
	
component Topo
	generic(n	:	integer := n_bits);
	port (
		clk     	: 	in std_logic;
		rst_n   	: 	in std_logic;
		input   	: 	in std_logic_vector(n-1 downto 0);
		result  	: 	out std_logic_vector((n/2)-1 downto 0);
		done   		:	out std_logic	
	);
end component;

begin
	DUV: Topo port map (
		i_clk,
		i_rst_n,
		i_input_tb,
		o_res_tb,
		o_done
	);
	
	-- reset acontece quando esta em '0'
	i_rst_n <= '0', '1' after 1 ns;
	
	-- 100MHz
	i_clk <= not i_clk after 5 ns;

end tb;
