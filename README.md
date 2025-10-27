# ShortcutCounterMac

A native macOS menubar application that tracks and logs keyboard shortcuts with detailed session information.

## Features

- 🎯 **Real-time tracking** of keyboard shortcuts (CMD, OPT, CTRL, SHIFT combinations)
- 📊 **Live breakdown** showing usage statistics for each shortcut
- 💾 **Persistent logging** to local file with timestamps
- 🛌 **Session tracking** with automatic sleep/wake detection
- ⌨️ **Comprehensive key support** including letters, numbers, special characters, and arrow keys
- 📱 **Clean menubar interface** with total count display

## Screenshots

[Screenshots will be added here]

## Installation

### Requirements
- macOS 13.0 or later
- Input Monitoring permission (manual setup required)

### Download & Install

**Option 1: Ready-to-use App (Recommended)**
1. Download `ShortcutCounter.app` directly from this repository
2. Drag `ShortcutCounter.app` to your Applications folder
3. **Important**: Right-click the app → "Open" (required for unsigned apps)
4. Follow the permission setup below

**Option 2: Download from Releases**
1. Download the latest release from [Releases](https://github.com/MarkMeinema/ShortcutCounterMac/releases)
2. Unzip and drag `ShortcutCounter.app` to your Applications folder
3. Follow the permission setup below

### ⚠️ Required Permission Setup

**The app will NOT appear automatically in Input Monitoring list.** You must add it manually:

1. **Launch the app** - it will appear in your menubar
2. **Open System Preferences** → **Privacy & Security** → **Input Monitoring**
3. **Click the "+" button** to add a new app
4. **Navigate to Applications folder** → Select **ShortcutCounter.app**
5. **Check the box** next to ShortcutCounter to grant permission
6. **Restart the app** if keyboard shortcuts aren't being detected

**Why manual setup?** The app is not code-signed with an Apple Developer certificate, so macOS doesn't automatically add it to the permission list. This is normal for free/open-source apps.

### Build from Source

1. Clone this repository:
   ```bash
   git clone https://github.com/MarkMeinema/ShortcutCounterMac.git
   cd ShortcutCounterMac
   ```

2. Open in Xcode:
   ```bash
   open Package.swift
   ```

3. Build and run (⌘+R)

## Usage

1. **Launch**: The app appears as a keyboard icon in your menubar
2. **View stats**: Click the menubar icon to see breakdown of shortcuts used
3. **Logs**: All shortcuts are logged to `~/Applications/ShortcutCounter/shortcut_log.txt`
4. **Session tracking**: Sleep/wake events are automatically logged for session analysis

## Log Format

```
2025-10-27 09:15:30 === LAPTOP WAKE UP ===
2025-10-27 09:16:45 CMD+A
2025-10-27 09:17:12 CMD+C
2025-10-27 09:17:15 CMD+V
2025-10-27 12:30:20 === LAPTOP SLEEP/STANDBY ===
```

## Supported Shortcuts

- **All modifier combinations**: CMD, OPT, CTRL, SHIFT
- **Letters**: A-Z
- **Numbers**: 0-9
- **Special characters**: `, [ ] - = ' ; , . / \`
- **Function keys**: Tab, Esc, Return, Space, Delete, Arrow keys

## Privacy

- All data stays **locally on your Mac**
- No network connections or data transmission
- Logs are stored in your home directory
- Only keyboard shortcuts with modifiers are tracked (not individual keystrokes)

## Development

### Architecture

- **SwiftUI** for the menubar interface
- **Carbon/Cocoa** for low-level keyboard event detection
- **CGEventTap** for system-wide shortcut monitoring
- **NSWorkspace** for sleep/wake notifications

### Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Known Issues

- **Manual permission setup required** - app doesn't auto-appear in Input Monitoring list (due to lack of Apple Developer certificate)
- May show harmless Control Center warnings in console after sleep/wake
- Xcode rebuilds require re-granting permissions during development

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by KeyCastr and similar keyboard monitoring tools
- Built with SwiftUI and modern macOS APIs
- Thanks to the macOS development community for guidance on CGEventTap usage

## Support

If you encounter issues:

1. **Permission problems**: Follow the detailed permission setup instructions above - manual setup is required
2. **App not detecting shortcuts**: Restart the app after granting Input Monitoring permission
3. **"App can't be opened" error**: Right-click app → "Open" to bypass unsigned app warning
4. **For development issues**: Check the Xcode console for detailed logs
5. Open an issue on GitHub with details about your setup

### Troubleshooting Input Monitoring

If shortcuts aren't being detected:
- Verify ShortcutCounter appears in System Preferences → Privacy & Security → Input Monitoring
- Ensure the checkbox next to ShortcutCounter is **checked**
- Try removing and re-adding the app using the "-" and "+" buttons
- Restart ShortcutCounter after making permission changes

---

**Note**: This app requires macOS Input Monitoring permissions to function. This is a system requirement for any app that monitors keyboard events system-wide.
