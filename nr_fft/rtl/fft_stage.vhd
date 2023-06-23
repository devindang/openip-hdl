----------------------------------------------------------------------------------
--  Engineer:       Devin
--  Email:          balddevin@outlook.com
--  Description:    Single stage for pipelined architecture.
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

entity fft_stage is
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
end fft_stage;

architecture Behavioral of fft_stage is

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

component tw_tab is
  Port ( 
    i_clk       : in  std_logic;
    i_rst       : in  std_logic;
    i_en        : in  std_logic;
    iv_addr     : in  std_logic_vector(11 downto 0);
    ov_tw       : out std_logic_vector(31 downto 0);
    o_vld       : out std_logic
  );
end component;

component btf_r4 is
  Port ( 
    i_clk       : in  std_logic;
    i_rst       : in  std_logic;
    i_en        : in  std_logic;
    iv_din1     : in  std_logic_vector(31 downto 0);    -- fix16_12
    iv_din2     : in  std_logic_vector(31 downto 0);
    iv_din3     : in  std_logic_vector(31 downto 0);
    iv_din4     : in  std_logic_vector(31 downto 0);
    iv_tw2      : in  std_logic_vector(31 downto 0);    -- The first Twiddle Factor is constant 1.
    iv_tw3      : in  std_logic_vector(31 downto 0);
    iv_tw4      : in  std_logic_vector(31 downto 0);
    o_valid     : out std_logic;
    ov_dout1    : out std_logic_vector(47 downto 0);    -- fix24_18
    ov_dout2    : out std_logic_vector(47 downto 0);
    ov_dout3    : out std_logic_vector(47 downto 0);
    ov_dout4    : out std_logic_vector(47 downto 0);
    ov_ovflo    : out std_logic_vector(1 downto 0)      -- Overflow control, unsigned block exponent.
  );
end component;

--------------------------------------------------------------------------
-- In-Situ Storage
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
signal rama_din     : std_logic_vector(47 downto 0);
signal ramb_din     : std_logic_vector(47 downto 0);
signal ramc_din     : std_logic_vector(47 downto 0);
signal ramd_din     : std_logic_vector(47 downto 0);
signal wr_addr_tmp1 : std_logic_vector(9 downto 0);
signal wr_addr_tmp2 : std_logic_vector(9 downto 0);
signal wr_addr_tmp3 : std_logic_vector(9 downto 0);
signal wr_addr_tmp4 : std_logic_vector(9 downto 0);
signal rama_wr_addr : std_logic_vector(9 downto 0);
signal ramb_wr_addr : std_logic_vector(9 downto 0);
signal ramc_wr_addr : std_logic_vector(9 downto 0);
signal ramd_wr_addr : std_logic_vector(9 downto 0);
signal ram_wr_en    : std_logic_vector(0 downto 0);

