library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PS2Controller is
	port (Reset     : in STD_LOGIC;
		  Clock     : in STD_LOGIC;
		  PS2Clock  : inout STD_LOGIC;
		  PS2Data   : inout STD_LOGIC;
		  Send      : in STD_LOGIC;
		  Command   : in STD_LOGIC_VECTOR(7 downto 0);
		  PS2Busy   : out STD_LOGIC;
		  PS2Error  : buffer STD_LOGIC;
		  DataReady : out STD_LOGIC;
		  DataByte  : out STD_LOGIC_VECTOR(7 downto 0));
end PS2Controller;

architecture Behavioral of PS2Controller is

	constant ClockFreq     : natural := 50; -- MHz
	constant Time100us     : natural := 100 * ClockFreq;
	constant Time20us      : natural := 20 * ClockFreq;
	constant DebounceDelay : natural := 16;
	
	type StateType is (Idle, ReceiveData, InhibitComunication, RequestToSend, SendData, CheckAck, WaitRiseClock);
	signal State            : StateType;
	signal BitsRead         : natural range 0 to 10;
	signal BitsSent         : natural range 0 to 10;
	signal Byte             : STD_LOGIC_VECTOR(7 downto 0);
	signal CountOnes        : STD_LOGIC; -- One bit only to know if even or odd number of ones
	signal DReady           : STD_LOGIC;
	signal PS2ClockPrevious : STD_LOGIC;
	signal PS2ClockOut      : STD_LOGIC;
	signal PS2Clock_Z       : STD_LOGIC;
	signal PS2Clock_D       : STD_LOGIC;
	signal PS2DataOut       : STD_LOGIC;
	signal PS2Data_Z        : STD_LOGIC;
	signal PS2Data_D        : STD_LOGIC;	
	signal TimeCounter      : natural range 0 to Time100us;

begin

	DebounceClock: entity work.Debouncer
		generic map (Delay => DebounceDelay)
		port map (Clock  => Clock,
				  Reset  => Reset,
				  Input  => PS2Clock,
				  Output => PS2Clock_D);

	DebounceData: entity work.Debouncer
		generic map (Delay => DebounceDelay)
		port map (Clock  => Clock,
				  Reset  => Reset,
				  Input  => PS2Data,
				  Output => PS2Data_D);

	PS2Clock <= PS2ClockOut when PS2Clock_Z <= '0' else 'Z';
	PS2Data <= PS2DataOut when PS2Data_Z <= '0' else 'Z';

	process(Reset, Clock)
	begin
		if Reset = '1' then
			PS2Clock_Z <= '1';
			PS2ClockOut <= '1';
			PS2Data_Z <= '1';
			PS2DataOut <= '1';
			DataReady <= '0';
			DReady <= '0';
			DataByte <= (others => '0');
			PS2Busy <= '0';
			PS2Error <= '0';
			BitsRead <= 0;
			BitsSent <= 0;
			CountOnes <= '0';
			TimeCounter <= 0;
			PS2ClockPrevious <= '1';
			Byte <= x"FF";
			State <= InhibitComunication;
		elsif rising_edge(Clock) then
			PS2ClockPrevious <= PS2Clock_D;
			case State is
				when Idle =>
					DataReady <= '0';
					DReady <= '0';
					BitsRead <= 0;
					PS2Error <= '0';
					CountOnes <= '0';
					if PS2Data_D = '0' then                  -- Start bit
						PS2Busy <= '1';
						State <= ReceiveData;
					elsif Send = '1' then
						Byte <= Command;
						PS2Busy <= '1';
						TimeCounter <= 0;
						State <= InhibitComunication;
					else
						State <= Idle;
					end if;
				when ReceiveData =>
					if PS2ClockPrevious = '1' and PS2Clock_D = '0' then -- falling edge
						case BitsRead is
							when 1 to 8 =>						-- 8 Data bits
								Byte(BitsRead - 1) <= PS2Data_D;
								if PS2Data_D = '1' then
									CountOnes <= not CountOnes;
								end if;
							when 9 =>							-- Parity bit
								case CountOnes is
									when '0' =>
										if PS2Data_D = '0' then
											PS2Error <= '1';	-- Error when CountOnes is even (0)
										else				    -- and parity bit is unasserted
											PS2Error <= '0';
										end if;
									when others =>
										if PS2Data_D = '1' then
											PS2Error <= '1';	-- Error when CountOnes is odd (1)
										else				    -- and parity bit is asserted
											PS2Error <= '0';
										end if;
								end case;
							when 10 =>							-- Stop bit
								if PS2Error = '0' then
									DataByte <= Byte;
									DReady <= '1';
								else
									DReady <= '0';
								end if;
								State <= WaitRiseClock;
							when others => null;
						end case;
						BitsRead <= BitsRead + 1;
					end if;
				when InhibitComunication =>
					PS2Clock_Z <= '0';
					PS2ClockOut <= '0';
					if TimeCounter = Time100us then
						TimeCounter <= 0;
						State <= RequestToSend;
					else
						TimeCounter <= TimeCounter + 1;
					end if;
				when RequestToSend =>
					PS2Clock_Z <= '1';
					PS2Data_Z <= '0';
					PS2DataOut <= '0'; -- Sets the start bit, valid when PS2Clock is high
					if TimeCounter = Time20us then
						TimeCounter <= 0;
						PS2ClockOut <= '1';
						BitsSent <= 1;
						State <= SendData;
					else
						TimeCounter <= TimeCounter + 1;
					end if;
				when SendData =>
					PS2Clock_Z <= '1';
					if PS2ClockPrevious = '1' and PS2Clock_D = '0' then -- falling edge
						case BitsSent is
							when 1 to 8 =>						-- 8 Data bits
								if Byte(BitsSent - 1) = '0' then
									PS2DataOut <= '0';
								else
									CountOnes <= not CountOnes;
									PS2DataOut <= '1';
								end if;
							when 9 =>							-- Parity bit
								if CountOnes = '0' then
									PS2DataOut <= '1';
								else
									PS2DataOut <= '0';
								end if;
							when 10 =>							-- Stop bit
								PS2DataOut <= '1';
								State <= CheckAck;
							when others => null;
						end case;
						BitsSent <= BitsSent + 1;
					end if;
				when CheckAck =>
					PS2Data_Z <= '1';
					if PS2ClockPrevious = '1' and PS2Clock_D = '0' then
						if PS2Data_D = '1' then -- no Acknowledge received
							PS2Error <= '1';
						end if;
						State <= WaitRiseClock;
					end if;
				when WaitRiseClock =>
					if PS2ClockPrevious = '0' and PS2Clock_D = '1' then
						PS2Busy <= '0';
						DataReady <= DReady;
						State <= Idle;
					end if;
				when others => null;
			end case;
		end if;
	end process;

end Behavioral;