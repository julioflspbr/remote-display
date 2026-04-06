# 📟 Arduino Wireless LCD Display

A simple Arduino project that lets you send text from your computer or iPhone to a 16x2 LCD display in real time using either **WiFi (ESP8266 ESP-01)** or **Bluetooth LE (AT-09)**.

Type a message → it shows instantly on your LCD.

---

## ✨ Features

- 📱 Works with both computer and iPhone
- 🧾 Displays live text input on a 16x2 LCD (LCM1602A)
- ⚡ Lightweight and responsive
- 🔌 Simple hardware setup
- 📡 Dual communication support:
	- WiFi via ESP8266 (ESP-01)
	- Bluetooth Low Energy via AT-09

---

## 🧠 Architecture & Learning Goals

This project is intentionally designed with a modular architecture to explore **inter-process communication (IPC)** concepts, rather than keeping everything in a single application.

### 🧩 macOS Design (Planned)

On macOS, the system is split into two main components:

- **Frontend App**
	- User interface for typing and sending messages
	- Communicates with a background service

- **Communication Service (XPC)**
	- Exposes a clean API to the frontend via XPC
	- Handles all hardware communication:
		- WiFi (ESP8266)
		- Bluetooth LE (AT-09)

This separation allows:
- Better abstraction of hardware logic
- Reusable communication layer
- Hands-on experience with XPC services and IPC patterns

---

### 📡 Why XPC?

The project explores:

- Secure and structured IPC on macOS
- Separation of concerns (UI vs hardware communication)
- Service-oriented design patterns

---

### 📱 iOS Considerations

On iOS, the same architecture is more constrained:

- True background services and arbitrary IPC (like XPC) are limited
- Bluetooth and networking must run within app lifecycle rules
- Background execution is tightly controlled by the system

Because of this:

- The iOS version may:
	- Combine UI + communication into a single app
	- Or use approved background modes (e.g., BLE)

However:
- Core communication logic will be shared as much as possible
- The project explores how platform constraints shape architecture decisions

---

### 🎯 Learning Objectives

This project is not just about displaying text on an LCD — it’s about exploring:

- Inter-process communication (IPC)
- XPC services on macOS
- BLE vs WiFi communication patterns
- Cross-platform code sharing (macOS / iOS)
- Hardware/software boundary design
- System architecture trade-offs

---

## 🧰 Hardware Requirements

- Arduino (Uno, Nano, or similar)
- LCM1602A 16x2 LCD display
- ESP8266 ESP-01 (for WiFi)
- AT-09 BLE module (for Bluetooth)
- Breadboard & jumper wires
- Resistor (for LCD contrast, typically 10k potentiometer recommended)
