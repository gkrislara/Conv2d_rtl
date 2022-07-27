----------------------------------------------------------------------------------
-- Company: HTIC-IITM
-- Engineer: Gokula Krishnan Ravi
-- 
-- Create Date: 10.02.2022 12:51:25
-- Design Name: Conv2d
-- Module Name: formatter - Behavioral
-- Project Name: Conv2d
-- Target Devices: ZU+ zczu7ev-fbvb900-1-e 
-- Tool Versions: 2019.2
-- Description: module that formats incoming pixel data into window and passes to conv module  
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
use work.types.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity formatter is
    generic(
        PIXSIZE : integer := 8; --pixelsize
        MAXWBITS : integer := 12; --max bits for width
        H : integer := 720;
        W : integer := 1280;
        KS: integer := 3
    );
    Port (
        clk        : in std_logic;
        reset      : in std_logic;
        i_hcounter : in unsigned (MAXWBITS - 1 downto 0);
        i_active   : in std_logic;
        i_pix      :in pixel;
        i_mask     : in mask_array(0 to KS**2-1);
        o_pix      : out pixel 
    );
end formatter;
architecture rtl of formatter is
    
    signal rows : pixel_array(0 to ((KS -1) * W) + KS-1) := (others => (others => '0'));
    
    signal window : pixel_array(0 to KS**2-1) := (others => (others => '0'));
    
    signal mask : mask_array(0 to KS**2-1) := (others => 0);
    
    signal validrow,enable :std_logic := '0';
    
begin
    --line buffer mechanism / shift register
    process(clk,reset) is
    begin 
        if (reset = '1') then rows <= (others => (others => '0'));
        elsif rising_edge(clk) then  -- or use  clk'event and clk'last_value = '0' and clk = '1'
            if i_active = '1' then 
                rows <= rows(1 to rows'high) & i_pix;
            end if;
        end if;
    end process;
    
    --Registered cascaded mux
    process(clk,reset) is
    begin
        if (reset = '1') then validrow <= '0';
        elsif rising_edge(clk) then
            if i_hcounter <= (KS-1)/2 then
                    validrow <= '0';
            elsif i_hcounter > H-(KS-1)/2 -1 then
                    validrow <= '0';
            else
                    validrow <= i_active;
            end if;
         end if;
     end process;
    
    enable <= validrow when rising_edge(clk); -- concurrent statement for DFF
    
    --mask register
    process(clk,reset) is
    begin
        if ( reset = '1') then mask <= (0, 0, 0,
                                        0, 1, 0,
                                        0, 0, 0
                                        );
        elsif rising_edge(clk) then
            mask <= i_mask;
        end if;
    end process;
    
    
    w_gen: for i in 0 to KS-1 generate
    begin
        window(i*KS to i*KS + KS-1) <= rows(i*W to i*W + KS-1); 
    end generate;
    
    --2d convolution
    
    c2d: entity work.conv2d(parallel_serial)
    generic map(PIXSIZE => PIXSIZE, KS => KS)
    port map (clk=>clk, reset=>reset, i_enable => enable, i_window => window, i_mask=>mask, o_pix=>o_pix);
    
    
end rtl;
