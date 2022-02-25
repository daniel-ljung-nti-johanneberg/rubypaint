require 'gosu' # Hämtar gosu-bibloteket, grunden för projektet
require 'matrix' #hämtar ett matrix-biblotek, används för ritfunktionerna

# Klass för spelet, inheritar från Gosu::Window, själva grunden för en Gosu applikation
class Game < Gosu::Window

    def initialize

        # Här initieras viktiga variabler för spelet
        
        @width = 1920
        @height = 1080

        @input_pos = 0

        @last_time = Time.now

        @lasttimer_time = Time.now

        @lastdisplay_wordtime = Time.now

        @delay = 0.1

        @last_Word = ""

        @pixel_size = 2
        
        super @width, @height, fullscreen: true
        self.caption = "Paint-spel"

        @drawing = []

        @menu = Menu.new()

        @draw_section = Hash.new(0x0)

        @released = false

        @color = 0xffffffff

        @i = 0

        # Ordlista
        @word_list = ["gurka","äpple","sten","hus","snowboard","läkare","torn","biljard","helikopter","landskap","skatt"]
        # Slumpa fram ett ord
        @random_word = @word_list[rand(0..(@word_list.length-1))]

        # Text för spelet som måste initieras på detta sätt, och sedan kan renderas i draw funktion
        @text = Gosu::Image.from_text(self, "COLOR", Gosu.default_font_name, 45)
        @word = Gosu::Image.from_text(self, @random_word, Gosu.default_font_name, 90)

        # Återigen, variabler för spelet
        @reveal_word = false

        @action = :home

        @plrs = 0

        @rounds = 0

        @crrnt_plr = 1

        @timer = 0

        @halfway = 0

    end

 
    def update
        # Funktionen update körs hela tiden

        # Text för spelet som måste initieras på detta sätt (men som behöver uppdateras), renderas sedan i draw funktionen
        @player_count_text = Gosu::Image.from_text(self, "Player #{@crrnt_plr}'s turn", Gosu.default_font_name, 60)
        @timer_text = Gosu::Image.from_text(self, "Timer:#{@timer} ", Gosu.default_font_name, 45)
        @rounds_text = Gosu::Image.from_text(self, "Round:#{@rounds} ", Gosu.default_font_name, 45)

        # Ändra penselfärgen när knappar trycks ner
        if Gosu.button_down?(Gosu::KbLeft)
            @color = 0xffffffff
        end

        if Gosu.button_down?(Gosu::KbRight)
            @color = 0xff_0000ff
        end
        
        # Menyval, får endast göras om det har gått ett visst intervall mellan man senast använde menyn därav delayen, 
        # det förhindrar att input-positionen blir för hög eller låg för snabbt, då menyn blir oanvändbar isåfall.

        # Upp knappen används för menyn, ändrar input_pos som är den aktiva positionen i menyn
    
        if Gosu.button_down?(Gosu::KbUp)
            @color = 0xff_ff0000
            if Time.now - @last_time > @delay
                @input_pos -= 1
                @last_time = Time.now
            end
            
        end
        # Ner knappen används även för menyn, ändrar input_pos som är den aktiva positionen i menyn
        if Gosu.button_down?(Gosu::KbDown)
            @color = 0xff_00ff00
            if Time.now - @last_time > @delay
                @input_pos += 1
                @last_time = Time.now
            end
        end

        # Kunna göra UNDO genom Cntrl ´+ Z, tar bort senaste elementet i drawing
        if Gosu.button_down?(Gosu::KbZ) && Gosu.button_down?(Gosu::KB_LEFT_CONTROL)
            if Time.now - @last_time > @delay
                @drawing.delete_at(-1)
                @last_time = Time.now
            end
        end


        # Kunna klicka R - för att reveala ordet, då sätts variabeln @reveal_word som är global till true
        # Detta kan man endast göra om rundan inte är slut och förändringen återspeglas sedan genom draw funktionen som
        # renderar ordet. 

        if Gosu.button_down?(Gosu::KbR) && @timer != 20
            @reveal_word = true
        else
            @reveal_word = false
        end


        # close, inbyggd funktion som stänger det aktiva fönstret
        if Gosu.button_down?(Gosu::KbEscape)
            close 
        end

        # Se ifall @action är symbolen :start, vilket betydet att spelet har initierars, och då kan 'lyssna' efter andra kommandon
        # som att välja antal spelare, vilket görs genom if-satser när tangenter trycks ner.

        if @action == :start

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

            if Gosu.button_down?(Gosu::KbP) && @action != :started
                @action = :started
                @rounds = @plrs * 2
                @timer = 30
            end
        end

        # När @action är :started, alltså när spelet är igång, sker flertal checkar (i form av if-satser)
        # Dessa checkar bestämer antalet rundor, reset:ar timer, updaterar det hemliga ordet, och ser till att alla får köra två gånger
        if @action == :started

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
                    @last_Word = @random_word
                    @reveal_word = true

                    @lastdisplay_wordtime = Time.now
                    
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
                    @action = :home
                    @crrnt_plr = 1
                    @plrs = 1
                    @halfway = 0
                end
            end
        end

        # Så länge @action INTE är :started är spacebar använt för navigation
        if @action != :started

            if Gosu.button_down?(Gosu::KB_SPACE)
                case @input_pos
                when 0
                    @action = :start
                when 1
                    @action = :controls
                end
            end
        end
        
        # Q är inputen för att återvända till huvudmenyn, den reset:ar också timern, vems tur det var, och allt som hade ritats
        if Gosu.button_down?(Gosu::KB_Q)
            @timer = 30
            @crrnt_plr = 1
            @drawing = []
            @action = :home
        end

        paint()

        # Satsen nedan avgör ifall round-timer:n ska visas eller om det hemliga ordet ska visas, detta sker när en runda är över
        if Time.now - @lastdisplay_wordtime < 3
            @timer_text = Gosu::Image.from_text(self, "Ordet var #{@last_Word}", Gosu.default_font_name, 45)
            @timer = 30
        else
            @timer_text = Gosu::Image.from_text(self, "Timer:#{@timer} ", Gosu.default_font_name, 45)
        end

        # För navigation av huvudmenyn
        if @input_pos > 1

            @input_pos = 1

        elsif @input_pos < 0

            @input_pos = 0

        end
  
    end


    def paint()
        # funktion som delar in alla punkter som ritas (punkterna sparas som vektorer) ut i hashes, körs bara då musen är inom spel-fönstret och då "space" trycks på.

        if !(mouse_x < 0 || mouse_x > @width || mouse_y < 0 || mouse_y > @height) && Gosu.button_down?(Gosu::KB_SPACE)
            (@draw_section[Vector[mouse_x.to_i / @pixel_size, mouse_y.to_i / @pixel_size]] = @color)
            @released = true
        elsif @released
            # När @released = true sparas de ritade punkternas hash i en array, @drawing, och en ny hash skapas.
            @drawing << @draw_section
            @draw_section = Hash.new(0x0)
            @released = false
        end
        
    end


    def render_paint()
        #denna ritar ut varje linje mellan punkterna så användarens input upplevs som en linje och inte flertal prickar. Funktionen går igenom varje hash i arrayen @drawing.

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


    def draw
        # Draw är en obligatorisk funktion för gosu, just denna ritar ut allt som syns på skärmen

        @menu.draw(@input_pos, @action, @plrs)

        @text.draw(10, 20, 0, 1, 1, Gosu::Color.new(@color))

        @player_count_text.draw(1500, 20, 0, 1, 1, Gosu::Color.new(0xffffffff))
        @rounds_text.draw(200, 20, 0, 1, 1, Gosu::Color.new(0xffffffff))
      
        if @action == :started && @timer > 0
            @timer_text.draw(1000, 20, 0, 1, 1, Gosu::Color.new(0xffffffff))

            if @reveal_word
                @word.draw(10, 50, 0, 1, 1, Gosu::Color.new(0xffffffff))
            end
            render_paint()
            
        end
    end
