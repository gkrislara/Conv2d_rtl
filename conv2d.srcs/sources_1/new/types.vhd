----------------------------------------------------------------------------------
-- Company: HTIC-IITM
-- Engineer: Gokula Krishnan Ravi
-- 
-- Create Date: 10.02.2022 10:41:52
-- Design Name: Conv2d
-- Module Name: types - Behavioral
-- Project Name: Conv2d
-- Target Devices:  ZU+ zczu7ev-fbvb900-1-e
-- Tool Versions: 2019.2
-- Description: types for data movement 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package types is
    
    -- 8-bit pixel type
    subtype pixel is unsigned(7 downto 0);
    type pixel_array is array(natural range <>) of pixel;
    
    --8-bit mask type
    subtype mask is integer range -128 to 127;
    type mask_array is array(natural range <>) of mask;
    
    -- 3x3 mask
    subtype mask3 is mask_array(0 to 8);
    
    -- 5x5 mask
    subtype mask5 is mask_array(0 to 24);

end types;