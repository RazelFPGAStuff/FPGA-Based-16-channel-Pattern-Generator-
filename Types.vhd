-- Package File Template
--
-- Purpose: This package defines supplemental types, subtypes,
-- constants, and functions
library IEEE;
use IEEE.STD_LOGIC_1164.all;

package types is
-- Declare types and subtypes
subtype byte_t is STD_LOGIC_VECTOR (7 downto 0);
subtype halfword_t is STD_LOGIC_VECTOR (15 DOWNTO 0);
subtype word_t is STD_LOGIC_VECTOR (31 DOWNTO 0);
type data_t is array (7 downto 0) of byte_t;

-- Declare constants
constant byte_zero : byte_t := "00000000";

constant halfword_zero : halfword_t := byte_zero & byte_zero;
constant word_zero : word_t := halfword_zero & halfword_zero;

--component declarations

component UART_RX is
  generic (
    N : integer := 434 --87     -- Needs to be set correctly
    );
  port (
    i_Clk       : in  std_logic;
    i_RX_Serial : in  std_logic;
    o_RX_DV     : out std_logic;
    o_RX_Byte   : out std_logic_vector(7 downto 0)
    );
end component UART_RX;



component Byte_Collector is
Port (
	CLK 		: in STD_LOGIC;
	DATA_IN 	: in STD_LOGIC_VECTOR (7 downto 0);
	DATA_OUT 	: out STD_LOGIC_VECTOR (15 downto 0);
	BYTE_READY 	: in STD_LOGIC;
	WORD_READY  : out STD_LOGIC
);
end component Byte_Collector;

component Controller
Port (
	CLK : 		in STD_LOGIC;
	DATA_IN : 	in STD_LOGIC_VECTOR (15 downto 0); --16 bits instruction/data from RX
	BYTE_READY: in STD_LOGIC; --high when 16 bits data is receive from RX
	DATA_OUT : 	out STD_LOGIC_VECTOR (15 downto 0); --16 bits instruction/data
	MEM_ADR : 	out STD_LOGIC_VECTOR (14 downto 0); --32k locations
	MEM_WE : 	out STD_LOGIC;
	MEM_EN : 	out STD_LOGIC
);
end component Controller;

COMPONENT BRAM_16384x16
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END COMPONENT;

-- 16384x16 single-port RAM in VHDL
-- component Single_port_RAM_VHDL
-- port(
 -- RAM_ADDR: in std_logic_vector(15 downto 0); -- Address to write/read RAM
 -- RAM_DATA_IN: in std_logic_vector(15 downto 0); -- Data to write into RAM
 -- RAM_ENABLE: in std_logic; -- ENABLE
 -- RAM_WR: in std_logic; -- Write = 1 /Read = 0  
 -- RAM_CLOCK: in std_logic; -- clock input for RAM
 -- RAM_DATA_OUT: out std_logic_vector(15 downto 0) -- Data output of RAM
-- );
-- end component;

-- A 128x8 single-port RAM in VHDL
-- component Single_port_RAM_VHDL
-- port(
 -- RAM_ADDR: in std_logic_vector(14 downto 0); -- Address to write/read RAM
 -- RAM_DATA_IN: in std_logic_vector(14 downto 0); -- Data to write into RAM
 -- RAM_WR: in std_logic; -- Write enable 
 -- RAM_CLOCK: in std_logic; -- clock input for RAM
 -- RAM_DATA_OUT: out std_logic_vector(15 downto 0) -- Data output of RAM
-- );
-- end  component Single_port_RAM_VHDL;

-- Instructions
constant CLEAR 		: STD_LOGIC_VECTOR (15 downto 0) 	:= "1000000000000000";
constant SETCLOCK 	: STD_LOGIC_VECTOR (15 downto 0) 	:= "0000000001010001"; --10Mhz
constant LOAD 		: STD_LOGIC_VECTOR (15 downto 0)	:= "1000000000000010";
constant RUN 		: STD_LOGIC_VECTOR (15 downto 0)	:= "1000000000000011";
constant STOP 		: STD_LOGIC_VECTOR (15 downto 0)	:= "1000000000000100";
end types;

package body types is
end types;