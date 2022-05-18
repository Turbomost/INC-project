-- uart.vhd: UART controller - receiving part
-- Author(s): xvalen29
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
-------------------------------------------------
ENTITY UART_RX IS
	PORT (
		CLK : IN STD_LOGIC;
		RST : IN STD_LOGIC;
		DIN : IN STD_LOGIC;
		DOUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		DOUT_VLD : OUT STD_LOGIC

	);
END UART_RX;
-------------------------------------------------
------         MB_COUNTER                 -------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY MB_COUNTER_E IS
	PORT (
		CLK : IN STD_LOGIC;
		RST : IN STD_LOGIC;
		CNT_EN : IN STD_LOGIC;
		CNT_RST : IN STD_LOGIC;
		CNT_OUT : OUT STD_LOGIC_VECTOR (4 DOWNTO 0) := "00000"
	);
END MB_COUNTER_E;

ARCHITECTURE behavioral OF MB_COUNTER_E IS
	SIGNAL cnt_out_signal : STD_LOGIC_VECTOR (4 DOWNTO 0);
BEGIN
	bit16_counter : PROCESS (CLK, RST, CNT_EN, CNT_RST)
	BEGIN
		IF RST = '1' THEN
			cnt_out_signal <= "00000";
		ELSIF rising_edge(CLK) THEN
			IF CNT_RST = '1' THEN
				cnt_out_signal <= "00000";
			ELSIF CNT_EN = '1' THEN
				cnt_out_signal <= cnt_out_signal + 1;
			END IF;
		END IF;
	END PROCESS;
	CNT_OUT <= cnt_out_signal;
END behavioral;

-------------------------------------------------
------           START_COUNTER            -------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY START_COUNTER_E IS
	PORT (
		CLK : IN STD_LOGIC;
		RST : IN STD_LOGIC;
		CNT_EN : IN STD_LOGIC;
		CNT_RST : IN STD_LOGIC;
		CNT_OUT : OUT STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000"
	);
END START_COUNTER_E;

ARCHITECTURE behavioral OF START_COUNTER_E IS
	SIGNAL cnt_out_signal : STD_LOGIC_VECTOR (3 DOWNTO 0);
BEGIN
	bit8_counter : PROCESS (CLK, RST, CNT_EN, CNT_RST)
	BEGIN
		IF RST = '1' THEN
			cnt_out_signal <= "0000";
		ELSIF rising_edge(CLK) THEN
			IF CNT_RST = '1' THEN
				cnt_out_signal <= "0000";
			ELSIF CNT_EN = '1' THEN
				cnt_out_signal <= cnt_out_signal + 1;
			END IF;
		END IF;
	END PROCESS;
	CNT_OUT <= cnt_out_signal;
END behavioral;

-------------------------------------------------
------           LB_COUNTER               -------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY LB_COUNTER_E IS
	PORT (
		CLK : IN STD_LOGIC;
		RST : IN STD_LOGIC;
		CNT_EN : IN STD_LOGIC;
		CNT_RST : IN STD_LOGIC;
		CNT_OUT : OUT STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000"
	);
END LB_COUNTER_E;

ARCHITECTURE behavioral OF LB_COUNTER_E IS
	SIGNAL cnt_out_signal : STD_LOGIC_VECTOR (3 DOWNTO 0);
BEGIN
	bit8_counter : PROCESS (CLK, RST, CNT_EN, CNT_RST)
	BEGIN
		IF RST = '1' THEN
			cnt_out_signal <= "0000";
		ELSIF rising_edge(CLK) THEN
			IF CNT_RST = '1' THEN
				cnt_out_signal <= "0000";
			ELSIF CNT_EN = '1' THEN
				cnt_out_signal <= cnt_out_signal + 1;
			END IF;
		END IF;
	END PROCESS;
	CNT_OUT <= cnt_out_signal;
END behavioral;

