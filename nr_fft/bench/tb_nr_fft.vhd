----------------------------------------------------------------------------------
--  Engineer:       Devin
--  Email:          balddevin@outlook.com
--  Description:    
--  Parameters:
--  Additional:     
--  Revision:
--    Revision 0.01 - File Created
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;
use std.textio.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_nr_fft is
--  Port ( );
end tb_nr_fft;

architecture Behavioral of tb_nr_fft is

component nr_fft is
  Port ( 
    i_clk       : in  std_logic;
    i_rst       : in  std_logic;
    i_start     : in  std_logic;
    i_en        : in  std_logic;
    iv_din1     : in  std_logic_vector(31 downto 0);
    iv_din2     : in  std_logic_vector(31 downto 0);
    iv_din3     : in  std_logic_vector(31 downto 0);
    iv_din4     : in  std_logic_vector(31 downto 0);
    ov_dout1    : out std_logic_vector(31 downto 0);
    ov_dout2    : out std_logic_vector(31 downto 0);
    ov_dout3    : out std_logic_vector(31 downto 0);
    ov_dout4    : out std_logic_vector(31 downto 0);
    ov_blk_exp  : out std_logic_vector(3 downto 0);
    o_start     : out std_logic;
    o_valid     : out std_logic
  );
end component;

file fin_vector : text open read_mode is
    "C:\Users\Devin\Documents\workspace\fpga\nr_fft\nr_fft.srcs\sources_1\tb\tb_din.dat";
file fout_vector : text open write_mode is
    "C:\Users\Devin\Documents\workspace\fpga\nr_fft\nr_fft.srcs\sources_1\tb\tb_dout.dat";

constant clk_period : time := 10 ns;
signal clk  : std_logic:='0';
signal rst  : std_logic:='0';
signal in_start : std_logic;
signal in_en    : std_logic;
signal din1     : std_logic_vector(31 downto 0);
signal din2     : std_logic_vector(31 downto 0);
signal din3     : std_logic_vector(31 downto 0);
signal din4     : std_logic_vector(31 downto 0);
signal dout1    : std_logic_vector(31 downto 0);
signal dout2    : std_logic_vector(31 downto 0);
signal dout3    : std_logic_vector(31 downto 0);
signal dout4    : std_logic_vector(31 downto 0);
signal out_blk_exp  : std_logic_vector(3 downto 0);
signal out_start    : std_logic;
signal out_vld      : std_logic;

begin

input_proc: process(clk,rst)
variable v_finline  : line;
variable v_start    : std_logic;
variable v_en       : std_logic;
variable v_din1i    : integer;
variable v_din1r    : integer;
variable v_din2i    : integer;
variable v_din2r    : integer;
variable v_din3i    : integer;
variable v_din3r    : integer;
variable v_din4i    : integer;
variable v_din4r    : integer;

begin
    if(clk'event and clk='1') then
        if(rst='1') then
            in_start    <=  '0';
            in_en       <=  '0';
            din1        <=  (others=>'0');
            din2        <=  (others=>'0');
            din3        <=  (others=>'0');
            din4        <=  (others=>'0');
        else
            if(not endfile(fin_vector)) then
                readline(fin_vector,v_finline);
                read(v_finline,v_start);
                read(v_finline,v_en);
                read(v_finline,v_din1i);
                read(v_finline,v_din1r);
                read(v_finline,v_din2i);
                read(v_finline,v_din2r);
                read(v_finline,v_din3i);
                read(v_finline,v_din3r);
                read(v_finline,v_din4i);
                read(v_finline,v_din4r);
                in_start    <=  v_start;
                in_en       <=  v_en;
                din1        <=  conv_std_logic_vector(v_din1i,16) & conv_std_logic_vector(v_din1r,16);
                din2        <=  conv_std_logic_vector(v_din2i,16) & conv_std_logic_vector(v_din2r,16);
                din3        <=  conv_std_logic_vector(v_din3i,16) & conv_std_logic_vector(v_din3r,16);
                din4        <=  conv_std_logic_vector(v_din4i,16) & conv_std_logic_vector(v_din4r,16);
            else
                in_start    <=  '0';
                in_en       <=  '0';
                din1        <=  (others=>'0');
                din2        <=  (others=>'0');
                din3        <=  (others=>'0');
                din4        <=  (others=>'0');
            end if;
        end if;
    end if;
end process;

output_proc: process(clk,rst)
variable v_foutline : line;
variable v_dout1i,v_dout1r  : integer;
variable v_dout2i,v_dout2r  : integer;
variable v_dout3i,v_dout3r  : integer;
variable v_dout4i,v_dout4r  : integer;
begin
    if(clk'event and clk='1') then
        if(rst='1') then

        else
            if(out_vld='1') then
                v_dout1i    :=  conv_integer(dout1(31 downto 16));
                v_dout1r    :=  conv_integer(dout1(15 downto 0));
                v_dout2i    :=  conv_integer(dout2(31 downto 16));
                v_dout2r    :=  conv_integer(dout2(15 downto 0));
                v_dout3i    :=  conv_integer(dout3(31 downto 16));
                v_dout3r    :=  conv_integer(dout3(15 downto 0));
                v_dout4i    :=  conv_integer(dout4(31 downto 16));
                v_dout4r    :=  conv_integer(dout4(15 downto 0));
                
                write(v_foutline,v_dout1i); write(v_foutline,HT);
                write(v_foutline,v_dout1r);
                writeline(fout_vector,v_foutline);
                write(v_foutline,v_dout2i); write(v_foutline,HT);
                write(v_foutline,v_dout2r);
                writeline(fout_vector,v_foutline);
                write(v_foutline,v_dout3i); write(v_foutline,HT);
                write(v_foutline,v_dout3r);
                writeline(fout_vector,v_foutline);
                write(v_foutline,v_dout4i); write(v_foutline,HT);
                write(v_foutline,v_dout4r);
                writeline(fout_vector,v_foutline);
                
            end if;
        end if;
    end if;
end process;


clk_proc: process
begin
    wait for clk_period/2;
    clk <=  not clk;
end process;

rst <=  '1' after 5 ns,
        '0' after 105 ns;

tb_nr_fft: nr_fft
  Port map( 
    i_clk       =>  clk,
    i_rst       =>  rst,
    i_start     =>  in_start,
    i_en        =>  in_en,
    iv_din1     =>  din1,
    iv_din2     =>  din2,
    iv_din3     =>  din3,
    iv_din4     =>  din4,
    ov_dout1    =>  dout1,
    ov_dout2    =>  dout2,
    ov_dout3    =>  dout3,
    ov_dout4    =>  dout4,
    ov_blk_exp  =>  out_blk_exp,
    o_start     =>  out_start,
    o_valid     =>  out_vld
  );

end Behavioral;
