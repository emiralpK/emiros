# XFCE Customization Guide

This guide explains how to customize the XFCE desktop environment in EmiROS.

## Desktop Appearance

### Changing Wallpaper

EmiROS includes a custom wallpaper. To change it:

1. Right-click on desktop
2. Select "Desktop Settings"
3. Choose "Background" tab
4. Click folder icon to browse
5. Select your image

Or via command line:
```bash
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s /path/to/image.png
```

### Theme Settings

Change theme:
```bash
xfce4-appearance-settings
```

Options:
- **Style**: GTK theme
- **Icons**: Icon theme
- **Fonts**: System fonts

### Window Manager Theme

```bash
xfwm4-settings
```

Customize:
- Window decorations
- Button layout
- Focus behavior

## Panel Customization

### Adding Panel Items

1. Right-click on panel
2. Select "Panel" → "Add New Items"
3. Choose from available plugins:
   - Application Menu
   - Clock
   - System Load Monitor
   - Network Monitor
   - CPU Graph
   - Weather

### Panel Position

1. Right-click on panel
2. Select "Panel" → "Panel Preferences"
3. Adjust:
   - Position (top, bottom, left, right)
   - Size
   - Auto-hide behavior

### Creating Additional Panels

```bash
xfce4-panel --add
```

## File Manager (Thunar)

### Thunar Settings

```bash
thunar-settings
```

Customize:
- View options
- Hidden files
- Side panel shortcuts

### Custom Actions

Add custom right-click actions in Thunar:

1. Edit → Configure custom actions
2. Add new action
3. Define command and conditions

Example - Open terminal here:
```
Name: Open Terminal Here
Command: xfce4-terminal --working-directory=%f
Icon: utilities-terminal
Appears if selection contains: Directories
```

## Terminal Customization

### Terminal Preferences

```bash
xfce4-terminal --preferences
```

Or from terminal: Edit → Preferences

Options:
- Colors and background
- Fonts
- Scrolling
- Shortcuts

### Terminal Color Scheme

Create custom color scheme:

1. Open terminal preferences
2. Colors tab
3. Uncheck "Use colors from system theme"
4. Customize:
   - Text color: #e6edf3
   - Background: #0d1117
   - Cursor: #58a6ff

## Keyboard Shortcuts

### Setting Shortcuts

```bash
xfce4-keyboard-settings
```

Recommended shortcuts:
```
Super+T         → xfce4-terminal
Super+E         → thunar
Super+R         → xfce4-appfinder
Super+L         → xflock4
Print           → xfce4-screenshooter
```

### Custom Commands

Add in Keyboard settings:
```bash
/usr/bin/firefox
/usr/bin/chromium
```

## Autostart Applications

### Adding Autostart Items

```bash
xfce4-session-settings
```

Go to "Application Autostart" tab.

Or manually create in:
```bash
~/.config/autostart/
```

Example autostart file:
```ini
[Desktop Entry]
Type=Application
Name=My App
Exec=/path/to/app
Hidden=false
```

## Desktop Icons

### Enabling Desktop Icons

```bash
xfconf-query -c xfce4-desktop -p /desktop-icons/style -s 2
```

Styles:
- 0: None
- 1: File/launcher icons
- 2: File/launcher and removable media icons

### Creating Desktop Launchers

Create `.desktop` file in `~/Desktop/`:

```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=Web Browser
Comment=Browse the web
Exec=firefox
Icon=firefox
Terminal=false
Categories=Network;WebBrowser;
```

## Window Behavior

### Focus Settings

```bash
xfwm4-tweaks-settings
```

Options:
- Click to focus vs. Focus follows mouse
- Raise on focus
- Raise delay

### Workspace Settings

```bash
xfwm4-workspace-settings
```

Configure:
- Number of workspaces
- Names
- Margins

## Task Manager

Launch task manager:
```bash
xfce4-taskmanager
```

Or add to panel for quick access.

## Power Management

```bash
xfce4-power-manager-settings
```

Configure:
- Display brightness
- Screen blanking
- Sleep settings
- Power button action

## Notifications

### Notification Settings

```bash
xfce4-notifyd-config
```

Customize:
- Position
- Duration
- Theme

## Creating Custom Theme

### Step 1: Create Theme Directory

```bash
mkdir -p ~/.themes/EmiROS/xfwm4
```

### Step 2: Theme Files

Create `~/.themes/EmiROS/xfwm4/themerc`:

```ini
button_offset=2
button_spacing=2
full_width_title=true
title_horizontal_offset=2

active_text_color=#e6edf3
inactive_text_color=#8b949e

# More customization...
```

### Step 3: Apply Theme

```bash
xfconf-query -c xfwm4 -p /general/theme -s EmiROS
```

## Default Applications

Set default applications:

```bash
exo-preferred-applications
```

Configure:
- Web Browser
- Mail Reader
- File Manager
- Terminal Emulator

## XFCE Configuration Files

All XFCE settings are stored in:
```
~/.config/xfce4/
```

Key files:
- `xfconf/xfce-perchannel-xml/` - All settings
- `panel/` - Panel configuration
- `terminal/` - Terminal settings

### Backup Configuration

```bash
tar czf xfce4-config-backup.tar.gz ~/.config/xfce4/
```

### Restore Configuration

```bash
tar xzf xfce4-config-backup.tar.gz -C ~/
```

## Scripting XFCE

### Using xfconf-query

Query settings:
```bash
xfconf-query -c xfce4-desktop -l
```

Set value:
```bash
xfconf-query -c xfce4-desktop -p /path/to/property -s "value"
```

### Example: Dark Mode Script

```bash
#!/bin/bash
# Toggle dark mode

current=$(xfconf-query -c xsettings -p /Net/ThemeName)

if [ "$current" = "Adwaita-dark" ]; then
    xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita"
else
    xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark"
fi
```

## Performance Tuning

### Disable Compositing

For better performance on Pi:
```bash
xfconf-query -c xfwm4 -p /general/use_compositing -s false
```

### Reduce Visual Effects

```bash
xfwm4-tweaks-settings
```

Disable:
- Shadows
- Transparency
- Animations

### Lightweight Panel

Remove heavy panel plugins:
- System load monitor
- Weather plugin
- Complex launchers

## EmiROS Specific Customization

### Custom XFCE Configuration

EmiROS includes pre-configured settings in:
```
/etc/xdg/xfce4/
```

These are system-wide defaults. User settings override them.

### Branding

EmiROS logo and wallpaper:
```
/usr/share/emiros/logo.svg
/usr/share/emiros/wallpaper.svg
```

Use these for consistent branding.

## Troubleshooting

### Reset XFCE Settings

```bash
rm -rf ~/.config/xfce4
xfce4-session-logout
```

Log back in - defaults will be restored.

### Panel Missing

```bash
xfce4-panel --restart
```

Or:
```bash
killall xfce4-panel
xfce4-panel &
```

### Desktop Icons Not Showing

```bash
xfdesktop --reload
```

## Resources

- [XFCE Documentation](https://docs.xfce.org/)
- [XFCE Wiki](https://wiki.xfce.org/)
- [GTK Themes](https://www.gnome-look.org/)
- [Icon Themes](https://www.xfce-look.org/)

## Next Steps

- Explore XFCE panel plugins
- Create custom themes
- Share your customizations with the EmiROS community
