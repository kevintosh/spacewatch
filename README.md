# SpaceWatch

SpaceWatch is a small native macOS command-line utility that preserves and restores window placement when external displays disconnect and reconnect. WindowServer preserves display and Space UUIDs, but can still move windows, alter their coordinates, or assign them to the wrong display or Space.

## What it does

- Saves regular application windows, including bundle ID, title, CoreGraphics window ID, frame, persistent Space UUID and display UUID.
- Matches the exact monitor set using CoreGraphics vendor, model, serial and resolution data, allowing separate profiles for configurations such as home and office.
- Resolves each persistent Space UUID to its current runtime `ManagedSpaceID`, moves the window, then restores its position and size.
- Provides `watch-auto`, an automatic profile manager that selects profiles by display set, creates names for unknown sets, and restores profiles when WindowServer's Space mapping is stable.
- Polls the captured state once per second, but writes a profile only when its state fingerprint changes and the same changed state is observed twice consecutively.
- Supports profile renaming without changing display matching.

## Important limitations

- Position and size use Apple's public Accessibility API.
- Moving a window to a Space uses dynamically loaded private SkyLight functions. This requires no SIP change and no scripting addition, but Apple can change these functions in a future macOS update.
- Windows with identical app, title and role are matched heuristically. Stable browser page titles improve matching. Untitled or dynamically titled windows can remain unmatched.
- Full-screen Spaces and Stage Manager are not supported. Turn Stage Manager off.
- This package cannot be compiled in a Linux build environment. Build it on a Mac with Apple's Swift toolchain.

## Installation

Extract the archive, then run:

```zsh
cd ~/Downloads/SpaceWatch
chmod +x install.sh install-watcher.sh uninstall.sh
./install.sh
```

If Swift is unavailable, install Apple's Command Line Tools:

```zsh
xcode-select --install
```

If required, add the binary directory to your shell path:

```zsh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## Grant Accessibility permission

Run:

```zsh
spacewatch displays
spacewatch snapshot home
```

macOS should request Accessibility permission. If it does not, open **System Settings > Privacy & Security > Accessibility**, press **+**, then add:

```text
~/.local/bin/spacewatch
```

You may need to press Command+Shift+G in the file chooser and enter the full path.

## Automatic profile management

Run interactively:

```zsh
spacewatch watch-auto
```

Or install it as a LaunchAgent:

```zsh
./install-watcher.sh
```

`watch-auto` identifies the exact connected display set. If no existing profile matches, it creates a stable name such as `auto-2d-a1b2c3d4`, where `2d` is the display count and the suffix is derived from the display signature.

When a known display set returns, SpaceWatch waits until the persistent Space UUIDs have a stable runtime mapping before restoring the matching profile. While the display set remains connected, SpaceWatch polls once per second. It does not save on a fixed interval: a profile is rewritten only when the state fingerprint changes and the same changed state is observed in two consecutive polls.

## Manual profiles

Arrange all windows and Spaces as desired, then save a named profile:

```zsh
spacewatch snapshot home
```

Restore it manually:

```zsh
spacewatch restore home
```

The older single-profile watcher remains available:

```zsh
spacewatch watch home
```

Profiles are stored under:

```text
~/Library/Application Support/SpaceWatch/Profiles/
```

## List and rename profiles

List profiles:

```zsh
spacewatch list
```

Rename a profile, including an automatically named one:

```zsh
spacewatch rename auto-2d-a1b2c3d4 home
```

The JSON filename and the profile's internal name are both updated. Display matching and `watch-auto` continue under the new name. Renaming fails rather than overwriting an existing profile.

## Logs

```text
~/Library/Logs/SpaceWatch/out.log
~/Library/Logs/SpaceWatch/error.log
```

## Safe testing sequence

1. Save important documents and turn Stage Manager off.
2. Arrange a few test windows, including two browser windows on different Spaces.
3. Run `spacewatch watch-auto` in Terminal.
4. Wait for the first automatic profile save and confirm it with `spacewatch list`.
5. Rename the profile if desired with `spacewatch rename OLD_NAME NEW_NAME`.
6. Disconnect and reconnect the external display.
7. Confirm Space and frame restoration before installing the LaunchAgent.

## Remove

```zsh
./uninstall.sh
```

The uninstall script deliberately preserves profiles.

## Disclaimer

This software is provided “as is”, without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose and non-infringement.

Use this software entirely at your own risk. The authors and contributors shall not be liable for any direct, indirect, incidental, special, consequential or other damages arising from the use of, or inability to use, this software. This includes, without limitation, loss of data, loss of work, application or system instability, and unintended changes to windows, displays, Spaces, desktop arrangements or other macOS settings.

This project is an independent open-source project and is not affiliated with, authorised, sponsored or endorsed by Apple Inc. macOS behaviour and APIs may change between operating system releases, and functionality that works on one version of macOS may not work correctly on another.

Always save important work and maintain appropriate backups before using this software.

## Licence

SPDX-License-Identifier: GPL-3.0-or-later

This project is free software licensed under the GNU General Public License, version 3 (GPL-3.0). You may redistribute and/or modify this software under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the Licence or, if you choose, any later version.

This software is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the `LICENSE` file included with this project for the full licence terms.
