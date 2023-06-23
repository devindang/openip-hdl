----------------------------------------------------------------------------------
--  Engineer:       Devin
--  Email:          balddevin@outlook.com
--  Description:    Twiddle Factor table for 4096 points FFT. Only one quarters of twiddle
--                  factors are stored, the others are obtained by coordinate mapping.
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

entity tw_tab is
  Port (
    i_clk       : in  std_logic;
    i_rst       : in  std_logic;
    i_en        : in  std_logic;
    iv_addr     : in  std_logic_vector(11 downto 0);
    ov_tw       : out std_logic_vector(31 downto 0);
    o_vld       : out std_logic
  );
end tw_tab;

architecture Behavioral of tw_tab is

component tw_rom IS
  PORT (
    a : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END component;

constant zeros  : std_logic_vector(15 downto 0):=(others=>'0');
signal quadrant : std_logic_vector(1 downto 0);
signal tw_addr  : std_logic_vector(9 downto 0);
signal tw_dout  : std_logic_vector(31 downto 0);
signal en_reg1  : std_logic;

begin

-- Mapping address of [0:4095] to [0:1023];
addr_map_proc: process(i_clk,i_rst)
variable addr_tmp   : std_logic_vector(11 downto 0);
begin
    if(i_clk'event and i_clk='1') then
        if(i_rst='1') then
            quadrant    <=  (others=>'0');
            tw_addr     <=  (others=>'0');
        else
            if(iv_addr>=3072) then
                addr_tmp    :=  iv_addr-3072;
                quadrant    <=  "00";   -- First quadrant.
            elsif(iv_addr>=2048) then
                addr_tmp    :=  iv_addr-2048;
                quadrant    <=  "01";   -- Second quadrant.
            elsif(iv_addr>=1024) then
                addr_tmp    :=  iv_addr-1024;
                quadrant    <=  "10";   -- Third quadrant.
            else
                addr_tmp    :=  iv_addr;
                quadrant    <=  "11";   -- Fourth quadrant.
            end if;
            tw_addr <=  addr_tmp(9 downto 0);
        end if;
    end if;
end process;

-- Mapping cordinates.
cord_map_proc: process(i_clk,i_rst)
begin
    if(i_clk'event and i_clk='1') then
        if(i_rst='1') then
            ov_tw   <=  (others=>'0');
            en_reg1 <=  '0';
            o_vld   <=  '0';
        else
            en_reg1 <=  i_en;
            o_vld   <=  en_reg1;
            case quadrant is
                when "11" =>
                    ov_tw(31 downto 16) <=  tw_dout(31 downto 16);  -- Imaginary Parts.
                    ov_tw(15 downto 0)  <=  tw_dout(15 downto 0);   -- Real Parts.
                when "10" =>
                    ov_tw(31 downto 16) <=  zeros - tw_dout(15 downto 0);
                    ov_tw(15 downto 0)  <=  tw_dout(31 downto 16);
                when "01" =>
                    ov_tw(31 downto 16) <=  zeros - tw_dout(31 downto 16);
                    ov_tw(15 downto 0)  <=  zeros - tw_dout(15 downto 0);
                when "00" =>
                    ov_tw(31 downto 16) <=  tw_dout(15 downto 0);
                    ov_tw(15 downto 0)  <=  zeros - tw_dout(31 downto 16);
                when others => null;
            end case;
        end if;
    end if;
end process;

inst_tw_rom: tw_rom
  port map (
    a       =>  tw_addr,
    spo     =>  tw_dout
  );

end Behavioral;
