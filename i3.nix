{pkgs, environment, config, lib, ... }:

with pkgs;

let

  i3_conf_file =  pkgs.writeText "config" ''

  # i3 config file (v4)
  # doc: https://i3wm.org/docs/userguide.html

  set $mod Mod4

  # Font for window titles. Will also be used by the bar unless a different font
  # is used in the bar {} block below.
  font pango:monospace 8

  # Use Mouse+$mod to drag floating windows to their wanted position
  floating_modifier $mod

  # start a terminal
  bindsym $mod+Return exec alacritty

  # kill focused window
  bindsym $mod+Shift+q kill

  # start rofi program launcher
  bindsym $mod+d exec ${pkgs.rofi}/bin/rofi -modi drun#run -combi-modi drun#run -show combi -show-icons -display-combi run
  # Switch windows with rofi
  bindsym $mod+x exec ${pkgs.rofi}/bin/rofi -modi window -show window -auto-select

  # There also is the (new) i3-dmenu-desktop which only displays applications
  # shipping a .desktop file. It is a wrapper around dmenu, so you need that
  # installed.
  # bindsym $mod+d exec --no-startup-id i3-dmenu-desktop

  # change focus
  bindsym $mod+j focus left
  bindsym $mod+k focus down
  bindsym $mod+l focus up
  bindsym $mod+semicolon focus right

  # alternatively, you can use the cursor keys:
  bindsym $mod+Left focus left
  bindsym $mod+Down focus down
  bindsym $mod+Up focus up
  bindsym $mod+Right focus right

  # move focused window
  bindsym $mod+Shift+j move left
  bindsym $mod+Shift+k move down
  bindsym $mod+Shift+l move up
  bindsym $mod+Shift+semicolon move right

  # alternatively, you can use the cursor keys:
  bindsym $mod+Shift+Left move left
  bindsym $mod+Shift+Down move down
  bindsym $mod+Shift+Up move up
  bindsym $mod+Shift+Right move right

  # split in horizontal orientation
  bindsym $mod+h split h

  # split in vertical orientation
  bindsym $mod+v split v

  # enter fullscreen mode for the focused container
  bindsym $mod+f fullscreen toggle

  # change container layout (stacked, tabbed, toggle split)
  bindsym $mod+s layout stacking
  bindsym $mod+w layout tabbed
  bindsym $mod+e layout toggle split

  # toggle tiling / floating
  bindsym $mod+Shift+space floating toggle

  # change focus between tiling / floating windows
  bindsym $mod+space focus mode_toggle

  # focus the parent container
  bindsym $mod+a focus parent

  # focus the child container
  #bindsym $mod+d focus child

  # Define names for default workspaces for which we configure key bindings later on.
  # We use variables to avoid repeating the names in multiple places.
  set $ws1 "1"
  set $ws2 "2"
  set $ws3 "3: Emacs"
  set $ws4 "4"
  set $ws5 "5"
  set $ws6 "6"
  set $ws7 "7"
  set $ws8 "8"
  set $ws9 "9"
  set $ws10 "10"

  assign [class="emacs"] $ws3

  # switch to workspace
  bindsym $mod+1 workspace $ws1
  bindsym $mod+2 workspace $ws2
  bindsym $mod+3 workspace $ws3
  bindsym $mod+4 workspace $ws4
  bindsym $mod+5 workspace $ws5
  bindsym $mod+6 workspace $ws6
  bindsym $mod+7 workspace $ws7
  bindsym $mod+8 workspace $ws8
  bindsym $mod+9 workspace $ws9
  bindsym $mod+0 workspace $ws10

  # move focused container to workspace
  bindsym $mod+Shift+1 move container to workspace $ws1
  bindsym $mod+Shift+2 move container to workspace $ws2
  bindsym $mod+Shift+3 move container to workspace $ws3
  bindsym $mod+Shift+4 move container to workspace $ws4
  bindsym $mod+Shift+5 move container to workspace $ws5
  bindsym $mod+Shift+6 move container to workspace $ws6
  bindsym $mod+Shift+7 move container to workspace $ws7
  bindsym $mod+Shift+8 move container to workspace $ws8
  bindsym $mod+Shift+9 move container to workspace $ws9
  bindsym $mod+Shift+0 move container to workspace $ws10

  # reload the configuration file
  bindsym $mod+Shift+c reload
  # restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
  bindsym $mod+Shift+r restart
  # exit i3 (logs you out of your X session)
  bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"

  # resize window (you can also use the mouse for that)
  mode "resize" {
          # These bindings trigger as soon as you enter the resize mode

          # Pressing left will shrink the window’s width.
          # Pressing right will grow the window’s width.
          # Pressing up will shrink the window’s height.
          # Pressing down will grow the window’s height.
          bindsym j resize shrink width 10 px or 10 ppt
          bindsym k resize grow height 10 px or 10 ppt
          bindsym l resize shrink height 10 px or 10 ppt
          bindsym semicolon resize grow width 10 px or 10 ppt

          # same bindings, but for the arrow keys
          bindsym Left resize shrink width 10 px or 10 ppt
          bindsym Down resize grow height 10 px or 10 ppt
          bindsym Up resize shrink height 10 px or 10 ppt
          bindsym Right resize grow width 10 px or 10 ppt

          # back to normal: Enter or Escape or $mod+r
          bindsym Return mode "default"
          bindsym Escape mode "default"
          bindsym $mod+r mode "default"
  }

  bindsym $mod+r mode "resize"

    bar {
        status_command i3status
        position top
    }

    #######################
    #                     #
    #       AUTORUNS      #
    #                     #
    #######################
    # Start firefox
    exec --no-startup-id ${pkgs.firefox}/bin/firefox --new-instance --setDefaultBrowser

    # Start my-emacs server
    exec --no-startup-id my-emacs-daemon
  '';

in {

  #######################
  #                     #
  #     AUTORANDR       #
  #                     #
  #######################

  # Start autorandr on display change
  services.autorandr = {
    enable = true;
    defaultTarget = "mobile";
  };

  # What to execute after resolution has been changed
  environment.etc."xdg/autorandr/postswitch" = {
    text = '' sleep 4 && i3-msg "restart" '';

  };

  # Start autorandr once on startup
  systemd.user.services.boot-autorandr = {
    description = "Autorandr service";
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.autorandr}/bin/autorandr -c";
      Type = "oneshot";
    };
  };



  #######################
  #                     #
  #       XSERVER       #
  #                     #
  #######################
services.xserver.enable = true;

  # Enable i3 Window Manager
  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;
    configFile = i3_conf_file;
   };


  # ${pkgs.xorg.xhost}/bin/xhost +SI:localuser:${cfg.user.name}
  # ${pkgs.xorg.xhost}/bin/xhost -LOCAL:
  services.xserver.windowManager.default = "i3";
  services.xserver.desktopManager.xterm.enable = false;


  # Enable the X11 windowing system.
  services.xserver.displayManager.lightdm.enable = true;

  # Allow users in video group to change brightness
  hardware.brightnessctl.enable = true;

  environment.systemPackages = with pkgs; [
    rofi     # Dmenu replacement
    acpilight # Replacement for xbacklight
    arandr # Xrandr gui
    alacritty
    feh
    wirelesstools # To get wireless statistics
    acpi
    xorg.xhost
    xorg.xauth
  ];

}
