----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.02.2022 19:48:30
-- Design Name: 
-- Module Name: tb_kernel3x3 - Behavioral
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
library work;
use work.types.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use STD.textio.all;
use ieee.std_logic_textio.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_kernel3x3 is
--  Port ( );
end tb_kernel3x3;

architecture rtl of tb_kernel3x3 is
    signal clk : std_logic := '1'; --'0'
    signal rst : std_logic := '1'; --'1'
    
    constant clk_period : time := 8ns;
    constant reset_time : time := 6 * clk_period;
    constant frame_time : time := 49 * clk_period;
    
    constant PIXEL_SIZE : natural :=8;
    constant MAXWBITS   : integer :=12;
    shared variable H   : natural := 3;
    shared variable W   : natural := 3;
    constant KS         : natural := 3;
    constant C          : natural := 3;
    
    constant file_path_c    :   string := "image_2.ppm";
    constant file_path_o    :   string := "conv2dop.ppm";
    file    input_file, output_file : text;
    signal  hsize_s, vsize_s : integer;
    
--    constant i_img : pixel_array(0 to 79) := (
--		x"01", x"02", x"03", x"04", x"05", x"06", x"07", x"08", x"09", x"0A",
--		x"01", x"02", x"03", x"04", x"05", x"06", x"07", x"08", x"09", x"0A",
--		x"01", x"02", x"03", x"04", x"05", x"06", x"07", x"08", x"09", x"0A",
--		x"01", x"02", x"03", x"04", x"05", x"06", x"07", x"08", x"09", x"0A",
--		x"01", x"02", x"03", x"04", x"05", x"06", x"07", x"08", x"09", x"0A",
--		x"01", x"02", x"03", x"04", x"05", x"06", x"07", x"08", x"09", x"0A",
--		x"01", x"02", x"03", x"04", x"05", x"06", x"07", x"08", x"09", x"0A",
--		x"01", x"02", x"03", x"04", x"05", x"06", x"07", x"08", x"09", x"0A"
--	);
	
	-- edge mask
	-- constant mask : mask3 := (
	-- 	-1, -1, -1,
	-- 	-1,  8, -1,
	-- 	-1, -1, -1
	-- );

	-- sharpen mask
--	 constant mask : mask3 := (
--	 	 0, -1,  0,
--	 	-1,  5, -1,
--	 	 0, -1,  0
--	 );
	
	--identity mask
	constant mask : mask3 := (
	      0, 0, 0,
	      0, 1, 0,
	      0, 0, 0
    );
    
    type packed_pixel is array(natural range <>) of pixel; 
    signal i_pix, o_pix : packed_pixel(0 to C-1) := (others => (others => '0'));
    signal i_active : std_logic := '0';
    signal i_hcounter :unsigned(MAXWBITS -1 downto 0) := (1=> '1',others => '0') ;
    
    
    
begin
    convrgb: for i in 0 to C-1 generate
    uut: entity work.formatter
          generic map(H=>H,W=>W,KS=>KS)
          port map(clk=>clk, reset=>rst, i_hcounter=>i_hcounter, i_active=>i_active, i_pix=>i_pix(i),
          i_mask=>mask, o_pix=>o_pix(i));
    end generate;
          
    --clock generate
    process
    begin
        --for i in 0 to 2*frame_time /clk_period loop
        wait for clk_period/2;
        clk <= not clk;
        --end loop;
        --wait;
    end process;

    process
    variable fopen_status_v,fopen_status_o : FILE_OPEN_STATUS;
    variable line_in_v          : line;
    variable line_out_v         : line;
    variable magic_number_v     : string(1 to 2);
    variable picture_hsize_v    : integer;
    variable picture_vsize_v    : integer;
    variable red_v              : natural;
    variable green_v            : natural;
    variable blue_v             : natural;
    variable max_encod_value_v  : integer;
    variable pixel_number_v,pixel_written : integer := 0;
    variable space_v            : character;

    
    begin
        
        FILE_OPEN(fopen_status_v,input_file, file_path_c,READ_MODE);
        
        if fopen_status_v = OPEN_OK then
            report "File opened in read only mode";
        else
            report "Error while opening the file" severity error;
        end if;
        
        FILE_OPEN(fopen_status_o,output_file,file_path_o,WRITE_MODE);
        
        if fopen_status_o = OPEN_OK then
            report "File opened in write only mode";
        else
            report "Error while opeing the file" severity error;
        end if;
        
        -- Check if file type is P3 (ASCII PPM)
        readline(input_file, line_in_v);
        read(line_in_v,magic_number_v);
        if magic_number_v = "P3" then
            report "File type is P3";
            write(line_out_v,magic_number_v);
            writeline(output_file,line_out_v);
        else
            report "File type not supported" severity error;
        end if;
  
        readline(input_file, line_in_v);
        -- Read the width
        read(line_in_v,picture_hsize_v);
        -- Print the width in the console
        write(line_out_v,picture_hsize_v);
        
        report "width: "&integer'image(picture_hsize_v);
        hsize_s <= picture_hsize_v;
        W := picture_hsize_v;
        -- Read the space character
        read(line_in_v,space_v);
        write(line_out_v,space_v);
        -- Read the height
        read(line_in_v,picture_vsize_v);
        write(line_out_v,picture_vsize_v);
        -- Print the height in the console
        report "height: "&integer'image(picture_vsize_v);
        vsize_s <= picture_vsize_v;  
        H := picture_vsize_v; 
        writeline(output_file, line_out_v);
  
        -- Get max encoding value and print it in the console
        readline(input_file, line_in_v);
        read(line_in_v,max_encod_value_v);
        report "Max encoding value: "&integer'image(max_encod_value_v);
        
        write(line_out_v,max_encod_value_v);
        writeline(output_file,line_out_v);

        i_active <= '0';
        rst <= '1';
        wait for reset_time;
        rst <= '0';
        i_active <= '1';
        
        while not endfile(input_file) and pixel_written <= H*W*C loop
        
            -- read red component
            readline(input_file, line_in_v);
            read(line_in_v,red_v);
        
            --set i_pix(0)
            i_pix(0)<=to_unsigned(red_v,PIXEL_SIZE);
            
            
            readline(input_file, line_in_v);
            read(line_in_v,green_v);
        
            --set i_pix(1)
            i_pix(1)<=to_unsigned(green_v,PIXEL_SIZE);       
            
            
            -- Read Blue component
            readline(input_file, line_in_v);
            read(line_in_v,blue_v);
        
            --set i_pix(2)
            i_pix(2) <= to_unsigned(blue_v,PIXEL_SIZE);
            
            wait for clk_period;
            
            --o_pix(0),o_pix(1),o_pix(2) in order to output file
            write(line_out_v,to_integer(o_pix(0)));
            writeline(output_file,line_out_v);
            
            write(line_out_v,to_integer(o_pix(1)));
            writeline(output_file,line_out_v);
            
            write(line_out_v,to_integer(o_pix(2)));
            writeline(output_file,line_out_v);
            
            pixel_written := pixel_written + 3;
            
            -- Diplay Pixel Value
            report "Pixel #"&integer'image(pixel_number_v)&" : red value: "&integer'image(red_v)&
            ", green value: "&integer'image(green_v)&", blue value: "&integer'image(blue_v);
        
            pixel_number_v := pixel_number_v + 1;
            
        end loop;    
--        for i in i_img'range loop
--            i_pix <= i_img(i);
--            wait for clk_period;
--        end loop;
--        i_active <= '0';
        FILE_CLOSE(output_file);
        FILE_CLOSE(input_file);
        wait;
    end process;
end rtl;
