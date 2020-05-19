unless RUBY_ENGINE == "mruby"
  begin
    require_relative "../ffi-gosu/lib/gosu"
  rescue LoadError
    require "gosu"
  end
end

ROOT_PATH = File.expand_path("..", __FILE__)

# MRUBY requires mruby-require mgem (https://github.com/mattn/mruby-require)
require "#{ROOT_PATH}/lib/jcaster"
require "#{ROOT_PATH}/lib/world_map"
require "#{ROOT_PATH}/lib/player"
require "#{ROOT_PATH}/lib/map"
require "#{ROOT_PATH}/lib/timer"

class Launcher < Gosu::Window
  DETAILS = { 0 => "Very low", 1=> "Low", 2 => "Medium", 3 => "High", 4 => "Max" }
  def initialize
    super 640, 480, fullscreen: false
    self.caption = "jCaster Launcher"
    @title = Gosu::Image.new("#{ROOT_PATH}/media/title.jpg", tileable: true)
    @font = Gosu::Font.new(20, name: "#{ROOT_PATH}/media/boxybold.ttf")

    settings = File.read("#{ROOT_PATH}/settings").lines.map { |l| l.chomp.to_i }

    @screen_width = Gosu.screen_width
    @screen_height = Gosu.screen_height
    @details = settings[2]
    @timer = Timer.new
  end

  def update
    if Gosu.button_down? Gosu::KB_D and @timer.time > 100
      @details > DETAILS.size - 2 ? @details = 0 : @details += 1
      save_settings
      @timer.reset
    end
    if Gosu.button_down? Gosu::KB_RETURN
      JCaster.new.show
      close
    end
    close if Gosu.button_down? Gosu::KB_ESCAPE
  end

  def save_settings
    file = File.new("settings", 'w')
    if file
      file.syswrite(@screen_width.to_s + "\n" + @screen_height.to_s + "\n" + @details.to_s)
    else
      puts "File access error"
    end
    file.close
  end

  def draw
    @title.draw(0,0,10,2,2)
    @font.draw_text("v#{VERSION}!", 460, 140, 10, 1, 1, color = 0xffffffff)
    @font.draw_markup("<c=6a6a6a>R</c>esolution: #{@screen_width} x #{@screen_height}", 20, 240, 10, 1, 1, color = 0xffffffff)
    @font.draw_markup("<c=6a6a6a>D</c>etails: #{DETAILS[@details]}", 20, 300, 10, 1, 1, color = 0xffffffff)
    @font.draw_text_rel("PRESS ENTER TO START", 320, 440, 10, 0.5, 0.5, 1, 1, color = 0xffffffff) if (Gosu.milliseconds / 500).to_i % 2 == 0
  end
end

Launcher.new.show
