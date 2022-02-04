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

        @word_list = ["gurka","äpple","sten","hus","snowboard","läkare","torn","biljard","helikopter","landskap","skatt"]

        @random_word = @word_list[rand(0..(@word_list.length-1))]

        @text = Gosu::Image.from_text(self, "COLOR", Gosu.default_font_name, 45)

        @word = Gosu::Image.from_text(self, @random_word, Gosu.default_font_name, 90)

        @reveal_word = false

        @action = "home"

        @plrs = 0

        @rounds = 0

        @crrnt_plr = 1

        @timer = 0

        @halfway = 0

    end
 
    def update

        @player_count_text = Gosu::Image.from_text(self, "Player #{@crrnt_plr} turn:", Gosu.default_font_name, 60)

        @timer_text = Gosu::Image.from_text(self, "Timer:#{@timer} ", Gosu.default_font_name, 45)

        @rounds_text = Gosu::Image.from_text(self, "Round:#{@rounds} ", Gosu.default_font_name, 45)


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
        else
            @reveal_word = false
        end

        if Gosu.button_down?(Gosu::KbEscape)
            close 
        end

        if @action == "start"

            @input_pos = 0

            if Gosu.button_down?(Gosu::KB_SPACE)
                if Time.now - @last_time > @delay
                    @plrs += 1
                    @last_time = Time.now
                end
            end
        
            if Gosu.button_down?(Gosu::KB_BACKSPACE)
                if Time.now - @last_time > @delay && @plrs != 1
                    @plrs -= 1
                    @last_time = Time.now
                end
            end

            if Gosu.button_down?(Gosu::KbP) && @action != "started"
                @action = "started"
                @rounds = @plrs * 2
                @timer = 30
            end
        end

        if @action == "started"

            case @plrs
            when 1
                @timer = 999
                @plrs = 1
                @crrnt_plr = 1

            else

                if Gosu.button_down?(Gosu::KbE)
                    if Time.now - @last_time > @delay
                        @timer = 0
                        @last_time = Time.now
                    end
                end

                if @timer != 0
                    if Time.now - @lasttimer_time > 1
                        @lasttimer_time = Time.now
                        @timer -= 1
                    end
                end

                if @timer == 0 && @rounds != 0
                    @timer = 30
                    @crrnt_plr += 1
                    @drawing = []
                    @random_word = @word_list[rand(0..(@word_list.length-1))]
                    @word = Gosu::Image.from_text(self, @random_word, Gosu.default_font_name, 90)
                end

                if @crrnt_plr >= (@rounds/2)+1
                    @crrnt_plr = 1
                    @halfway += 1 
                end

                if @halfway == 2
                    @action = "home"
                    @crrnt_plr = 1
                    @plrs = 1
                    @halfway = 0
                end
            end
        end

        if @action != "started"

            if Gosu.button_down?(Gosu::KB_SPACE)
                case @input_pos
                when 0
                    @action = "start"
                when 1
                    @action = "controls"
                end
            end
        end

        if Gosu.button_down?(Gosu::KB_Q)
            @action = "home"
        end

        if !(mouse_x < 0 || mouse_x > @width || mouse_y < 0 || mouse_y > @height) && Gosu.button_down?(Gosu::KB_SPACE)
            (@draw_section[Vector[mouse_x.to_i / @pixel_size, mouse_y.to_i / @pixel_size]] = @color)
            @released = true
        elsif @released
            @drawing << @draw_section
            @draw_section = Hash.new(0x0)
            @released = false
        end

        if @input_pos > 1

            @input_pos = 1

        elsif @input_pos < 0

            @input_pos = 0

        end
  
    end

    def draw
        
        @menu.draw(@input_pos, @action, @plrs)

        @text.draw(10, 20, 0, 1, 1, Gosu::Color.new(@color))

        @player_count_text.draw(1200, 20, 0, 1, 1, Gosu::Color.new(0xffffffff))
        @rounds_text.draw(200, 20, 0, 1, 1, Gosu::Color.new(0xffffffff))

      
        if @action == "started" && @timer > 0
            @timer_text.draw(1000, 20, 0, 1, 1, Gosu::Color.new(0xffffffff))

            if @reveal_word
                @word.draw(10, 50, 0, 1, 1, Gosu::Color.new(0xffffffff))
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

        @controls = Gosu::Image.from_text(self, "Controls", Gosu.default_font_name, 60)

        @controls_info = Gosu::Image.from_text(self, "Select colors with the 'Arrow Keys'\nReveal word with 'r'\nExit with 'Escape'\nSkip turn with 'e'\nUndo with 'ctrl + z'", Gosu.default_font_name, 60)
        
    end

    def draw(position, action, plrs)

        @start = Gosu::Image.from_text(self, "Choose amount of players: #{plrs}, and click 'P' to play", Gosu.default_font_name, 60)       

        case action
        when "home"

            @title.draw(600, 100, 0, 1, 1, Gosu::Color.new(0xffffffff))

            case position
 
            when 0
                @play.draw(600, 200, 0, 1, 1, Gosu::Color.new(0xffffffff))
                @controls.draw(600, 260, 0, 1, 1, Gosu::Color.new(0xff_808080))
            when 1
                @play.draw(600, 200, 0, 1, 1, Gosu::Color.new(0xff_808080))
                @controls.draw(600, 260, 0, 1, 1, Gosu::Color.new(0xffffffff))
            end
        when "controls"

            @controls_info.draw(10, 200, 0, 1, 1, Gosu::Color.new(0xffffffff))

        when "start"

            @start.draw(600, 100, 0, 1, 1, Gosu::Color.new(0xffffffff))

        when "started"

        end

    end

  
end

Game.new.show