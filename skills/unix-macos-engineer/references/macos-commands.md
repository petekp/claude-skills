# macOS-Specific Commands

Quick reference for macOS system commands and utilities.

## System Information

```bash
# macOS version
sw_vers

# Hardware info
system_profiler SPHardwareDataType

# CPU info
sysctl -n machdep.cpu.brand_string

# Memory
sysctl hw.memsize

# Disk space
df -h

# System uptime
uptime
```

## defaults (Preferences)

Read and write user defaults (preferences):

```bash
# Read a preference
defaults read com.apple.finder AppleShowAllFiles

# Write a preference
defaults write com.apple.finder AppleShowAllFiles -bool true

# Delete a preference (reset to default)
defaults delete com.apple.finder AppleShowAllFiles

# List all preferences for an app
defaults read com.apple.finder

# Find preferences (search)
defaults read | grep -i "keyword"

# Write different types
defaults write com.example.app setting -string "value"
defaults write com.example.app setting -int 42
defaults write com.example.app setting -float 3.14
defaults write com.example.app setting -bool true
defaults write com.example.app setting -array "a" "b" "c"
```

### Common Finder Settings

```bash
# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Restart Finder to apply
killall Finder
```

### Common Dock Settings

```bash
# Auto-hide dock
defaults write com.apple.dock autohide -bool true

# Set dock size
defaults write com.apple.dock tilesize -int 48

# Minimize to application icon
defaults write com.apple.dock minimize-to-application -bool true

# Restart Dock to apply
killall Dock
```

## Spotlight (mdfind)

```bash
# Search by name
mdfind -name "document.pdf"

# Search by content
mdfind "search term"

# Limit to directory
mdfind -onlyin ~/Documents "search term"

# Search by file type
mdfind "kMDItemContentType == 'public.jpeg'"

# Search by date
mdfind "kMDItemFSCreationDate > \$time.today(-7)"

# Rebuild Spotlight index
sudo mdutil -E /
```

## Clipboard (pbcopy/pbpaste)

```bash
# Copy to clipboard
echo "text" | pbcopy
cat file.txt | pbcopy

# Paste from clipboard
pbpaste
pbpaste > file.txt

# Copy file contents
pbcopy < file.txt
```

## open Command

```bash
# Open file with default app
open document.pdf

# Open with specific app
open -a "Visual Studio Code" file.txt

# Open URL
open https://example.com

# Open directory in Finder
open .
open ~/Documents

# Reveal file in Finder
open -R file.txt

# Open new instance of app
open -n -a "Safari"
```

## Process Management

```bash
# List all processes
ps aux

# Find process by name
pgrep -l "Safari"

# Kill by name
pkill "Safari"

# Force quit app
killall "Safari"

# Activity Monitor data
top -l 1 -s 0

# Per-process CPU/memory
ps -eo pid,pcpu,pmem,comm | head -20
```

## Disk Utilities

```bash
# List disks
diskutil list

# Disk info
diskutil info /dev/disk0

# Eject disk
diskutil eject /dev/disk2

# Mount/unmount
diskutil mount /dev/disk2s1
diskutil unmount /dev/disk2s1

# Repair permissions (legacy, now automatic)
diskutil verifyPermissions /

# APFS snapshots
tmutil listlocalsnapshots /
```

## Network

```bash
# Current network
networksetup -getairportnetwork en0

# List Wi-Fi networks
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s

# DNS servers
scutil --dns

# Flush DNS cache
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder

# Network interfaces
ifconfig

# Active connections
netstat -an | grep ESTABLISHED

# Test connectivity
ping -c 3 google.com

# Trace route
traceroute google.com
```

## Security

```bash
# Keychain access (read password)
security find-generic-password -s "service-name" -w

# Add to keychain
security add-generic-password -s "service-name" -a "account" -w "password"

# List keychains
security list-keychains

# Code signing info
codesign -dv --verbose=4 /Applications/App.app

# Verify code signature
codesign --verify --verbose /Applications/App.app

# Gatekeeper check
spctl --assess --verbose /Applications/App.app
```

## Power Management

```bash
# Prevent sleep
caffeinate -d  # Display sleep
caffeinate -i  # Idle sleep
caffeinate -s  # System sleep

# Prevent sleep for duration
caffeinate -t 3600  # 1 hour

# Prevent sleep while command runs
caffeinate -i long_running_command

# Battery info
pmset -g batt

# Sleep settings
pmset -g

# Schedule shutdown
sudo shutdown -h +60  # In 60 minutes
```

## Screenshots

```bash
# Screenshot entire screen
screencapture screen.png

# Screenshot selection
screencapture -i selection.png

# Screenshot window
screencapture -w window.png

# Screenshot to clipboard
screencapture -c

# Screenshot with delay
screencapture -T 5 delayed.png

# Screenshot specific display
screencapture -D 1 display1.png
```

## Text-to-Speech

```bash
# Speak text
say "Hello, world"

# List voices
say -v '?'

# Use specific voice
say -v "Samantha" "Hello"

# Save to file
say -o output.aiff "Hello, world"

# Read file
say -f input.txt
```

## Notifications

```bash
# Display notification (requires terminal-notifier or osascript)
osascript -e 'display notification "Message" with title "Title"'

# With sound
osascript -e 'display notification "Message" with title "Title" sound name "Ping"'
```

## AppleScript Bridge

```bash
# Run AppleScript
osascript -e 'tell application "Finder" to get name of front window'

# Multi-line
osascript <<EOF
tell application "Safari"
    activate
    open location "https://example.com"
end tell
EOF
```

## SIP (System Integrity Protection)

```bash
# Check SIP status
csrutil status

# Disable (requires Recovery Mode)
# Boot to Recovery → Terminal → csrutil disable

# Enable (requires Recovery Mode)
# Boot to Recovery → Terminal → csrutil enable
```

## Homebrew Integration

```bash
# Install package
brew install package-name

# Install GUI app
brew install --cask app-name

# Update all
brew update && brew upgrade

# List installed
brew list
brew list --cask

# Services (launchd wrapper)
brew services list
brew services start service-name
brew services stop service-name
brew services restart service-name
```
