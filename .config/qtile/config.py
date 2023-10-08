import os
import subprocess
from Xlib import display as xdisplay
from libqtile import qtile
from libqtile.config import Key, Screen, Group, Drag, Click, Match
from libqtile.command import lazy
from libqtile.log_utils import logger
from libqtile import layout, bar, widget, hook

from qtile_extras.popup.toolkit import PopupRelativeLayout, PopupImage, PopupText
from qtile_extras.widget.upower import UPowerWidget

# DEFINING SOME VARIABLES #
mod = "mod4"  # Sets mod key to SUPER/WINDOWS
myTerm = "alacritty"  # My terminal of choice

backlightNames = ["intel_backlight", "edp-backlight"]

# HELPER FUNCTIONS #

backlightName = ""
for name in backlightNames:
    if os.path.exists("/sys/class/backlight/" + name):
        backlightName = name


def get_num_monitors():
    num_monitors = 0
    try:
        display = xdisplay.Display()
        screen = display.screen()
        resources = screen.root.xrandr_get_screen_resources()

        for output in resources.outputs:
            monitor = display.xrandr_get_output_info(output, resources.config_timestamp)
            preferred = False
            if hasattr(monitor, "preferred"):
                preferred = monitor.preferred
            elif hasattr(monitor, "num_preferred"):
                preferred = monitor.num_preferred
            if preferred:
                num_monitors += 1
    except Exception:
        # always setup at least one monitor
        return 1
    else:
        return num_monitors


def show_power_menu(qtile):
    controls = [
        PopupImage(
            filename="~/.config/qtile/icons/logout.svg",
            pos_x=0.15,
            pos_y=0.1,
            width=0.1,
            height=0.5,
            mouse_callbacks={"Button1": lazy.shutdown()},
        ),
        PopupImage(
            filename="~/.config/qtile/icons/sleep.svg",
            pos_x=0.45,
            pos_y=0.1,
            width=0.1,
            height=0.5,
            mouse_callbacks={"Button1": lazy.spawn("systemctl suspend")},
        ),
        PopupImage(
            filename="~/.config/qtile/icons/power-off.svg",
            pos_x=0.75,
            pos_y=0.1,
            width=0.1,
            height=0.5,
            highlight="A00000",
            mouse_callbacks={"Button1": lazy.spawn("shutdown now")},
        ),
        PopupText(
            text="Logout", pos_x=0.1, pos_y=0.7, width=0.2, height=0.2, h_align="center"
        ),
        PopupText(
            text="Sleep", pos_x=0.4, pos_y=0.7, width=0.2, height=0.2, h_align="center"
        ),
        PopupText(
            text="Shutdown",
            pos_x=0.7,
            pos_y=0.7,
            width=0.2,
            height=0.2,
            h_align="center",
        ),
    ]

    layout = PopupRelativeLayout(
        qtile,
        width=1000,
        height=200,
        controls=controls,
        background="00000060",
        initial_focus=None,
        keymap={},
    )

    layout.show(centered=True)


