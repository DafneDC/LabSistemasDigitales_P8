----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.04.2021 14:40:01
-- Design Name: 
-- Module Name: pwm - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;

entity pwm is  
port (
    clk100m : in std_logic;
    btn_in  : in std_logic;
    pwm_out : out std_logic;
    D7A : out STD_LOGIC_VECTOR (7 downto 0);
    D71 : out STD_LOGIC_VECTOR (7 downto 0)
);
end pwm;

architecture Behavioral of pwm is

component Seg7 is
       Port(ck : in  std_logic;                          
			number : in  std_logic_vector (63 downto 0);
			seg : out  std_logic_vector (7 downto 0);
			an : out  std_logic_vector (7 downto 0));
end component;

component Dbncr is                             -- has to be stable until a one-shot output signal is generated
   port(
      clk_i : in std_logic;
      sig_i : in std_logic;
      pls_o : out std_logic
   );
end component;

subtype u20 is unsigned(19 downto 0);
signal counter      : u20 := x"00000";

constant clk_freq   : integer := 100_000_000;       -- Clock frequency in Hz (10 ns)
constant pwm_freq   : integer := 50;                -- PWM signal frequency in Hz (20 ms)
constant period     : integer := clk_freq/pwm_freq; -- Clock cycle count per PWM period
signal duty_cycle : integer := 50_000;            -- Clock cycle count per PWM duty cycle

signal pwm_counter  : std_logic := '0';
signal stateHigh    : std_logic := '1';

--component clock port (-- Clock in ports
--  -- Clock out ports
--  clk50m          : out    std_logic;
--  -- Status and control signals
--  reset             : in     std_logic;
--  locked            : out    std_logic;
--  clk_in1           : in     std_logic
-- );
--end component;
signal d7s : STD_LOGIC_VECTOR (63 downto 0) := (others => '1');
signal btn: std_logic;
begin

--clock_instance : clock port map ( 
--  -- Clock out ports  
--   clk50m => clk50m,
--  -- Status and control signals                
--   reset => reset,
--   locked => locked,
--   -- Clock in ports
--   clk_in1 => clk100m );
 
Segm7: Seg7 port map (ck=>clk100m , number=>d7s, seg=> D7A, an=>D71);
boton1: Dbncr port map (clk_i => clk100m, sig_i =>btn_in , pls_o =>btn);

pwm_generator : process(clk100m, btn_in) is
variable cur : u20 := counter;
begin       
         
    if((btn_in = '1' and btn_in'event)) then   
        if(duty_cycle /= 250_000) then
            duty_cycle <= duty_cycle + 50_000;
        else
            duty_cycle <= 50_000;
        end if;
    end if;
    
    if ((clk100m = '1' and clk100m'event) ) then
        cur := cur + 1;  
        counter <= cur;
        if (cur <= duty_cycle) then
            pwm_counter <= '1'; 
        elsif (cur > duty_cycle) then
            pwm_counter <= '0';
        elsif (cur = period) then
            cur := x"00000";
        end if;  
    end if;
    
    case (duty_cycle) is
        when 50_000 => 
            d7s(23 downto 16) <= "11111111";
            d7s(15 downto 8) <= "11111111";
            d7s(7 downto 0) <= "11000000"; -- 0           
        when 100_000 => 
            d7s(23 downto 16) <= "11111111";
            d7s(15 downto 8) <= "10011001"; -- 4
            d7s(7 downto 0) <= "10010010"; -- 5
        when 150_000 => 
            d7s(23 downto 16) <= "11111111";
            d7s(15 downto 8) <= "10010000"; -- 9
            d7s(7 downto 0) <= "11000000"; -- 0
        when 200_000 =>
            d7s(23 downto 16) <= "11111001"; --1
            d7s(15 downto 8) <= "10110000"; --3
            d7s(7 downto 0) <= "10010010"; -- 5
        when 250_000 =>
            d7s(23 downto 16) <= "11111001"; --1
            d7s(15 downto 8) <= "10000000"; --8
            d7s(7 downto 0) <= "11000000"; -- 0
        when others => 
            d7s(23 downto 16) <= "11111111";
            d7s(15 downto 8) <= "11111111";
            d7s(7 downto 0) <= "11111111";
        end case;
end process pwm_generator;
pwm_out <= pwm_counter;
end Behavioral;