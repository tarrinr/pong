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

    type field_pos is
        record
            x : integer range 0 to 599;
            y : integer range 0 to 319;
        end record;
    type color is std_logic_vector(3 downto 0);
    type reflection is (NO_REF, N_S, NNE_SSW, NE_SW, ENE_WSW, E_W, NNW_SSE, NW_SE, WNW_ESE);


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

    -- line_1 outputs
    signal l1_r   : color;
    signal l1_g   : color;
    signal l1_b   : color;
    signal l1_ref : reflection;

begin

    --
    -- Asyncronous assignments
    --

    --
    -- Processes
    --

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
    
    -- Bottom boundary line, combinational logic
    line_6 : process is
        begin
    
            -- Painting
            if (line_num < 322)   and (line_num > 319)  and
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
            if ball_pos.y > 311 then
                if ball_pos.x < 28 then
                    l1_ref <= NW_SE;
                elsif ball_pos.x > 611 then
                    l1_ref <= NE_SW;
                else
                    l1_ref <= E_W;
                end if;
            else
                l1_ref <= NO_REF;
            end if;
    
        end process; 

end architecture RTL;
