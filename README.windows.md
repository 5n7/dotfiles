# Windows setup

Gaming PC. Apps and Windows settings are managed with
[WinGet Configuration](https://learn.microsoft.com/windows/package-manager/configuration/)
in `windows/configuration.dsc.yaml`; everything else is a manual step below.

Build: Ryzen 7 9800X3D, ASUS TUF GAMING X870-PLUS WIFI, Radeon RX 9070 XT,
DDR5-6400 CL32 2x16GB, WD_BLACK SN850X 2TB.

Follow the steps in order.

## 1. Hardware

- Put the SN850X in the top M.2 slot (CPU-attached).
- Feed the GPU's 8-pin connectors with separate PSU cables, not one
  daisy-chained cable.

## 2. BIOS (ASUS UEFI)

- Update the BIOS first, with BIOS FlashBack from a USB stick if needed.
- The first boot after changing memory settings trains memory and can sit on
  a black screen for several minutes; wait it out.
- Enable EXPO.
- Set UCLK DIV1 MODE to UCLK=MEMCLK. DDR5-6400 may default to 1:2, which is
  slower than 6000 at 1:1. If 6400 at 1:1 is unstable, drop to 6000.
- Once stable, enable Memory Context Restore to shorten boot time.
- Disable "Download & Install ARMOURY CRATE app" under Tool.
- Check that Re-Size BAR is on (Smart Access Memory on Radeon).
- Keep fTPM and Secure Boot on; VALORANT's Vanguard requires them.
- Set a fan curve in Q-Fan Control; the GRAND TORNADO 120 is loud at full
  speed.
- Leave PBO and Curve Optimizer at defaults.

## 3. Windows install

- Attach the bundled Wi-Fi antenna to the board's rear I/O.
- There is no wired connection, and Windows setup may not ship a driver for
  the board's Wi-Fi 7 chip. Beforehand, download the Wi-Fi and Bluetooth
  drivers from the board's ASUS support page onto a USB stick (extracted, not
  zipped). If setup's network screen finds no Wi-Fi, use its "Install
  driver" option and point it at the stick.
- Decline OneDrive folder backup if setup offers it; step 5 uninstalls
  OneDrive.
- A clean install of Windows 11 24H2 or later turns on BitLocker when you
  sign in with a Microsoft account. Save the recovery key from account.microsoft.com/devices/recoverykey to
  1Password. Before any later BIOS update, suspend BitLocker (Control Panel >
  BitLocker Drive Encryption > Suspend protection); otherwise the fTPM reset
  asks for the recovery key at boot.
- Run Windows Update until nothing is left. It may install a Radeon driver;
  step 4 replaces it.

## 4. Drivers

Install from amd.com, in this order:

1. AMD Chipset Software for X870. It sets up the Ryzen power plan; keep the
   Balanced power plan.
2. AMD Software: Adrenalin Edition for the RX 9070 XT (Full install). Stay on
   the Recommended (WHQL) channel; Adrenalin notifies about updates.

LAN, Wi-Fi, Bluetooth, and audio usually come through Windows Update. Use the
board's ASUS support page only for a device that still shows up in Device
Manager without a driver.

## 5. Apps and Windows settings

Git is needed once to fetch this repository:

```powershell
winget install Git.Git
git clone https://github.com/5n7/dotfiles.git
cd dotfiles
winget configure -f windows/configuration.dsc.yaml
```

Approve the one UAC prompt; the widgets policy needs admin rights. Sign out
once afterwards so the mouse settings take effect.

Re-run the same command to update; settings already in place are skipped.
It upgrades the packages marked `UseLatest` (Claude Code, EarTrumpet, Git,
HWiNFO); the other apps update themselves. It also removes OneDrive again if a Windows
feature update reinstalled it.

Then turn off autostart in Settings > Apps > Startup for Discord, Riot
Client, Rockstar Games Launcher, and Steam. Keep EarTrumpet and Riot Vanguard
on. Apps can turn this back on when they update; check again if boot gets
slower.

## 6. Display, mouse, and GPU

Windows:

- Settings > Display > Advanced display: set the monitor's full refresh rate.
- Settings > Personalization > Taskbar > Other system tray icons: turn
  EarTrumpet on so its icon stays visible on the taskbar.
- Unpin promoted apps from Start (Spotify, TikTok, and so on). Most are
  install stubs, so unpinning removes them.

Pulsar mouse: set DPI and polling rate with Pulsar's software or web driver
from pulsar.gg; it is not on winget.

AMD Software: Adrenalin Edition:

- FreeSync on (also in the monitor's OSD).
- Radeon Anti-Lag on.
- Radeon Chill, Radeon Boost, Enhanced Sync, and HYPR-RX off.
- FSR 4 in games that support it. Prefer a game's own FSR frame generation
  over AFMF.
- AMD Fluid Motion Frames (AFMF) off globally. Turn it on per game only for
  single-player games that already reach 60 fps; it adds input latency, so
  keep it off for VALORANT.
