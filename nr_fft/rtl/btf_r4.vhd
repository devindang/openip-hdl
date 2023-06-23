----------------------------------------------------------------------------------
--  Engineer:       Devin
--  Email:          balddevin@outlook.com
--  Description:    Radix-4 butterfly unit.
--  Parameters:
--  Additional:     
--  Revision:
--    Revision 0.01 - File Created
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use iEEE.STD_LOGIC_SIGNED.ALL;
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity btf_r4 is
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
end btf_r4;

architecture Behavioral of btf_r4 is

component tw_mult IS
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_dout_tvalid : OUT STD_LOGIC;
    m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(79 DOWNTO 0)
  );
END component;

signal addi1_i  : std_logic_vector(17 downto 0);
signal addi1_r  : std_logic_vector(17 downto 0);
signal addi2_i  : std_logic_vector(17 downto 0);
signal addi2_r  : std_logic_vector(17 downto 0);
signal addi3_i  : std_logic_vector(17 downto 0);
signal addi3_r  : std_logic_vector(17 downto 0);
signal addi4_i  : std_logic_vector(17 downto 0);
signal addi4_r  : std_logic_vector(17 downto 0);

signal tw2_reg  : std_logic_vector(31 downto 0);
signal tw3_reg  : std_logic_vector(31 downto 0);
signal tw4_reg  : std_logic_vector(31 downto 0);

signal btf_cmpy_in2 : std_logic_vector(47 downto 0);
signal btf_cmpy_in3 : std_logic_vector(47 downto 0);
signal btf_cmpy_in4 : std_logic_vector(47 downto 0);

signal tw2_reg1 : std_logic_vector(31 downto 0);
signal tw3_reg1 : std_logic_vector(31 downto 0);
signal tw4_reg1 : std_logic_vector(31 downto 0);

signal btf_cmpy_out2    : std_logic_vector(79 downto 0);
signal btf_cmpy_out3    : std_logic_vector(79 downto 0);
signal btf_cmpy_out4    : std_logic_vector(79 downto 0);

signal btf_cmpy_vld2    : std_logic;
signal btf_cmpy_vld3    : std_logic;
signal btf_cmpy_vld4    : std_logic;

type delay_type is array(4 downto 0) of std_logic_vector(17 downto 0);  -- Delay 6 cycles.
signal btf1r_delay   : delay_type;
signal btf1i_delay   : delay_type;
signal en_delay      : std_logic_vector(6 downto 0);

signal btf1_ovflo_exp2  : std_logic;
signal btf2_ovflo_exp2  : std_logic;
signal btf3_ovflo_exp2  : std_logic;
signal btf4_ovflo_exp2  : std_logic;
signal btf1_ovflo_exp1  : std_logic;
signal btf2_ovflo_exp1  : std_logic;
signal btf3_ovflo_exp1  : std_logic;
signal btf4_ovflo_exp1  : std_logic;
signal dout1_reg        : std_logic_vector(47 downto 0);
signal dout2_reg        : std_logic_vector(47 downto 0);
signal dout3_reg        : std_logic_vector(47 downto 0);
signal dout4_reg        : std_logic_vector(47 downto 0);


begin

