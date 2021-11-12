require 'gosu'



class Game < Gosu::Window

    def initialize
        
        super 640, 480
        self.caption = "Paint-spel"

        @first_time = true

        @drawthis = []

        @i = 0


    end
    
 
    def update

        
        if @first_time == true || "#{mouse_x},#{mouse_y}" != @drawthis[@drawthis.length - 1]
            @drawthis << "#{mouse_x},#{mouse_y}"
            @first_time = false
            p @first_time
            p @drawthis[-1]
            p @drawthis.length
        end

    end

    def draw


        while @i < @drawthis.length

            draw_rect(20,20, 30, 30, Gosu::Color.new(0xff_ffffff))

            draw_rect(@drawthis[@i].split(',')[0].to_f, @drawthis[@i].split(',')[1].to_f, 30, 30, Gosu::Color.new(0xff_ffffff))

            @i += 1
            
        end
    



    end


end


Game.new.show

