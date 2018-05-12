

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
	
--entity top_patgen_16bits is
--
--Port (
--	CLK 		: in STD_LOGIC;
--	DATA_READY  : in STD_LOGIC;
--	DATA_IN 	: in STD_LOGIC_VECTOR (7 downto 0);
--	DATA_OUT 	: out STD_LOGIC_VECTOR (15 downto 0)
--	-- MEM_ADR 	: out STD_LOGIC_VECTOR (14 downto 0); -- 15 bits bcoz msb is used for data decoding RUN, LOAD , etc
--	-- MEM_WE 		: out STD_LOGIC;
--	-- MEM_EN 		: out STD_LOGIC
--);
--end top_patgen_16bits;

entity top_patgen_16bits is
Port (
    i_Clk       : in  std_logic;
    i_RX_Serial : in  std_logic;
    o_ready     : out std_logic;
    o_LED   	 : out std_logic_vector(7 downto 0)
);
end top_patgen_16bits;


architecture Behavioral of top_patgen_16bits is

-- signal addr : 			std_logic_vector(14 downto 0); 
-- signal w_RX_DIV: 		std_logic;
--signal w_ready: 		std_logic;
-- signal w_RX_Byte: 	STD_LOGIC_VECTOR(7 downto 0);
-- signal w_LED: 			STD_LOGIC_VECTOR(7 downto 0);
signal w_DATA 		: 	STD_LOGIC_VECTOR(15 downto 0)  := halfword_zero;
signal w_DATA_OUT : 	STD_LOGIC_VECTOR(15 downto 0)  := halfword_zero;
signal w_MEM_ADR 	: 	STD_LOGIC_VECTOR (14 downto 0) := "000000000000000"; 
signal w_MEM_DATA : 	STD_LOGIC_VECTOR (15 downto 0); 
signal w_MEM_WE 	: 	STD_LOGIC_VECTOR (0 downto 0);
signal w_RX_Byte	: 	STD_LOGIC_VECTOR (7 downto 0);
signal w_MEM_EN 	: 	STD_LOGIC;
signal w_BYTE_DATA_READY		: STD_LOGIC;
signal w_HALFWORD_DATA_READY	: STD_LOGIC;

--signal w_temp_addr: STD_LOGIC_VECTOR(15 downto 0)  := halfword_zero;

--signal w_controller_out: STD_LOGIC_VECTOR(7 downto 0):= byte_zero;


begin

	o_ready <=  not w_HALFWORD_DATA_READY;
	
	o_LED    <= w_DATA_OUT (7 downto 0);

	------ Instantiate new components here -----	

	u_UART_RX: UART_RX 
		GENERIC MAP (
					N     			=> 434 
					)
	PORT MAP(
			i_Clk 		=> i_Clk,
			i_RX_Serial => i_RX_Serial,
			o_RX_DV 		=> w_BYTE_DATA_READY,
			o_RX_Byte 	=> w_RX_Byte
		);

	u_halfword_collector: Byte_Collector
	PORT MAP (
		CLK 			=> i_Clk,
		DATA_IN 		=> w_RX_Byte,
		DATA_OUT		=> w_DATA,
		BYTE_READY 	=> w_BYTE_DATA_READY ,
		WORD_READY 	=> w_HALFWORD_DATA_READY
		);
	
	u_controller: Controller 

	 PORT MAP (
		CLK  	    	=>	i_Clk	,
		DATA_IN		=>	w_DATA,
		BYTE_READY 	=>	w_HALFWORD_DATA_READY	,
		DATA_OUT 	=>	w_MEM_DATA	,
		MEM_ADR 		=>	w_MEM_ADR	,
		MEM_WE 		=>	w_MEM_WE (0)	,
		MEM_EN 		=> w_MEM_EN
		);

	u_memory : BRAM_16384x16
		PORT MAP (
		 clka 	=> i_Clk,
		 ena 		=> w_MEM_EN,
		 wea 		=> w_MEM_WE,
		 addra 	=> w_MEM_ADR (13 downto 0),
		 dina 	=> w_MEM_DATA,
		 douta 	=> w_DATA_OUT
	  );

		
		

end Behavioral;