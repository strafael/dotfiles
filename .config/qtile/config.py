import os
import re
import socket
import subprocess

from libqtile import layout, bar, widget, hook
from libqtile.command import lazy
from libqtile.config import Drag, Key, Screen, Group, Drag, Click, Rule
from libqtile.widget import Spacer

mod = "mod4"
mod1 = "alt"
mod2 = "control"
home = os.path.expanduser('~')
myterm = "alacritty"

keys = [
    # Essentials
    Key([mod], "Return", lazy.spawn('alacritty'), desc="Launch terminal"),
    Key([mod], "d", lazy.spawn("rofi -show drun"), desc="Run launcher"),
    Key([mod], "space", lazy.next_layout(), desc="Change to next layout"),
    Key([mod, "shift"], "q", lazy.window.kill(), desc="Kill active window"),
    Key([mod], "0", lazy.spawn('arcolinux-logout'), desc="Open exit menu"),
    Key([mod, "shift"], "r", lazy.restart(), desc="Restart Qtile"),

    # Switch focus to specific monitor (out of three)
    Key([mod], "w", lazy.to_screen(0), desc='Keyboard focus to monitor 1'),
    Key([mod], "e", lazy.to_screen(1), desc='Keyboard focus to monitor 2'),
    Key([mod], "r", lazy.to_screen(2), desc='Keyboard focus to monitor 3'),

    # Switch focus of monitors
    Key([mod], "period", lazy.next_screen(), desc='Move focus to next monitor'),
    Key([mod], "comma", lazy.prev_screen(), desc='Move focus to prev monitor'),

    # Treetab controls
    # Key([mod], "control", "k", lazy.layout.section_up(), desc="Move up a section in treetab"),
    # Key([mod], "control", "j", lazy.layout.section_down(), desc="Move down a section in treetab"),

    # Change focus
    Key([mod], "Up", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "Down", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "Left", lazy.layout.left(), desc="Move focus left"),
    Key([mod], "Right", lazy.layout.right(), desc="Move focus right"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "h", lazy.layout.left(), desc="Move focus left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus right"),

    # Window controls
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen"),
    Key([mod, "shift"], "space", lazy.window.toggle_floating(), desc="Toggle floating"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window right"),

    # Resize window
    Key([mod, "control"], "h", lazy.layout.grow(), lazy.layout.increase_nmaster(), desc="Expand window / increase number in master pane"),
    Key([mod, "control"], "l", lazy.layout.shrink(), lazy.layout.decrease_nmaster(), desc="Shrink window / decrease number in master pane"),
    Key([mod], "n", lazy.layout.normalize(), desc="Normalize window size ratios"),
    Key([mod], "m", lazy.layout.maximize(), desc="Toggle window between minimum and maximum sizes"),

    # Stack controls
    Key([mod, "shift"], "f", lazy.layout.rotate(), lazy.layout.flip(), desc="Switch which side main pane occupies (XmonadTall)"),
    Key([mod], "Tab", lazy.layout.next(), desc="Switch window focus to other pane(s) of stack"),
    # TODO que isso faz???
    Key([mod, "control"], "Return", lazy.layout.toggle_split(), desc='Toggle between split and unsplit sides of stack'),

    # Dmenu scripts lanched with Ctrl + Alt + Key

    # Applications launched with Super + Alt + Key
    Key([mod, "mod1"], "y", lazy.spawn("gtk3-youtube-viewer"), desc="youtube-viewer"),
    Key([mod, "mod1"], "Left", lazy.spawn('variety -p')),
    Key([mod, "mod1"], "Right", lazy.spawn('variety -n')),

    # Applications launched with Ctrl + Shift + Key
    Key([mod2, "shift"], "Escape", lazy.spawn('xfce4-taskmanager')),

# SCREENSHOTS

    Key([], "Print", lazy.spawn("scrot 'ArcoLinux-%Y-%m-%d-%s_screenshot_$wx$h.jpg' -e 'mv $f $$(xdg-user-dir PICTURES)'")),
    Key([mod2], "Print", lazy.spawn('xfce4-screenshooter')),
    Key([mod2, "shift"], "Print", lazy.spawn('gnome-screenshot -i')),

# MULTIMEDIA KEYS

# INCREASE/DECREASE BRIGHTNESS
    Key([], "XF86MonBrightnessUp", lazy.spawn("xbacklight -inc 5")),
    Key([], "XF86MonBrightnessDown", lazy.spawn("xbacklight -dec 5")),

# INCREASE/DECREASE/MUTE VOLUME
    Key([], "XF86AudioMute", lazy.spawn("amixer -q set Master toggle")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("amixer -q set Master 5%-")),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("amixer -q set Master 5%+")),

    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause")),
    Key([], "XF86AudioNext", lazy.spawn("playerctl next")),
    Key([], "XF86AudioPrev", lazy.spawn("playerctl previous")),
    Key([], "XF86AudioStop", lazy.spawn("playerctl stop")),

# QTILE LAYOUT KEYS
    Key([mod], "n", lazy.layout.normalize()),



# RESIZE UP, DOWN, LEFT, RIGHT
    Key([mod, "control"], "l",
        lazy.layout.grow_right(),
        lazy.layout.grow(),
        lazy.layout.increase_ratio(),
        lazy.layout.delete(),
        ),
    Key([mod, "control"], "Right",
        lazy.layout.grow_right(),
        lazy.layout.grow(),
        lazy.layout.increase_ratio(),
        lazy.layout.delete(),
        ),
    Key([mod, "control"], "h",
        lazy.layout.grow_left(),
        lazy.layout.shrink(),
        lazy.layout.decrease_ratio(),
        lazy.layout.add(),
        ),
    Key([mod, "control"], "Left",
        lazy.layout.grow_left(),
        lazy.layout.shrink(),
        lazy.layout.decrease_ratio(),
        lazy.layout.add(),
        ),
    Key([mod, "control"], "k",
        lazy.layout.grow_up(),
        lazy.layout.grow(),
        lazy.layout.decrease_nmaster(),
        ),
    Key([mod, "control"], "Up",
        lazy.layout.grow_up(),
        lazy.layout.grow(),
        lazy.layout.decrease_nmaster(),
        ),
    Key([mod, "control"], "j",
        lazy.layout.grow_down(),
        lazy.layout.shrink(),
        lazy.layout.increase_nmaster(),
        ),
    Key([mod, "control"], "Down",
        lazy.layout.grow_down(),
        lazy.layout.shrink(),
        lazy.layout.increase_nmaster(),
        ),


# FLIP LAYOUT FOR MONADTALL/MONADWIDE

# FLIP LAYOUT FOR BSP
    Key([mod, "mod1"], "k", lazy.layout.flip_up()),
    Key([mod, "mod1"], "j", lazy.layout.flip_down()),
    Key([mod, "mod1"], "l", lazy.layout.flip_right()),
    Key([mod, "mod1"], "h", lazy.layout.flip_left()),

# MOVE WINDOWS UP OR DOWN BSP LAYOUT

# MOVE WINDOWS UP OR DOWN MONADTALL/MONADWIDE LAYOUT
    Key([mod, "shift"], "Up", lazy.layout.shuffle_up()),
    Key([mod, "shift"], "Down", lazy.layout.shuffle_down()),
    Key([mod, "shift"], "Left", lazy.layout.swap_left()),
    Key([mod, "shift"], "Right", lazy.layout.swap_right()),
]

