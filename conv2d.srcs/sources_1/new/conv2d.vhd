----------------------------------------------------------------------------------
-- Company: HTIC-IITM
-- Engineer: Gokula Krishnan Ravi
-- 
-- Create Date: 10.02.2022 10:36:18
-- Design Name: Conv2d
-- Module Name: conv2d - Behavioral
-- Project Name: conv2d
-- Target Devices: ZU+ zczu7ev-fbvb900-1-e
-- Tool Versions: 2019.2
-- Description: Conv2d operation
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Ref: https://github.com/fcayci/vhdl-conv2d
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.types.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity conv2d is
    generic (
        PIXSIZE : integer := 8; -- pixel size
        KS : integer := 3 -- mask size
    );
    Port (
        clk      : in std_logic;
        reset    : in std_logic;
        -- control signals
        i_enable : in std_logic;
        
        --window /mask
        i_window : in pixel_array (0 to KS**2-1);
        i_mask   : in mask_array(0 to KS**2-1);
        
        --output pixel and valid signals
        o_pix    : out pixel 
    );
end conv2d;

architecture parallel_serial of conv2d is
        type pixel_extended is array(natural range <>) of signed(2*PIXSIZE-1 downto 0);
        signal x: pixel_extended (0 to KS**2-1) := (others => (others => '0'));
        --signal sumb : signed(2*PIXSIZE-1 downto 0) := (others => '0');
        --constant y : signed(2*PIXSIZE-1 downto 0) := b"1010101010101010";
begin   
        --parallel muls
        mul: for i in 0 to KS**2-1 generate
                x(i) <= to_signed(to_integer(i_window(i)) * i_mask(i), 2*PIXSIZE);
        end generate;
        
       --serial ckt --ref ricardo jasinki: loops
       process(clk,reset) is          
            variable sum : integer := 0; 
       begin 
           if (reset = '1') then sum:=0;--sumb<= (others => '0');
           elsif rising_edge(clk) then
               if i_enable = '1' then
                   for i in 0 to KS**2-1 loop
                       sum:= sum + to_integer(x(i));
                   end loop;
                   --sumb <= to_signed(sum,2*PIXSIZE);
                   if sum < 0 then
                        o_pix <= (others => '0');
                   elsif sum > 255 then
                        o_pix <= (others => '1');
                   else
                        o_pix <= to_unsigned(sum,PIXSIZE);
                   end if;     
               end if; -- implied latch is present
           else sum := 0;
           end if;
        end process; 

            
        --sumb <= x(0)+x(1)+x(2)+x(3)+x(4)+x(5)+x(6)+x(7)+x(8); -- works
--        o_pix <= (others => '0') when to_integer(sumb) < 0 else  -- check hw implementation ; used seq ckt in case the hw bloats up for(to_integer)
--                    (others => '1') when to_integer(sumb) > 255 else 
--                            unsigned(sumb(7 downto 0));
     
          --Fir kinda implementation ref: Ricardo Jasinki
--        process(clk,reset) is
--           variable sum: integer := 0;
--        begin
--            if (reset = '1') then x <= (others => (others => '0'));
--            elsif rising_edge(clk) then  -- or use clk'event and clk'last_value = '0' and clk = '1' ; compatible for synthesis and simulation
--               if i_enable = '1' then
--                    for n in 0 to KS**2-1 loop
----                        for k in 0 to KS-1 loop
--                            x(n) <= to_signed(to_integer(i_window(n)) * i_mask(n), 2*PIXSIZE); --n*KS+k
--                             -- parallel ckt Ref:Loops - Ricardo Jasinki 
--                        --end loop;
--                     end loop;
--                else
--                    for i in x'range loop
--                        x(i) <= (others => '0');
--                    end loop;
           
--                end if;
--            end if;
--         end process; 
end parallel_serial;
