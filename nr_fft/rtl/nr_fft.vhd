----------------------------------------------------------------------------------
--  Engineer:       Devin
--  Email:          balddevin@outlook.com
--  Description:    Perform 4-parallels FFT, which has the sampling rate 491.52MHz when working at 122.88MHz.
--                  The data proccessed is fixed point.
--  Parameters:
--  Additional:     
--  References:     Xie Y K, Fu B. Design and implementation of high throughput FFT processor[J]. Journal of Computer Research and Development, 2004, 41(6): 1022-1029.
--  Latency:        7295 cycles. (Required to be optimized)
--  Revision:
--    Revision 0.01 - File Created
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity nr_fft is
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
end nr_fft;

architecture Behavioral of nr_fft is

component fft_stage is
  Port ( 
    i_clk       : in  std_logic;
    i_rst       : in  std_logic;
    i_start     : in  std_logic;
    i_en        : in  std_logic;
    iv_stage    : in  std_logic_vector(2 downto 0); 
    iv_din1     : in  std_logic_vector(47 downto 0);
    iv_din2     : in  std_logic_vector(47 downto 0);
    iv_din3     : in  std_logic_vector(47 downto 0);
    iv_din4     : in  std_logic_vector(47 downto 0);
    iv_ovflo    : in  std_logic_vector(1 downto 0);
    iv_blk_exp  : in  std_logic_vector(3 downto 0);
    ov_dout1    : out std_logic_vector(47 downto 0);
    ov_dout2    : out std_logic_vector(47 downto 0);
    ov_dout3    : out std_logic_vector(47 downto 0);
    ov_dout4    : out std_logic_vector(47 downto 0);
    ov_ovflo    : out std_logic_vector(1 downto 0);
    ov_blk_exp  : out std_logic_vector(3 downto 0);
    o_start     : out std_logic;
    o_vld       : out std_logic
  );
end component;

component bit_rev is
  Port ( 
    i_clk       : in  std_logic;
    i_rst       : in  std_logic;
    i_start     : in  std_logic;
    i_en        : in  std_logic;
    iv_din1     : in  std_logic_vector(47 downto 0);
    iv_din2     : in  std_logic_vector(47 downto 0);
    iv_din3     : in  std_logic_vector(47 downto 0);
    iv_din4     : in  std_logic_vector(47 downto 0);
    iv_ovflo    : in  std_logic_vector(1 downto 0);
    iv_blk_exp  : in  std_logic_vector(3 downto 0);
    ov_dout1    : out std_logic_vector(31 downto 0);
    ov_dout2    : out std_logic_vector(31 downto 0);
    ov_dout3    : out std_logic_vector(31 downto 0);
    ov_dout4    : out std_logic_vector(31 downto 0);
    ov_blk_exp  : out std_logic_vector(3 downto 0);
    o_start     : out std_logic;
    o_vld       : out std_logic
  );
end component;

signal st0_start    : std_logic;
signal st1_start    : std_logic;
signal st2_start    : std_logic;
signal st3_start    : std_logic;
signal st4_start    : std_logic;
signal st5_start    : std_logic;
signal st0_en       : std_logic;
signal st1_en       : std_logic;
signal st2_en       : std_logic;
signal st3_en       : std_logic;
signal st4_en       : std_logic;
signal st5_en       : std_logic;
signal st0_din1     : std_logic_vector(47 downto 0);
signal st1_din1     : std_logic_vector(47 downto 0);
signal st2_din1     : std_logic_vector(47 downto 0);
signal st3_din1     : std_logic_vector(47 downto 0);
signal st4_din1     : std_logic_vector(47 downto 0);
signal st5_din1     : std_logic_vector(47 downto 0);
signal st0_din2     : std_logic_vector(47 downto 0);
signal st1_din2     : std_logic_vector(47 downto 0);
signal st2_din2     : std_logic_vector(47 downto 0);
signal st3_din2     : std_logic_vector(47 downto 0);
signal st4_din2     : std_logic_vector(47 downto 0);
signal st5_din2     : std_logic_vector(47 downto 0);
signal st0_din3     : std_logic_vector(47 downto 0);
signal st1_din3     : std_logic_vector(47 downto 0);
signal st2_din3     : std_logic_vector(47 downto 0);
signal st3_din3     : std_logic_vector(47 downto 0);
signal st4_din3     : std_logic_vector(47 downto 0);
signal st5_din3     : std_logic_vector(47 downto 0);
signal st0_din4     : std_logic_vector(47 downto 0);
signal st1_din4     : std_logic_vector(47 downto 0);
signal st2_din4     : std_logic_vector(47 downto 0);
signal st3_din4     : std_logic_vector(47 downto 0);
signal st4_din4     : std_logic_vector(47 downto 0);
signal st5_din4     : std_logic_vector(47 downto 0);
signal st1_ovflo    : std_logic_vector(1 downto 0);
signal st2_ovflo    : std_logic_vector(1 downto 0);
signal st3_ovflo    : std_logic_vector(1 downto 0);
signal st4_ovflo    : std_logic_vector(1 downto 0);
signal st5_ovflo    : std_logic_vector(1 downto 0);
signal st1_blk_exp  : std_logic_vector(3 downto 0);
signal st2_blk_exp  : std_logic_vector(3 downto 0);
signal st3_blk_exp  : std_logic_vector(3 downto 0);
signal st4_blk_exp  : std_logic_vector(3 downto 0);
signal st5_blk_exp  : std_logic_vector(3 downto 0);