--------------------------------------------------------------------------
-- Retrieve for Radix-4 butterfly
signal st1_cnt      : std_logic_vector(10 downto 0); -- Current stage Butterfly operation counter.
signal st1_cnt_reg1 : std_logic_vector(10 downto 0);
type cnt_delay14 is array(12 downto 0) of std_logic_vector(10 downto 0);
signal st1_cnt_regn : cnt_delay14;
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
signal rama_dout    : std_logic_vector(47 downto 0);
signal ramb_dout    : std_logic_vector(47 downto 0);
signal ramc_dout    : std_logic_vector(47 downto 0);
signal ramd_dout    : std_logic_vector(47 downto 0);
signal rd_addr_tmp1 : std_logic_vector(9 downto 0);
signal rd_addr_tmp2 : std_logic_vector(9 downto 0);
signal rd_addr_tmp3 : std_logic_vector(9 downto 0);
signal rd_addr_tmp4 : std_logic_vector(9 downto 0);
signal rama_rd_addr : std_logic_vector(9 downto 0);
signal ramb_rd_addr : std_logic_vector(9 downto 0);
signal ramc_rd_addr : std_logic_vector(9 downto 0);
signal ramd_rd_addr : std_logic_vector(9 downto 0);
signal ram_rd_en        : std_logic;
signal btf_din1_f   : std_logic_vector(47 downto 0);
signal btf_din2_f   : std_logic_vector(47 downto 0);
signal btf_din3_f   : std_logic_vector(47 downto 0);
signal btf_din4_f   : std_logic_vector(47 downto 0);
signal reserve_en       : std_logic;
signal reserve_en_reg1  : std_logic;
signal reserve_en_reg2  : std_logic;
signal reserve_en_reg3  : std_logic;
signal reserve_en_reg4  : std_logic;
--------------------------------------------------------------------------
-- Retrieve twiddle factors.
signal tw_en        : std_logic;
signal tw2_addr     : std_logic_vector(11 downto 0);
signal tw3_addr     : std_logic_vector(11 downto 0);
signal tw4_addr     : std_logic_vector(11 downto 0);
signal btf_tw2      : std_logic_vector(31 downto 0);
signal btf_tw3      : std_logic_vector(31 downto 0);
signal btf_tw4      : std_logic_vector(31 downto 0);
signal tw_vld       : std_logic;
signal tw_addr      : std_logic_vector(9 downto 0);
signal tw_addr_reg1 : std_logic_vector(9 downto 0);
signal tw_addr_reg2 : std_logic_vector(9 downto 0);

--------------------------------------------------------------------------
-- Butterfly Unit.
signal start_delay16    : std_logic_vector(14 downto 0);
signal btf_start    : std_logic;
signal st0_ovflo    : std_logic_vector(1 downto 0); -- Last stage overflow.
signal btf_en       : std_logic;
signal btf_din1     : std_logic_vector(31 downto 0);
signal btf_din2     : std_logic_vector(31 downto 0);
signal btf_din3     : std_logic_vector(31 downto 0);
signal btf_din4     : std_logic_vector(31 downto 0);
signal btf_dout1    : std_logic_vector(47 downto 0);
signal btf_dout2    : std_logic_vector(47 downto 0);
signal btf_dout3    : std_logic_vector(47 downto 0);
signal btf_dout4    : std_logic_vector(47 downto 0);
signal btf_vld      : std_logic;
signal btf_ovflo    : std_logic_vector(1 downto 0);
signal st1_ovflo    : std_logic_vector(1 downto 0); -- Current stage overflow.
signal ovflo        : std_logic_vector(1 downto 0); -- Registered overflow.
signal blk_exp      : std_logic_vector(3 downto 0); -- Unsigned positive integer.



begin

