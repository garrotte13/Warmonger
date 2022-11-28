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


return util
