require 'gosu'
require 'matrix'
class Game < Gosu::Window


    def initialize

        
        @width = 1920
        @height = 1080

        @input_pos = 0

        @last_time = Time.now

        @lasttimer_time = Time.now

        @delay = 0.1

        @pixel_size = 2
        
        super @width, @height, fullscreen: true
        self.caption = "Paint-spel"

        @drawing = []

        @menu = Menu.new()

        @draw_section = Hash.new(0x0)

        @released = false

        @color = 0xffffffff

        @i = 0

        @word_list = ["gurka","äpple","sten","hus", "snowboard"]

        @random_word = @word_list[rand(0..(@word_list.length-1))]

        @text = Gosu::Image.from_text(self, "COLOR", Gosu.default_font_name, 45)

        @word = Gosu::Image.from_text(self, @random_word, Gosu.default_font_name, 90)

        @reveal_word = false

        @action = "home"

        @plrs = 0

        @crrnt_plr = 0

        @timer = 0

    end
 
    def update

        @player_count = Gosu::Image.from_text(self, "Player #{@crrnt_plr} turn:", Gosu.default_font_name, 60)

        @timer_text = Gosu::Image.from_text(self, "Timer:#{@timer} ", Gosu.default_font_name, 45)


        if Gosu.button_down?(Gosu::KbLeft)
            @color = 0xffffffff
        end

        if Gosu.button_down?(Gosu::KbRight)
            @color = 0xff_0000ff
        end

        if Gosu.button_down?(Gosu::KbUp)
            @color = 0xff_ff0000
            if Time.now - @last_time > @delay
                @input_pos -= 1
                @last_time = Time.now
            end
            
        end

        if Gosu.button_down?(Gosu::KbDown)
            @color = 0xff_00ff00
            if Time.now - @last_time > @delay
                @input_pos += 1
                @last_time = Time.now
            end
        end

        if Gosu.button_down?(Gosu::KbZ) && Gosu.button_down?(Gosu::KB_LEFT_CONTROL)
            if Time.now - @last_time > @delay
                @drawing.delete_at(-1)
                @last_time = Time.now
            end
        end

        if Gosu.button_down?(Gosu::KbR)
            @reveal_word = true
        end

        if Gosu.button_down?(Gosu::KB_SPACE) && @action == "start"
            if Time.now - @last_time > @delay
                @plrs += 1
                @last_time = Time.now
            end
        end

        
        if Gosu.button_down?(Gosu::KB_BACKSPACE) && @action == "start"
            if Time.now - @last_time > @delay && @plrs != 1
                @plrs -= 1
                @last_time = Time.now
            end
        end

        if Gosu.button_down?(Gosu::KB_SPACE) && @input_pos == 0
            @action = "start"
        end

        if Gosu.button_down?(Gosu::KbP) && @action == "start"
            @action = "started"
            @timer = 20
        end

        if Gosu.button_down?(Gosu::KbE) && @action == "started"
            if Time.now - @last_time > @delay && @crrnt_plr != @plrs
                @crrnt_plr += 1
                @last_time = Time.now
            end
        end

        if @timer == 0
            @timer = 20
            @crrnt_plr += 1
        end

        if Gosu.button_down?(Gosu::KbEscape)
            close 
        end

        if @input_pos > 2 

            @input_pos = 2

        
        elsif @input_pos < 0

            @input_pos = 0

        end
        
        if @action == "started" && @timer != 0
            puts("timertest")
            if Time.now - @lasttimer_time > 1
                @lasttimer_time = Time.now
                @timer -= 1
            end
        end

        if !(mouse_x < 0 || mouse_x > @width || mouse_y < 0 || mouse_y > @height) && Gosu.button_down?(Gosu::KB_SPACE)
            (@draw_section[Vector[mouse_x.to_i / @pixel_size, mouse_y.to_i / @pixel_size]] = @color)
            @released = true
        elsif @released
            @drawing << @draw_section
            @draw_section = Hash.new(0x0)
            @released = false
        end

        
    end

    def draw
        
        @menu.draw(@input_pos, @action, @plrs)

        @text.draw(10, 20, 0, 1, 1, Gosu::Color.new(@color))

        @player_count.draw(1200, 20, 0, 1, 1, Gosu::Color.new(0xffffffff))

      
        if @action == "started" && @timer > 0
            @timer_text.draw(1000, 20, 0, 1, 1, Gosu::Color.new(@color))

            if @reveal_word
                
                @word.draw(10, 50, 0, 1, 1, Gosu::Color.new(@color))
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
end           

    


class Menu

    def initialize()

        @title = Gosu::Image.from_text(self, "paintly: more than art", Gosu.default_font_name, 90)

        @play = Gosu::Image.from_text(self, "Start game", Gosu.default_font_name, 60)

        @settings = Gosu::Image.from_text(self, "Settings", Gosu.default_font_name, 60)

        @exit = Gosu::Image.from_text(self, "Exit", Gosu.default_font_name, 60)
        
        # Game start
        
        
    end

    def draw(position, action, plrs)

        @start = Gosu::Image.from_text(self, "Choose amount of players: #{plrs}, and click 'P' to play", Gosu.default_font_name, 60)

        p action        

        if action == "home"

            @title.draw(600, 100, 0, 1, 1, Gosu::Color.new(0xffffffff))

            case position
 
            when 0
                @play.draw(600, 200, 0, 1, 1, Gosu::Color.new(0xffffffff))
                @settings.draw(600, 260, 0, 1, 1, Gosu::Color.new(0xff_808080))
                @exit.draw(600, 320, 0, 1, 1, Gosu::Color.new(0xff_808080))
            when 1
                @play.draw(600, 200, 0, 1, 1, Gosu::Color.new(0xff_808080))
                @settings.draw(600, 260, 0, 1, 1, Gosu::Color.new(0xffffffff))
                @exit.draw(600, 320, 0, 1, 1, Gosu::Color.new(0xff_808080))
            when 2
                @play.draw(600, 200, 0, 1, 1, Gosu::Color.new(0xff_808080))
                @settings.draw(600, 260, 0, 1, 1, Gosu::Color.new(0xff_808080))
                @exit.draw(600, 320, 0, 1, 1, Gosu::Color.new(0xffffffff))
            end
        elsif action == "start"

            @start.draw(600, 100, 0, 1, 1, Gosu::Color.new(0xffffffff))

        elsif action == "started"

        end

    end

  
end

Game.new.show