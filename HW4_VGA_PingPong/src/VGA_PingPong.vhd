library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity VGA_PingPong is
port(
	clk : in std_logic;
	rst : in std_logic;
	btn_l : in std_logic;
	btn_r : in std_logic;
	btn_s : in std_logic;
	
    hsync   : out STD_LOGIC;
    vsync   : out STD_LOGIC;
    o_red   : out STD_LOGIC_VECTOR (3 downto 0);
    o_green : out STD_LOGIC_VECTOR (3 downto 0);
    o_blue  : out STD_LOGIC_VECTOR (3 downto 0);
	LED     : out std_logic_vector (7 downto 0)
	);

end VGA_PingPong;

architecture Behavioral of VGA_PingPong is
	signal ball    : std_logic_vector(7 downto 0);
	signal score_l : std_logic_vector(3 downto 0);
	signal score_r : std_logic_vector(3 downto 0);
	type   state_type is (initial,move_left,move_right,win_l,win_r,ready_ml,ready_mr);
	signal state   : state_type;
	signal pre_state : state_type;
	signal i : integer range 0 to 30;
    signal i2 : integer range 0 to 3;
    signal lfsr : std_logic_vector (1 downto 0);
    signal feedback : std_logic;
    signal v_clk : std_logic;
	
	
	 
	
	constant hRez        : integer := 640;  -- horizontal resolution
    constant hStartSync  : integer := 656;  -- start of horizontal sync pulse
    constant hEndSync    : integer := 752;  -- end of horizontal sync pulse
    constant hMaxCount   : integer := 800;  -- total pixels per line

    constant vRez        : integer := 480;  -- vertical resolution
    constant vStartSync  : integer := 490;  -- start of vertical sync pulse
    constant vEndSync    : integer := 492;  -- end of vertical sync pulse
    constant vMaxCount   : integer := 525;  -- total lines per frame
	
	constant ball_r      : integer := 40;
	signal h_shift     : integer;
	signal h_shift_b   : integer;

    signal hCount : integer := 0;
    signal vCount : integer := 0;
	signal div    : std_logic_vector(60 downto 0);
    signal e_clk  : std_logic;
	
	signal vga_clk : std_logic;
	
	signal block_out : STD_LOGIC_VECTOR(7 downto 0);
	signal addr      : STD_LOGIC_VECTOR(16 downto 0);
	signal data_in   : STD_LOGIC_VECTOR(7 downto 0);
	signal address   : integer range 0 to 76800;
	

begin
LED <= ball;


fsm : process(clk, rst, btn_l, btn_r, btn_s)  --clk
begin
	if rst = '1' then
		state <= initial;
	elsif rising_edge(clk) then
		pre_state <= state;
		case state is
			when initial =>
				if btn_l = '1' then
					state <= move_right;
				end if;
			when move_right =>
				if ball = "10000000" and btn_r = '1' then
					state <= move_left;
					
                elsif (ball = "00000000") or (ball > "00000001" and btn_r = '1') then
				    state <= win_l;
				end if;
			when move_left =>
				if ball = "00000001" and btn_l = '1' then
					state <= move_right;
					
                elsif (ball = "00000000") or (ball > "10000000" and btn_l = '1') then
				    state <= win_r;
				end if;
			when win_l =>
				if score_l = "0100" then
					state <= initial;
				else
					if btn_l = '1' then
						state <= ready_mr;
					end if;
				end if;
			when win_r =>
				if score_r = "0100" then
					state <= initial;
				else
					if btn_r = '1' then
						state <= ready_ml;
					end if;
				end if;
			when ready_mr =>
				if ball = "00000001" then 
					state <= move_right;
				else state <= ready_mr;
				end if;
			when ready_ml =>
				if ball = "10000000" then 
					state <= move_left;
				else 
					state <= ready_ml;
				end if;
		end case;
	end if;
end process;

led_show : process(e_clk, rst, btn_l, btn_r, btn_s)  --e_clk
begin
	if rst = '1' then
		ball <= "00000001";
	elsif rising_edge(e_clk) then
		case state is
			when initial =>
				ball <= "00000001";
			when move_right =>
				ball <= ball(6 downto 0) & '0';
			when move_left =>
				ball <= '0' & ball(7 downto 1);
			when win_l =>
				ball <= score_r & score_l;
			when win_r =>
				ball <= score_r & score_l;
			when ready_mr =>
				ball <= "00000001";
			when ready_ml =>
				ball <= "10000000";
		end case;
	end if;
