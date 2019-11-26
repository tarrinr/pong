-- pong.vhdl
-- Tarrin Rasmussen 11/18/2019

--------------
-- PACKAGES --
--------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


------------
-- ENTITY --
------------

entity PONG is

    port (

        -- Inputs
        ADC_CLK_10 : in std_logic;
        KEY        : in std_logic_vector(1 downto 0); -- 0: RST, 1: START

        -- Outputs
        VGA_R  : out std_logic_vector(3 downto 0);
        VGA_G  : out std_logic_vector(3 downto 0);
        VGA_B  : out std_logic_vector(3 downto 0);
        VGA_HS : out std_logic;
        VGA_VS : out std_logic

    );

end entity PONG;


------------------
-- ARCHITECTURE --
------------------

architecture RTL of PONG is

    --
    -- Types
    --

    type    direction          is (NO_DIR, NNE, NE, ENE, E, ESE, SE, SSE, SSW, SW, WSW, W, WNW, NW, NNW);
    type    position           is record
                                      x : integer range 0 to 639;
                                      y : integer range 0 to 479;
                                  end record;
    type    vga_hor_state_type is (vga_hor_A, vga_hor_B, vga_hor_C, vga_hor_D);
    type    vga_ver_state_type is (vga_ver_A, vga_ver_B, vga_ver_C, vga_ver_D);
    subtype color              is std_logic_vector(3 downto 0);
    subtype reflection         is std_logic_vector(2 downto 0);
    subtype score              is integer range 0 to 5;
    subtype adc_value          is unsigned(11 downto 0);


    --
    -- Constants
    --

    constant INIT_POS : position   := (x => 320, y => 105);
    constant NO_REF   : reflection := "000";
    constant N_S      : reflection := "001";
    constant NNE_SSW  : reflection := "010";
    constant NE_SW    : reflection := "011";
    constant E_W      : reflection := "100";
    constant NNW_SSE  : reflection := "101";
    constant NW_SE    : reflection := "110";


    --
    -- Components
    --

    component pll
	PORT
	(
		inclk0	: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC 
	);
    end component;


    --
    -- Signals
    --

    -- VGA
    signal clk       : std_logic;
    signal line_num  : integer range 0 to 479;
    signal pixel_num : integer range 0 to 639;
    signal vga_en    : std_logic;
    signal h_en      : std_logic;
    signal v_en      : std_logic;

    -- Ball
    signal ball_pos  : position;
    signal ball_dir  : direction;
    signal ref       : reflection;
    signal b_r       : color;
    signal b_g       : color;
    signal b_b       : color;
    signal g1        : score;
    signal g2        : score;

    -- States
    signal vga_hor_state : vga_hor_state_type;
    signal vga_ver_state : vga_ver_state_type;

    --paddle_1 outputs
    signal p1_r     : color;
    signal p1_g     : color;
    signal p1_b     : color;
    signal p1_ref   : reflection;
    signal p1_value : adc_value;

    --paddle_2 outputs
    signal p2_r     : color;
    signal p2_g     : color;
    signal p2_b     : color;
    signal p2_ref   : reflection;
    signal p2_value : adc_value;

    -- score_1 outputs
    signal g1_r : color;
    signal g1_g : color;
    signal g1_b : color;

    -- score_2 outputs
    signal g2_r : color;
    signal g2_g : color;
    signal g2_b : color;

    -- line_1 outputs
    signal l1_r   : color;
    signal l1_g   : color;
    signal l1_b   : color;
    signal l1_ref : reflection;

    -- line_2 outputs
    signal l2_r   : color;
    signal l2_g   : color;
    signal l2_b   : color;
    signal l2_ref : reflection;

    -- line_3 outputs
    signal l3_r   : color;
    signal l3_g   : color;
    signal l3_b   : color;
    signal l3_ref : reflection;

    -- line_4 outputs
    signal l4_r   : color;
    signal l4_g   : color;
    signal l4_b   : color;
    signal l4_ref : reflection;

    -- line_5 outputs
    signal l5_r   : color;
    signal l5_g   : color;
    signal l5_b   : color;
    signal l5_ref : reflection;

    -- line_6 outputs
    signal l6_r   : color;
    signal l6_g   : color;
    signal l6_b   : color;
    signal l6_ref : reflection;

    -- block_1 outputs
    signal b1_r   : color;
    signal b1_g   : color;
    signal b1_b   : color;
    signal b1_ref : reflection;

    -- block_2 outputs
    signal b2_r   : color;
    signal b2_g   : color;
    signal b2_b   : color;
    signal b2_ref : reflection;

    -- block_3 outputs
    signal b3_r   : color;
    signal b3_g   : color;
    signal b3_b   : color;
    signal b3_ref : reflection;

    -- block_4 outputs
    signal b4_r   : color;
    signal b4_g   : color;
    signal b4_b   : color;
    signal b4_ref : reflection;

    -- block_5 outputs
    signal b5_r   : color;
    signal b5_g   : color;
    signal b5_b   : color;
    signal b5_ref : reflection;

    -- block_6 outputs
    signal b6_r   : color;
    signal b6_g   : color;
    signal b6_b   : color;
    signal b6_ref : reflection;

    -- block_7 outputs
    signal b7_r   : color;
    signal b7_g   : color;
    signal b7_b   : color;
    signal b7_ref : reflection;

    -- block_8 outputs
    signal b8_r   : color;
    signal b8_g   : color;
    signal b8_b   : color;
    signal b8_ref : reflection;

    -- block_9 outputs
    signal b9_r   : color;
    signal b9_g   : color;
    signal b9_b   : color;
    signal b9_ref : reflection;

