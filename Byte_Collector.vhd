----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 12:27:00 08/06/2007
-- Design Name:
-- Module Name: Byte_Collector - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
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
	
entity Byte_Collector is

Port (
	CLK 		: in STD_LOGIC;
	DATA_IN 	: in STD_LOGIC_VECTOR (7 downto 0);
	DATA_OUT 	: out STD_LOGIC_VECTOR (15 downto 0);
	BYTE_READY 	: in STD_LOGIC;
	WORD_READY  : out STD_LOGIC
);
end Byte_Collector;

architecture Behavioral of Byte_Collector is
	signal byte_count : STD_LOGIC := '0'; 
	signal Sreg : STD_LOGIC_VECTOR (15 downto 0) := halfword_zero;
	signal BYTE_READY_DELAYED : STD_LOGIC := '0';
	signal data_ready : STD_LOGIC := '0';
begin

process(CLK)
begin
	if (CLK'Event and CLK = '1') then
		BYTE_READY_DELAYED <= BYTE_READY;
		if BYTE_READY_DELAYED = '0' and BYTE_READY = '1' then
			Sreg <= Sreg(7 downto 0) & DATA_IN; --concatenate 2 x 8 bits
			byte_count <= not byte_count ;
		end if;
	end if;
end process;

process (CLK)
begin
	if CLK'event and CLK = '1' then
		if (byte_count = '1' and BYTE_READY = '1' and BYTE_READY_DELAYED = '0') then
			data_ready <= '1';
		else
			data_ready <= '0';
	end if;
	end if;
end process;
	DATA_OUT <= Sreg when data_ready = '1';
	WORD_READY <= data_ready;
end Behavioral;