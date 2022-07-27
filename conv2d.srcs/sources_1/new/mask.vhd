----------------------------------------------------------------------------------
-- Company: HTIC-IITM
-- Engineer: Gokula Krishnan Ravi
-- 
-- Create Date: 10.02.2022 19:17:30
-- Design Name: 
-- Module Name: mask - rtl
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
use work.types.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mask is
    generic(
        KS : integer := 3
    );
    Port ( 
        i_ctrl : in std_logic_vector(2 downto 0);
        o_mask: out mask_array(0 to KS**2-1) 
    );
end mask;

architecture rtl of mask is

    --identity mask
    constant identity5 : mask5 := (
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0
    );
    
    --laplacian mask
    constant laplacian5 : mask5 := (
        0,  0, -1,  0,  0,
        0, -1, -2, -1,  0,
       -1, -2, 16, -2, -1,
        0, -1, -2, -1,  0,
        0,  0, -1,  0,  0
    );
    
    --identity mask
    constant identity3 : mask3 := (
        0, 0, 0,
        0, 1, 0,
        0, 0, 0
    );
    
    --edge mask
    constant edge3 : mask3 := (
        0, -1,  0,
       -1,  5, -1,
        0, -1,  0
    );
    
    --sharpen mask
    constant sharpen3 : mask3 := (
        0, -1,  0,
       -1,  5, -1,
        0, -1,  0 
    );
    
begin
    
    m3_gen: if (KS = 3) generate
    begin
    o_mask <= identity3 when i_ctrl = "000" else
               edge3 when i_ctrl = "001" else
               sharpen3;
    end generate;
    
    m5_gen: if (KS = 5) generate
    begin
    o_mask <= identity5 when i_ctrl = "000" else
              laplacian5;
    end generate;

end rtl;