begin

    --
    -- Concurrent signal assignments
    --

    VGA_R  <= l1_r   or l2_r   or l3_r   or l4_r   or l5_r   or l6_r   or b_r    or p1_r   or p2_r   or s1_r   or s2_r   or b1_r   or b2_r   or b3_r   or b4_r   or b5_r   or b6_r   or b7_r   or b8_r   or b9_r;
    VGA_G  <= l1_g   or l2_g   or l3_g   or l4_g   or l5_g   or l6_g   or b_g    or p1_g   or p2_g   or s1_g   or s2_g   or b1_g   or b2_g   or b3_g   or b4_g   or b5_g   or b6_g   or b7_g   or b8_g   or b9_g;
    VGA_B  <= l1_b   or l2_b   or l3_b   or l4_b   or l5_b   or l6_b   or b_b    or p1_b   or p2_b   or s1_b   or s2_b   or b1_b   or b2_b   or b3_b   or b4_b   or b5_b   or b6_b   or b7_b   or b8_b   or b9_b;
    ref    <= l1_ref or l2_ref or l3_ref or l4_ref or l5_ref or l6_ref or p1_ref or p2_ref or b1_ref or b2_ref or b3_ref or b4_ref or b5_ref or b6_ref or b7_ref or b8_ref or b9_ref;
    vga_en <= h_en and v_en;

    --
    -- Processes
    --

    -- Ball position/direction, Moore FSM
        -- Inputs:   clk, KEY(0), ref, line_num, pixel_num
        -- Outputs:  b_r, b_g, b_b, ball_pos, g1, g2
        -- Internal: ball_dir
    ball : process (clk) is
        variable start_dir : direction;
        variable new_dir   : direction;
        variable new_pos   : position;
        variable new_g1    : score;
        variable new_g2    : score;
        variable bounced   : boolean;
    begin
        if rising_edge(clk) then
            if KEY(0) = '1' then
                if (line_num = 479) and (pixel_num = 639) then

                    -- Check for bounce
                    if ref = NO_REF then
                        bounce := 0;
                        new_dir := new_dir;

                    -- New direction
                    elsif bounced = 0 then
                        case ball_dir is
                            when NNE    =>
                                case ref is
                                    when N_S     => new_dir := NNW;
                                    when NNE_SSW => new_dir := NW;----
                                    when NE_SW   => new_dir := ENE;
                                    when E_W     => new_dir := SSE;
                                    when NW_SE   => new_dir := WSW;
                                    when NNW_SSE => new_dir := WNW;
                                    when others  => new_dir := NNE;
                                end case;
                            when NE     =>
                                case ref is
                                    when N_S     => new_dir := NW;
                                    when NNE_SSW => new_dir := NNW;----
                                    when NE_SW   => new_dir := NE;--
                                    when E_W     => new_dir := SE;
                                    when NW_SE   => new_dir := SW;
                                    when NNW_SSE => new_dir := W;
                                    when others  => new_dir := NE;
                                end case;
                            when ENE    =>
                                case ref is
                                    when N_S     => new_dir := WNW;
                                    when NNE_SSW => new_dir := NNW;
                                    when NE_SW   => new_dir := NNE;
                                    when E_W     => new_dir := ESE;
                                    when NW_SE   => new_dir := SSW;
                                    when NNW_SSE => new_dir := WSW;
                                    when others  => new_dir := ENE;
                                end case;
                            when E      =>
                                case ref is
                                    when N_S     => new_dir := W;
                                    when NNE_SSW => new_dir := NW;
                                    when NE_SW   => new_dir := NNE;----
                                    when E_W     => new_dir := E;--
                                    when NW_SE   => new_dir := SSE;----
                                    when NNW_SSE => new_dir := SW;
                                    when others  => new_dir := E;
                                end case;
                            when ESE    =>
                                case ref is
                                    when N_S     => new_dir := WSW;
                                    when NNE_SSW => new_dir := WNW;
                                    when NE_SW   => new_dir := NNW;
                                    when E_W     => new_dir := ENE;
                                    when NW_SE   => new_dir := SSE;
                                    when NNW_SSE => new_dir := SSW;
                                    when others  => new_dir := ESE;
                                end case;
                            when SE     =>
                                case ref is
                                    when N_S     => new_dir := SW;
                                    when NNE_SSW => new_dir := W;
                                    when NE_SW   => new_dir := NW;
                                    when E_W     => new_dir := NE;
                                    when NW_SE   => new_dir := SE;--
                                    when NNW_SSE => new_dir := SSW;----
                                    when others  => new_dir := SE;
                                end case;
                            when SSE    =>
                                case ref is
                                    when N_S     => new_dir := SSW;
                                    when NNE_SSW => new_dir := WSW;
                                    when NE_SW   => new_dir := WNW;
                                    when E_W     => new_dir := NNE;
                                    when NW_SE   => new_dir := ESE;
                                    when NNW_SSE => new_dir := SW;----
                                    when others  => new_dir := SSE;
                                end case;
                            when SSW    =>
                                case ref is
                                    when N_S     => new_dir := SSE;
                                    when NNE_SSW => new_dir := SE;----
                                    when NE_SW   => new_dir := WSW;
                                    when E_W     => new_dir := NNW;
                                    when NW_SE   => new_dir := ENE;
                                    when NNW_SSE => new_dir := ESE;
                                    when others  => new_dir := SSW;
                                end case;
                            when SW     =>
                                case ref is
                                    when N_S     => new_dir := SE;
                                    when NNE_SSW => new_dir := SSE;----
                                    when NE_SW   => new_dir := SW;--
                                    when E_W     => new_dir := NW;
                                    when NW_SE   => new_dir := NE;
                                    when NNW_SSE => new_dir := E;
                                    when others  => new_dir := SW;
                                end case;
                            when WSW    =>
                                case ref is
                                    when N_S     => new_dir := ESE;
                                    when NNE_SSW => new_dir := SSE;
                                    when NE_SW   => new_dir := SSW;
                                    when E_W     => new_dir := WNW;
                                    when NW_SE   => new_dir := NNE;
                                    when NNW_SSE => new_dir := ENE;
                                    when others  => new_dir := WSW;
                                end case;
                            when W      =>
                                case ref is
                                    when N_S     => new_dir := E;
                                    when NNE_SSW => new_dir := SE;
                                    when NE_SW   => new_dir := SSW;----
                                    when E_W     => new_dir := W;--
                                    when NW_SE   => new_dir := NNW;----
                                    when NNW_SSE => new_dir := NE;
                                    when others  => new_dir := W;
                                end case;
                            when WNW    =>
                                case ref is
                                    when N_S     => new_dir := ENE;
                                    when NNE_SSW => new_dir := ESE;
                                    when NE_SW   => new_dir := SSE;
                                    when E_W     => new_dir := WSW;
                                    when NW_SE   => new_dir := NNW;
                                    when NNW_SSE => new_dir := NNE;
                                    when others  => new_dir := WNW;
                                end case;
                            when NW     =>
                                case ref is
                                    when N_S     => new_dir := NE;
                                    when NNE_SSW => new_dir := E;
                                    when NE_SW   => new_dir := SE;
                                    when E_W     => new_dir := SW;
                                    when NW_SE   => new_dir := NW;--
                                    when NNW_SSE => new_dir := NNE;----
                                    when others  => new_dir := NW;
                                end case;
                            when NNW    =>
                                case ref is
                                    when N_S     => new_dir := NNE;
                                    when NNE_SSW => new_dir := ENE;
                                    when NE_SW   => new_dir := ESE;
                                    when E_W     => new_dir := SSW;
                                    when NW_SE   => new_dir := WNW;
                                    when NNW_SSE => new_dir := NE;----
                                    when others  => new_dir := NNW;
                                end case;
                            when NO_DIR =>
                                if (KEY(1) = '0') and (new_g1 < 5) and (new_g2 < 5) then
                                    new_dir := start_dir;
                                else
                                    new_dir := new_dir;
                                end if;
                            when others =>
                                new_dir := new_dir;
                        end case;
                        bounced := 1;
                    else
                        bounced := 1;
                        new_dir := new_dir;
                    end if;

                    -- New position
                    case new_dir is
                        when NNE    => new_pos.x := ball_pos.x + 2; new_pos.y := ball_pos.y - 4;
                        when NE     => new_pos.x := ball_pos.x + 3; new_pos.y := ball_pos.y - 3;
                        when ENE    => new_pos.x := ball_pos.x + 4; new_pos.y := ball_pos.y - 2;
                        when E      => new_pos.x := ball_pos.x + 4; new_pos.y := ball_pos.y + 0;
                        when ESE    => new_pos.x := ball_pos.x + 4; new_pos.y := ball_pos.y + 2;
                        when SE     => new_pos.x := ball_pos.x + 3; new_pos.y := ball_pos.y + 3;
                        when SSE    => new_pos.x := ball_pos.x + 2; new_pos.y := ball_pos.y + 4;
                        when SSW    => new_pos.x := ball_pos.x - 2; new_pos.y := ball_pos.y + 4;
                        when SW     => new_pos.x := ball_pos.x - 3; new_pos.y := ball_pos.y + 3;
                        when WSW    => new_pos.x := ball_pos.x - 4; new_pos.y := ball_pos.y + 2;
                        when W      => new_pos.x := ball_pos.x - 4; new_pos.y := ball_pos.y + 0;
                        when WNW    => new_pos.x := ball_pos.x - 4; new_pos.y := ball_pos.y - 2;
                        when NW     => new_pos.x := ball_pos.x - 3; new_pos.y := ball_pos.y - 3;
                        when NNW    => new_pos.x := ball_pos.x - 2; new_pos.y := ball_pos.y - 4;
                        when others => new_pos := new_pos;
                    end case;

                    -- Check for goal
                    if new_pos.x < 28 then
                        start_dir := W;
                        new_g1    := new_g1;
                        new_g2    := new_g2 + 1;
                        new_pos   := INIT_POS;
                        new_dir   := NO_DIR;
                    elsif new_pos.x > 611 then
                        start_dir := E;
                        new_g1    := new_g1 + 1;
                        new_g2    := new_g2;
                        new_pos   := INIT_POS;
                        new_dir   := NO_DIR;
                    else
                        start_dir := start_dir;
                        new_g1    := new_g1;
                        new_g2    := new_g2;
                        new_pos   := new_pos;
                        new_dir   := new_dir;
                    end if;
                
                else
                    start_dir := start_dir;
                    new_dir   := new_dir;
                    new_pos   := new_pos;
                    new_g1    := new_g1;
                    new_g2    := new_g2;
                end if;
                
                ball_pos <= new_pos;
                ball_dir <= new_dir;
                g1       <= new_g1;
                g2       <= new_g2;

            else
                start_dir := W;
                new_dir   := NO_DIR;
                new_pos   := INIT_POS;
                new_g1    := 0;
                new_g2    := 0;
                ball_pos  <= INIT_POS;
                ball_dir  <= NO_DIR;
                g1        <= 0;
                g2        <= 0;
            end if;
        end if;
    end process;

    -- Ball painting, combinational logic
    ball_paint : process (line_num, pixel_num, ball_pos) is
    begin
        if ((line_num < ball_pos.y + 3)  and (line_num > ball_pos.y - 3)   and
           (pixel_num < ball_pos.x + 5)  and (pixel_num > ball_pos.x - 5)) or
           (((line_num = ball_pos.y + 3) or  (line_num = ball_pos.y - 3))  and
           (pixel_num < ball_pos.x + 4)  and (pixel_num > ball_pos.x - 4)) or
           (((line_num = ball_pos.y + 4) or  (line_num = ball_pos.y - 4))  and
           (pixel_num < ball_pos.x + 3)  and (pixel_num > ball_pos.x - 3)) then
            b_r <= b"1111";
            b_g <= b"1111";
            b_b <= b"1111";
        else
            b_r <= b"0000";
            b_g <= b"0000";
            b_b <= b"0000";
        end if;
    end process;

    -- Paddle 1, combinational logic
    paddle_1 : process (line_num, pixel_num, ball_pos, p1_value) is
        variable pad_pos : integer range 88 to 351;
    begin

        -- Calculate paddle position
        pad_pos := (p1_value / x"FFF") * 263 + 88;

        -- Painting
        if (pixel_num > 39) and (pixel_num < 45) and
           (line_num > (pad_pos - 20)) and (line_num < (pad_pos + 20)) then
            p1_r <= b"1111";
            p1_g <= b"1010";
            p1_b <= b"0000";
        else
            p1_r <= b"0000";
            p1_g <= b"0000";
            p1_b <= b"0000";
        end if;

        -- Ball reflections
        if (ball_pos.x > 44) and (ball_pos.x < 53) then
            if (ball_pos.y > (pad_pos - 5)) and (ball_pos.y < (pad_pos + 5)) then
                p1_ref <= N_S;
            elsif (ball_pos.y > (pad_pos - 15)) and (ball_pos.y < pad_pos) then
                p1_ref <= NNW_SSE;
            elsif (ball_pos.y < (pad_pos + 15)) and (ball_pos.y > pad_pos) then
                p1_ref <= NNE_SSW;
            elsif (ball_pos.y > (pad_pos - 20)) and (ball_pos.y < pad_pos) then
                p1_ref <= NW_SE;
            elsif (ball_pos.y < (pad_pos + 20)) and (ball_pos.y > pad_pos) then
                p1_ref <= NE_SW;
            else
                p1_ref <= NO_REF;
            end if;
        else
            p1_ref <= NO_REF;
        end if;

    end process;

    -- Paddle 2

    -- Score 1, combinational logic
    score_1 : process (line_num, pixel_num, g1) is
    begin
        case g1 is
            when 0      =>
                if ((line_num > 409)  and (line_num < 440)   and -- left vertical
                   (pixel_num > 129)  and (pixel_num < 134)) or
                   ((line_num > 409)  and (line_num < 440)   and -- right vertical
                   (pixel_num > 145)  and (pixel_num < 150)) or
                   ((line_num > 409)  and (line_num < 414)   and -- top horizontal
                   (pixel_num > 133)  and (pixel_num < 146)) or
                   ((line_num > 435)  and (line_num < 440)   and -- bottom horizontal
                   (pixel_num > 133)  and (pixel_num < 146)) then
                    g1_r <= b"1111";
                    g1_g <= b"1111";
                    g1_b <= b"1111";
                else
                    g1_r <= b"0000";
                    g1_g <= b"0000";
                    g1_b <= b"0000";
                end if;
            when 1      =>
                if (line_num > 409)  and (line_num < 440)  and --right vertical
                   (pixel_num > 145) and (pixel_num < 150) then
                    g1_r <= b"1111";
                    g1_g <= b"1111";
                    g1_b <= b"1111";
                else
                    g1_r <= b"0000";
                    g1_g <= b"0000";
                    g1_b <= b"0000";
                end if;
            when 2      =>
                if ((line_num > 409)  and (line_num < 414)   and -- top horizontal
                   (pixel_num > 129)  and (pixel_num < 146)) or
                   ((line_num > 409)  and (line_num < 422)   and -- right vertical
                   (pixel_num > 145)  and (pixel_num < 150)) or
                   ((line_num > 422)  and (line_num < 427)   and -- middle horizontal
                   (pixel_num > 133)  and (pixel_num < 146)) or
                   ((line_num > 426)  and (line_num < 440)   and -- left vertical
                   (pixel_num > 129)  and (pixel_num < 134)) or
                   ((line_num > 435)  and (line_num < 440)   and -- bottom horizontal
                   (pixel_num > 133)  and (pixel_num < 150)) then
                    g1_r <= b"1111";
                    g1_g <= b"1111";
                    g1_b <= b"1111";
                else
                    g1_r <= b"0000";
                    g1_g <= b"0000";
                    g1_b <= b"0000";
                end if;
            when 3      =>
                if ((line_num > 409)  and (line_num < 440)   and -- right vertical
                   (pixel_num > 145)  and (pixel_num < 150)) or
                   ((line_num > 409)  and (line_num < 414)   and -- top horizontal
                   (pixel_num > 129)  and (pixel_num < 146)) or
                   ((line_num > 422)  and (line_num < 427)   and -- middle horizontal
                   (pixel_num > 133)  and (pixel_num < 146)) or
                   ((line_num > 435)  and (line_num < 440)   and -- bottom horizontal
                   (pixel_num > 129)  and (pixel_num < 146)) then
                    g1_r <= b"1111";
                    g1_g <= b"1111";
                    g1_b <= b"1111";
                else
                    g1_r <= b"0000";
                    g1_g <= b"0000";
                    g1_b <= b"0000";
                end if;
            when 4      =>
                if ((line_num > 409)  and (line_num < 427)   and -- left vertical
                   (pixel_num > 129)  and (pixel_num < 134)) or
                   ((line_num > 409)  and (line_num < 440)   and -- right vertical
                   (pixel_num > 145)  and (pixel_num < 150)) or
                   ((line_num > 422)  and (line_num < 427)   and -- middle horizontal
                   (pixel_num > 133)  and (pixel_num < 146)) then
                    g1_r <= b"1111";
                    g1_g <= b"1111";
                    g1_b <= b"1111";
                else
                    g1_r <= b"0000";
                    g1_g <= b"0000";
                    g1_b <= b"0000";
                end if;
            when 5      =>
                if ((line_num > 409)  and (line_num < 414)   and -- top horizontal
                   (pixel_num > 133)  and (pixel_num < 150)) or
                   ((line_num > 409)  and (line_num < 422)   and -- left vertical
                   (pixel_num > 129)  and (pixel_num < 134)) or
                   ((line_num > 422)  and (line_num < 427)   and -- middle horizontal
                   (pixel_num > 133)  and (pixel_num < 146)) or
                   ((line_num > 422)  and (line_num < 440)   and -- right vertical
                   (pixel_num > 145)  and (pixel_num < 150)) or
                   ((line_num > 435)  and (line_num < 440)   and -- bottom horizontal
                   (pixel_num > 129)  and (pixel_num < 146)) then
                    g1_r <= b"1111";
                    g1_g <= b"1111";
                    g1_b <= b"1111";
                else
                    g1_r <= b"0000";
                    g1_g <= b"0000";
                    g1_b <= b"0000";
                end if;
            when others =>
                g1_r <= b"0000";
                g1_g <= b"0000";
                g1_b <= b"0000";
        end case;
    end process;

    -- Score 2, combinational logic
    

    -- Top boundary line, combinational logic
    line_1 : process (line_num, pixel_num, ball_pos) is
    begin

        -- Painting
        if (line_num < 60)   and (line_num > 57)  and
           (pixel_num < 622) and (pixel_num > 17) then
            l1_r <= b"1111";
            l1_g <= b"1111";
            l1_b <= b"1111";
        else
            l1_r <= b"0000";
            l1_g <= b"0000";
            l1_b <= b"0000";
        end if;

        -- Ball reflections
        if ball_pos.y < 68 then
            if ball_pos.x < 28 then
                l1_ref <= NE_SW;
            elsif ball_pos.x > 611 then
                l1_ref <= NW_SE;
            else
                l1_ref <= E_W;
            end if;
        else
            l1_ref <= NO_REF;
        end if;

    end process;

    -- Left top boundary line, combinational logic
    line_2 : process (line_num, pixel_num, ball_pos) is
    begin

        -- Painting
        if (line_num < 185) and (line_num > 59)  and
           (pixel_num < 20) and (pixel_num > 17) then
            l2_r <= b"1111";
            l2_g <= b"1111";
            l2_b <= b"1111";
        else
            l2_r <= b"0000";
            l2_g <= b"0000";
            l2_b <= b"0000";
        end if;

        -- Ball reflections
        if (ball_pos.x < 28)  and  (ball_pos.y > 67) and
           (ball_pos.y < 185) then
            l2_ref <= N_S;
        else
            l2_ref <= NO_REF;
        end if;

    end process;

    -- Right top boundary line, combinational logic
    line_3 : process (line_num, pixel_num, ball_pos) is
    begin

        -- Painting
        if (line_num < 185)  and (line_num > 59)  and
           (pixel_num < 622) and (pixel_num > 619) then
            l3_r <= b"1111";
            l3_g <= b"1111";
            l3_b <= b"1111";
        else
            l3_r <= b"0000";
            l3_g <= b"0000";
            l3_b <= b"0000";
        end if;

        -- Ball reflections
        if (ball_pos.x > 611) and  (ball_pos.y > 67) and
            (ball_pos.y < 185) then
            l3_ref <= N_S;
        else
            l3_ref <= NO_REF;
        end if;

    end process;

    -- Left bottom boundary line, combinational logic
    line_4 : process (line_num, pixel_num, ball_pos) is
    begin

        -- Painting
        if (line_num < 380) and (line_num > 254)  and
           (pixel_num < 20) and (pixel_num > 17) then
            l4_r <= b"1111";
            l4_g <= b"1111";
            l4_b <= b"1111";
        else
            l4_r <= b"0000";
            l4_g <= b"0000";
            l4_b <= b"0000";
        end if;

        -- Ball reflections
        if (ball_pos.x < 28)  and  (ball_pos.y > 254) and
            (ball_pos.y < 380) then
            l4_ref <= N_S;
        else
            l4_ref <= NO_REF;
        end if;

    end process;

    -- Right bottom boundary line, combinational logic
    line_5 : process (line_num, pixel_num, ball_pos) is
    begin

        -- Painting
        if (line_num < 380)  and (line_num > 254)  and
           (pixel_num < 622) and (pixel_num > 619) then
            l5_r <= b"1111";
            l5_g <= b"1111";
            l5_b <= b"1111";
        else
            l5_r <= b"0000";
            l5_g <= b"0000";
            l5_b <= b"0000";
        end if;

        -- Ball reflections
        if (ball_pos.x > 611) and  (ball_pos.y > 254) and
            (ball_pos.y < 380) then
            l5_ref <= N_S;
        else
            l5_ref <= NO_REF;
        end if;

    end process;
    
    -- Bottom boundary line, combinational logic
    line_6 : process (line_num, pixel_num, ball_pos) is
    begin

        -- Painting
        if (line_num < 382)  and (line_num > 379)  and
           (pixel_num < 622) and (pixel_num > 17) then
            l6_r <= b"1111";
            l6_g <= b"1111";
            l6_b <= b"1111";
        else
            l6_r <= b"0000";
            l6_g <= b"0000";
            l6_b <= b"0000";
        end if;

        -- Ball reflections
        if ball_pos.y > 371 then
            if ball_pos.x < 28 then
                l6_ref <= NW_SE;
            elsif ball_pos.x > 611 then
                l6_ref <= NE_SW;
            else
                l6_ref <= E_W;
            end if;
        else
            l6_ref <= NO_REF;
        end if;

    end process;

    -- Top left block, combinational logic
    block_1 : process (line_num, pixel_num, ball_pos) is
    begin

        -- Painting
        if (line_num > 149)  and (line_num < 170)  and
           (pixel_num > 129) and (pixel_num < 150) then
            b1_r <= b"1111";
            b1_g <= b"0000";
            b1_b <= b"0000";
        else
            b1_r <= b"0000";
            b1_g <= b"0000";
            b1_b <= b"0000";
        end if;

        -- Ball reflections
        if (ball_pos.y > 141)  and (ball_pos.y < 150)  then

            if (ball_pos.x > 121) and (ball_pos.x < 130) then
                b1_ref <= NE_SW;
            elsif (ball_pos.x > 129) and (ball_pos.x < 150) then
                b1_ref <= E_W;
            elsif (ball_pos.x > 149) and (ball_pos.x < 158) then
                b1_ref <= NW_SE;
            else
                b1_ref <= NO_REF;
            end if;

        elsif (ball_pos.y > 149)  and (ball_pos.y < 170)  then

            if (ball_pos.x > 121) and (ball_pos.x < 130) then
                b1_ref <= N_S;
            elsif (ball_pos.x > 149) and (ball_pos.x < 158) then
                b1_ref <= N_S;
            else
                b1_ref <= NO_REF;
            end if;

        elsif (ball_pos.y > 169)  and (ball_pos.y < 178)  then

            if (ball_pos.x > 121) and (ball_pos.x < 130) then
                b1_ref <= NW_SE;
            elsif (ball_pos.x > 129) and (ball_pos.x < 150) then
                b1_ref <= E_W;
            elsif (ball_pos.x > 149) and (ball_pos.x < 158) then
                b1_ref <= NE_SW;
            else
                b1_ref <= NO_REF;
            end if;

        else
            b1_ref <= NO_REF;
        end if;

    end process;

    -- Top middle left block, combinational logic
    block_2 : process (line_num, pixel_num, ball_pos) is
    begin

        -- Painting
        if (line_num > 149)  and (line_num < 170)  and
           (pixel_num > 249) and (pixel_num < 270) then
            b2_r <= b"1111";
            b2_g <= b"0000";
            b2_b <= b"0000";
        else
            b2_r <= b"0000";
            b2_g <= b"0000";
            b2_b <= b"0000";
        end if;

        -- Ball reflections
        if (ball_pos.y > 141)  and (ball_pos.y < 150)  then

            if (ball_pos.x > 241) and (ball_pos.x < 250) then
                b2_ref <= NE_SW;
            elsif (ball_pos.x > 249) and (ball_pos.x < 270) then
                b2_ref <= E_W;
            elsif (ball_pos.x > 269) and (ball_pos.x < 278) then
                b2_ref <= NW_SE;
            else
                b2_ref <= NO_REF;
            end if;

        elsif (ball_pos.y > 149)  and (ball_pos.y < 170)  then

            if (ball_pos.x > 241) and (ball_pos.x < 250) then
                b2_ref <= N_S;
            elsif (ball_pos.x > 269) and (ball_pos.x < 278) then
                b2_ref <= N_S;
            else
                b2_ref <= NO_REF;
            end if;

        elsif (ball_pos.y > 169)  and (ball_pos.y < 178)  then

            if (ball_pos.x > 241) and (ball_pos.x < 250) then
                b2_ref <= NW_SE;
            elsif (ball_pos.x > 249) and (ball_pos.x < 270) then
                b2_ref <= E_W;
            elsif (ball_pos.x > 269) and (ball_pos.x < 278) then
                b2_ref <= NE_SW;
            else
                b2_ref <= NO_REF;
            end if;

        else
            b2_ref <= NO_REF;
        end if;

    end process;

    -- Top middle right block, combinational logic
    block_3 : process (line_num, pixel_num, ball_pos) is
    begin

        -- Painting
        if (line_num > 149)  and (line_num < 170)  and
           (pixel_num > 369) and (pixel_num < 390) then
            b3_r <= b"1111";
            b3_g <= b"0000";
            b3_b <= b"0000";
        else
            b3_r <= b"0000";
            b3_g <= b"0000";
            b3_b <= b"0000";
        end if;

        -- Ball reflections
        if (ball_pos.y > 141)  and (ball_pos.y < 150)  then

            if (ball_pos.x > 361) and (ball_pos.x < 370) then
                b3_ref <= NE_SW;
            elsif (ball_pos.x > 369) and (ball_pos.x < 390) then
                b3_ref <= E_W;
            elsif (ball_pos.x > 389) and (ball_pos.x < 398) then
                b3_ref <= NW_SE;
            else
                b3_ref <= NO_REF;
            end if;

        elsif (ball_pos.y > 149)  and (ball_pos.y < 170)  then

            if (ball_pos.x > 361) and (ball_pos.x < 370) then
                b3_ref <= N_S;
            elsif (ball_pos.x > 389) and (ball_pos.x < 398) then
                b3_ref <= N_S;
            else
                b3_ref <= NO_REF;
            end if;

        elsif (ball_pos.y > 169)  and (ball_pos.y < 178)  then

            if (ball_pos.x > 361) and (ball_pos.x < 370) then
                b3_ref <= NW_SE;
            elsif (ball_pos.x > 369) and (ball_pos.x < 390) then
                b3_ref <= E_W;
            elsif (ball_pos.x > 389) and (ball_pos.x < 398) then
                b3_ref <= NE_SW;
            else
                b3_ref <= NO_REF;
            end if;

        else
            b3_ref <= NO_REF;
        end if;

    end process;

    -- Top right block, combinational logic
    block_4 : process (line_num, pixel_num, ball_pos) is
    begin

        -- Painting
        if (line_num > 149)  and (line_num < 170)  and
           (pixel_num > 489) and (pixel_num < 510) then
            b4_r <= b"1111";
            b4_g <= b"0000";
            b4_b <= b"0000";
        else
            b4_r <= b"0000";
            b4_g <= b"0000";
            b4_b <= b"0000";
        end if;

        -- Ball reflections
        if (ball_pos.y > 141)  and (ball_pos.y < 150)  then

            if (ball_pos.x > 481) and (ball_pos.x < 490) then
                b4_ref <= NE_SW;
            elsif (ball_pos.x > 489) and (ball_pos.x < 510) then
                b4_ref <= E_W;
            elsif (ball_pos.x > 509) and (ball_pos.x < 518) then
                b4_ref <= NW_SE;
            else
                b4_ref <= NO_REF;
            end if;

        elsif (ball_pos.y > 149)  and (ball_pos.y < 170)  then

            if (ball_pos.x > 481) and (ball_pos.x < 490) then
                b4_ref <= N_S;
            elsif (ball_pos.x > 389) and (ball_pos.x < 398) then
                b4_ref <= N_S;
            else
                b4_ref <= NO_REF;
            end if;

        elsif (ball_pos.y > 169)  and (ball_pos.y < 178)  then

            if (ball_pos.x > 481) and (ball_pos.x < 490) then
                b4_ref <= NW_SE;
            elsif (ball_pos.x > 489) and (ball_pos.x < 510) then
                b4_ref <= E_W;
            elsif (ball_pos.x > 509) and (ball_pos.x < 518) then
                b4_ref <= NE_SW;
            else
                b4_ref <= NO_REF;
            end if;

        else
            b4_ref <= NO_REF;
        end if;

    end process;

    -- Middle block, combinational logic
    block_5 : process (line_num, pixel_num, ball_pos) is
    begin

        -- Painting
        if (line_num > 209)  and (line_num < 230)  and
           (pixel_num > 309) and (pixel_num < 330) then
            b5_r <= b"1111";
            b5_g <= b"0000";
            b5_b <= b"0000";
        else
            b5_r <= b"0000";
            b5_g <= b"0000";
            b5_b <= b"0000";
        end if;

        -- Ball reflections
        if (ball_pos.y > 201)  and (ball_pos.y < 210)  then

            if (ball_pos.x > 301) and (ball_pos.x < 310) then
                b5_ref <= NE_SW;
            elsif (ball_pos.x > 309) and (ball_pos.x < 330) then
                b5_ref <= E_W;
            elsif (ball_pos.x > 329) and (ball_pos.x < 338) then
                b5_ref <= NW_SE;
            else
                b5_ref <= NO_REF;
            end if;

        elsif (ball_pos.y > 209)  and (ball_pos.y < 230)  then

            if (ball_pos.x > 301) and (ball_pos.x < 310) then
                b5_ref <= N_S;
            elsif (ball_pos.x > 329) and (ball_pos.x < 338) then
                b5_ref <= N_S;
            else
                b5_ref <= NO_REF;
            end if;

        elsif (ball_pos.y > 229)  and (ball_pos.y < 238)  then

            if (ball_pos.x > 301) and (ball_pos.x < 310) then
                b5_ref <= NW_SE;
            elsif (ball_pos.x > 309) and (ball_pos.x < 330) then
                b5_ref <= E_W;
            elsif (ball_pos.x > 329) and (ball_pos.x < 338) then
                b5_ref <= NE_SW;
            else
                b5_ref <= NO_REF;
            end if;

        else
            b5_ref <= NO_REF;
        end if;

    end process;

    -- Bottom left block, combinational logic
    block_6 : process (line_num, pixel_num, ball_pos) is
    begin

        -- Painting
        if (line_num > 269)  and (line_num < 290)  and
           (pixel_num > 129) and (pixel_num < 150) then
            b6_r <= b"1111";
            b6_g <= b"0000";
            b6_b <= b"0000";
        else
            b6_r <= b"0000";
            b6_g <= b"0000";
            b6_b <= b"0000";
        end if;

        -- Ball reflections
        if (ball_pos.y > 261)  and (ball_pos.y < 270)  then

            if (ball_pos.x > 121) and (ball_pos.x < 130) then
                b6_ref <= NE_SW;
            elsif (ball_pos.x > 129) and (ball_pos.x < 150) then
                b6_ref <= E_W;
            elsif (ball_pos.x > 149) and (ball_pos.x < 158) then
                b6_ref <= NW_SE;
            else
                b6_ref <= NO_REF;
            end if;

        elsif (ball_pos.y > 269)  and (ball_pos.y < 290)  then

            if (ball_pos.x > 121) and (ball_pos.x < 130) then
                b6_ref <= N_S;
            elsif (ball_pos.x > 149) and (ball_pos.x < 158) then
                b6_ref <= N_S;
            else
                b6_ref <= NO_REF;
            end if;

        elsif (ball_pos.y > 289)  and (ball_pos.y < 298)  then

            if (ball_pos.x > 121) and (ball_pos.x < 130) then
                b6_ref <= NW_SE;
            elsif (ball_pos.x > 129) and (ball_pos.x < 150) then
                b6_ref <= E_W;
            elsif (ball_pos.x > 149) and (ball_pos.x < 158) then
                b6_ref <= NE_SW;
            else
                b6_ref <= NO_REF;
            end if;

        else
            b6_ref <= NO_REF;
        end if;

    end process;
    
    -- Bottom middle left block, combinational logic
    block_7 : process (line_num, pixel_num, ball_pos) is
    begin

        -- Painting
        if (line_num > 269)  and (line_num < 290)  and
           (pixel_num > 249) and (pixel_num < 270) then
            b7_r <= b"1111";
            b7_g <= b"0000";
            b7_b <= b"0000";
        else
            b7_r <= b"0000";
            b7_g <= b"0000";
            b7_b <= b"0000";
        end if;

        -- Ball reflections
        if (ball_pos.y > 261)  and (ball_pos.y < 270)  then

            if (ball_pos.x > 241) and (ball_pos.x < 250) then
                b7_ref <= NE_SW;
            elsif (ball_pos.x > 249) and (ball_pos.x < 270) then
                b7_ref <= E_W;
            elsif (ball_pos.x > 269) and (ball_pos.x < 278) then
                b7_ref <= NW_SE;
            else
                b7_ref <= NO_REF;
            end if;

        elsif (ball_pos.y > 269)  and (ball_pos.y < 290)  then

            if (ball_pos.x > 241) and (ball_pos.x < 250) then
                b7_ref <= N_S;
            elsif (ball_pos.x > 269) and (ball_pos.x < 278) then
                b7_ref <= N_S;
            else
                b7_ref <= NO_REF;
            end if;

        elsif (ball_pos.y > 289)  and (ball_pos.y < 298)  then

            if (ball_pos.x > 241) and (ball_pos.x < 250) then
                b7_ref <= NW_SE;
            elsif (ball_pos.x > 249) and (ball_pos.x < 270) then
                b7_ref <= E_W;
            elsif (ball_pos.x > 269) and (ball_pos.x < 278) then
                b7_ref <= NE_SW;
            else
                b7_ref <= NO_REF;
            end if;

        else
            b7_ref <= NO_REF;
        end if;

    end process;

    -- Bottom middle right block, combinational logic
    block_8 : process (line_num, pixel_num, ball_pos) is
    begin

        -- Painting
        if (line_num > 269)  and (line_num < 290)  and
           (pixel_num > 369) and (pixel_num < 390) then
            b8_r <= b"1111";
            b8_g <= b"0000";
            b8_b <= b"0000";
        else
            b8_r <= b"0000";
            b8_g <= b"0000";
            b8_b <= b"0000";
        end if;

        -- Ball reflections
        if (ball_pos.y > 261)  and (ball_pos.y < 270)  then

            if (ball_pos.x > 361) and (ball_pos.x < 370) then
                b8_ref <= NE_SW;
            elsif (ball_pos.x > 369) and (ball_pos.x < 390) then
                b8_ref <= E_W;
            elsif (ball_pos.x > 389) and (ball_pos.x < 398) then
                b8_ref <= NW_SE;
            else
                b8_ref <= NO_REF;
            end if;

        elsif (ball_pos.y > 269)  and (ball_pos.y < 290)  then

            if (ball_pos.x > 361) and (ball_pos.x < 370) then
                b8_ref <= N_S;
            elsif (ball_pos.x > 389) and (ball_pos.x < 398) then
                b8_ref <= N_S;
            else
                b8_ref <= NO_REF;
            end if;

        elsif (ball_pos.y > 289)  and (ball_pos.y < 298)  then

            if (ball_pos.x > 361) and (ball_pos.x < 370) then
                b8_ref <= NW_SE;
            elsif (ball_pos.x > 369) and (ball_pos.x < 390) then
                b8_ref <= E_W;
            elsif (ball_pos.x > 389) and (ball_pos.x < 398) then
                b8_ref <= NE_SW;
            else
                b8_ref <= NO_REF;
            end if;

        else
            b8_ref <= NO_REF;
        end if;

    end process;

    -- Bottom right block, combinational logic
    block_9 : process (line_num, pixel_num, ball_pos) is
    begin

        -- Painting
        if (line_num > 269)  and (line_num < 290)  and
           (pixel_num > 489) and (pixel_num < 510) then
            b9_r <= b"1111";
            b9_g <= b"0000";
            b9_b <= b"0000";
        else
            b9_r <= b"0000";
            b9_g <= b"0000";
            b9_b <= b"0000";
        end if;

        -- Ball reflections
        if (ball_pos.y > 261)  and (ball_pos.y < 270)  then

            if (ball_pos.x > 481) and (ball_pos.x < 490) then
                b9_ref <= NE_SW;
            elsif (ball_pos.x > 489) and (ball_pos.x < 510) then
                b9_ref <= E_W;
            elsif (ball_pos.x > 509) and (ball_pos.x < 518) then
                b9_ref <= NW_SE;
            else
                b9_ref <= NO_REF;
            end if;

        elsif (ball_pos.y > 269)  and (ball_pos.y < 290)  then

            if (ball_pos.x > 481) and (ball_pos.x < 490) then
                b9_ref <= N_S;
            elsif (ball_pos.x > 389) and (ball_pos.x < 398) then
                b9_ref <= N_S;
            else
                b9_ref <= NO_REF;
            end if;

        elsif (ball_pos.y > 289)  and (ball_pos.y < 298)  then

            if (ball_pos.x > 481) and (ball_pos.x < 490) then
                b9_ref <= NW_SE;
            elsif (ball_pos.x > 489) and (ball_pos.x < 510) then
                b9_ref <= E_W;
            elsif (ball_pos.x > 509) and (ball_pos.x < 518) then
                b9_ref <= NE_SW;
            else
                b9_ref <= NO_REF;
            end if;

        else
            b9_ref <= NO_REF;
        end if;

    end process;

    -- VGA horizontal signals, Moore FSM
        -- Inputs:   clk, KEY(0)
        -- Outputs:  h_en, VGA_HS, pixel_num
        -- Internal: vga_hor_state, cnt
    vga_hor_fsm : process (clk) is
        variable cnt : natural;
    begin
        if rising_edge(clk) then
            if KEY(0) = '1' then

                case vga_hor_state is

                    -- A state
                    when vga_hor_A =>
                        if cnt = 15 then
                            vga_hor_state <= vga_hor_B;
                            h_en          <= '0';
                            VGA_HS        <= '0';
                            pixel_num     <= 0;
                        else
                            vga_hor_state <= vga_hor_A;
                            h_en          <= '0';
                            VGA_HS        <= '1';
                            pixel_num     <= 0;
                        end if;
                        cnt := cnt + 1;

                    -- B state
                    when vga_hor_B =>
                        if cnt = 111 then
                            vga_hor_state <= vga_hor_C;
                            h_en          <= '0';
                            VGA_HS        <= '1';
                            pixel_num     <= 0;
                        else
                            vga_hor_state <= vga_hor_B;
                            h_en          <= '0';
                            VGA_HS        <= '0';
                            pixel_num     <= 0;
                        end if;
                        cnt := cnt + 1;

                    -- C state
                    when vga_hor_C =>
                        if cnt = 159 then
                            vga_hor_state <= vga_hor_D;
                            h_en          <= '1';
                            VGA_HS        <= '1';
                            pixel_num     <= 0;
                        else
                            vga_hor_state <= vga_hor_C;
                            h_en          <= '0';
                            VGA_HS        <= '1';
                            pixel_num     <= 0;
                        end if;
                        cnt := cnt + 1;

                    -- D state
                    when vga_hor_D =>
                        if cnt = 799 then
                            vga_hor_state <= vga_hor_A;
                            h_en          <= '0';
                            VGA_HS        <= '1';
                            pixel_num     <= 0;
                            cnt           := 0;
                        else
                            vga_hor_state <= vga_hor_D;
                            h_en          <= '1';
                            VGA_HS        <= '1';
                            pixel_num     <= cnt - 159;
                            cnt           := cnt + 1;
                        end if;

                    when others =>
                        vga_hor_state <= vga_hor_A;
                        h_en          <= '0';
                        VGA_HS        <= '1';
                        pixel_num     <= 0;
                        cnt           := 0;
                    
                end case;

            else
                vga_hor_state <= vga_hor_A;
                h_en          <= '0';
                VGA_HS        <= '1';
                pixel_num     <= 0;
                cnt           := 0;
            end if;
        end if;
    end process;

    -- VGA vertical signals, Moore FSM
        -- Inputs:   clk, KEY(0)
        -- Outputs:  v_en, VGA_VS, line_num
        -- Internal: vga_ver_state, cnt
    vga_ver_fsm : process (clk) is
        variable cnt : natural;
    begin
        if rising_edge(clk) then
            if KEY(0) = '1' then

                case vga_ver_state is

                    -- A state
                    when vga_ver_A =>
                        if cnt = 7999 then
                            vga_ver_state <= vga_ver_B;
                            v_en          <= '0';
                            VGA_VS        <= '0';
                            line_num      <= 0;
                        else
                            vga_ver_state <= vga_ver_A;
                            v_en          <= '0';
                            VGA_VS        <= '1';
                            line_num      <= 0;
                        end if;
                        cnt := cnt + 1;

                    -- B state
                    when vga_ver_B =>
                        if cnt = 9599 then
                            vga_ver_state <= vga_ver_C;
                            v_en          <= '0';
                            VGA_VS        <= '1';
                            line_num      <= 0;
                        else
                            vga_ver_state <= vga_ver_B;
                            v_en          <= '0';
                            VGA_VS        <= '0';
                            line_num      <= 0;
                        end if;
                        cnt := cnt + 1;

                    -- C state
                    when vga_ver_C =>
                        if cnt = 35999 then
                            vga_ver_state <= vga_ver_D;
                            v_en          <= '1';
                            VGA_VS        <= '1';
                            line_num      <= 0;
                        else
                            vga_ver_state <= vga_ver_C;
                            v_en          <= '0';
                            VGA_VS        <= '1';
                            line_num      <= 0;
                        end if;
                        cnt := cnt + 1;

                    -- D state
                    when vga_ver_D =>
                        if cnt = 419999 then
                            vga_ver_state <= vga_ver_A;
                            v_en          <= '0';
                            VGA_VS        <= '1';
                            line_num      <= 0;
                            cnt           := 0;
                        else
                            vga_ver_state <= vga_ver_D;
                            v_en          <= '1';
                            VGA_VS        <= '1';
                            line_num      <= (cnt - 35999) / 800;
                            cnt           := cnt + 1;
                        end if;

                    when others =>
                        vga_ver_state <= vga_ver_A;
                        v_en          <= '0';
                        VGA_VS        <= '1';
                        line_num      <= 0;
                        cnt           := 0;
                    
                end case;
                
            else
                vga_ver_state <= vga_ver_A;
                v_en          <= '0';
                VGA_VS        <= '1';
                line_num      <= 0;
                cnt           := 0;
            end if;
        end if;
    end process;

    --
    -- Component instantiation
    --

    pll_inst : pll PORT MAP (
		inclk0 => ADC_CLK_10,
		c0	   => clk
	);

end architecture RTL;
