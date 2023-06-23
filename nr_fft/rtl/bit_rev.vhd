----------------------------------------------------------------------------------
--  Engineer:       Devin
--  Email:          balddevin@outlook.com
--  Description:    Bit reverse moudule for the last stage output.
--                  The data proccessed is fixed point.
--  Parameters:
--  Additional:     
--  Revision:
--    Revision 0.01 - File Created
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bit_rev is
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
end bit_rev;

architecture Behavioral of bit_rev is

component fft_r4_ram IS
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
  );
END component;

--------------------------------------------------------------------------
-- Last stage storage
signal st0_cnt      : std_logic_vector(9 downto 0); -- Last stage In-Situ Storage counter.
signal st0_cnt_reg1 : std_logic_vector(9 downto 0);
signal st0_cnt_reg2 : std_logic_vector(9 downto 0);
signal en_reg1      : std_logic;
signal en_reg2      : std_logic;
signal en_reg3      : std_logic;
signal din1_reg1,  din1_reg2,  din1_reg3,  din1_reg4    : std_logic_vector(47 downto 0);
signal din2_reg1,  din2_reg2,  din2_reg3,  din2_reg4    : std_logic_vector(47 downto 0);
signal din3_reg1,  din3_reg2,  din3_reg3,  din3_reg4    : std_logic_vector(47 downto 0);
signal din4_reg1,  din4_reg2,  din4_reg3,  din4_reg4    : std_logic_vector(47 downto 0);
signal reorder_sign_wr_tmp1 : std_logic_vector(1 downto 0);
signal reorder_sign_wr_tmp2 : std_logic_vector(1 downto 0);
signal reorder_sign_wr      : std_logic_vector(1 downto 0);
signal ram_wr_en    : std_logic_vector(0 downto 0);
signal wr_addr_tmp1 : std_logic_vector(9 downto 0);
signal wr_addr_tmp2 : std_logic_vector(9 downto 0);
signal wr_addr_tmp3 : std_logic_vector(9 downto 0);
signal wr_addr_tmp4 : std_logic_vector(9 downto 0);
signal rama_wr_addr : std_logic_vector(9 downto 0);
signal ramb_wr_addr : std_logic_vector(9 downto 0);
signal ramc_wr_addr : std_logic_vector(9 downto 0);
signal ramd_wr_addr : std_logic_vector(9 downto 0);
signal rama_din     : std_logic_vector(47 downto 0);
signal ramb_din     : std_logic_vector(47 downto 0);
signal ramc_din     : std_logic_vector(47 downto 0);
signal ramd_din     : std_logic_vector(47 downto 0);
signal ovflo        : std_logic_vector(1 downto 0);

--------------------------------------------------------------------------
-- Bit reverse order
signal st1_cnt      : std_logic_vector(10 downto 0);
signal st1_cnt_reg1 : std_logic_vector(10 downto 0);
signal reserve_en   : std_logic;
signal ram_rd_en    : std_logic;
signal ram_rd_en_reg1   : std_logic;
signal ram_rd_en_reg2   : std_logic;
signal rd_addr_tmp1 : std_logic_vector(9 downto 0);
signal rd_addr_tmp2 : std_logic_vector(9 downto 0);
signal rd_addr_tmp3 : std_logic_vector(9 downto 0);
signal rd_addr_tmp4 : std_logic_vector(9 downto 0);
signal rama_rd_addr : std_logic_vector(9 downto 0);
signal ramb_rd_addr : std_logic_vector(9 downto 0);
signal ramc_rd_addr : std_logic_vector(9 downto 0);
signal ramd_rd_addr : std_logic_vector(9 downto 0);
signal rama_dout    : std_logic_vector(47 downto 0);
signal ramb_dout    : std_logic_vector(47 downto 0);
signal ramc_dout    : std_logic_vector(47 downto 0);
signal ramd_dout    : std_logic_vector(47 downto 0);
signal retrieve_start   : std_logic;
signal retrieve_en      : std_logic;
signal retrieve_en_reg1 : std_logic;
signal retrieve_en_reg2 : std_logic;
signal reorder_sign_rd_tmp1 : std_logic_vector(1 downto 0);
signal reorder_sign_rd_tmp2 : std_logic_vector(1 downto 0);
signal reorder_sign_rd      : std_logic_vector(1 downto 0);
signal reorder_sign_rd_reg1 : std_logic_vector(1 downto 0);
signal reorder_sign_rd_reg2 : std_logic_vector(1 downto 0);
signal reorder_sign_rd_reg3 : std_logic_vector(1 downto 0);

