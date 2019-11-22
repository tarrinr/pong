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
        CLK : in std_logic;

        -- Outputs
        R :
        G :
        B :


    );

end entity PONG;


------------------
-- ARCHITECTURE --
------------------

architecture RTL of PONG is

    --
    -- Types
    --

    type color      is std_logic_vector(3 downto 0);
    type reflection is (NO_REF, N_S, NNE_SSW, NE_SW, E_W, NNW_SSE, NW_SE);
    type direction  is (NO_DIR, NNE, NE, ENE, E, ESE, SE, SSE, SSW, SW, WSW, W, WNW, NW, NNW);
    type field_pos  is
        record
            x : integer range 0 to 599;
            y : integer range 0 to 319;
        end record;


    --
    -- Constants
    --



    --
    -- Signals
    --

    -- VGA
    signal line_num  : integer range 0 to 479;
    signal pixel_num : integer range 0 to 639;
    signal vga_en    : std_logic;
    signal h_en      : std_logic;
    signal v_en      : std_logic;

    -- Ball
    signal ball_pos  : field_pos;
    signal ball_dir  : direction;
    signal ref       : reflection;

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

begin

    --
    -- Concurrent signal assignments
    --

    R   <= l1_r   or l2_r   or l3_r   or l4_r   or l5_r   or l6_r;
    G   <= l1_g   or l2_g   or l3_g   or l4_g   or l5_g   or l6_g;
    B   <= l1_b   or l2_b   or l3_b   or l4_b   or l5_b   or l6_b;
    ref <= l1_ref or l2_ref or l3_ref or l4_ref or l5_ref or l6_ref;

    --
    -- Processes
    --

    -- Ball position/direction, Moore FSM
    ball : process (CLK) is
        var
    begin

        -- Position/direction
        case ball_dir is
            when NO_DIR =>
                ball_pos <= ball_pos;
                ball_dir <= NO_DIR;
            when NNE    =>
                case ref is
                    when NO_REF  => ball_pos.x <= ball_pos.x + 2; ball_pos.y <= ball_pos.y - 4; ball_dir <= NNE;
                    when N_S     => ball_pos.x <= ball_pos.x - 2; ball_pos.y <= ball_pos.y - 4; ball_dir <= NNW;
                    when NNE_SSW => ball_pos.x <= ball_pos.x - 3; ball_pos.y <= ball_pos.y - 3; ball_dir <= NW;
                    when NE_SW   => ball_pos.x <= ball_pos.x + 4; ball_pos.y <= ball_pos.y - 2; ball_dir <= ENE;
                    when E_W     => ball_pos.x <= ball_pos.x + 2; ball_pos.y <= ball_pos.y + 4; ball_dir <= SSE;
                    when NNW_SSE => ball_pos.x <= ball_pos.x - 3; ball_pos.y <= ball_pos.y - 3; ball_dir <= NW;
                    when NW_SE   => ball_pos.x <= ball_pos.x - 4; ball_pos.y <= ball_pos.y + 2; ball_dir <= WSW;
                    when others  => ball_pos.x <= ball_pos.x + 2; ball_pos.y <= ball_pos.y - 4; ball_dir <= NNE;
                end case;
            when NE     =>
                case ref is
                    when NO_REF  => ball_pos.x <= ball_pos.x + 3; ball_pos.y <= ball_pos.y - 3; ball_dir <= NE;
                    when N_S     => ball_pos.x <= ball_pos.x - 3; ball_pos.y <= ball_pos.y - 3; ball_dir <= NW;
                    when NNE_SSW => ball_pos.x <= ball_pos.x + 4; ball_pos.y <= ball_pos.y - 2; ball_dir <= ENE;
                    when NE_SW   => ball_pos.x <= ball_pos.x + 3; ball_pos.y <= ball_pos.y - 3; ball_dir <= NE;
                    when E_W     => ball_pos.x <= ball_pos.x + 3; ball_pos.y <= ball_pos.y + 3; ball_dir <= SE;
                    when NNW_SSE => ball_pos.x <= ball_pos.x - 4; ball_pos.y <= ball_pos.y;     ball_dir <= W;
                    when NW_SE   => ball_pos.x <= ball_pos.x - 4; ball_pos.y <= ball_pos.y + 4; ball_dir <= SW;
                    when others  => ball_pos.x <= ball_pos.x + 3; ball_pos.y <= ball_pos.y - 3; ball_dir <= NE;
                end case;
            when ENE    =>
                case ref is
                    when NO_REF  => ball_pos.x <= ball_pos.x + 4; ball_pos.y <= ball_pos.y - 2; ball_dir <= ENE;
                    when N_S     => ball_pos.x <= ball_pos.x - 4; ball_pos.y <= ball_pos.y - 2; ball_dir <= WNW;
                    when NNE_SSW => ball_pos.x <= ball_pos.x - 2; ball_pos.y <= ball_pos.y - 4; ball_dir <= NNW;
                    when NE_SW   => ball_pos.x <= ball_pos.x + 2; ball_pos.y <= ball_pos.y - 4; ball_dir <= NNE;
                    when E_W     => ball_pos.x <= ball_pos.x + 4; ball_pos.y <= ball_pos.y + 2; ball_dir <= ESE;
                    when NNW_SSE => ball_pos.x <= ball_pos.x - 4; ball_pos.y <= ball_pos.y + 2; ball_dir <= WSW;
                    when NW_SE   => ball_pos.x <= ball_pos.x - 2; ball_pos.y <= ball_pos.y + 4; ball_dir <= SSW;
                    when others  => ball_pos.x <= ball_pos.x + 4; ball_pos.y <= ball_pos.y - 2; ball_dir <= ENE;
                end case;
            when E      =>
                case ref is
                    when NO_REF  => ball_pos.x <= ball_pos.x + 4; ball_pos.y <= ball_pos.y;     ball_dir <= E;
                    when N_S     => ball_pos.x <= ball_pos.x - 4; ball_pos.y <= ball_pos.y;     ball_dir <= W;
                    when NNE_SSW => ball_pos.x <= ball_pos.x - 3; ball_pos.y <= ball_pos.y - 3; ball_dir <= NW;
                    when NE_SW   => ball_pos.x <= ball_pos.x - 2; ball_pos.y <= ball_pos.y - 4; ball_dir <= NNW;
                    when E_W     => ball_pos.x <= ball_pos.x + 4; ball_pos.y <= ball_pos.y - 2; ball_dir <= ENE;
                    when NNW_SSE => ball_pos.x <= ball_pos.x - 4; ball_pos.y <= ball_pos.y + 4; ball_dir <= SW;
                    when NW_SE   => ball_pos.x <= ball_pos.x - 2; ball_pos.y <= ball_pos.y + 4; ball_dir <= SSW;
                    when others  => ball_pos.x <= ball_pos.x + 4; ball_pos.y <= ball_pos.y;     ball_dir <= E;
                end case;
            when ESE    =>
                case ref is
                    when NO_REF  => ball_pos.x <= ball_pos.x + 4; ball_pos.y <= ball_pos.y + 2; ball_dir <= ESE;
                    when N_S     => ball_pos.x <= ball_pos.x - 4; ball_pos.y <= ball_pos.y + 2; ball_dir <= WSW;
                    when NNE_SSW => ball_pos.x <= ball_pos.x - 4; ball_pos.y <= ball_pos.y - 2; ball_dir <= WNW;
                    when NE_SW   => ball_pos.x <= ball_pos.x - 2; ball_pos.y <= ball_pos.y - 4; ball_dir <= NNW;
                    when E_W     => ball_pos.x <= ball_pos.x + 4; ball_pos.y <= ball_pos.y - 2; ball_dir <= ENE;
                    when NNW_SSE => ball_pos.x <= ball_pos.x - 2; ball_pos.y <= ball_pos.y + 4; ball_dir <= SSW;
                    when NW_SE   => ball_pos.x <= ball_pos.x + 2; ball_pos.y <= ball_pos.y + 4; ball_dir <= SSE;
                    when others  => ball_pos.x <= ball_pos.x + 4; ball_pos.y <= ball_pos.y + 2; ball_dir <= ESE;
                end case;
            when SE     =>
                case ref is
                    when NO_REF  => ball_pos.x <= ball_pos.x + 3; ball_pos.y <= ball_pos.y + 3; ball_dir <= SE;
                    when N_S     => ball_pos.x <= ball_pos.x - 4; ball_pos.y <= ball_pos.y + 4; ball_dir <= SW;
                    when NNE_SSW => ball_pos.x <= ball_pos.x - 4; ball_pos.y <= ball_pos.y;     ball_dir <= W;
                    when NE_SW   => ball_pos.x <= ball_pos.x - 3; ball_pos.y <= ball_pos.y - 3; ball_dir <= NW;
                    when E_W     => ball_pos.x <= ball_pos.x + 3; ball_pos.y <= ball_pos.y - 3; ball_dir <= NE;
                    when NNW_SSE => ball_pos.x <= ball_pos.x - 2; ball_pos.y <= ball_pos.y + 4; ball_dir <= SSW;
                    when NW_SE   => ball_pos.x <= ball_pos.x + 3; ball_pos.y <= ball_pos.y + 3; ball_dir <= SE;
                    when others  => ball_pos.x <= ball_pos.x + 3; ball_pos.y <= ball_pos.y + 3; ball_dir <= SE;
                end case;
            when SSE    =>
                case ref is
                    when NO_REF  => ball_pos.x <= ball_pos.x + 2; ball_pos.y <= ball_pos.y + 4; ball_dir <= SSE;
                    when N_S     => ball_pos.x <= ball_pos.x - 2; ball_pos.y <= ball_pos.y + 4; ball_dir <= SSW;
                    when NNE_SSW => ball_pos.x <= ball_pos.x - 4; ball_pos.y <= ball_pos.y + 2; ball_dir <= WSW;
                    when NE_SW   => ball_pos.x <= ball_pos.x - 4; ball_pos.y <= ball_pos.y - 2; ball_dir <= WNW;
                    when E_W     => ball_pos.x <= ball_pos.x + 2; ball_pos.y <= ball_pos.y - 4; ball_dir <= NNE;
                    when NNW_SSE => ball_pos.x <= ball_pos.x - 4; ball_pos.y <= ball_pos.y + 4; ball_dir <= SW;
                    when NW_SE   => ball_pos.x <= ball_pos.x + 4; ball_pos.y <= ball_pos.y + 2; ball_dir <= ESE;
                    when others  => ball_pos.x <= ball_pos.x + 2; ball_pos.y <= ball_pos.y + 4; ball_dir <= SSE;
                end case;
            when SSW    =>
                case ref is
                    when NO_REF  => ball_pos.x <= ball_pos.x - 2; ball_pos.y <= ball_pos.y + 4; ball_dir <= SSW;
                    when N_S     => ball_pos.x <= ball_pos.x + 2; ball_pos.y <= ball_pos.y + 4; ball_dir <= SSE;
                    when NNE_SSW => ball_pos.x <= ball_pos.x + 3; ball_pos.y <= ball_pos.y + 3; ball_dir <= SE;
                    when NE_SW   => ball_pos.x <= ball_pos.x - 4; ball_pos.y <= ball_pos.y + 2; ball_dir <= WSW;
                    when E_W     => ball_pos.x <= ball_pos.x - 2; ball_pos.y <= ball_pos.y - 4; ball_dir <= NNW;
                    when NNW_SSE => ball_pos.x <= ball_pos.x - 4; ball_pos.y <= ball_pos.y + 4; ball_dir <= SW;
                    when NW_SE   => ball_pos.x <= ball_pos.x + 4; ball_pos.y <= ball_pos.y + 2; ball_dir <= ESE;
                    when others  => ball_pos.x <= ball_pos.x - 2; ball_pos.y <= ball_pos.y + 4; ball_dir <= SSW;
                end case;
            when SW     =>
            when WSW    =>
            when W      =>
            when WNW    =>
            when NW     =>
            when NNW    =>
        end case;

    end process;

    -- Top boundary line, combinational logic
    line_1 : process is
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
    line_2 : process is
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
    line_3 : process is
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
    line_4 : process is
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
    line_5 : process is
        begin
    
            -- Painting
            if (line_num < 380)  and (line_num > 254)  and
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
            if (ball_pos.x > 611) and  (ball_pos.y > 254) and
               (ball_pos.y < 380) then
                l3_ref <= N_S;
            else
                l3_ref <= NO_REF;
            end if;
    
        end process;
    
    -- Bottom boundary line, combinational logic
    line_6 : process is
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

end architecture RTL;
