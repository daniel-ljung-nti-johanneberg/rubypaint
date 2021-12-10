require 'gosu'
require 'matrix'


class Game < Gosu::Window

    def initialize
        @width = 1920
        @height = 1080
        @pixel_size = 2
        
        super @width, @height, fullscreen: true
        self.caption = "Paint-spel"

        @first_time = true

        @drawing = []

        @draw_section = Hash.new(0x0)

        @released = false

        @color = 0xffffffff

        @i = 0

        @text = Gosu::Image.from_text(self, "COLOR", Gosu.default_font_name, 45)
    end
 
    def update

        if Gosu.button_down?(Gosu::KbLeft)
            @color = 0xffffffff
        end

        if Gosu.button_down?(Gosu::KbRight)
            @color = 0xff_0000ff
        end

        if Gosu.button_down?(Gosu::KbUp)
            @color = 0xff_ff0000
        end

        if Gosu.button_down?(Gosu::KbDown)
            @color = 0xff_00ff00
        end

        if Gosu.button_down?(Gosu::KbZ)
            @drawing.delete_at(-1)
            sleep(0.1)
        end

        if !(mouse_x < 0 || mouse_x > @width || mouse_y < 0 || mouse_y > @height) && Gosu.button_down?(Gosu::KB_SPACE)
            (@draw_section[Vector[mouse_x.to_i / @pixel_size, mouse_y.to_i / @pixel_size]] = @color)
            @released = true
        elsif @released
            @drawing << @draw_section
            @draw_section = Hash.new(0x0)
            @released = false
        end

        if Gosu.button_down?(Gosu::KbEscape)
            close 
        end

    end

    def draw
        @text.draw(10, 20, 0, 1, 1, Gosu::Color.new(@color))

        @drawing.each do |index|
            @old_value = nil
            index.each do |coord, color|
                draw_rect(coord[0] * @pixel_size, coord[1] * @pixel_size, @pixel_size, @pixel_size, Gosu::Color.new(color))
                if @old_value.class != NilClass
                    draw_line(coord[0] * @pixel_size, coord[1] * @pixel_size, Gosu::Color.new(color), @old_value[0] * @pixel_size, @old_value[1] * @pixel_size, Gosu::Color.new(color))
                end
                @old_value = coord
            end
        end
        @draw_section.each do |coord, color|
            draw_rect(coord[0] * @pixel_size, coord[1] * @pixel_size, @pixel_size, @pixel_size, Gosu::Color.new(color))
        end
    end
end


Game.new.show