end           

    

class Menu
    # Detta är en mindre klass som existerar enbart för att rita ut menyn, ser till att huvudklassen inte bloatas.

    def initialize()
        # Definerar variabler som är bara text

        @title = Gosu::Image.from_text(self, "paintly: more than art", Gosu.default_font_name, 90)

        @play = Gosu::Image.from_text(self, "Start game", Gosu.default_font_name, 60)

        @controls = Gosu::Image.from_text(self, :controls, Gosu.default_font_name, 60)

        @controls_info = Gosu::Image.from_text(self, "Select colors with the 'Arrow Keys'\nReveal word with 'r'\nExit with 'Escape'\nSkip turn with 'e'\nUndo with 'ctrl + z'", Gosu.default_font_name, 60)
        
    end


    def draw(position, action, plrs)
        # Ritar ut viss text beroende på variabeln "action", här bestäms exempelvis om huvudmenyn eller inställningar ska visas

        @start = Gosu::Image.from_text(self, "Choose amount of players: #{plrs}, and click 'P' to play", Gosu.default_font_name, 60)       

        case action
        when :home

            @title.draw(600, 100, 0, 1, 1, Gosu::Color.new(0xffffffff))

            case position
 
            when 0
                @play.draw(600, 200, 0, 1, 1, Gosu::Color.new(0xffffffff))
                @controls.draw(600, 260, 0, 1, 1, Gosu::Color.new(0xff_808080))
            when 1
                @play.draw(600, 200, 0, 1, 1, Gosu::Color.new(0xff_808080))
                @controls.draw(600, 260, 0, 1, 1, Gosu::Color.new(0xffffffff))
            end
        when :controls

            @controls_info.draw(10, 200, 0, 1, 1, Gosu::Color.new(0xffffffff))

        when :start

            @start.draw(600, 100, 0, 1, 1, Gosu::Color.new(0xffffffff))

        when :started

        end
    end
end

Game.new.show #Skapar ett objekt av klassen game och visar det