end process;

score : process(clk, rst, btn_l, btn_r, btn_s)  --clk
begin
	if rst = '1' then
		score_l <= "0000";
		score_r <= "0000";
	elsif rising_edge(clk) then
		case state is
			when initial =>
                score_l <= "0000";
				score_r <= "0000";
			when move_right =>
				null;
			when move_left =>
                null;
			when win_l =>
			    if pre_state = move_right then
					score_l <= score_l + '1';
				else 
					score_l <= score_l;
				end if;
			when win_r =>
				if pre_state = move_left then
					score_r <= score_r + '1';
				else 
					score_r <= score_r;
				end if;
			when ready_mr =>
				null;
			when ready_ml =>
				null;
		end case;
	end if;
end process;

div_clk : process(clk, rst)
begin
    if rst = '1' then
        div <= (others => '0');
    elsif rising_edge(clk) then
        div <= div + 1;
    end if;
end process;
e_clk <= div(24);
process(e_clk, rst)
begin
    if rst = '1' then
        lfsr <= "01";
        i <= 0;
        i2 <= 0;
    elsif rising_edge(e_clk) then
        feedback <= lfsr(1) xor lfsr(0);
        lfsr    <= feedback & lfsr(1);
        i2      <= to_integer(signed(lfsr));
        i <= i2 + 23;
    end if;
end process;
v_clk <= div(i);

div_clk_vga : process(clk)
	begin
		if rst='1' then 
			div<=(others=>'0');
		elsif rising_edge(clk) then 
			div<=div+1;
		End if;
end process;
vga_clk <= div(1);

hsync_vsync : process(vga_clk)
    begin
        if rising_edge(vga_clk) then
            -- Horizontal counter
            if hCount = hMaxCount - 1 then
                hCount <= 0;
                -- Vertical counter
                if vCount = vMaxCount - 1 then
                    vCount <= 0;
                else
                    vCount <= vCount + 1;
                end if;
            else
                hCount <= hCount + 1;
            end if;
        end if;
    end process;

hsync <= '0' when (hCount >= hStartSync and hCount < hEndSync) else '1';
vsync <= '0' when (vCount >= vStartSync and vCount < vEndSync) else '1';


vga_show : process(rst,vga_clk)  
begin
	if rst = '1' then
		addr  <= "00000000000000000";
	elsif (hCount <= hRez and vCount <= vRez) then --é¡¯ç¤º??ƒç?„ç?‹å?ç¢¼
		if (hCount - h_shift)**2 + (vCount - 400)**2 <= ball_r**2 then
			o_green <= "1111";
		end if;
	elsif rising_edge(vga_clk) then
		if (hCount <= hRez and vCount <= vRez) then
			if (hCount >= (0+h_shift_b ) and hCount <= (319+h_shift_b) and vCount >= 0 and vCount <= 239) then
				addr  <= addr + 1;
				o_red   <= block_out(7 downto 4); 
				o_green <= block_out(7 downto 4);
				o_blue  <= block_out(7 downto 4);
			elsif (hCount = (320+h_shift_b ) and vCount = 240) then
				addr  <= "00000000000000000";
			end if;
		end if;
	end if;


	

end process;

vga_h : process(e_clk, rst, btn_l, btn_r, btn_s)  --e_clk
begin
	if rst = '1' then
		h_shift <= 64;
	elsif rising_edge(e_clk) then
		case state is
			when initial =>
				h_shift <= 64;
			when move_right =>
				h_shift <= h_shift + 64;
			when move_left =>
				h_shift <= h_shift - 64;
			when win_l =>
				h_shift <= 64;
			when win_r =>
				h_shift <= 576;
			when ready_mr =>
				h_shift <= 64;
			when ready_ml =>
				h_shift <= 576;
		end case;
	end if;
end process;
bram_h : process(e_clk, rst, btn_l, btn_r, btn_s)  --e_clk
begin
	if rst = '1' then
		h_shift_b <= 0;
	elsif rising_edge(e_clk) then
		case state is
			when initial =>
				h_shift_b <= 0;
			when move_right =>
				h_shift_b <= h_shift_b + 40;
			when move_left =>
				h_shift_b <= h_shift_b - 40;
			when win_l =>
				h_shift_b <= 0;
			when win_r =>
				h_shift_b <= 320;
			when ready_mr =>
				h_shift_b <= 0;
			when ready_ml =>
				h_shift_b <= 320;
		end case;
	end if;
end process;


end Behavioral;