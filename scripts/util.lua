local util = {}

function util.box_ceiling(area)

  return {
    left_top = {
      x = math.floor(area.left_top.x),
      y = math.floor(area.left_top.y),
    },
    right_bottom = {
      x = math.ceil(area.right_bottom.x) - 0.03125,
      y = math.ceil(area.right_bottom.y) - 0.03125,
    }
  }
end

function util.flying_text_with_sound(player, text, options)
  options = options or {}
  options.sound = options.sound or { path = "utility/cannot_build" }
  player.create_local_flying_text({
    color = options.color,
    create_at_cursor = not options.position,
    position = options.position,
    text = text,
  })
  player.play_sound(options.sound)
end

function util.add_commands(commands_list)
  for name, func in pairs(commands_list) do
    commands.add_command(name, { "command-help." .. name }, function()
      func()
    end)
  end
end

util.ensure_pos_xy = function(pos)
  local new_pos

  if pos.x ~= nil then
    new_pos = {x = pos.x, y = pos.y}
  else
    new_pos = {x = pos[1], y = pos[2]}
  end

  return new_pos
end

util.ensure_box_xy = function(bounding_box)
  local new_bounding_box = {}
  new_bounding_box.left_top = util.ensure_pos_xy(bounding_box.left_top)
  new_bounding_box.right_bottom = util.ensure_pos_xy(bounding_box.right_bottom)
  return new_bounding_box
end


function util.get_centre(box)
  box = util.ensure_box_xy(box)

  local x = box.left_top.x + (box.right_bottom.x - box.left_top.x) / 2
  local y = box.left_top.y + (box.right_bottom.y - box.left_top.y) / 2

  return {x = x, y = y}
end

function util.contains_point(box, point)
  box = util.ensure_box_xy(box)
  point = util.ensure_pos_xy(point)

  return box.left_top.x <= point.x and box.right_bottom.x >= point.x and
         box.left_top.y <= point.y and box.right_bottom.y >= point.y
end


return util
