require 'gosu'
require 'matrix'


class Game < Gosu::Window

    def initialize
        @width = 1920
        @height = 1080
        @pixel_size = 1
        
        super @width, @height, fullscreen: true
        self.caption = "Paint-spel"

        @first_time = true

        @drawing = Hash.new(0x0)

        @color = 0xffffffff

        # (0...@height/@pixel_size).each do |y|
        #     @drawing << []
        #     (0..@width/@pixel_size).each do |x|
        #         @drawing[y] << 0
        #     end
        # end

        # p @drawing

        @i = 0

        # @drawing[10][10] = 0xffffffff
    end
    
 
    def update
        # the cursed point
        @drawing[Vector[-1000000000, -1000000000]] = @color

        if Gosu.button_down?(Gosu::KbLeft)
            @color = 0xffffffff
        end

        if Gosu.button_down?(Gosu::KbRight)
            @color = 0xff2f43ff
        end

        if Gosu.button_down?(Gosu::KbUp)
            @color = 0x00ff00ff
        end

        if Gosu.button_down?(Gosu::KbDown)
            @color = 0xff244f20
        end

        if !(mouse_x < 0 || mouse_x > @width || mouse_y < 0 || mouse_y > @height) && Gosu.button_down?(Gosu::KB_SPACE)
            @drawing[Vector[mouse_x.to_i / @pixel_size, mouse_y.to_i / @pixel_size]] = @color
        end

        if Gosu.button_down?(Gosu::KbEscape)
            close 
        end

    end

    def draw
        @drawing.each do |coord, color|
            
            draw_rect(coord[0] * @pixel_size, coord[1] * @pixel_size, @pixel_size, @pixel_size, Gosu::Color.new(color))
            if @old_value.class != NilClass && (coord - @old_value).magnitude <= 150
                    draw_line(coord[0] * @pixel_size, coord[1] * @pixel_size, Gosu::Color.new(color), @old_value[0] * @pixel_size, @old_value[1] * @pixel_size, Gosu::Color.new(color))
            end
            @old_value = coord
        end

    end

    # hash i hash system????
end


Game.new.show