group_names = [
    ("1", {"layout": "max"}),
    ("2", {"layout": "monadtall"}),
    ("3", {"layout": "monadtall"}),
    ("4", {"layout": "monadtall"}),
    ("5", {"layout": "monadtall"}),
    ("6", {"layout": "monadtall"}),
    ("7", {"layout": "monadtall"}),
    ("8", {"layout": "floating"}),
]
groups = [Group(name, **kwargs) for name, kwargs in group_names]

# Add workspace specific keybindinds to each workspace
for i, (name, kwargs) in enumerate(group_names, 1):
    # Switch to another group
    keys.append(Key([mod], str(i), lazy.group[name].toscreen()))

    # Send current window to another group and follow moved window
    keys.append(Key([mod, "shift"], str(i), lazy.window.togroup(name), lazy.group[name].toscreen()))

    # Switch to next group
    keys.append(Key(["mod1"], "Tab", lazy.screen.next_group()))

    # Swith to previous group
    keys.append(Key(["mod1", "shift"], "Tab", lazy.screen.prev_group()))

layout_theme = {
    "margin": 5,
    "border_width": 2,
    "border_focus": "#5e81ac",
    "border_normal": "#4c566a",
}

layouts = [
    layout.MonadTall(**layout_theme),
    layout.Bsp(**layout_theme),
    layout.Columns(**layout_theme),
    layout.Max(**layout_theme),
    layout.MonadWide(**layout_theme),
    layout.Tile(shift_windows=True, **layout_theme),
    layout.VerticalTile(**layout_theme),
    layout.RatioTile(**layout_theme),
    layout.Matrix(**layout_theme),
    layout.Zoomy(**layout_theme),
    layout.Stack(num_stacks=2),
    layout.TreeTab(
        font = "Ubuntu",
        fontsize = 10,
        sections = ["FIRST", "SECOND"],
        section_fontsize = 11,
        bg_color = "141414",
        active_bg = "90C435",
        active_fg = "000000",
        inactive_bg = "384323",
        inactive_fg = "a0a0a0",
        padding_y = 5,
        section_top = 10,
        panel_width = 320,
    ),
    layout.Floating(**layout_theme),
]

colors = {
    "bg": "#282c34",
    "fg": "#ffffff",
    "inactive": "#909090",
    "border": "#2d82b7",
    "border_other_screen": "#364d5c",
    "window_name": "#e1acff",
}

widget_defaults = dict(
    font="Ubuntu Mono",
    fontsize = 12,
    padding = 2,
    background=colors["bg"],
    foreground=colors["fg"],
)

