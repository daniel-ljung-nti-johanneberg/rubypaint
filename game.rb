require 'gosu'
require 'matrix'




class Game < Gosu::Window

    attr_accessor :menu


    def initialize

        
        @width = 1920
        @height = 1080

        @input_pos = 0

        @last_time = Time.now

        @delay = 0.3
    
        @pixel_size = 2
        
        super @width, @height, fullscreen: true
        self.caption = "Paint-spel"

        @drawing = []

        @menu = Menu.new(0)

        @draw_section = Hash.new(0x0)

        @released = false

        @color = 0xffffffff

        @players = []

        @i = 0

        @word_list = ["gurka","äpple","sten","hus", "snowboard"]

        @random_word = @word_list[rand(0..(@word_list.length-1))]

        @text = Gosu::Image.from_text(self, "COLOR", Gosu.default_font_name, 45)

        @word = Gosu::Image.from_text(self, @random_word, Gosu.default_font_name, 90)

        @reveal_word = false
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
            @input_pos -= 1
        end

        if Gosu.button_down?(Gosu::KbDown)
            @color = 0xff_00ff00
            @input_pos += 1
        end

        if Gosu.button_down?(Gosu::KbZ)
            @drawing.delete_at(-1)
            sleep(0.1)
        end

        if Gosu.button_down?(Gosu::KbR)
            @reveal_word = true
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

        if @input_pos > 30 

            @input_pos = 30

        elsif @input_pos < 0

            @input_pos = 0

        end

        if Time.now - @last_time > @delay
            @menu = Menu.new(@input_pos)
            @last_time = Time.now
        end



    end

    def draw
        
        @menu.draw()

        @text.draw(10, 20, 0, 1, 1, Gosu::Color.new(@color))
        if @reveal_word
            @word.draw(10, 50, 0, 1, 1, Gosu::Color.new(@color))
        else
            @word.draw(10, 50, 0, 1, 1, Gosu::Color.new(0x00_000000))
        end

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


class Menu

    attr_accessor :input_pos

    def initialize(input_pos)

        @position = input_pos

        @title = Gosu::Image.from_text(self, "paintly: more than art", Gosu.default_font_name, 90)

        @play = Gosu::Image.from_text(self, "Start game", Gosu.default_font_name, 60)

        @settings = Gosu::Image.from_text(self, "Settings", Gosu.default_font_name, 60)

        @exit = Gosu::Image.from_text(self, "Exit", Gosu.default_font_name, 60)
        
    end

    def draw

        @title.draw(600, 100, 0, 1, 1, Gosu::Color.new(0xffffffff))

        case @position
        when 0..10
            @play.draw(600, 200, 0, 1, 1, Gosu::Color.new(0xffffffff))
            @settings.draw(600, 260, 0, 1, 1, Gosu::Color.new(0xff_808080))
            @exit.draw(600, 320, 0, 1, 1, Gosu::Color.new(0xff_808080))
        when 11..20
            @play.draw(600, 200, 0, 1, 1, Gosu::Color.new(0xff_808080))
            @settings.draw(600, 260, 0, 1, 1, Gosu::Color.new(0xffffffff))
            @exit.draw(600, 320, 0, 1, 1, Gosu::Color.new(0xff_808080))
        when 21..30
            @play.draw(600, 200, 0, 1, 1, Gosu::Color.new(0xff_808080))
            @settings.draw(600, 260, 0, 1, 1, Gosu::Color.new(0xff_808080))
            @exit.draw(600, 320, 0, 1, 1, Gosu::Color.new(0xffffffff))
        end

    end


end


Game.new.show

