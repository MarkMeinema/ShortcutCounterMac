# ShortcutCounter

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
- Input Monitoring permission (automatically requested)

### Download & Install

1. Download the latest release from [Releases](https://github.com/yourusername/ShortcutCounter/releases)
2. Unzip and drag `ShortcutCounter.app` to your Applications folder
3. Launch the app - it will appear in your menubar
4. Grant Input Monitoring permission when prompted
5. Restart the app after granting permissions

### Build from Source

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/ShortcutCounter.git
   cd ShortcutCounter
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

- Requires Input Monitoring permission (macOS security requirement)
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

1. Check that Input Monitoring permission is granted in System Preferences
2. Try restarting the app after granting permissions
3. For development issues, check the Xcode console for detailed logs
4. Open an issue on GitHub with details about your setup

---

**Note**: This app requires macOS Input Monitoring permissions to function. This is a system requirement for any app that monitors keyboard events system-wide.