-- In-Situ Storage for the last stage.
in_situ_stor_proc: process(i_clk,i_rst)
begin
    if(i_clk'event and i_clk='1') then
        if(i_rst='1') then
            st0_cnt         <=  (others=>'0');
            st0_cnt_reg1    <=  (others=>'0');
            st0_cnt_reg2    <=  (others=>'0');
            wr_addr_tmp1    <=  (others=>'0');
            wr_addr_tmp2    <=  (others=>'0');
            wr_addr_tmp3    <=  (others=>'0');
            wr_addr_tmp4    <=  (others=>'0');
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
            case iv_stage is
                when "000" =>
                    wr_addr_tmp1    <=  st0_cnt_reg1(9 downto 0);
                    wr_addr_tmp2    <=  st0_cnt_reg1(9 downto 0);
                    wr_addr_tmp3    <=  st0_cnt_reg1(9 downto 0);
                    wr_addr_tmp4    <=  st0_cnt_reg1(9 downto 0);
                when "001" =>
                    wr_addr_tmp1    <=  "00" & st0_cnt_reg1(9 downto 2);
                    wr_addr_tmp2    <=  "01" & st0_cnt_reg1(9 downto 2);
                    wr_addr_tmp3    <=  "10" & st0_cnt_reg1(9 downto 2);
                    wr_addr_tmp4    <=  "11" & st0_cnt_reg1(9 downto 2);
                when "010" =>
                    wr_addr_tmp1    <=  st0_cnt_reg1(9 downto 8) & "00" & st0_cnt_reg1(7 downto 2);
                    wr_addr_tmp2    <=  st0_cnt_reg1(9 downto 8) & "01" & st0_cnt_reg1(7 downto 2);
                    wr_addr_tmp3    <=  st0_cnt_reg1(9 downto 8) & "10" & st0_cnt_reg1(7 downto 2);
                    wr_addr_tmp4    <=  st0_cnt_reg1(9 downto 8) & "11" & st0_cnt_reg1(7 downto 2);
                when "011" =>
                    wr_addr_tmp1    <=  st0_cnt_reg1(9 downto 6) & "00" & st0_cnt_reg1(5 downto 2);
                    wr_addr_tmp2    <=  st0_cnt_reg1(9 downto 6) & "01" & st0_cnt_reg1(5 downto 2);
                    wr_addr_tmp3    <=  st0_cnt_reg1(9 downto 6) & "10" & st0_cnt_reg1(5 downto 2);
                    wr_addr_tmp4    <=  st0_cnt_reg1(9 downto 6) & "11" & st0_cnt_reg1(5 downto 2);
                when "100" =>
                    wr_addr_tmp1    <=  st0_cnt_reg1(9 downto 4) & "00" & st0_cnt_reg1(3 downto 2);
                    wr_addr_tmp2    <=  st0_cnt_reg1(9 downto 4) & "01" & st0_cnt_reg1(3 downto 2);
                    wr_addr_tmp3    <=  st0_cnt_reg1(9 downto 4) & "10" & st0_cnt_reg1(3 downto 2);
                    wr_addr_tmp4    <=  st0_cnt_reg1(9 downto 4) & "11" & st0_cnt_reg1(3 downto 2);
                when "101" =>
                    wr_addr_tmp1    <=  st0_cnt_reg1(9 downto 2) & "00";
                    wr_addr_tmp2    <=  st0_cnt_reg1(9 downto 2) & "01";
                    wr_addr_tmp3    <=  st0_cnt_reg1(9 downto 2) & "10";
                    wr_addr_tmp4    <=  st0_cnt_reg1(9 downto 2) & "11";
                when others => null;
            end case;
            
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

-- Retrieve in current stage.
retrieve_proc: process(i_clk,i_rst)
begin
    if(i_clk'event and i_clk='1') then
        if(i_rst='1') then
            retrieve_en             <=  '0';
            st1_cnt                 <=  (others=>'0');
            st1_cnt_reg1            <=  (others=>'0');
            reorder_sign_rd_tmp1    <=  (others=>'0');
            reorder_sign_rd_tmp2    <=  (others=>'0');
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
            btf_din1_f              <=  (others=>'0');
            btf_din2_f              <=  (others=>'0');
            btf_din3_f              <=  (others=>'0');
            btf_din4_f              <=  (others=>'0');
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
            
            -- Generate RAM write address in natural order.
            st1_cnt_reg1    <=  st1_cnt;
            case iv_stage is
                when "000" =>
                    rd_addr_tmp1    <=  "00" & st1_cnt_reg1(9 downto 2);
                    rd_addr_tmp2    <=  "01" & st1_cnt_reg1(9 downto 2);
                    rd_addr_tmp3    <=  "10" & st1_cnt_reg1(9 downto 2);
                    rd_addr_tmp4    <=  "11" & st1_cnt_reg1(9 downto 2);
                when "001" =>
                    rd_addr_tmp1    <=  st1_cnt_reg1(9 downto 8) & "00" & st1_cnt_reg1(7 downto 2);
                    rd_addr_tmp2    <=  st1_cnt_reg1(9 downto 8) & "01" & st1_cnt_reg1(7 downto 2);
                    rd_addr_tmp3    <=  st1_cnt_reg1(9 downto 8) & "10" & st1_cnt_reg1(7 downto 2);
                    rd_addr_tmp4    <=  st1_cnt_reg1(9 downto 8) & "11" & st1_cnt_reg1(7 downto 2);
                when "010" =>
                    rd_addr_tmp1    <=  st1_cnt_reg1(9 downto 6) & "00" & st1_cnt_reg1(5 downto 2);
                    rd_addr_tmp2    <=  st1_cnt_reg1(9 downto 6) & "01" & st1_cnt_reg1(5 downto 2);
                    rd_addr_tmp3    <=  st1_cnt_reg1(9 downto 6) & "10" & st1_cnt_reg1(5 downto 2);
                    rd_addr_tmp4    <=  st1_cnt_reg1(9 downto 6) & "11" & st1_cnt_reg1(5 downto 2);
                when "011" =>
                    rd_addr_tmp1    <=  st1_cnt_reg1(9 downto 4) & "00" & st1_cnt_reg1(3 downto 2);
                    rd_addr_tmp2    <=  st1_cnt_reg1(9 downto 4) & "01" & st1_cnt_reg1(3 downto 2);
                    rd_addr_tmp3    <=  st1_cnt_reg1(9 downto 4) & "10" & st1_cnt_reg1(3 downto 2);
                    rd_addr_tmp4    <=  st1_cnt_reg1(9 downto 4) & "11" & st1_cnt_reg1(3 downto 2);
                when "100" =>
                    rd_addr_tmp1    <=  st1_cnt_reg1(9 downto 2) & "00";
                    rd_addr_tmp2    <=  st1_cnt_reg1(9 downto 2) & "01";
                    rd_addr_tmp3    <=  st1_cnt_reg1(9 downto 2) & "10";
                    rd_addr_tmp4    <=  st1_cnt_reg1(9 downto 2) & "11";
                when "101" =>
                    rd_addr_tmp1    <=  st1_cnt_reg1(9 downto 0);
                    rd_addr_tmp2    <=  st1_cnt_reg1(9 downto 0);
                    rd_addr_tmp3    <=  st1_cnt_reg1(9 downto 0);
                    rd_addr_tmp4    <=  st1_cnt_reg1(9 downto 0);
                when others => null;
            end case;
            
            -- Reorder natural read address to conflict-free order.
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
                    btf_din1_f  <=  rama_dout;  -- Full word length butterfly input data, required to be scaled.
                    btf_din2_f  <=  ramb_dout;
                    btf_din3_f  <=  ramc_dout;
                    btf_din4_f  <=  ramd_dout;
                when "01" =>
                    btf_din1_f  <=  ramb_dout;
                    btf_din2_f  <=  ramc_dout;
                    btf_din3_f  <=  ramd_dout;
                    btf_din4_f  <=  rama_dout;
                when "10" =>
                    btf_din1_f  <=  ramc_dout;
                    btf_din2_f  <=  ramd_dout;
                    btf_din3_f  <=  rama_dout;
                    btf_din4_f  <=  ramb_dout;
                when "11" =>
                    btf_din1_f  <=  ramd_dout;
                    btf_din2_f  <=  rama_dout;
                    btf_din3_f  <=  ramb_dout;
                    btf_din4_f  <=  ramc_dout;
                when others => null;
            end case;
            
        end if;
    end if;
end process;

-- Retrieve twiddle factors.
tw_proc: process(i_clk,i_rst)
begin
    if(i_clk'event and i_clk='1') then
        if(i_rst='1') then
            tw_addr         <=  (others=>'0');
            tw_addr_reg1    <=  (others=>'0');
            tw_addr_reg2    <=  (others=>'0');
            tw2_addr    <=  (others=>'0');
            tw3_addr    <=  (others=>'0');
            tw4_addr    <=  (others=>'0');
        else
            case iv_stage is
                when "000" =>
                    tw_addr <=  st1_cnt_reg1(9 downto 0);
                when "001" =>
                    tw_addr <=  st1_cnt_reg1(7 downto 0) & "00";
                when "010" =>
                    tw_addr <=  st1_cnt_reg1(5 downto 0) & "0000";
                when "011" =>
                    tw_addr <=  st1_cnt_reg1(3 downto 0) & b"00_0000";
                when "100" =>
                    tw_addr <=  st1_cnt_reg1(1 downto 0) & b"0000_0000";
                when "101" =>
                    tw_addr <=  b"00_0000_0000";
                when others => null;
            end case;
            tw_addr_reg1    <=  tw_addr;
            tw_addr_reg2    <=  tw_addr_reg1;
            tw2_addr    <=  "00" & tw_addr_reg2;
            tw3_addr    <=  "0" & tw_addr_reg2 & "0";
            tw4_addr    <=  ("00" & tw_addr_reg2) + ("0" & tw_addr_reg2 & "0");
        end if;
    end if;
end process;


-- Radix-4 Butterfly inputs.
btfly_in_proc: process(i_clk,i_rst)
begin
    if(i_clk'event and i_clk='1') then
        if(i_rst='1') then
            btf_en          <=  '0';
            tw_en           <=  '0';
            st0_ovflo   <=  (others=>'0');
            btf_din1    <=  (others=>'0');
            btf_din2    <=  (others=>'0');
            btf_din3    <=  (others=>'0');
            btf_din4    <=  (others=>'0');
            reserve_en_reg1 <=  '0';
            reserve_en_reg2 <=  '0';
            reserve_en_reg3 <=  '0';
            reserve_en_reg4 <=  '0';
        else
            -- Rounding operation goes here.
            if(st0_cnt=1023) then
                st0_ovflo   <=  iv_ovflo;
            end if;
            if(st0_ovflo="00") then
                btf_din1    <=  btf_din1_f(45 downto 30) & btf_din1_f(21 downto 6); -- fix24_18 -> fix 16_12
                btf_din2    <=  btf_din2_f(45 downto 30) & btf_din2_f(21 downto 6);
                btf_din3    <=  btf_din3_f(45 downto 30) & btf_din3_f(21 downto 6);
                btf_din4    <=  btf_din4_f(45 downto 30) & btf_din4_f(21 downto 6);
            elsif(st0_ovflo="01") then
                btf_din1    <=  btf_din1_f(46 downto 31) & btf_din1_f(22 downto 7);
                btf_din2    <=  btf_din2_f(46 downto 31) & btf_din2_f(22 downto 7);
                btf_din3    <=  btf_din3_f(46 downto 31) & btf_din3_f(22 downto 7);
                btf_din4    <=  btf_din4_f(46 downto 31) & btf_din4_f(22 downto 7);
            elsif(st0_ovflo="10") then
                btf_din1    <=  btf_din1_f(47 downto 32) & btf_din1_f(23 downto 8);
                btf_din2    <=  btf_din2_f(47 downto 32) & btf_din2_f(23 downto 8);
                btf_din3    <=  btf_din3_f(47 downto 32) & btf_din3_f(23 downto 8);
                btf_din4    <=  btf_din4_f(47 downto 32) & btf_din4_f(23 downto 8);
            end if;
            
            reserve_en_reg1 <=  reserve_en;
            reserve_en_reg2 <=  reserve_en_reg1;
            reserve_en_reg3 <=  reserve_en_reg2;
            reserve_en_reg4 <=  reserve_en_reg3;
            btf_en          <=  reserve_en_reg4;
            tw_en           <=  reserve_en_reg2;
        end if;
    end if;
end process;

-- Radix-4 Butterfly outputs.
btfly_out_proc: process(i_clk,i_rst)
begin
    if(i_clk'event and i_clk='1') then
        if(i_rst='1') then
            start_delay16   <=  (others=>'0');
            btf_start       <=  '0';
            st1_ovflo       <=  (others=>'0');
            st1_cnt_regn    <=  (others=>(others=>'0'));
            ovflo           <=  (others=>'0');
            blk_exp         <=  (others=>'0');
        else
            -- Delay /retrieve_start/ 10 cycles as /btf_start/. 
            start_delay16(0)            <=  retrieve_start;
            start_delay16(14 downto 1)  <=  start_delay16(13 downto 0);
            btf_start                   <=  start_delay16(14);
            if(btf_start='1') then
                st1_ovflo   <=  btf_ovflo;
            elsif(btf_vld='1') then
                if(btf_ovflo>st1_ovflo) then
                    st1_ovflo   <=  btf_ovflo;
                end if;
            end if;
            
            -- Delay read counter to calculate block exponent.
            st1_cnt_regn(0) <=  st1_cnt_reg1;
            st1_cnt_regn(12 downto 1) <=  st1_cnt_regn(11 downto 0);
            if(st1_cnt_regn(12)=1024) then
                blk_exp <=  iv_blk_exp + ("00" & st1_ovflo);
            end if;
            
            if(st1_cnt_regn(12)=1024) then
                ovflo    <=  st1_ovflo;
            else
                ovflo    <=  (others=>'0');
            end if;
        end if;
    end if;
end process;

-- Transfer to the next stage.
out_proc: process(i_clk,i_rst)
begin
    if(i_clk'event and i_clk='1') then
        if(i_rst='1') then
            ov_dout1    <=  (others=>'0');
            ov_dout2    <=  (others=>'0');
            ov_dout3    <=  (others=>'0');
            ov_dout4    <=  (others=>'0');
            ov_ovflo    <=  (others=>'0');
            ov_blk_exp  <=  (others=>'0');
            o_start     <=  '0';
            o_vld       <=  '0';
        else
            ov_dout1    <=  btf_dout1;
            ov_dout2    <=  btf_dout2;
            ov_dout3    <=  btf_dout3;
            ov_dout4    <=  btf_dout4;
            
            ov_ovflo    <=  ovflo;
            ov_blk_exp  <=  blk_exp;
            o_vld       <=  btf_vld;
            o_start     <=  btf_start;
        end if;
    end if;
end process;

fft_r4_ram_a: fft_r4_ram
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

fft_r4_ram_b: fft_r4_ram
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

fft_r4_ram_c: fft_r4_ram
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

fft_r4_ram_d: fft_r4_ram
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


inst_tw_tab2: tw_tab
  port map ( 
    i_clk       =>  i_clk,
    i_rst       =>  i_rst,
    i_en        =>  tw_en,
    iv_addr     =>  tw2_addr,
    ov_tw       =>  btf_tw2,
    o_vld       =>  tw_vld
  );

inst_tw_tab3: tw_tab
  port map ( 
    i_clk       =>  i_clk,
    i_rst       =>  i_rst,
    i_en        =>  tw_en,
    iv_addr     =>  tw3_addr,
    ov_tw       =>  btf_tw3,
    o_vld       =>  open
  );

inst_tw_tab4: tw_tab
  port map ( 
    i_clk       =>  i_clk,
    i_rst       =>  i_rst,
    i_en        =>  tw_en,
    iv_addr     =>  tw4_addr,
    ov_tw       =>  btf_tw4,
    o_vld       =>  open
  );

inst_btf_r4: btf_r4
  port map ( 
    i_clk       =>  i_clk,
    i_rst       =>  i_rst,
    i_en        =>  btf_en,
    iv_din1     =>  btf_din1,
    iv_din2     =>  btf_din2,
    iv_din3     =>  btf_din3,
    iv_din4     =>  btf_din4,
    iv_tw2      =>  btf_tw2,
    iv_tw3      =>  btf_tw3,
    iv_tw4      =>  btf_tw4,
    o_valid     =>  btf_vld,
    ov_dout1    =>  btf_dout1,
    ov_dout2    =>  btf_dout2,
    ov_dout3    =>  btf_dout3,
    ov_dout4    =>  btf_dout4,
    ov_ovflo    =>  btf_ovflo
  );

end Behavioral;
