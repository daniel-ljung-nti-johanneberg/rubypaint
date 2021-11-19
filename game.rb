require 'gosu'



class Game < Gosu::Window

    def initialize
        @width = 640
        @height = 480
        @pixel_size = 15
        
        super @width, @height
        self.caption = "Paint-spel"

        @first_time = true

        @drawing = []

        (0...@height/@pixel_size).each do |y|
            @drawing << []
            (0..@width/@pixel_size).each do |x|
                @drawing[y] << 0
            end
        end

        # p @drawing

        @i = 0

        # @drawing[10][10] = 0xffffffff
    end
    
 
    def update

        
        # if @first_time == true || "#{mouse_x},#{mouse_y}" != @drawthis[@drawthis.length - 1]
        #     @drawthis << "#{mouse_x},#{mouse_y}"
        #     @first_time = false
        #     p @first_time
        #     p @drawthis[-1]
        #     p @drawthis.length
        # end
        if !(mouse_x < 0 || mouse_x > @width || mouse_y < 0 || mouse_y > @height) && Gosu.button_down?(Gosu::KB_SPACE)
            @drawing[mouse_y.to_i / @pixel_size][mouse_x.to_i / @pixel_size] = 0xf12ff2ff
        end

        if Gosu.button_down?(Gosu::KB_)

    end

    def draw
        @drawing.each_with_index do |row, y|
            row.each_with_index do |cell, x|
                if cell == 0
                    next
                end
                draw_rect(x * @pixel_size, y * @pixel_size, @pixel_size, @pixel_size, Gosu::Color.new(cell))
            end
        end

        

        # @drawing[10][50] = draw_rect(x, y, 1, 1, Gosu::Color.new(0xff_ffffff))
        # draw_rect(@drawthis[@i].split(',')[0].to_f, @drawthis[@i].split(',')[1].to_f, 30, 30, Gosu::Color.new(0xff_ffffff))


    end


end


Game.new.show