# KEYBINDINGS #
keys = [
    # The essentials
    Key([mod], "Return", lazy.spawn(myTerm)),  # Open terminal
    Key(
        [mod, "shift"],
        "Return",
        lazy.spawn(
            "rofi -combi-modes window,drun,ssh,run -theme solarized_alternate -font"
            " 'hack 12' -show combi -icon-theme 'Papirus' -show-icons"
        ),
    ),  # Run Launcher
    Key([mod], "Tab", lazy.next_layout()),  # Toggle through layouts
    Key([mod, "shift"], "c", lazy.window.kill()),  # Kill active window
    Key([mod, "shift"], "r", lazy.restart()),  # Restart Qtile
    Key([mod, "shift"], "q", lazy.function(show_power_menu)),  # Shutdown Qtile
    Key([mod], "z", lazy.spawn("xscreensaver-command -lock")),  # Lock Session
    # Switch focus to specific monitor (out of three)
    Key(
        [mod],
        "w",
        # Keyboard focus to screen(0)
        lazy.to_screen(0),
    ),
    Key(
        [mod],
        "e",
        # Keyboard focus to screen(1)
        lazy.to_screen(1),
    ),
    Key(
        [mod],
        "r",
        # Keyboard focus to screen(2)
        lazy.to_screen(2),
    ),
    # Switch focus of monitors
    # Move monitor focus to next screen
    Key([mod], "period", lazy.next_screen()),
    # Move monitor focus to prev screen
    Key([mod], "comma", lazy.prev_screen()),
    # Treetab controls
    Key(
        # Move up a section in treetab
        [mod, "control"],
        "k",
        lazy.layout.section_up(),
    ),
    Key(
        [mod, "control"],
        "j",
        lazy.layout.section_down(),  # Move down a section in treetab
    ),
    # Window controls
    # Switch between windows in current stack pane
    Key([mod], "k", lazy.layout.down()),
    # Switch between windows in current stack pane
    Key([mod], "j", lazy.layout.up()),
    Key(
        [mod, "shift"],
        "k",
        lazy.layout.shuffle_down(),  # Move windows down in current stack
    ),
    Key(
        [mod, "shift"],
        "j",
        lazy.layout.shuffle_up(),  # Move windows up in current stack
    ),
    Key(
        [mod],
        "h",
        lazy.layout.grow(),  # Grow size of current window (XmonadTall)
        lazy.layout.increase_nmaster(),  # Increase number in master pane (Tile)
    ),
    Key(
        [mod],
        "l",
        lazy.layout.shrink(),  # Shrink size of current window (XmonadTall)
        lazy.layout.decrease_nmaster(),  # Decrease number in master pane (Tile)
    ),
    Key(
        [mod],
        "n",
        lazy.layout.normalize(),  # Restore all windows to default size ratios
    ),
    Key(
        [mod],
        "m",
        # Toggle a window between minimum and maximum sizes
        lazy.layout.maximize(),
    ),
    Key([mod, "shift"], "f", lazy.window.toggle_floating()),  # Toggle floating
    # Stack controls
    Key(
        [mod],
        "down",
        lazy.layout.rotate(),  # Swap panes of split stack (Stack)
        # Switch which side main pane occupies (XmonadTall)
        lazy.layout.flip(),
    ),
    Key(
        [mod],
        "up",
        # Switch window focus to other pane(s) of stack
        lazy.layout.next(),
    ),
    Key(
        [mod, "control"],
        "Return",
        # Toggle between split and unsplit sides of stack
        lazy.layout.toggle_split(),
    ),
    # Dmenu scripts launched with ALT + CTRL + KEY
    Key(["mod1", "control"], "e", lazy.spawn("./.dmenu/dmenu-edit-configs.sh")),
    # My applications launched with SUPER + ALT + KEY
    Key([mod], "s", lazy.spawn("pavucontrol-qt")),
    # Special Keybindings
    Key(
        [],
        "XF86AudioRaiseVolume",
        lazy.spawn(
            'sh -c "pactl set-sink-mute @DEFAULT_SINK@ false ; pactl set-sink-volume'
            ' @DEFAULT_SINK@ +5%"'
        ),
    ),
    Key(
        [],
        "XF86AudioLowerVolume",
        lazy.spawn(
            'sh -c "pactl set-sink-mute @DEFAULT_SINK@ false ; pactl set-sink-volume'
            ' @DEFAULT_SINK@ -5%"'
        ),
    ),
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")),
    Key([], "XF86MonBrightnessUp", lazy.spawn("light -A 10")),
    Key([], "XF86MonBrightnessDown", lazy.spawn("light -U 10")),
]


# GROUPS #
group_names = [
    ("1", {"layout": "monadtall"}),
    ("2", {"layout": "monadtall"}),
    ("3", {"layout": "monadtall"}),
    ("4", {"layout": "monadtall"}),
    ("5", {"layout": "monadtall"}),
    ("6", {"layout": "monadtall"}),
    ("7", {"layout": "monadtall"}),
    ("8", {"layout": "monadtall"}),
    ("9", {"layout": "floating"}),
]

groups = [Group(name, **kwargs) for name, kwargs in group_names]

for i, (name, kwargs) in enumerate(group_names, 1):
    # Switch to another group
    keys.append(Key([mod], str(i), lazy.group[name].toscreen()))
    # Send current window to another group
    keys.append(Key([mod, "shift"], str(i), lazy.window.togroup(name)))


# DEFAULT THEME SETTINGS FOR LAYOUTS #
layout_theme = {
    "border_width": 2,
    "margin": 4,
    "border_focus": "#1793D1",
    "border_normal": "#1D2330",
}

