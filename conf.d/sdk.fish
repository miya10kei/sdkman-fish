function _sdk_install --on-event sdk_install --on-event sdk_update
  ln -fs $HOME/.config/fish/functions/sdk.fish $HOME/.config/fish/functions/__sdk_auto_env.fish
end

function _sdk_uninstall --on-event sdk_uninstall
  unlink $HOME/.config/fish/functions/__sdk_auto_env.fish
end
