library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Keyboard is
	port (Reset     : in STD_LOGIC;
		  Clock     : in STD_LOGIC;
		  PS2Clock  : inout STD_LOGIC;
		  PS2Data   : inout STD_LOGIC;
		  CodeReady : out STD_LOGIC;
		  ScanCode  : out STD_LOGIC_VECTOR(9 downto 0)
);
end Keyboard;

architecture Behavioral of Keyboard is

	signal Send      : STD_LOGIC;
	signal Command   : STD_LOGIC_VECTOR(7 downto 0);
	signal PS2Busy   : STD_LOGIC;
	signal PS2Error  : STD_LOGIC;
	signal DataReady : STD_LOGIC;
	signal DataByte  : STD_LOGIC_VECTOR(7 downto 0);

begin

	PS2_Controller: entity work.PS2Controller
		port map (Reset     => Reset,
				  Clock     => Clock,
				  PS2Clock  => PS2Clock,
				  PS2Data   => PS2Data,
				  Send      => Send,
				  Command   => Command,
				  PS2Busy   => PS2Busy,
				  PS2Error  => PS2Error,
				  DataReady => DataReady,
				  DataByte  => DataByte);

	Keyboard_Mapper: entity work.KeyboardMapper
		port map (Clock     => Clock,
				  Reset     => Reset,
				  PS2Busy   => PS2Busy,
				  PS2Error  => PS2Error,
				  DataReady => DataReady,
				  DataByte  => DataByte,
				  Send      => Send,
				  Command   => Command,
				  CodeReady => CodeReady,
				  ScanCode  => ScanCode);

end Behavioral;