--  Radix-4 Butterfly.
--  btf1 = (in1 +   in2 + in3 +   in4) * tw(1);
--  btf2 = (in1 -1i*in2 - in3 +1i*in4) * tw(2);
--  btf3 = (in1 -   in2 + in3 -   in4) * tw(3);
--  btf4 = (in1 +1i*in2 - in3 -1i*in4) * tw(4);
add_proc: process(i_clk,i_rst)
begin
    if(i_clk'event and i_clk='1') then
        if(i_rst='1') then
            addi1_i <=  (others=>'0');  addi1_r <=  (others=>'0');
            addi2_i <=  (others=>'0');  addi2_r <=  (others=>'0');
            addi3_i <=  (others=>'0');  addi3_r <=  (others=>'0');
            addi4_i <=  (others=>'0');  addi4_r <=  (others=>'0');
            tw2_reg <=  (others=>'0');
            tw3_reg <=  (others=>'0');
            tw4_reg <=  (others=>'0');
            btf_cmpy_in2    <=  (others=>'0');
            btf_cmpy_in3    <=  (others=>'0');
            btf_cmpy_in4    <=  (others=>'0');
            tw2_reg1    <=  (others=>'0');
            tw3_reg1    <=  (others=>'0');
            tw4_reg1    <=  (others=>'0');
        else
            -- Input register.
            addi1_i <=  sxt(iv_din1(31 downto 16),18) + sxt(iv_din2(31 downto 16),18) + sxt(iv_din3(31 downto 16),18) + sxt(iv_din4(31 downto 16),18);  -- fix18_12
            addi1_r <=  sxt(iv_din1(15 downto  0),18) + sxt(iv_din2(15 downto  0),18) + sxt(iv_din3(15 downto  0),18) + sxt(iv_din4(15 downto  0),18);
            addi2_i <=  sxt(iv_din1(31 downto 16),18) - sxt(iv_din2(15 downto  0),18) - sxt(iv_din3(31 downto 16),18) + sxt(iv_din4(15 downto  0),18);
            addi2_r <=  sxt(iv_din1(15 downto  0),18) + sxt(iv_din2(31 downto 16),18) - sxt(iv_din3(15 downto  0),18) - sxt(iv_din4(31 downto 16),18);
            addi3_i <=  sxt(iv_din1(31 downto 16),18) - sxt(iv_din2(31 downto 16),18) + sxt(iv_din3(31 downto 16),18) - sxt(iv_din4(31 downto 16),18);
            addi3_r <=  sxt(iv_din1(15 downto  0),18) - sxt(iv_din2(15 downto  0),18) + sxt(iv_din3(15 downto  0),18) - sxt(iv_din4(15 downto  0),18);
            addi4_i <=  sxt(iv_din1(31 downto 16),18) + sxt(iv_din2(15 downto  0),18) - sxt(iv_din3(31 downto 16),18) - sxt(iv_din4(15 downto  0),18);
            addi4_r <=  sxt(iv_din1(15 downto  0),18) - sxt(iv_din2(31 downto 16),18) - sxt(iv_din3(15 downto  0),18) + sxt(iv_din4(31 downto 16),18);
            tw2_reg <=  iv_tw2; -- fix16_14
            tw3_reg <=  iv_tw3;
            tw4_reg <=  iv_tw4;
            
            -- Complex multiplier data in.
            btf_cmpy_in2    <=  sxt(addi2_i,24) & sxt(addi2_r,24);  -- fix18_12 -> fix24_12
            btf_cmpy_in3    <=  sxt(addi3_i,24) & sxt(addi3_r,24);
            btf_cmpy_in4    <=  sxt(addi4_i,24) & sxt(addi4_r,24);
            tw2_reg1    <=  tw2_reg;    -- fix16_14
            tw3_reg1    <=  tw3_reg;
            tw4_reg1    <=  tw4_reg;
        end if;
    end if;
end process;

-- The first Twiddle Factor is constant 1, so the first butterfly output doesnot need to multiply twddle factor.
delay_proc: process(i_clk,i_rst)
begin
    if(i_clk'event and i_clk='1') then
        if(i_rst='1') then
            btf1i_delay <=  (others=>(others=>'0'));
            en_delay    <=  (others=>'0');
        else
            btf1i_delay(4 downto 1) <=  btf1i_delay(3 downto 0);
            btf1r_delay(4 downto 1) <=  btf1r_delay(3 downto 0);
            btf1i_delay(0)  <=  addi1_i;
            btf1r_delay(0)  <=  addi1_r;

            en_delay(6 downto 1)  <=  en_delay(5 downto 0);
            en_delay(0)   <=  i_en;
        end if;
    end if;
end process;

-- Rounding will be perform after block exponent be declared.
out_proc: process(i_clk,i_rst)
variable v_ovflo_exp2   : std_logic;
variable v_ovflo_exp1   : std_logic;
begin
    if(i_clk'event and i_clk='1') then
        if(i_rst='1') then
            dout1_reg   <=  (others=>'0');
            dout2_reg   <=  (others=>'0');
            dout3_reg   <=  (others=>'0');
            dout4_reg   <=  (others=>'0');
            ov_dout1    <=  (others=>'0');
            ov_dout2    <=  (others=>'0');
            ov_dout3    <=  (others=>'0');
            ov_dout4    <=  (others=>'0');
            ov_ovflo    <=  (others=>'0');
            o_valid     <=  '0';
            btf1_ovflo_exp2 <=  '0';
            btf2_ovflo_exp2 <=  '0';
            btf3_ovflo_exp2 <=  '0';
            btf4_ovflo_exp2 <=  '0';
            btf1_ovflo_exp1 <=  '0';
            btf2_ovflo_exp1 <=  '0';
            btf3_ovflo_exp1 <=  '0';
            btf4_ovflo_exp1 <=  '0';
            
        else
            -- Why there is no truncation protection?
            -- Twiddle factor has the amplitude less or equal than 1, which is fix16_14.
            dout1_reg   <=  btf1i_delay(4) & "000000" & btf1r_delay(4) & "000000";  -- fix24_18
            dout2_reg   <=  btf_cmpy_out2(71 downto 48) & btf_cmpy_out2(31 downto 8); -- fix35_26 -> fix24_18
            dout3_reg   <=  btf_cmpy_out3(71 downto 48) & btf_cmpy_out3(31 downto 8); -- Twiddle factor has the amplitude less than 1 which is fix16_14,
            dout4_reg   <=  btf_cmpy_out4(71 downto 48) & btf_cmpy_out4(31 downto 8); -- so the integer growth bits and addition growth bit can be ignored.
            
            ov_dout1    <=  dout1_reg;
            ov_dout2    <=  dout2_reg;
            ov_dout3    <=  dout3_reg;
            ov_dout4    <=  dout4_reg;
            
            o_valid     <=  en_delay(6);
            
            -- Determine overflow factor in 2 cycles for security.
            if((btf1i_delay(4)(17 downto 15)="000" or btf1i_delay(4)(17 downto 15)="111") and
              (btf1r_delay(4)(17 downto 15)="000" or btf1r_delay(4)(17 downto 15)="111")) then
                btf1_ovflo_exp2 <=  '0';
            else
                btf1_ovflo_exp2 <=  '1';
            end if;
            if((btf_cmpy_out2(71 downto 69)="000" or btf_cmpy_out2(71 downto 69)="111") and
              (btf_cmpy_out2(31 downto 29)="000" or btf_cmpy_out2(31 downto 29)="111")) then
                btf2_ovflo_exp2 <=  '0';
            else
                btf2_ovflo_exp2 <=  '1';
            end if;
            if((btf_cmpy_out3(71 downto 69)="000" or btf_cmpy_out3(71 downto 69)="111") and
              (btf_cmpy_out3(31 downto 29)="000" or btf_cmpy_out3(31 downto 29)="111")) then
                btf3_ovflo_exp2 <=  '0';
            else
                btf3_ovflo_exp2 <=  '1';
            end if;
            if((btf_cmpy_out4(71 downto 69)="000" or btf_cmpy_out4(71 downto 69)="111") and
              (btf_cmpy_out4(31 downto 29)="000" or btf_cmpy_out4(31 downto 29)="111")) then
                btf4_ovflo_exp2 <=  '0';
            else
                btf4_ovflo_exp2 <=  '1';
            end if;
            v_ovflo_exp2  :=  btf1_ovflo_exp2 or btf2_ovflo_exp2 or btf3_ovflo_exp2 or btf4_ovflo_exp2;
            
            if((btf1i_delay(4)(17 downto 16)="00" or btf1i_delay(4)(17 downto 16)="11") and
              (btf1r_delay(4)(17 downto 16)="00" or btf1r_delay(4)(17 downto 16)="11")) then
                btf1_ovflo_exp1 <=  '0';
            else
                btf1_ovflo_exp1 <=  '1';
            end if;
            if((btf_cmpy_out2(71 downto 70)="00" or btf_cmpy_out2(71 downto 70)="11") and
              (btf_cmpy_out2(31 downto 30)="00" or btf_cmpy_out2(31 downto 30)="11")) then
                btf2_ovflo_exp1 <=  '0';
            else
                btf2_ovflo_exp1 <=  '1';
            end if;
            if((btf_cmpy_out3(71 downto 70)="00" or btf_cmpy_out3(71 downto 70)="11") and
              (btf_cmpy_out3(31 downto 30)="00" or btf_cmpy_out3(31 downto 30)="11")) then
                btf3_ovflo_exp1 <=  '0';
            else
                btf3_ovflo_exp1 <=  '1';
            end if;
            if((btf_cmpy_out4(71 downto 70)="00" or btf_cmpy_out4(71 downto 70)="11") and
              (btf_cmpy_out4(31 downto 30)="00" or btf_cmpy_out4(31 downto 30)="11")) then
                btf4_ovflo_exp1 <=  '0';
            else
                btf4_ovflo_exp1 <=  '1';
            end if;
            v_ovflo_exp1  :=  btf1_ovflo_exp1 or btf2_ovflo_exp1 or btf3_ovflo_exp1 or btf4_ovflo_exp1;
            
            if(v_ovflo_exp2='0') then
                ov_ovflo    <=  "00";
            elsif(v_ovflo_exp1='0') then
                ov_ovflo    <=  "01";
            else
                ov_ovflo    <=  "10";
            end if;
--            if((btf1i_delay(4)(17 downto 15)="000" or btf1i_delay(4)(17 downto 15)="111") and
--              (btf1r_delay(4)(17 downto 15)="000" or btf1r_delay(4)(17 downto 15)="111") and
--              (btf_cmpy_out2(72 downto 70)="000" or btf_cmpy_out2(32 downto 30)="111") and
--              (btf_cmpy_out3(72 downto 70)="000" or btf_cmpy_out3(32 downto 30)="111") and
--              (btf_cmpy_out4(72 downto 70)="000" or btf_cmpy_out4(32 downto 30)="111")) then
--                ov_ovflo  <=  "00";
--            elsif((btf1i_delay(4)(17 downto 16)="00" or btf1i_delay(4)(17 downto 16)="11") and
--              (btf1r_delay(4)(17 downto 16)="00" or btf1r_delay(4)(17 downto 16)="11") and
--              (btf_cmpy_out2(72 downto 71)="00" or btf_cmpy_out2(32 downto 31)="11") and
--              (btf_cmpy_out3(72 downto 71)="00" or btf_cmpy_out3(32 downto 31)="11") and
--              (btf_cmpy_out4(72 downto 71)="00" or btf_cmpy_out4(32 downto 31)="11")) then
--                ov_ovflo  <=  "01";
--            else
--                ov_ovflo  <=  "10";
--            end if;
            
        end if;
    end if;
end process;

inst_tw_mult2: tw_mult
  port map (
    aclk                =>  i_clk,
    s_axis_a_tvalid     =>  '1',
    s_axis_a_tdata      =>  btf_cmpy_in2,
    s_axis_b_tvalid     =>  '1',
    s_axis_b_tdata      =>  tw2_reg1,
    m_axis_dout_tvalid  =>  btf_cmpy_vld2,
    m_axis_dout_tdata   =>  btf_cmpy_out2
  );

inst_tw_mult3: tw_mult
  port map (
    aclk                =>  i_clk,
    s_axis_a_tvalid     =>  '1',
    s_axis_a_tdata      =>  btf_cmpy_in3,
    s_axis_b_tvalid     =>  '1',
    s_axis_b_tdata      =>  tw3_reg1,
    m_axis_dout_tvalid  =>  btf_cmpy_vld3,
    m_axis_dout_tdata   =>  btf_cmpy_out3
  );

inst_tw_mult4: tw_mult
  port map (
    aclk                =>  i_clk,
    s_axis_a_tvalid     =>  '1',
    s_axis_a_tdata      =>  btf_cmpy_in4,
    s_axis_b_tvalid     =>  '1',
    s_axis_b_tdata      =>  tw4_reg1,
    m_axis_dout_tvalid  =>  btf_cmpy_vld4,
    m_axis_dout_tdata   =>  btf_cmpy_out4
  );

end Behavioral;
