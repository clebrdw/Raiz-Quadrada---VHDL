-- Autor: Cleber Werlang
-- Diciplina: Sistemas Embarcados II
-- DataPath do Circuito que calcula Raiz Quadrada

library ieee;
	use ieee.std_logic_1164.all;

package datapath_package is 

component DataPath is
	generic( n	:	integer:= 8); 
	port (
		input 				:	in 		std_logic_vector(n-1 downto 0);
		sel,clk,en,rst_n	: 	in		std_logic;
		done				:	out 	std_logic;
		resultado			: 	out		std_logic_vector((n/2)-1 downto 0)
	);
end component;

end datapath_package;	

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_arith.all;
	
library work;
	use work.adder_package.all;
	use work.AddSub_package.all;
	use work.gen_reg_package.all;
	use work.mux_package.all;

entity DataPath is
	generic( n	:	integer:= 8); 
	port(
		input 				:	in 		std_logic_vector(n-1 downto 0);
		sel,clk,en,rst_n	: 	in		std_logic;
		done				:	out 	std_logic;
		resultado			: 	out		std_logic_vector((n/2)-1 downto 0)
	);
end DataPath;


architecture estrutural of DataPath is
	
	--Sinais utilizados
	signal resultado_temp 	: std_logic_vector((n/2)-1 downto 0);
	signal reg_square_temp 	: std_logic_vector(n-1 downto 0);
	signal fio_reg_root		: std_logic_vector((n/2)-1 downto 0);
	signal fio_reg_square	: std_logic_vector(n-1 downto 0);
	signal fio_mux_out		: std_logic_vector(n-1 downto 0);
	signal sub_out			: std_logic_vector(n-1 downto 0);
	signal fio_sum_square	: std_logic_vector(n-1 downto 0);
	signal fio_sum_root		: std_logic_vector((n/2)-1 downto 0);
	
	--Sinais input
	--signal set_zero		: std_logic := 0;
	--signal set_one		: std_logic := 1;
	
	-- Utilizar constantes para definir valores nas entradas
	constant set_zero		: std_logic := '0';
	constant set_one		: std_logic := '1';

begin
	
	-- Splitter do 'SEL' no sum_reg_root --> n/2 BITS
	--fio_sum_root <= (others => '0') & (sel) & (not sel);	
	fio_sum_root(0)	<=	not sel;
	fio_sum_root(1)	<=	sel;
	SEL_GEN: for i in 0 to (n/2)-3 generate
		fio_sum_root(i+2) <= '0';
	end generate SEL_GEN;

	-- Atualizando a saida do registrador "Reg_root"
	resultado <= resultado_temp;
	
	-- Valor MSB do resultado da subtracao, indica termino do algoritmo
	done <= sub_out(n-1);
	
	-- Shift Right do Splitter entre 'fio_reg_root' e 'reg_square'
	fio_sum_square(0)	<=	'0';
	SHIFT_RIGHT_GEN: for i in 0 to (n/2)-2 generate
		fio_sum_square(i+1) <= fio_reg_root(i);
	end generate SHIFT_RIGHT_GEN;
	-- Estende a parte dos zeros 
	ESTENDE: for i in (n/2) to n-1 generate
		fio_sum_square(i) <= '0';
	end generate ESTENDE;
		
	--### TESTE - Debug ###
	--r_square <= reg_square_temp;
	--r_bef_square <= fio_reg_square;
	
	-- Somador Reg_root
	SUM_Reg_root: entity work.Adder(dataflow)
		generic map((n/2)) 
		port map(
			input0 		=>	resultado_temp,
			input1 		=> 	fio_sum_root,
			carry_in	=>	set_zero,	
			result		=>	fio_reg_root,
			carry_out	=>	open
		);
	
	-- Somador Reg_square
	SUM_Reg_square: entity work.Adder(dataflow)
		generic map(n) 
		port map(
			input0		=>	fio_mux_out,
			input1		=>	fio_sum_square,
			carry_in	=>	set_one,	-- 1
			result		=>	fio_reg_square,
			carry_out	=>	open
		);

	-- Registrador Reg_root
	Reg_root: entity work.gen_reg(structure)
		generic map((n/2)) 
		port map(
			datain		=>	fio_reg_root,	
			set			=>	set_one,	-- 1
			reset		=>	rst_n,
			enable		=>	en,
			clock		=>	clk,
			dataout		=>	resultado_temp
		);
	
	-- Registrador Reg_square
	Reg_square: entity work.gen_reg(structure)
		generic map(n) 
		port map(
			datain		=>	fio_reg_square,	
			set			=>	set_one, -- 1
			reset		=>	rst_n,
			enable		=>	en,
			clock		=>	clk,
			dataout		=>	reg_square_temp
		);
	
	-- Multiplexador Reg_square
	MUX_reg_square: entity work.mux_2_1(dataflow)
		generic map(n) 
		port map(
			A0			=>	reg_square_temp,
			A1			=>	CONV_STD_LOGIC_VECTOR(4, n), -- Converte '4' para n bits de dados
			s0			=>	sel,
			result		=>	fio_mux_out
		);
	
	-- Subtrator 
	SUB_reg_square: entity work.AddSub(dataflow)
		generic map(n) 
		port map(	
			input0     	=> 	input,		-- Valor de entrada
			input1    	=>	reg_square_temp,
			carry_in  	=>	set_zero,	
			ctrl      	=>	set_one,	-- Subtrator
			result    	=>	sub_out,	-- result[0] == 1 eh negativo, result[0] => done
			carry_out	=>	open
		);
end estrutural;