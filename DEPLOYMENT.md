# Deployment Guide

This document explains how to create distributable builds of ShortcutCounter for other Mac users.

## Option 1: GitHub Releases (Recommended)

### Step 1: Create Signed App Bundle

1. Open the project in Xcode
2. Select "Any Mac" as the destination
3. Product → Archive
4. In Organizer, select your archive
5. Click "Distribute App"
6. Choose "Developer ID" for distribution outside App Store
7. Follow the signing process
8. Export the signed .app

### Step 2: Create DMG (Optional but Professional)

Using create-dmg tool:

```bash
# Install create-dmg
brew install create-dmg

# Create DMG
create-dmg \
  --volname "ShortcutCounter" \
  --window-pos 200 120 \
  --window-size 600 300 \
  --icon-size 100 \
  --icon "ShortcutCounter.app" 175 120 \
  --hide-extension "ShortcutCounter.app" \
  --app-drop-link 425 120 \
  "ShortcutCounter.dmg" \
  "path/to/ShortcutCounter.app"
```

### Step 3: Create GitHub Release

1. Go to your GitHub repository
2. Click "Releases" → "Create a new release"
3. Tag: `v1.0.0`
4. Title: `ShortcutCounter v1.0.0`
5. Description: Release notes with features
6. Attach the .app or .dmg file
7. Publish release

## Option 2: Direct Download

### Zip Distribution

```bash
# Create zip for distribution
zip -r ShortcutCounter-v1.0.0.zip ShortcutCounter.app
```

### Installation Instructions for Users

1. Download ShortcutCounter.zip
2. Extract the zip file
3. Drag ShortcutCounter.app to Applications folder
4. **Important**: Right-click app → "Open" (first time only, to bypass Gatekeeper)
5. Grant Input Monitoring permission when prompted
6. Restart the app

## Option 3: Homebrew Cask (Advanced)

For advanced distribution, create a Homebrew cask:

```ruby
cask "shortcutcounter" do
  version "1.0.0"
  sha256 "abc123..."
  
  url "https://github.com/yourusername/ShortcutCounter/releases/download/v#{version}/ShortcutCounter.dmg"
  name "ShortcutCounter"
  desc "macOS menubar app to track keyboard shortcuts"
  homepage "https://github.com/yourusername/ShortcutCounter"
  
  app "ShortcutCounter.app"
end
```

## Security & Signing

### Developer ID Signing (Recommended)

1. Enroll in Apple Developer Program ($99/year)
2. Create Developer ID certificates
3. Sign your app with Developer ID
4. Users can install without "unknown developer" warnings

### Without Developer ID (Free)

Users will see "app from unknown developer" warning:
- They need to right-click → "Open" first time
- Or go to System Preferences → Security → "Open Anyway"

## Distribution Checklist

- [ ] App builds and runs on clean macOS system
- [ ] Input Monitoring permission flow works
- [ ] README.md includes clear installation instructions
- [ ] .gitignore excludes build artifacts and logs
- [ ] License file included
- [ ] Version number updated in code
- [ ] Release notes written
- [ ] App signed (if using Developer ID)
- [ ] DMG created (optional)
- [ ] GitHub release created with attached binaries

## Testing Distribution

Before public release:

1. Test on different macOS versions (13.0+)
2. Test on fresh Mac without development tools
3. Verify permission prompts work correctly
4. Check app launches from Applications folder
5. Confirm logging works in user environment

## Marketing & Visibility

- Add screenshots to README
- Create demo GIF/video
- Post on relevant forums (r/MacApps, Hacker News, etc.)
- Add to app directory sites
- Tweet about it
- Blog post explaining the development process