-------------------------------------------------
------           DMX               -------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY DEMULTIPLEX_E IS
	PORT (
		CLK : IN STD_LOGIC;
		RST : IN STD_LOGIC;
		READ_DATA : IN STD_LOGIC;
		CNT_IN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		DOUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		DIN : IN STD_LOGIC
	);
END DEMULTIPLEX_E;

ARCHITECTURE behavioral OF DEMULTIPLEX_E IS
	SIGNAL dout_signal : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
	demultiplex : PROCESS (CLK, RST, READ_DATA, CNT_IN, DIN)
	BEGIN
		IF READ_DATA = '1' THEN
			CASE CNT_IN IS
				WHEN "0000" => dout_signal(0) <= DIN;
				WHEN "0001" => dout_signal(1) <= DIN;
				WHEN "0010" => dout_signal(2) <= DIN;
				WHEN "0011" => dout_signal(3) <= DIN;
				WHEN "0100" => dout_signal(4) <= DIN;
				WHEN "0101" => dout_signal(5) <= DIN;
				WHEN "0110" => dout_signal(6) <= DIN;
				WHEN "0111" => dout_signal(7) <= DIN;
				WHEN OTHERS => NULL;
			END CASE;
		END IF;
	END PROCESS demultiplex;
	DOUT <= dout_signal;
END behavioral;

-------------------------------------------------
ARCHITECTURE behavioral OF UART_RX IS

	SIGNAL mb_counter : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000";
	SIGNAL lb_counter : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
	SIGNAL start_counter : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
	SIGNAL data_out : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";

	SIGNAL read_data : STD_LOGIC := '0';

	SIGNAL start_counter_en : STD_LOGIC := '0';
	SIGNAL start_counter_rst : STD_LOGIC := '0';

	SIGNAL mb_counter_en : STD_LOGIC := '0';
	SIGNAL mb_counter_rst : STD_LOGIC := '0';

	SIGNAL lb_counter_en : STD_LOGIC := '0';
	SIGNAL lb_counter_rst : STD_LOGIC := '0';

	SIGNAL dout_vld_signal : STD_LOGIC := '0';

BEGIN

	UART_FSM : ENTITY work.UART_FSM(behavioral)
		PORT MAP(
			CLK => CLK,
			RST => RST,
			DIN => DIN,
			DOUT_VLD => dout_vld_signal,
			READ_DATA => read_data,
			START_COUNTER => start_counter,
			START_COUNTER_EN => start_counter_en,
			START_COUNTER_RST => start_counter_rst,
			MB_COUNTER => mb_counter,
			MB_COUNTER_EN => mb_counter_en,
			MB_COUNTER_RST => mb_counter_rst,
			LB_COUNTER => lb_counter,
			LB_COUNTER_EN => lb_counter_en,
			LB_COUNTER_RST => lb_counter_rst
		);

	MB_COUNTER_E : ENTITY work.MB_COUNTER_E(behavioral)
		PORT MAP(
			CLK => CLK,
			RST => RST,
			CNT_EN => mb_counter_en,
			CNT_RST => mb_counter_rst,
			CNT_OUT => mb_counter
		);

	START_COUNTER_E : ENTITY work.START_COUNTER_E(behavioral)
		PORT MAP(
			CLK => CLK,
			RST => RST,
			CNT_EN => start_counter_en,
			CNT_RST => start_counter_rst,
			CNT_OUT => start_counter
		);

	LB_COUNTER_E : ENTITY work.LB_COUNTER_E(behavioral)
		PORT MAP(
			CLK => CLK,
			RST => RST,
			CNT_EN => lb_counter_en,
			CNT_RST => lb_counter_rst,
			CNT_OUT => lb_counter
		);

	DEMULTIPLEX_E : ENTITY work.DEMULTIPLEX_E(behavioral)
		PORT MAP(
			CLK => CLK,
			RST => RST,
			READ_DATA => read_data,
			DOUT => data_out,
			CNT_IN => lb_counter,
			DIN => DIN
		);

	DOUT <= data_out;
	DOUT_VLD <= dout_vld_signal;

END behavioral;