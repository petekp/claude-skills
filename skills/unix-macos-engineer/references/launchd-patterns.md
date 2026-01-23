# launchd Patterns

Common patterns for macOS service management with launchd.

## Plist Locations

| Location | Purpose | Runs As |
|----------|---------|---------|
| `~/Library/LaunchAgents/` | User agents | Current user |
| `/Library/LaunchAgents/` | System-wide user agents | Current user |
| `/Library/LaunchDaemons/` | System daemons | root |

## Basic Agent Template

Run a script when the user logs in:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.myagent</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/myscript.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
```

## Scheduled Task (cron replacement)

Run daily at 3 AM:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.daily-backup</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/backup.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>3</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
</dict>
</plist>
```

## Interval-Based Execution

Run every 5 minutes:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.periodic</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/check-status.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>300</integer>
</dict>
</plist>
```

## File Watcher

Run when a file/directory changes:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.filewatcher</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/on-change.sh</string>
    </array>
    <key>WatchPaths</key>
    <array>
        <string>/path/to/watch</string>
    </array>
</dict>
</plist>
```

## Keep-Alive Service

Restart if process exits:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.server</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/server</string>
    </array>
    <key>KeepAlive</key>
    <true/>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/var/log/myserver.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/myserver.error.log</string>
</dict>
</plist>
```

## Environment Variables

Set environment for the job:

```xml
<key>EnvironmentVariables</key>
<dict>
    <key>PATH</key>
    <string>/usr/local/bin:/usr/bin:/bin</string>
    <key>MY_CONFIG</key>
    <string>/etc/myapp/config.json</string>
</dict>
```

## Working Directory

```xml
<key>WorkingDirectory</key>
<string>/var/myapp</string>
```

## Resource Limits

```xml
<key>SoftResourceLimits</key>
<dict>
    <key>NumberOfFiles</key>
    <integer>1024</integer>
</dict>
<key>HardResourceLimits</key>
<dict>
    <key>NumberOfFiles</key>
    <integer>2048</integer>
</dict>
```

## Common Commands

```bash
# Load agent (start it)
launchctl load ~/Library/LaunchAgents/com.example.myagent.plist

# Unload agent (stop it)
launchctl unload ~/Library/LaunchAgents/com.example.myagent.plist

# Bootstrap (modern alternative to load)
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.example.myagent.plist

# Bootout (modern alternative to unload)
launchctl bootout gui/$(id -u)/com.example.myagent

# Check if running
launchctl list | grep com.example

# Start immediately (without waiting for trigger)
launchctl start com.example.myagent

# Stop
launchctl stop com.example.myagent

# Validate plist syntax
plutil -lint com.example.myagent.plist
```

## Debugging

```bash
# View logs (if using StandardOutPath/StandardErrorPath)
tail -f /var/log/myserver.log

# View system log for launch errors
log show --predicate 'subsystem == "com.apple.launchd"' --last 5m

# Check job status
launchctl print gui/$(id -u)/com.example.myagent
```

## Common Pitfalls

- **Plist must be owned by root:wheel** for LaunchDaemons
- **Scripts must be executable** (`chmod +x`)
- **Use absolute paths** in ProgramArguments
- **Label must match filename** (com.example.myagent.plist → Label: com.example.myagent)
- **Changes require unload/load** to take effect