------------------------------------------------------------------------
-- Bit reverse order.
signal rev_din1     : std_logic_vector(47 downto 0);
signal rev_din2     : std_logic_vector(47 downto 0);
signal rev_din3     : std_logic_vector(47 downto 0);
signal rev_din4     : std_logic_vector(47 downto 0);
signal rev_ovflo    : std_logic_vector(1 downto 0);
signal rev_blk_exp  : std_logic_vector(3 downto 0);
signal rev_start    : std_logic;
signal rev_en       : std_logic;
signal rev_valid    : std_logic;
signal rev_dout1    : std_logic_vector(31 downto 0);
signal rev_dout2    : std_logic_vector(31 downto 0);
signal rev_dout3    : std_logic_vector(31 downto 0);
signal rev_dout4    : std_logic_vector(31 downto 0);
signal rev_start_out    : std_logic;
signal rev_blk_exp_out  : std_logic_vector(3 downto 0);

begin

st0_din_proc: process(i_clk,i_rst)
begin
    if(i_clk'event and i_clk='1') then
        if(i_rst='1') then
            st0_start   <=  '0';
            st0_en      <=  '0';
            st0_din1    <=  (others=>'0');
            st0_din2    <=  (others=>'0');
            st0_din3    <=  (others=>'0');
            st0_din4    <=  (others=>'0');
        else
            st0_start   <=  i_start;
            st0_en      <=  i_en;
            st0_din1    <=  sxt(iv_din1(31 downto 16),18) & "000000" & sxt(iv_din1(15 downto 0),18) & "000000";
            st0_din2    <=  sxt(iv_din2(31 downto 16),18) & "000000" & sxt(iv_din2(15 downto 0),18) & "000000";
            st0_din3    <=  sxt(iv_din3(31 downto 16),18) & "000000" & sxt(iv_din3(15 downto 0),18) & "000000";
            st0_din4    <=  sxt(iv_din4(31 downto 16),18) & "000000" & sxt(iv_din4(15 downto 0),18) & "000000";
        end if;
    end if;
end process;

out_proc: process(i_clk,i_rst)
begin
    if(i_clk'event and i_clk='1') then
        if(i_rst='1') then
            ov_dout1    <=  (others=>'0');
            ov_dout2    <=  (others=>'0');
            ov_dout3    <=  (others=>'0');
            ov_dout4    <=  (others=>'0');
            ov_blk_exp  <=  (others=>'0');
            o_start     <=  '0';
            o_valid     <=  '0';
        else
            o_valid <=  rev_valid;
            if(rev_valid='1') then
                ov_dout1    <=  rev_dout1;
                ov_dout2    <=  rev_dout2;
                ov_dout3    <=  rev_dout3;
                ov_dout4    <=  rev_dout4;
                ov_blk_exp  <=  rev_blk_exp;
                o_start     <=  rev_start_out;
            else
                ov_dout1    <=  (others=>'0');
                ov_dout2    <=  (others=>'0');
                ov_dout3    <=  (others=>'0');
                ov_dout4    <=  (others=>'0');
                ov_blk_exp  <=  (others=>'0');
                o_start     <=  '0';
            end if;
        end if;
    end if;
end process;


st0_fft: fft_stage
  port map( 
    i_clk       =>  i_clk,
    i_rst       =>  i_rst,
    i_start     =>  st0_start,
    i_en        =>  st0_en,
    iv_stage    =>  "000",
    iv_din1     =>  st0_din1,
    iv_din2     =>  st0_din2,
    iv_din3     =>  st0_din3,
    iv_din4     =>  st0_din4,
    iv_ovflo    =>  "00",
    iv_blk_exp  =>  "0000",
    ov_dout1    =>  st1_din1,
    ov_dout2    =>  st1_din2,
    ov_dout3    =>  st1_din3,
    ov_dout4    =>  st1_din4,
    ov_ovflo    =>  st1_ovflo,
    ov_blk_exp  =>  st1_blk_exp,
    o_start     =>  st1_start,
    o_vld       =>  st1_en
  );

st1_fft: fft_stage
  port map( 
    i_clk       =>  i_clk,
    i_rst       =>  i_rst,
    i_start     =>  st1_start,
    i_en        =>  st1_en,
    iv_stage    =>  "001",
    iv_din1     =>  st1_din1,
    iv_din2     =>  st1_din2,
    iv_din3     =>  st1_din3,
    iv_din4     =>  st1_din4,
    iv_ovflo    =>  st1_ovflo,
    iv_blk_exp  =>  st1_blk_exp,
    ov_dout1    =>  st2_din1,
    ov_dout2    =>  st2_din2,
    ov_dout3    =>  st2_din3,
    ov_dout4    =>  st2_din4,
    ov_ovflo    =>  st2_ovflo,
    ov_blk_exp  =>  st2_blk_exp,
    o_start     =>  st2_start,
    o_vld       =>  st2_en
  );

st2_fft: fft_stage
  port map( 
    i_clk       =>  i_clk,
    i_rst       =>  i_rst,
    i_start     =>  st2_start,
    i_en        =>  st2_en,
    iv_stage    =>  "010",
    iv_din1     =>  st2_din1,
    iv_din2     =>  st2_din2,
    iv_din3     =>  st2_din3,
    iv_din4     =>  st2_din4,
    iv_ovflo    =>  st2_ovflo,
    iv_blk_exp  =>  st2_blk_exp,
    ov_dout1    =>  st3_din1,
    ov_dout2    =>  st3_din2,
    ov_dout3    =>  st3_din3,
    ov_dout4    =>  st3_din4,
    ov_ovflo    =>  st3_ovflo,
    ov_blk_exp  =>  st3_blk_exp,
    o_start     =>  st3_start,
    o_vld       =>  st3_en
  );

st3_fft: fft_stage
  port map( 
    i_clk       =>  i_clk,
    i_rst       =>  i_rst,
    i_start     =>  st3_start,
    i_en        =>  st3_en,
    iv_stage    =>  "011",
    iv_din1     =>  st3_din1,
    iv_din2     =>  st3_din2,
    iv_din3     =>  st3_din3,
    iv_din4     =>  st3_din4,
    iv_ovflo    =>  st3_ovflo,
    iv_blk_exp  =>  st3_blk_exp,
    ov_dout1    =>  st4_din1,
    ov_dout2    =>  st4_din2,
    ov_dout3    =>  st4_din3,
    ov_dout4    =>  st4_din4,
    ov_ovflo    =>  st4_ovflo,
    ov_blk_exp  =>  st4_blk_exp,
    o_start     =>  st4_start,
    o_vld       =>  st4_en
  );

st4_fft: fft_stage
  port map( 
    i_clk       =>  i_clk,
    i_rst       =>  i_rst,
    i_start     =>  st4_start,
    i_en        =>  st4_en,
    iv_stage    =>  "100",
    iv_din1     =>  st4_din1,
    iv_din2     =>  st4_din2,
    iv_din3     =>  st4_din3,
    iv_din4     =>  st4_din4,
    iv_ovflo    =>  st4_ovflo,
    iv_blk_exp  =>  st4_blk_exp,
    ov_dout1    =>  st5_din1,
    ov_dout2    =>  st5_din2,
    ov_dout3    =>  st5_din3,
    ov_dout4    =>  st5_din4,
    ov_ovflo    =>  st5_ovflo,
    ov_blk_exp  =>  st5_blk_exp,
    o_start     =>  st5_start,
    o_vld       =>  st5_en
  );

st5_fft: fft_stage
  port map( 
    i_clk       =>  i_clk,
    i_rst       =>  i_rst,
    i_start     =>  st5_start,
    i_en        =>  st5_en,
    iv_stage    =>  "101",
    iv_din1     =>  st5_din1,
    iv_din2     =>  st5_din2,
    iv_din3     =>  st5_din3,
    iv_din4     =>  st5_din4,
    iv_ovflo    =>  st5_ovflo,
    iv_blk_exp  =>  st5_blk_exp,
    ov_dout1    =>  rev_din1,
    ov_dout2    =>  rev_din2,
    ov_dout3    =>  rev_din3,
    ov_dout4    =>  rev_din4,
    ov_ovflo    =>  rev_ovflo,
    ov_blk_exp  =>  rev_blk_exp,
    o_start     =>  rev_start,
    o_vld       =>  rev_en
  );

bit_rev_order: bit_rev
  Port map( 
    i_clk       =>  i_clk,
    i_rst       =>  i_rst,
    i_start     =>  rev_start,
    i_en        =>  rev_en,
    iv_din1     =>  rev_din1,
    iv_din2     =>  rev_din2,
    iv_din3     =>  rev_din3,
    iv_din4     =>  rev_din4,
    iv_ovflo    =>  rev_ovflo,
    iv_blk_exp  =>  rev_blk_exp,
    ov_dout1    =>  rev_dout1,
    ov_dout2    =>  rev_dout2,
    ov_dout3    =>  rev_dout3,
    ov_dout4    =>  rev_dout4,
    ov_blk_exp  =>  rev_blk_exp_out,
    o_start     =>  rev_start_out,
    o_vld       =>  rev_valid
  );

end Behavioral;
