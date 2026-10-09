# ESP32 Remote Shell

An ESP32-based HID tool that emulates a Bluetooth keyboard to launch a remote controlled PowerShell session via Telegram.

---

## The Concept
The **ESP32 Remote Shell** is a hardware based command and control (C2) tool that bridges physical Human Interface Device (HID) emulation with a remote session. By emulating a Bluetooth keyboard, the ESP32 automates the Windows run sequence to execute a token-less PowerShell stager, establishing a secure and interactive remote shell controlled entirely via Telegram.

---

## Key Features

### Hardware HID Injection
- **Bluetooth Keyboard Emulation:** Uses the `BleKeyboard` library to register as a native wireless input devic via Bluetooth.
- **Automated Execution Sequence:** Triggers the Windows Run dialog (`Win + R`), invokes PowerShell, and injects the stager payload automatically upon connection.

### Remote Execution 
- **Stager Model:** Keeps the Telegram bot credentials off the target machine. The ESP32 injects the Telegram bot token directly into the (`$global:Token`) during setup, the token is only flashed on the ESP32 and no where else.
- **Payload Delivery:** Downloads the main execution script (`agent.ps1`) from GitHub using `Invoke-RestMethod` (`irm`) and `Invoke-Expression` (`iex`), leaving no scripts on the target machine.
- **Telegram Command Bridge:** Continuously polls the Telegram Bot API for commands prefixed with `!`, executes them via `Invoke-Expression`, and returns command outputs directly to the Telegram chat.

---

## Hardware Requirements

| Component | Specification | Details |
| :--- | :--- | :--- |
| **Microcontroller** | ESP32 Development Board | ESP32-WROOM-32 or equivalent with BLE support |
| **Interface** | USB Cable | Required for flashing firmware via Arduino IDE |
| **Target OS** | Windows 10 / 11 | Host machine must support Bluetooth peripherals &  use english |

---

## Setup & Installation

1. Install the `ESP32-BLE-Keyboard` library via the Arduino IDE Library Manager.
2. Open `ESP32-RemoteShell.ino` in the Arduino IDE.
3. Update the `telegramToken` and `stagerUrl` parameters at the top of the sketch with your specific Telegram bot token and GitHub raw file URL.
4. Select board `ESP32 Dev Module` in the Arduino IDE and upload the firmware.
5. Commit `agent.ps1` to the root of your public GitHub repository.
6. Pair the ESP32 via Bluetooth settings on the target Windows PC as `Esp Remote Shell`. The stager will execute automatically upon successful connection.

---

## Disclaimer
This project was developed for educational purposes, The author is not responsible for any unauthorized use or damage. Always obtain explicit permission before testing on any system.

---

### Developed by Itay Luria
