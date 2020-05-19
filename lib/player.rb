BOBBING = true
MOVE_SPEED = 6.0

class Player
attr_reader :pos_x, :pos_y, :dir_x, :dir_y, :plane_x, :plane_y, :move_speed, :rot_speed, :init
  def initialize(window, pos_x, pos_y)
    @window = window
    @pos_x, @pos_y = pos_x, pos_y
    @dir_x, @dir_y = -1.0, 0.0
    @plane_x, @plane_y = 0.0, 1.0

    @window.mouse_x = @window.width >> 1
    @mouse_pos = @window.mouse_x
    @mouse_speed = 0.005

    @weapon = Gosu::Image.new("#{ROOT_PATH}/media/uzi.png", tileable: false, retro: true)
    @weapon_offset = 0
    @weapon_ratio = 0.3 * Gosu.screen_height.to_f / (@weapon.height)

    @cross = Gosu.record(5, 5) do
      Gosu.draw_quad(2, 0, Gosu::Color::WHITE, 3, 0, Gosu::Color::WHITE, 2, 2, Gosu::Color::WHITE, 3, 2, Gosu::Color::WHITE)
      Gosu.draw_quad(2, 3, Gosu::Color::WHITE, 3, 3, Gosu::Color::WHITE, 2, 5, Gosu::Color::WHITE, 3, 5, Gosu::Color::WHITE)
      Gosu.draw_quad(0, 2, Gosu::Color::WHITE, 0, 3, Gosu::Color::WHITE, 2, 2, Gosu::Color::WHITE, 2, 3, Gosu::Color::WHITE)
      Gosu.draw_quad(3, 2, Gosu::Color::WHITE, 3, 3, Gosu::Color::WHITE, 5, 2, Gosu::Color::WHITE, 5, 3, Gosu::Color::WHITE)
    end
    @init = true
  end

  def up
    @pos_x += @dir_x * @move_speed if $world_map[(@pos_x + @dir_x * @move_speed).to_i][@pos_y.to_i] == 0
    @pos_y += @dir_y * @move_speed if $world_map[@pos_x.to_i][(@pos_y + @dir_y * @move_speed).to_i] == 0
  end

  def down
    @pos_x -= @dir_x * @move_speed if $world_map[(@pos_x - @dir_x * @move_speed).to_i][@pos_y.to_i] == 0
    @pos_y -= @dir_y * @move_speed if $world_map[@pos_x.to_i][(@pos_y - @dir_y * @move_speed).to_i] == 0
  end

  def right
    @pos_x += @plane_x * @move_speed if $world_map[(@pos_x + @plane_x * @move_speed).to_i][@pos_y.to_i] == 0
    @pos_y += @plane_y * @move_speed if $world_map[@pos_x.to_i][(@pos_y + @plane_y * @move_speed).to_i] == 0
  end

  def left
    @pos_x -= @plane_x * @move_speed if $world_map[(@pos_x - @plane_x * @move_speed).to_i][@pos_y.to_i] == 0
    @pos_y -= @plane_y * @move_speed if $world_map[@pos_x.to_i][(@pos_y - @plane_y * @move_speed).to_i] == 0
  end

  def turn
    old_dir_x = @dir_x;
    @dir_x = @dir_x * Math::cos((@mouse_pos-@window.mouse_x)*@mouse_speed) - @dir_y * Math::sin((@mouse_pos-@window.mouse_x)*@mouse_speed)
    @dir_y = old_dir_x * Math::sin((@mouse_pos-@window.mouse_x)*@mouse_speed) + @dir_y * Math::cos((@mouse_pos-@window.mouse_x)*@mouse_speed)
    old_plane_x = @plane_x
    @plane_x = @plane_x * Math::cos((@mouse_pos-@window.mouse_x)*@mouse_speed) - @plane_y * Math::sin((@mouse_pos-@window.mouse_x)*@mouse_speed)
    @plane_y = old_plane_x * Math::sin((@mouse_pos-@window.mouse_x)*@mouse_speed) + @plane_y * Math::cos((@mouse_pos-@window.mouse_x)*@mouse_speed)
    @window.mouse_x = @window.width >> 1 if @window.mouse_x <= 1 or @window.mouse_x >= Gosu.screen_width - 1
    @mouse_pos = @window.mouse_x
  end

  def gun_bobbing
    @weapon_offset = 2 * Math::sin((Gosu.milliseconds / 100) % 6)
  end

  def update
    @move_speed = ((double_keys? ? MOVE_SPEED / Math.sqrt(2) : MOVE_SPEED)) * @window.delta_time

    if Gosu.button_down? Gosu::KB_W
      up
      gun_bobbing if BOBBING
    end

    if Gosu.button_down? Gosu::KB_S
      down
      gun_bobbing if BOBBING
    end

    if Gosu.button_down? Gosu::KB_A
      left
      gun_bobbing if BOBBING
    end

    if Gosu.button_down? Gosu::KB_D
      right
      gun_bobbing if BOBBING
    end

    turn if @mouse_pos != @window.mouse_x
  end

  def double_keys?
    (Gosu.button_down? Gosu::KB_W or Gosu.button_down? Gosu::KB_S) and (Gosu.button_down? Gosu::KB_A or Gosu.button_down? Gosu::KB_D)
  end

  def draw
    @weapon.draw(0.6 * Gosu.screen_width, Gosu.screen_height - (@weapon.height - @weapon_offset - 5) * @weapon_ratio, 2, @weapon_ratio, @weapon_ratio)
    # draw_rot to avoid struggling with finding the exact center of screen
    @cross.draw_rot(Gosu.screen_width >> 1, Gosu.screen_height >> 1, 2, 0, 0, 0, 2.0, 2.0)
  end
end
