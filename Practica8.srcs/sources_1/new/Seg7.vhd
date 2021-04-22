----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/11/2020 07:32:14 PM
-- Design Name: 
-- Module Name: segm7 - Behavioral
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


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
----use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx leaf cells in this code.
----library UNISIM;
----use UNISIM.VComponents.all;

--entity segm7 is
--Port(
--        Clk: in std_logic;
--        N1, N2: in std_logic_vector(3 downto 0);
--        S81, S82: out std_logic_vector(7 downto 0)
--);
--end segm7;

--architecture Behavioral of segm7 is

--begin
--Process(Clk)
--begin
---- pasa valor de 4 bits a su equivalente para display de 7 segmentos
--case (n2) is
--                    when "0000" => S82 <= "11000000";
--                    when "0001" => S82 <= "11111001";
--                    when "0010" => S82 <= "10100100";
--                    when "0011" => S82 <= "10110000";
--                    when "0100" => S82 <= "10011001";
--                    when "0101" => S82 <= "10010010";
--                    when "0110" => S82 <= "10000010";
--                    when "0111" => S82 <= "11111000";
--                    when "1000" => S82 <= "10000000";
--                    when "1001" => S82 <= "10010000";
--                    when others => S82 <= "11111111";
--                    end case;

--case (n1) is
--                    when "0000" => S81 <= "11000000";
--                    when "0001" => S81 <= "11111001";
--                    when "0010" => S81 <= "10100100";
--                    when "0011" => S81 <= "10110000";
--                    when "0100" => S81 <= "10011001";
--                    when "0101" => S81 <= "10010010";
--                    when "0110" => S81 <= "10000010";
--                    when "0111" => S81 <= "11111000";
--                    when "1000" => S81 <= "10000000";
--                    when "1001" => S81 <= "10010000";
--                    when others => S81 <= "11111111";
--                    end case;

--end process;
--end Behavioral;

----------------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Author:  Mircea Dabacan
--          Copyright 2014 Digilent, Inc.
----------------------------------------------------------------------------
-- 
-- Create Date:    13:13:49 12/16/2010 
-- Design Name: 
-- Module Name:    sSegDisplay - Behavioral 
-- Description: 
--    This module represents the seven-segment display multiplexer
--    Because the pattern to be displayed does not contain numerical or
--    alphabetical characters representable on a seven-segment display,
--    the incoming data is NOT encoded to seven-segment code, 
--    instead the incoming data is sent directly to the cathodes, 
--    according to the diagram shown below
-- Segment encoding
--      0
--     ---  
--  5 |   | 1
--     ---   <- 6
--  4 |   | 2
--     ---
--      3
--  Decimal Point = 7
--
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;	-- add to do arithmetic operations
use IEEE.std_logic_arith.all;		-- add to do arithmetic operations

entity Seg7 is
    Port(ck : in  std_logic;                          -- 100MHz system clock
			number : in  std_logic_vector (63 downto 0); -- eight digit number to be displayed
			seg : out  std_logic_vector (7 downto 0);    -- display cathodes
			an : out  std_logic_vector (7 downto 0));    -- display anodes (active-low, due to transistor complementing)
end Seg7;

architecture Behavioral of Seg7 is

	signal cnt: std_logic_vector(19 downto 0); -- divider counter for ~95.3Hz refresh rate (with 100MHz main clock)
	signal hex: std_logic_vector(7 downto 0);  -- hexadecimal digit
	signal intAn: std_logic_vector(7 downto 0); -- internal signal representing anode data

begin

   -- Assign outputs
   an <= intAn;
   seg <= hex;

   clockDivider: process(ck)
   begin
      if ck'event and ck = '1' then
         cnt <= cnt + '1';
      end if;
   end process clockDivider;

   -- Anode Select
   with cnt(19 downto 17) select -- 100MHz/2^20 = 95.3Hz
      intAn <=    
         "11111110" when "000",
         "11111101" when "001",
         "11111011" when "010",
         "11110111" when "011",
         "11101111" when "100",
         "11011111" when "101",
         "10111111" when "110",
         "01111111" when others;

   -- Digit Select
   with cnt(19 downto 17) select -- 100MHz/2^20 = 95.3Hz
      hex <=      
         number(7 downto 0)   when "000",
         number(15 downto 8)  when "001",
         number(23 downto 16) when "010",
         number(31 downto 24) when "011",
         number(39 downto 32) when "100",
         number(47 downto 40) when "101",
         number(55 downto 48) when "110",
         number(63 downto 56) when others;

end Behavioral;
