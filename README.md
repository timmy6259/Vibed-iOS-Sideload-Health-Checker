# Vibed iOS Sideload Health Checker

This repository contains a SwiftUI iPhone app prototype for checking the health of a sideloaded iOS app at launch.

Included checks:
- JIT available vs unavailable
- Developer certificate signed vs likely not signed
- Jailbreak detection, including rootless jailbreak paths such as `/var/jb/*`

The UI is designed to auto-run on launch and display a simple green/yellow/red status for each check.

## Included files
- `HealthCheckApp/App/HealthCheckApp.swift` — app entry point and launch logic
- `HealthCheckApp/App/HealthCheckView.swift` — GUI view showing the three status cards
- `HealthCheckApp/Health/HealthStatus.swift` — data model and status logic
- `HealthCheckApp/Health/JitProbe.h` — C bridge header
- `HealthCheckApp/Health/JitProbe.c` — JIT availability probe for iOS
- `HealthCheckApp/Health/SigningCheck.swift` — certificate and developer entitlement detection
- `HealthCheckApp/Health/JailbreakCheck.swift` — jailbreak detection, including `/var/jb/*`
- `HealthCheckApp/Bridging-Header.h` — Swift/C bridge header
- `scripts/ci_health_check.sh` — example CI helper script for collecting status output

## Notes
- The JIT check is intentionally conservative: it probes writable+executable memory using `mmap`/`mprotect` and reports availability without executing untrusted machine code.
- The signing check inspects the app’s code-signing information and entitlements (`get-task-allow`) and reports whether it looks developer-signed.
- The jailbreak check includes rootless jailbreak paths: `/var/jb`, `/var/jb/usr/bin`, `/var/jb/usr/lib`, `/var/jb/bin`, etc.
- This repo is intended as a GUI app source template for Xcode; you can open the `HealthCheckApp` source files in an Xcode iOS app project and build it on-device.

## Example of the jailbreak paths checked
- `/Applications/Cydia.app`
- `/Library/MobileSubstrate/MobileSubstrate.dylib`
- `/usr/sbin/sshd`
- `/etc/apt`
- `/private/var/lib/apt`
- `/var/jb`
- `/var/jb/usr/bin`
- `/var/jb/usr/lib`
- `/var/jb/bin`

## Quick idea for use in Xcode
1. Create a new iOS app in Xcode.
2. Add the files from `HealthCheckApp/` to the project.
3. Ensure the bridging header includes: `#import "JitProbe.h"`.
4. Build for your physical iPhone and run.
5. The app will automatically check and show:
   - JIT Passes / Unavailable
   - Developer Certificate / Likely No
   - Jailbroken / Not Jailbroken
