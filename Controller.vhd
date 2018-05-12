----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.types.ALL;
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
entity Controller is
Port (
	CLK : 		in STD_LOGIC;
	DATA_IN : 	in STD_LOGIC_VECTOR (15 downto 0); --8 bits instruction/data from RX
	BYTE_READY: in STD_LOGIC; --high when 8 bits data is receive from RX
	DATA_OUT : 	out STD_LOGIC_VECTOR (15 downto 0); --8 bits instruction/data
	MEM_ADR : 	out STD_LOGIC_VECTOR (14 downto 0); -- 15 bits bcoz msb is used for data decoding RUN, LOAD , etc
	MEM_WE : 	out STD_LOGIC;
	MEM_EN : 	out STD_LOGIC
);
end Controller;

architecture Behavioral of Controller is

signal stall : STD_LOGIC_VECTOR (14 downto 0) :=  "000000000000000"; --number of vectors
--signal fe_count : STD_LOGIC_VECTOR (28 downto 0) := "00000000000000000000000000000";
--signal FQD : STD_LOGIC_VECTOR (28 downto 0) := "00000000000000000000000000001";
signal fe_count : STD_LOGIC_VECTOR (4 downto 0) := "00000";
signal FQD : STD_LOGIC_VECTOR (4 downto 0) 		:= "00001";
signal CLK_MODIFIED : STD_LOGIC := '0';
signal writeadr : STD_LOGIC_VECTOR (14 downto 0) := "000000000000000";
signal readadr : STD_LOGIC_VECTOR (14 downto 0)  := "000000000000000";
signal BYTE_READY_DELAYED : STD_LOGIC := '0';

type state_type is (IDLE_STATE,DECODE_STATE,RUNNING_STATE,NUMVECTOR_STATE,WRITE_STATE);
signal state, next_state: state_type;

begin
-- the user defined clock enable
process (CLK)
begin
	if CLK'event and CLK = '1' then
		fe_count <= fe_count + 1;
		if fe_count >= FQD then
			--fe_count <= "00000000000000000000000000000";
			fe_count <= "00000";
			CLK_MODIFIED <= '1';
		else
			CLK_MODIFIED <= '0';
		end if;
	end if;
end process;
-- 3 process FSM

state_register: process(CLK)
begin
	if (CLK'Event and CLK = '1') then
		state <= next_state;
	end if;
end process state_register;

nextstate_function : process (state, DATA_IN, BYTE_READY, writeadr, stall)
begin
	case state is
		when IDLE_STATE => -- IDLE
			next_state <= IDLE_STATE;
			if BYTE_READY = '1' then
				next_state <= DECODE_STATE;
			end if;
			
		when DECODE_STATE =>
			case DATA_IN(15 downto 0) is
				when CLEAR =>
					next_state <= DECODE_STATE;
					if BYTE_READY = '0' then
						next_state <= IDLE_STATE;
					end if;
				when SETCLOCK =>
					next_state <= DECODE_STATE;
					if BYTE_READY = '0' then
						next_state <= IDLE_STATE;
					end if;
				when RUN =>
					next_state <= RUNNING_STATE;
				when LOAD =>
					next_state <= DECODE_STATE;
					if BYTE_READY = '0' then
						next_state <= NUMVECTOR_STATE;
					end if;
				when others =>
					next_state <= DECODE_STATE;
			end case; 
	
		when RUNNING_STATE =>
			if (DATA_IN(15 downto 0) = STOP and BYTE_READY = '0') then
				next_state <= IDLE_STATE;
			else
				next_state <= RUNNING_STATE;
			end if;
			
		when NUMVECTOR_STATE =>
			if BYTE_READY = '1' then
				
				stall <= DATA_IN (14 downto 0) ;
				next_state <= WRITE_STATE ; --NUMVECTOR_STATE
			else
				next_state <= NUMVECTOR_STATE;
			end if;
			
		
		when WRITE_STATE =>
			next_state <= WRITE_STATE;
			if BYTE_READY = '0' and writeadr = stall then
				next_state <= IDLE_STATE;
			end if;
		when others => 
			next_state <= IDLE_STATE;
		end case;
end process nextstate_function;


memory_controller : process(CLK)
begin
if (CLK'Event and CLK = '1') then
	BYTE_READY_DELAYED <= BYTE_READY;

	case state is
	when RUNNING_STATE =>
		if(readadr < stall-1) then
			if CLK_MODIFIED = '1' then
				readadr <= readadr + 1;
			end if;
		end if;

	when WRITE_STATE =>
		if BYTE_READY_DELAYED = '0' and BYTE_READY = '1' then
			writeadr <= writeadr + 1;
	end if;

	when others =>
		writeadr <= "000000000000000";
		readadr <=  "000000000000000";
	end case;
end if;
end process memory_controller;


output_function : process (state, readadr, writeadr, DATA_IN)
begin

case state is

	when DECODE_STATE =>
		MEM_WE <= '0';
		MEM_EN <= '0';
		MEM_ADR <= "000000000000000";
		DATA_OUT <= halfword_zero;
		if DATA_IN(7 downto 0) = SETCLOCK then
			FQD <= DATA_IN(7 downto 3); --DATA_IN(31 downto 3);
		end if;
		
	when RUNNING_STATE => -- RUN
		MEM_WE <= '0';
		MEM_EN <= '1';
		MEM_ADR <= readadr;
		DATA_OUT <= halfword_zero;
	
	when WRITE_STATE => -- WRITE WORD
		MEM_WE <= '1';
		MEM_EN <= '1';
		MEM_ADR <= writeadr;
		DATA_OUT <= DATA_IN;
	when others =>
		MEM_WE <= '0';
		MEM_EN <= '0';
		MEM_ADR <= "000000000000000";
		DATA_OUT <= halfword_zero;
	end case;
end process output_function;

end Behavioral;