-- Truncation and rounding.
signal dout1_f      : std_logic_vector(47 downto 0);
signal dout2_f      : std_logic_vector(47 downto 0);
signal dout3_f      : std_logic_vector(47 downto 0);
signal dout4_f      : std_logic_vector(47 downto 0);
type cnt_delay14 is array(12 downto 0) of std_logic_vector(10 downto 0);
signal st1_cnt_regn : cnt_delay14;
signal blk_exp      : std_logic_vector(3 downto 0);
signal reserve_en_delay5 : std_logic_vector(3 downto 0);
signal retrieve_start_delay8    : std_logic_vector(6 downto 0);

begin

-- Last stage In-Situ storage.
in_situ_stor_proc: process(i_clk,i_rst)
begin
    if(i_clk'event and i_clk='1') then
        if(i_rst='1') then
            st0_cnt         <=  (others=>'0');
            st0_cnt_reg1    <=  (others=>'0');
            st0_cnt_reg2    <=  (others=>'0');
            en_reg1         <=  '0';
            en_reg2         <=  '0';
            en_reg3         <=  '0';
            reorder_sign_wr_tmp1 <=  (others=>'0');
            reorder_sign_wr_tmp2 <=  (others=>'0');
            reorder_sign_wr      <=  (others=>'0');
            din1_reg1 <= (others=>'0');   din1_reg2 <= (others=>'0');   din1_reg3 <= (others=>'0');   din1_reg4 <= (others=>'0');
            din2_reg1 <= (others=>'0');   din2_reg2 <= (others=>'0');   din2_reg3 <= (others=>'0');   din2_reg4 <= (others=>'0');
            din3_reg1 <= (others=>'0');   din3_reg2 <= (others=>'0');   din3_reg3 <= (others=>'0');   din3_reg4 <= (others=>'0');
            din4_reg1 <= (others=>'0');   din4_reg2 <= (others=>'0');   din4_reg3 <= (others=>'0');   din4_reg4 <= (others=>'0');
            rama_din        <=  (others=>'0');
            ramb_din        <=  (others=>'0');
            ramc_din        <=  (others=>'0');
            ramd_din        <=  (others=>'0');
            rama_wr_addr    <=  (others=>'0');
            ramb_wr_addr    <=  (others=>'0');
            ramc_wr_addr    <=  (others=>'0');
            ramd_wr_addr    <=  (others=>'0');
            ram_wr_en       <=  (others=>'0');
            retrieve_start  <=  '0';
        else
            -- Obtain reorder sign according to the thesis by Xie.
            if(i_start='1'or st0_cnt=1023) then    -- Clear st0 counter only on the occasion that the start signal falls.
                st0_cnt <=  (others=>'0');  
            elsif(i_en='1') then
                st0_cnt <=  st0_cnt+1;
            end if;
            reorder_sign_wr_tmp1   <=  st0_cnt(9 downto 8) + st0_cnt(7 downto 6) + st0_cnt(5 downto 4);
            reorder_sign_wr_tmp2   <=  st0_cnt(3 downto 2) + st0_cnt(1 downto 0);
            reorder_sign_wr        <=  reorder_sign_wr_tmp1 + reorder_sign_wr_tmp2;
            
            -- Register input data to match the latency.
            din1_reg1   <=  iv_din1;    din1_reg2   <=  din1_reg1;  din1_reg3   <=  din1_reg2;
            din2_reg1   <=  iv_din2;    din2_reg2   <=  din2_reg1;  din2_reg3   <=  din2_reg2;
            din3_reg1   <=  iv_din3;    din3_reg2   <=  din3_reg1;  din3_reg3   <=  din3_reg2;
            din4_reg1   <=  iv_din4;    din4_reg2   <=  din4_reg1;  din4_reg3   <=  din4_reg2;
            
            -- Generate RAM write address in natural order.
            st0_cnt_reg1    <=  st0_cnt;
            st0_cnt_reg2    <=  st0_cnt_reg1;
            wr_addr_tmp1    <=  st0_cnt_reg1(9 downto 0);
            wr_addr_tmp2    <=  st0_cnt_reg1(9 downto 0);
            wr_addr_tmp3    <=  st0_cnt_reg1(9 downto 0);
            wr_addr_tmp4    <=  st0_cnt_reg1(9 downto 0);
            
            -- Reordered RAM write process to conflict-free order .
            case reorder_sign_wr is
                when "00" =>
                    rama_din    <=  din1_reg3;
                    ramb_din    <=  din2_reg3;
                    ramc_din    <=  din3_reg3;
                    ramd_din    <=  din4_reg3;
                    rama_wr_addr    <=  wr_addr_tmp1;
                    ramb_wr_addr    <=  wr_addr_tmp2;
                    ramc_wr_addr    <=  wr_addr_tmp3;
                    ramd_wr_addr    <=  wr_addr_tmp4;
                when "01" =>
                    rama_din    <=  din4_reg3;
                    ramb_din    <=  din1_reg3;
                    ramc_din    <=  din2_reg3;
                    ramd_din    <=  din3_reg3;
                    rama_wr_addr    <=  wr_addr_tmp4;
                    ramb_wr_addr    <=  wr_addr_tmp1;
                    ramc_wr_addr    <=  wr_addr_tmp2;
                    ramd_wr_addr    <=  wr_addr_tmp3;
                when "10" =>
                    rama_din    <=  din3_reg3;
                    ramb_din    <=  din4_reg3;
                    ramc_din    <=  din1_reg3;
                    ramd_din    <=  din2_reg3;
                    rama_wr_addr    <=  wr_addr_tmp3;
                    ramb_wr_addr    <=  wr_addr_tmp4;
                    ramc_wr_addr    <=  wr_addr_tmp1;
                    ramd_wr_addr    <=  wr_addr_tmp2;
                when "11" =>
                    rama_din    <=  din2_reg3;
                    ramb_din    <=  din3_reg3;
                    ramc_din    <=  din4_reg3;
                    ramd_din    <=  din1_reg3;
                    rama_wr_addr    <=  wr_addr_tmp2;
                    ramb_wr_addr    <=  wr_addr_tmp3;
                    ramc_wr_addr    <=  wr_addr_tmp4;
                    ramd_wr_addr    <=  wr_addr_tmp1;
                when others => null;
            end case;
            
            en_reg1     <=  i_en;
            en_reg2     <=  en_reg1;
            en_reg3     <=  en_reg2;
            ram_wr_en(0)<=  en_reg3;    -- Write enable.
            
            -- Generate start signal for retrieve operation.
            if(st0_cnt_reg2=1023) then
                retrieve_start  <=  '1';
            else
                retrieve_start  <=  '0';
            end if;
            
        end if;
    end if;
end process;

-- Retrieve data and reverse to natrual order. 
retrieve_proc: process(i_clk,i_rst)
begin
    if(i_clk'event and i_clk='1') then
        if(i_rst='1') then
            retrieve_en             <=  '0';
            st1_cnt                 <=  (others=>'0');
            st1_cnt_reg1            <=  (others=>'0');
            reorder_sign_rd_tmp1    <=  (others=>'0');
            reorder_sign_rd_tmp1    <=  (others=>'0');
            reorder_sign_rd         <=  (others=>'0');
            rd_addr_tmp1            <=  (others=>'0');
            rd_addr_tmp2            <=  (others=>'0');
            rd_addr_tmp3            <=  (others=>'0');
            rd_addr_tmp4            <=  (others=>'0');
            rama_rd_addr            <=  (others=>'0');
            ramb_rd_addr            <=  (others=>'0');
            ramc_rd_addr            <=  (others=>'0');
            ramd_rd_addr            <=  (others=>'0');
            retrieve_en_reg1        <=  '0';
            retrieve_en_reg2        <=  '0';
            ram_rd_en               <=  '0';
            reorder_sign_rd_reg1    <=  (others=>'0');
            reorder_sign_rd_reg2    <=  (others=>'0');
            reorder_sign_rd_reg3    <=  (others=>'0');
            dout1_f                 <=  (others=>'0');
            dout2_f                 <=  (others=>'0');
            dout3_f                 <=  (others=>'0');
            dout4_f                 <=  (others=>'0');
            reserve_en              <=  '0';
        else
            -- Obtain reorder sign according to the thesis by Xie.
            if(retrieve_start='1' and retrieve_en='0') then
                retrieve_en <=  '1';
            elsif(st1_cnt=1025) then
                retrieve_en <=  '0';
            end if;
            
            if(st1_cnt>=1 and st1_cnt<=1024) then
                reserve_en  <=  '1';    -- Reserved for /btf_en/ and /tw_en/ in the next process.
            else
                reserve_en  <=  '0';
            end if;
            
            if(retrieve_start='1' or st1_cnt=1025) then
                st1_cnt <=  (others=>'0');  
            elsif(retrieve_en='1') then
                st1_cnt <=  st1_cnt+1;
            end if;
            reorder_sign_rd_tmp1   <=  st1_cnt(9 downto 8) + st1_cnt(7 downto 6) + st1_cnt(5 downto 4);
            reorder_sign_rd_tmp2   <=  st1_cnt(3 downto 2) + st1_cnt(1 downto 0);
            reorder_sign_rd        <=  reorder_sign_rd_tmp1 + reorder_sign_rd_tmp2;
            
            st1_cnt_reg1    <=  st1_cnt;
            -- Radix-4 bit reverse.
            rd_addr_tmp1    <=  "00" & st1_cnt_reg1(1 downto 0) & st1_cnt_reg1(3 downto 2) & st1_cnt_reg1(5 downto 4) & st1_cnt_reg1(7 downto 6);
            rd_addr_tmp2    <=  "01" & st1_cnt_reg1(1 downto 0) & st1_cnt_reg1(3 downto 2) & st1_cnt_reg1(5 downto 4) & st1_cnt_reg1(7 downto 6);
            rd_addr_tmp3    <=  "10" & st1_cnt_reg1(1 downto 0) & st1_cnt_reg1(3 downto 2) & st1_cnt_reg1(5 downto 4) & st1_cnt_reg1(7 downto 6);
            rd_addr_tmp4    <=  "11" & st1_cnt_reg1(1 downto 0) & st1_cnt_reg1(3 downto 2) & st1_cnt_reg1(5 downto 4) & st1_cnt_reg1(7 downto 6);
            
            -- Reorder conflict-free order read address to natural order.
            case reorder_sign_rd is
                when "00" =>
                    rama_rd_addr    <=  rd_addr_tmp1;
                    ramb_rd_addr    <=  rd_addr_tmp2;
                    ramc_rd_addr    <=  rd_addr_tmp3;
                    ramd_rd_addr    <=  rd_addr_tmp4;
                when "01" =>
                    rama_rd_addr    <=  rd_addr_tmp4;
                    ramb_rd_addr    <=  rd_addr_tmp1;
                    ramc_rd_addr    <=  rd_addr_tmp2;
                    ramd_rd_addr    <=  rd_addr_tmp3;
                when "10" =>
                    rama_rd_addr    <=  rd_addr_tmp3;
                    ramb_rd_addr    <=  rd_addr_tmp4;
                    ramc_rd_addr    <=  rd_addr_tmp1;
                    ramd_rd_addr    <=  rd_addr_tmp2;
                when "11" =>
                    rama_rd_addr    <=  rd_addr_tmp2;
                    ramb_rd_addr    <=  rd_addr_tmp3;
                    ramc_rd_addr    <=  rd_addr_tmp4;
                    ramd_rd_addr    <=  rd_addr_tmp1;
                when others => null;
            end case;
            
            retrieve_en_reg1    <=  retrieve_en;
            retrieve_en_reg2    <=  retrieve_en_reg1;
            ram_rd_en           <=  retrieve_en_reg2;
            
            -- Reorder conflict-free data to natural order.
            reorder_sign_rd_reg1    <=  reorder_sign_rd;
            reorder_sign_rd_reg2    <=  reorder_sign_rd_reg1;
            reorder_sign_rd_reg3    <=  reorder_sign_rd_reg2;
            case reorder_sign_rd_reg3 is
                when "00" =>
                    dout1_f  <=  rama_dout;  -- Full word length output data, required to be scaled.
                    dout2_f  <=  ramb_dout;
                    dout3_f  <=  ramc_dout;
                    dout4_f  <=  ramd_dout;
                when "01" =>
                    dout1_f  <=  ramb_dout;
                    dout2_f  <=  ramc_dout;
                    dout3_f  <=  ramd_dout;
                    dout4_f  <=  rama_dout;
                when "10" =>
                    dout1_f  <=  ramc_dout;
                    dout2_f  <=  ramd_dout;
                    dout3_f  <=  rama_dout;
                    dout4_f  <=  ramb_dout;
                when "11" =>
                    dout1_f  <=  ramd_dout;
                    dout2_f  <=  rama_dout;
                    dout3_f  <=  ramb_dout;
                    dout4_f  <=  ramc_dout;
                when others => null;
            end case;
            
        end if;
    end if;
end process;

-- Truncation and rounding.
out_proc: process(i_clk,i_rst)
begin
    if(i_clk'event and i_clk='1') then
        if(i_rst='1') then
            ovflo           <=  (others=>'0');
            ram_rd_en_reg1  <=  '0';
            ram_rd_en_reg2  <=  '0';
            ov_dout1    <=  (others=>'0');
            ov_dout2    <=  (others=>'0');
            ov_dout3    <=  (others=>'0');
            ov_dout4    <=  (others=>'0');
            o_vld       <=  '0';
            o_start     <=  '0';
            st1_cnt_regn    <=  (others=>(others=>'0'));
            blk_exp         <=  (others=>'0');
            reserve_en_delay5   <=  (others=>'0');
            retrieve_start_delay8   <=  (others=>'0');
        else
            -- Delay read counter to calculate block exponent.
            st1_cnt_regn(0) <=  st1_cnt_reg1;
            st1_cnt_regn(12 downto 1) <=  st1_cnt_regn(11 downto 0);
            if(st1_cnt_regn(12)=1023) then
                blk_exp <=  iv_blk_exp + ("00" & ovflo);
            end if;
            
            -- Rounding operation goes here.
            if(st0_cnt=1023) then
                ovflo   <=  iv_ovflo;
            end if;
            if(ovflo="00") then
                ov_dout1    <=  dout1_f(45 downto 30) & dout1_f(21 downto 6); -- fix24_18 -> fix 16_12
                ov_dout2    <=  dout2_f(45 downto 30) & dout2_f(21 downto 6);
                ov_dout3    <=  dout3_f(45 downto 30) & dout3_f(21 downto 6);
                ov_dout4    <=  dout4_f(45 downto 30) & dout4_f(21 downto 6);
            elsif(ovflo="01") then
                ov_dout1    <=  dout1_f(46 downto 31) & dout1_f(22 downto 7);
                ov_dout2    <=  dout2_f(46 downto 31) & dout2_f(22 downto 7);
                ov_dout3    <=  dout3_f(46 downto 31) & dout3_f(22 downto 7);
                ov_dout4    <=  dout4_f(46 downto 31) & dout4_f(22 downto 7);
            elsif(ovflo="10") then
                ov_dout1    <=  dout1_f(47 downto 32) & dout1_f(23 downto 8);
                ov_dout2    <=  dout2_f(47 downto 32) & dout2_f(23 downto 8);
                ov_dout3    <=  dout3_f(47 downto 32) & dout3_f(23 downto 8);
                ov_dout4    <=  dout4_f(47 downto 32) & dout4_f(23 downto 8);
            end if;
            reserve_en_delay5(0)    <=  reserve_en;
            reserve_en_delay5(3 downto 1)   <=  reserve_en_delay5(2 downto 0);
            retrieve_start_delay8(0)    <=  retrieve_start;
            retrieve_start_delay8(6 downto 1)   <=  retrieve_start_delay8(5 downto 0);
            o_start         <=  retrieve_start_delay8(6);
            o_vld           <=  reserve_en_delay5(3);
            ov_blk_exp      <=  blk_exp;
        end if;
    end if;
end process;


bit_rev_ram_a: fft_r4_ram
  PORT map(
    clka    =>  i_clk,
    wea     =>  ram_wr_en,
    addra   =>  rama_wr_addr,
    dina    =>  rama_din,
    clkb    =>  i_clk,
    enb     =>  ram_rd_en,
    addrb   =>  rama_rd_addr,
    doutb   =>  rama_dout
  );

bit_rev_ram_b: fft_r4_ram
  PORT map(
    clka    =>  i_clk,
    wea     =>  ram_wr_en,
    addra   =>  ramb_wr_addr,
    dina    =>  ramb_din,
    clkb    =>  i_clk,
    enb     =>  ram_rd_en,
    addrb   =>  ramb_rd_addr,
    doutb   =>  ramb_dout
  );

bit_rev_ram_c: fft_r4_ram
  PORT map(
    clka    =>  i_clk,
    wea     =>  ram_wr_en,
    addra   =>  ramc_wr_addr,
    dina    =>  ramc_din,
    clkb    =>  i_clk,
    enb     =>  ram_rd_en,
    addrb   =>  ramc_rd_addr,
    doutb   =>  ramc_dout
  );

bit_rev_ram_d: fft_r4_ram
  PORT map(
    clka    =>  i_clk,
    wea     =>  ram_wr_en,
    addra   =>  ramd_wr_addr,
    dina    =>  ramd_din,
    clkb    =>  i_clk,
    enb     =>  ram_rd_en,
    addrb   =>  ramd_rd_addr,
    doutb   =>  ramd_dout
  );


end Behavioral;
