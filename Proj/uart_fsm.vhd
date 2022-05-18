-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): xvalen29
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-------------------------------------------------
ENTITY UART_FSM IS
   PORT (
      CLK : IN STD_LOGIC;
      RST : IN STD_LOGIC;
      DIN : IN STD_LOGIC;
      START_COUNTER : IN STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
      MB_COUNTER : IN STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000";
      LB_COUNTER : IN STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";

      READ_DATA : OUT STD_LOGIC := '0';

      START_COUNTER_EN : OUT STD_LOGIC := '0';
      START_COUNTER_RST : OUT STD_LOGIC := '0';

      MB_COUNTER_EN : OUT STD_LOGIC := '0';
      MB_COUNTER_RST : OUT STD_LOGIC := '0';

      LB_COUNTER_EN : OUT STD_LOGIC := '0';
      LB_COUNTER_RST : OUT STD_LOGIC := '0';

      DOUT_VLD : OUT STD_LOGIC := '0'

   );
END ENTITY UART_FSM;

-------------------------------------------------
ARCHITECTURE behavioral OF UART_FSM IS
   TYPE FSM_STATE IS (IDLE, SHIFT, LISTENING, END_WAIT, DOUT);
   SIGNAL actual_state : FSM_STATE := IDLE;
   SIGNAL next_state : FSM_STATE := IDLE;
BEGIN

   actual_state_process : PROCESS (RST, CLK, next_state)
   BEGIN
      IF RST = '1' THEN
         actual_state <= IDLE;
      ELSIF rising_edge(CLK) THEN
         actual_state <= next_state;
      END IF;
   END PROCESS actual_state_process;

   next_state_process : PROCESS (RST, CLK)
   BEGIN
      CASE actual_state IS
         WHEN IDLE =>
         DOUT_VLD <= '0';
         START_COUNTER_EN <= '0';
         LB_COUNTER_EN <= '0';
         MB_COUNTER_EN <= '0';
         IF DIN = '0' THEN
               START_COUNTER_RST <= '1';
               MB_COUNTER_RST <= '1';
               LB_COUNTER_RST <= '1';
               next_state <= SHIFT;
            END IF;

         WHEN SHIFT =>
            START_COUNTER_RST <= '0';
            START_COUNTER_EN <= '1';
            LB_COUNTER_EN <= '0';
            MB_COUNTER_EN <= '0';
            IF START_COUNTER = "0111" THEN
               next_state <= LISTENING;
            END IF;

         WHEN LISTENING =>
            START_COUNTER_EN <= '0';
            LB_COUNTER_RST <= '0';
            LB_COUNTER_EN <= '0';
            MB_COUNTER_RST <= '0';
            MB_COUNTER_EN <= '1';
            READ_DATA <= '0';      
            IF MB_COUNTER = "10000" THEN
               MB_COUNTER_RST <= '1';
               LB_COUNTER_EN <= '1';
               READ_DATA <= '1';
            END IF;

            IF LB_COUNTER = "0111" THEN
               next_state <= END_WAIT;
            END IF;
         WHEN END_WAIT =>
            LB_COUNTER_EN <= '0';
            MB_COUNTER_EN <= '0';
            IF DIN = '1' THEN
               next_state <= DOUT;
            END IF;

         WHEN DOUT =>
            DOUT_VLD <= '1';
            next_state <= IDLE;

         WHEN OTHERS => NULL;
      END CASE;
   END PROCESS next_state_process;
END behavioral;