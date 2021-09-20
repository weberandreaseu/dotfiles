#!/usr/bin/env bash

if [[ -z $DISPLAY && $TTY = /dev/tty1 ]]; then
  # this may fix external monitor problem
  export WLR_DRM_NO_MODIFIERS=1

  # make Firefox use native Wayland backend
  export MOZ_ENABLE_WAYLAND=1

  # Force Wayland backend for qt5 apps
  export QT_QPA_PLATFORM=wayland
  export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

  # for Java some apps
  export _JAVA_AWT_WM_NONREPARENTING=1

  # general
  export XDG_SESSION_TYPE=wayland
  exec sway
fi
