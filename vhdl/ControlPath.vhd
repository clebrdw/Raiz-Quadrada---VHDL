-- Autor: Cleber Werlang
-- Diciplina: Sistemas Embarcados II
-- ControlPath do Circuito que calcula Raiz Quadrada

library ieee;
	use ieee.std_logic_1164.all;

package controlpath_package is

component DataPath is
	generic( n	:	integer:= 8); 
	port (
		clk, rst_n, done	:	in std_logic;
		sel, en				:	out std_logic
	);
end component;

end controlpath_package;	

library ieee;
	use ieee.std_logic_1164.all;
	
entity ControlPath is
	port(
		clk, rst_n, done	:	in std_logic;
		sel, en				:	out std_logic
	);
end entity;

-- Arquitetura Mealy, pois a entrada 'done' e usada
-- na parte Output Logic.
architecture mealy of ControlPath is

	type State is (S0, S1, S2);
	signal currentState, nextState : State;
	
begin
	
	process(clk, rst_n)
	begin
		
		if rst_n = '0' then
			currentState <= S0;
			
		elsif rising_edge(clk) then
			currentState <= nextState;
			
		end if;
	end process;
	
	-- NextState logic
	process(currentState, done)
	begin
		case currentState is
			when S0 =>
				nextState <= S1;
			when S1 =>
				if done = '1' then
					nextState <= S2;
				else
					nextState <= S1;
				end if;
			when S2 => 
				if done = '1' then
					nextState <= S2;
				else
					nextState <= S0;
				end if;
			when others =>
				nextState <= S0;
		end case;
	end process;

	-- Output Logic
	sel	<= 	'1' when currentState = S0 else '0';
	en 	<=	'0' when done = '1' else '1';
	
end architecture;	
	