prompt = "{0}@{1}: ".format(os.environ["USER"], socket.gethostname())
widgets_list = [
    widget.Sep(linewidth = 0, padding = 6),
    widget.GroupBox(
        font = "Ubuntu Bold",
        fontsize = 10,
        padding=5,
        active = colors["fg"],
        inactive = colors["inactive"],
        highlight_method="border",
        borderwidth = 2,
        rounded = True,
        this_current_screen_border=colors["border"],
        this_screen_border=colors["border"],
        other_current_screen_border=colors["border_other_screen"],
        other_screen_border=colors["border_other_screen"],
    ),
    widget.CurrentLayoutIcon(
        custom_icon_paths = [os.path.expanduser("~/.config/qtile/icons")],
        padding = 0,
        scale = 0.6
    ),
    widget.CurrentLayout(),
    widget.Sep(linewidth=0, padding=40),
    widget.WindowName(foreground=colors["window_name"], padding=0),
    widget.TextBox(text = " 🌡", padding = 2, fontsize = 11),
    widget.ThermalSensor(threshold = 90, padding = 5),
    widget.TextBox(
        text = " ⟳",
        padding = 2,
        fontsize = 14,
        mouse_callbacks = {'Button1': lambda qtile: qtile.cmd_spawn(myterm + " -e sh -c $HOME/.config/qtile/scripts/yay-update")},
    ),
    widget.Pacman(
        update_interval = 1800,
        mouse_callbacks = {'Button1': lambda qtile: qtile.cmd_spawn(myterm + " -e sh -c $HOME/.config/qtile/scripts/yay-update")},
    ),
    widget.TextBox(
        text = " ",
        fontsize = 11,
        padding = 0,
        mouse_callbacks = {'Button1': lambda qtile: qtile.cmd_spawn(myterm + ' -e htop')},
    ),
    widget.CPU(
        padding = 5,
        format="{load_percent}%",
        mouse_callbacks = {'Button1': lambda qtile: qtile.cmd_spawn(myterm + ' -e htop')},
    ),
    widget.TextBox(
        text = " 🖬",
        fontsize = 14,
        padding = 0,
        mouse_callbacks = {'Button1': lambda qtile: qtile.cmd_spawn(myterm + ' -e htop')},
    ),
    widget.Memory(
        padding = 5,
        format="{MemUsed}M",
        mouse_callbacks = {'Button1': lambda qtile: qtile.cmd_spawn(myterm + ' -e htop')},
    ),
    widget.Sep(linewidth = 0, padding = 20),
    widget.Clock(font="Ubuntu Mono Bold", format="%a %d %b %H:%M"),
    widget.Sep(linewidth = 0, padding = 10),
    widget.Systray(padding = 5),
]

def init_widgets_screen1():
    widgets_screen1 = widgets_list
    return widgets_screen1

def init_widgets_screen2():
    widgets_screen2 = widgets_list
    return widgets_screen2

def init_screens():
    return [
        Screen(top=bar.Bar(widgets=init_widgets_screen1(), opacity=1.0, size=26)),
        Screen(top=bar.Bar(widgets=init_widgets_screen2(), opacity=1.0, size=26)),
        Screen(top=bar.Bar(widgets=init_widgets_screen1(), opacity=1.0, size=26)),
    ]

screens = init_screens()

@lazy.function
def window_to_prev_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i - 1].name)

@lazy.function
def window_to_next_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i + 1].name)

mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]
dgroups_key_binder = None
dgroups_app_rules = []
main = None
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False

floating_layout = layout.Floating(
    float_rules=[
        {'wmclass': 'confirm'},
        {'wmclass': 'dialog'},
        {'wmclass': 'download'},
        {'wmclass': 'error'},
        {'wmclass': 'file_progress'},
        {'wmclass': 'notification'},
        {'wmclass': 'splash'},
        {'wmclass': 'toolbar'},
        {'wmclass': 'confirmreset'},  # gitk
        {'wmclass': 'makebranch'},  # gitk
        {'wmclass': 'maketag'},  # gitk
        {'wname': 'branchdialog'},  # gitk
        {'wname': 'pinentry'},  # GPG key password entry
        {'wmclass': 'ssh-askpass'},  # ssh-askpass
        {'wmclass': 'vlc'},
    ],
    fullscreen_border_width=0,
    border_width=0,
)
auto_fullscreen = True
focus_on_window_activation = "smart"

floating_types = ["notification", "toolbar", "splash", "dialog"]

@hook.subscribe.client_new
def set_floating(window):
    if (window.window.get_wm_transient_for()
            or window.window.get_wm_type() in floating_types):
        window.floating = True

@hook.subscribe.startup_once
def start_once():
    home = os.path.expanduser('~')
    subprocess.call([home + '/.config/qtile/scripts/autostart.sh'])

@hook.subscribe.startup
def start_always():
    # Set the cursor to something sane in X
    subprocess.Popen(['xsetroot', '-cursor_name', 'left_ptr'])

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
