local util = {}


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
    commands.add_command(name, { "command-help." .. name }, function(e)
      local player = game.get_player(e.player_index)
      if not player.admin then
        player.print({ "cant-run-command-not-admin", name })
        return
      end

      func(e)
    end)
  end
end


return util
