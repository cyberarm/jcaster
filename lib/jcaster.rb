VERSION = "0.2"
DEBUG = true

def debug(message)
  if RUBY_ENGINE == "mruby"
    puts "#{Time.now} - \t#{message}" if DEBUG
  else
    puts "#{Time.now.strftime("%H:%M:%S.%L")} - \t#{message}" if DEBUG
  end
end

debug("jCaster v#{VERSION} \n\t\tby Jahmaican")

class JCaster < Gosu::Window
attr_reader :player, :map, :image_width, :image_height
  def initialize
    settings = File.read("#{ROOT_PATH}/settings").lines.map { |l| l.chomp.to_i }

    super Gosu.screen_width, Gosu.screen_height, fullscreen: true
    self.caption = "jCaster v#{VERSION}"

    case settings[2]
    when 0
      @image_width = 160
      @image_height = 90
    when 1
      @image_width = 320
      @image_height = 180
    when 2
      @image_width = 1366 >> 1
      @image_height = 768 >> 1
    when 3
      @image_width = 1366
      @image_height = 768
    when 4
      @image_width = Gosu.screen_width
      @image_height = Gosu.screen_height
    end

    @font = Gosu::Font.new(20, name: "#{ROOT_PATH}/media/boxybold.ttf")
    @state = :loading
    @timer = Timer.new
    @last_frame_time = Gosu.milliseconds

    @player = Player.new(self, 18, 3)
    @map = Map.new(self)
    debug("All good!")
  end

  def delta_time
    (Gosu.milliseconds - @last_frame_time) / 1000.0
  end

  def update
    case @state
    when :loading
      @state = :game if Gosu.fps > 0 and @player.init and @map.init

    when :game
      @map.update
      @player.update
      close if Gosu.button_down? Gosu::KB_ESCAPE
      if Gosu.button_down? Gosu::KB_P and @timer.time > 256
        @timer.reset
        @state = :pause
      end

    when :pause
      close if Gosu.button_down? Gosu::KB_ESCAPE
      if Gosu.button_down? Gosu::KB_P and @timer.time > 256
        @timer.reset
        @state = :game
      end
    end

    @last_frame_time = Gosu.milliseconds
  end

  def draw
    case @state
    when :loading
      @font.draw_text("LOADING", 10, 10, 10, 1, 1, color = 0xffffffff)
    when :game
      @font.draw_text("#{Gosu.fps} fps", 10, 10, 10, 1, 1, color = 0xffffffff) if DEBUG
      @player.draw
      @map.draw
    when :pause
      @font.draw_text("PAUSED", 10, 10, 10, 1, 1, color = 0xffffffff)
      @player.draw
      @map.draw
    end
  end
end