# THE LAYOUTS #
layouts = [
    layout.Max(),
    layout.Stack(num_stacks=2, **layout_theme),
    # layout.MonadWide(**layout_theme),
    # layout.Bsp(**layout_theme),
    # layout.Stack(stacks=2, **layout_theme),
    # layout.Columns(**layout_theme),
    # layout.RatioTile(**layout_theme),
    # layout.VerticalTile(**layout_theme),
    # layout.Tile(shift_windows=True, **layout_theme),
    # layout.Matrix(**layout_theme),
    # layout.Zoomy(**layout_theme),
    layout.MonadTall(**layout_theme),
    layout.Floating(**layout_theme),
]

# DEFAULT WIDGET SETTINGS #
widget_defaults = dict(
    font="Hack Nerd Font",
    fontsize=14,
    padding=2,
)
extension_defaults = widget_defaults.copy()

# WIDGETS #


def init_widgets_list():
    sep_props = {"linewidth": 1, "foreground": "#ffffff"}
    widgets_list = [
        widget.Sep(padding=6, linewidth=0),
        widget.GroupBox(
            borderwidth=3,
            inactive="#ffffff.7",
            this_current_screen_border="#1793D1",
            other_screen_border="#1793D1.5",
            this_screen_border="#ffffff.7",
            other_current_screen_border="#ffffff.3",
        ),
        widget.Sep(
            padding=10,
            **sep_props,
        ),
        widget.WindowName(padding=5),
        widget.Notify(
            padding=5,
            default_timeout=5,
        ),
        widget.WidgetBox(
            widgets=[
                widget.Memory(padding=5),
                widget.Sep(**sep_props),
                widget.CPUGraph(type="line"),
                widget.Sep(**sep_props),
                widget.Net(padding=5, format="{down} ↓↑ {up}"),
                widget.Sep(**sep_props),
            ]
        ),
        UPowerWidget(
            border_charge_colour="79b807",
            border_colour="ffffff.5",
            border_critical_colour="ea625a",
        ),
        widget.Sep(**sep_props),
        widget.TextBox(text="🔊", padding=0, fontsize=14),
        widget.PulseVolume(
            padding=5, limit_max_volume=True, volume_app="pavucontrol-qt"
        ),
        widget.Sep(**sep_props),
        widget.Backlight(
            backlight_name=backlightName,
            change_command="light -S {0}",
            fmt=" {}",
            padding=5,
        ),
        widget.Sep(**sep_props),
        widget.CurrentLayoutIcon(
            custom_icon_paths=[os.path.expanduser("~/.config/qtile/icons")],
            padding=0,
            scale=0.7,
        ),
        widget.Sep(**sep_props),
        widget.Wttr(
            format=1,
            location= {"Home": "70619"},
            mouse_callbacks={
                "Button1": lambda: qtile.spawn(
                    myTerm + " --hold -e wttr 70619"
                )
            },
        ),
        widget.Sep(**sep_props),
        widget.Clock(
            format="%a, %b %d - %H:%M:%S",
            padding=2,
        ),
        widget.Sep(**sep_props),
        widget.KeyboardLayout(configured_keyboards=["us", "de"], padding=5),
        widget.Sep(**sep_props),
        widget.Systray(padding=5),
        widget.Sep(
            linewidth=0,
            padding=7,
        ),
    ]
    return widgets_list


# SCREENS ##### (MULTI MONITOR SETUP or ONE MONITOR)


def init_widgets_primary_screen():
    widgets = init_widgets_list()
    return widgets


def init_widgets_secoundary_screen():
    widgets = init_widgets_list()
    return widgets[:-3]


def init_screens(num_monitors):
    screen_props = {"opacity": 0.95, "size": 22, "background": "#ffffff.1"}
    if num_monitors == 1:
        return [
            Screen(top=bar.Bar(widgets=init_widgets_primary_screen(), **screen_props))
        ]
    else:
        screens = [
            Screen(top=bar.Bar(widgets=init_widgets_primary_screen(), **screen_props))
        ]
        for _ in range(num_monitors - 1):
            screens.append(
                Screen(
                    top=bar.Bar(
                        widgets=init_widgets_secoundary_screen(), **screen_props
                    )
                )
            )
        return screens


if __name__ in ["config", "__main__"]:
    num_monitors = get_num_monitors()
    logger.info("number of screens: {0}".format(num_monitors))
    screens = init_screens(num_monitors)

# DRAG FLOATING WINDOWS #

mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
main = None
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False

floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(title="emulator"),
    ]
)

auto_fullscreen = True
focus_on_window_activation = "smart"

# STARTUP APPLICATIONS #


@hook.subscribe.startup_once
def start_once():
    home = os.path.expanduser("~")
    subprocess.call([home + "/.config/qtile/autostart.sh"])


# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
