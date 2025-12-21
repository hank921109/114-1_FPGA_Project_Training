library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.std_logic_arith.ALL; -- 需要這個才能做簡單的算術運算

entity HW4_VGA is
    Port ( clk      : in  STD_LOGIC;       -- FPGA時鐘 (100MHz)
           rst      : in  STD_LOGIC;       -- 重置信號
           h_sync    : out STD_LOGIC;       -- 水平同步信號
           v_sync    : out STD_LOGIC;       -- 垂直同步信號
           o_red    : out STD_LOGIC_VECTOR (3 downto 0);  -- 紅色
           o_green  : out STD_LOGIC_VECTOR (3 downto 0);  -- 綠色
           o_blue   : out STD_LOGIC_VECTOR (3 downto 0)   -- 藍色
           );
end HW4_VGA;

architecture Behavioral of HW4_VGA is
    -- VGA參數定義 (640x480 @ 60Hz)
    constant H_SYNC_CYCLES  : integer := 96;
    constant H_BACK_PORCH   : integer := 48;
    constant H_ACTIVE_VIDEO : integer := 640;
    constant H_FRONT_PORCH  : integer := 16;
    
    constant V_SYNC_CYCLES  : integer := 2;
    constant V_BACK_PORCH   : integer := 33;
    constant V_ACTIVE_VIDEO : integer := 480;
    constant V_FRONT_PORCH  : integer := 10;

    signal divclk: STD_LOGIC_VECTOR(1 downto 0);
    signal fclk: STD_LOGIC;
    -- 定義計數器範圍
    signal h_count : integer range 0 to 799 := 0; 
    signal v_count : integer range 0 to 524 := 0; 

begin
    -- 1. 水平與垂直計數器
    process(fclk, rst)
    begin
        if rst = '0' then
            h_count <= 0;
            v_count <= 0;
        elsif rising_edge(fclk) then
            if h_count = 799 then
                h_count <= 0;
                if v_count = 524 then
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
                end if;
            else
                h_count <= h_count + 1;
            end if;
        end if;
    end process;

    -- 2. 同步信號產生
    h_sync <= '0' when (h_count < H_SYNC_CYCLES) else '1';
    v_sync <= '0' when (v_count < V_SYNC_CYCLES) else '1';

    -- 3. 顯示顏色與圖形邏輯 
    process(fclk, rst)
    begin
        if rst = '0' then
            o_red   <= "0000";
            o_green <= "0000";
            o_blue  <= "0000";
        elsif rising_edge(fclk) then
            -- 預設背景為黑色
            o_red   <= "0000";
            o_green <= "0000";
            o_blue  <= "0000";

            -- 確保只在顯示區域內繪圖 (避開同步信號與Porch區)
            -- 顯示區大約從 h=144, v=35 開始
            
            -- [圖形1] 紅色正方形 (Square)
            -- 邏輯：X 在範圍內 且 Y 在範圍內
            -- 位置：左側 (X約200), Y中間 (Y約240), 寬度80
            if (h_count > 160 and h_count < 240) and (v_count > 200 and v_count < 280) then
                o_red   <= "1111";
                o_green <= "0000";
                o_blue  <= "0000";
            
            -- [圖形2] 綠色三角形 (Triangle)
            -- 邏輯：利用絕對值模擬斜率。當 Y 往下增加時，X 的容許範圍變寬
            -- 位置：中間 (X中心 320), 頂點 Y=180, 底邊 Y=280
            elsif (v_count >= 180 and v_count <= 280) and 
                  (abs(h_count - 320) < (v_count - 180)) then
                o_red   <= "0000";
                o_green <= "1111";
                o_blue  <= "0000";

            -- [圖形3] 藍色圓形 (Circle)
            -- 邏輯：(x-x0)^2 + (y-y0)^2 <= r^2
            -- 位置：右側 (X中心 500), Y中心 240, 半徑 50
            elsif ((h_count - 500) * (h_count - 500) + (v_count - 240) * (v_count - 240) <= 50 * 50) then
                o_red   <= "0000";
                o_green <= "0000";
                o_blue  <= "1111";
            end if;

        end if;
    end process;

    -- 4. 時鐘分頻 (100MHz -> 25MHz)
    process(clk, rst)
    begin
        if rst = '0' then
            divclk <= (others => '0');
        elsif rising_edge(clk) then
            divclk <= divclk + 1;
        end if;
    end process;
    
    fclk <= divclk(1); -- Pixel Clock

end Behavioral;