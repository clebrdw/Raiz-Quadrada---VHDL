-- Autor: Cleber Werlang
-- Diciplina: Sistemas Embarcados II
-- Topo do Circuito que calcula Raiz Quadrada

library ieee;
	use ieee.std_logic_1164.all;
library work; --importacao de bibliotecas locais
	use work.datapath_package.all;	
	use work.controlpath_package.all;
	
entity Topo is
	generic(n	:	integer := 8);
	port(
		clk, rst_n		:	in 	std_logic;
		input			:	in	std_logic_vector(n-1 downto 0);
		result			:	out	std_logic_vector((n/2)-1 downto 0);
		done			:	out	std_logic			
	);
end Topo;

architecture main of Topo is
	
	signal s_sel, s_en	: 	std_logic;
	signal s_done		:	std_logic;
	signal i_input		:	std_logic_vector(n-1 downto 0); 
	signal o_result	  	:	std_logic_vector((n/2)-1 downto 0);

begin

	ControlPath: entity work.ControlPath(mealy)
		port map(
				clk 	=> clk,
				rst_n 	=> rst_n,
				done	=> s_done,
				sel 	=> s_sel,
				en		=> s_en
		);
		
	DataPath	: entity work.DataPath(estrutural)
		generic map(n)
		port map(
				clk		=> clk,
				rst_n	=> rst_n,
				done	=> s_done,
				sel 	=> s_sel,
				en		=> s_en,	
				input 	=> i_input,
				resultado => o_result
		);
		
	-- Atualiza valores 
	done	<= s_done;
	i_input <= input;
	result	<= o_result;

end main;