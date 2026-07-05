# ⏱️ FPGA Multi-Mode Digital Clock, Stopwatch & Timer

A Verilog-based multi-function digital timing system implemented on an FPGA. The design integrates a **Digital Clock**, **Stopwatch**, and **Countdown Timer** into a single module, displaying output on a four-digit seven-segment display using time-multiplexing.

---

## 📖 Overview

This project demonstrates the implementation of multiple timing functions on an FPGA using Verilog HDL. The system operates in three selectable modes:

* Digital Clock (MM:SS)
* Stopwatch
* Countdown Timer

The design uses a **100 MHz system clock**, generates a **1 Hz clock enable** for accurate timing, and multiplexes a four-digit seven-segment display without creating additional clock domains.

---

## ✨ Features

* 🕒 Real-time digital clock (MM:SS)
* ⏱ Stopwatch with Start/Stop functionality
* ⏲ Countdown timer with preset loading
* 🔘 Button edge detection
* ⚡ Single-clock synchronous design
* 📟 Four-digit seven-segment display multiplexing
* 🚫 No divided clocks (timing-safe implementation)
* 🔄 Asynchronous reset support

---

## 🛠 Hardware Requirements

* FPGA Development Board (e.g., Basys 3, Nexys A7, Artix-7)
* 100 MHz onboard clock
* Four-digit Seven-Segment Display
* Push Buttons
* Slide Switches

---

## 📌 Inputs

| Signal       | Width | Description              |
| ------------ | ----- | ------------------------ |
| `clk`        | 1     | 100 MHz system clock     |
| `reset`      | 1     | Asynchronous reset       |
| `mode`       | 2     | Operating mode selection |
| `start_stop` | 1     | Start/Stop control       |
| `clear`      | 1     | Stopwatch reset          |
| `load_timer` | 1     | Load timer preset        |

---

## 📤 Outputs

| Signal | Width | Description                   |
| ------ | ----- | ----------------------------- |
| `seg`  | 7     | Seven-segment display outputs |
| `an`   | 4     | Digit enable signals          |

---

## 🎛 Mode Selection

| Mode | Function        |
| ---- | --------------- |
| `00` | Digital Clock   |
| `01` | Stopwatch       |
| `10` | Countdown Timer |
| `11` | Reserved        |

---

## ⚙ Functional Description

### 1. Digital Clock

* Displays time in **MM:SS** format.
* Increments every second.
* Rolls over from **59:59** back to **00:00**.

---

### 2. Stopwatch

* Counts upward from **00** to **59** seconds.
* Start/Stop button toggles counting.
* Clear button resets the stopwatch.

---

### 3. Countdown Timer

* Loads a preset value of **30 seconds**.
* Counts down every second.
* Automatically stops at **00**.
* Can be restarted after reloading.

---

## ⏲ Clock Generation

The FPGA operates using a **100 MHz system clock**.

Instead of generating a new clock, a **1 Hz clock enable pulse** is created.

Advantages:

* Eliminates multiple clock domains
* Prevents timing violations
* Improves FPGA timing closure
* Recommended synchronous design practice

---

## 🔘 Button Functions

| Button     | Function                             |
| ---------- | ------------------------------------ |
| Start/Stop | Starts or pauses Stopwatch and Timer |
| Clear      | Resets Stopwatch                     |
| Load Timer | Loads 30-second countdown            |

Button edge detection ensures that each button press is registered only once.

---

## 📟 Seven-Segment Display

The display is multiplexed across four digits.

Display format:

```text
MM:SS
```

The refresh logic cycles rapidly through each digit, creating the appearance of a continuously illuminated display.

---

## 🔄 Internal Modules

The design consists of the following functional blocks:

* 1 Hz Clock Enable Generator
* Button Edge Detector
* Digital Clock Counter
* Stopwatch Controller
* Countdown Timer Controller
* Display Mode Multiplexer
* Binary-to-BCD Converter
* Seven-Segment Display Multiplexer
* Seven-Segment Decoder

---

## 🏗 System Architecture

```text
100 MHz Clock
       │
       ▼
1 Hz Clock Enable
       │
       ▼
 ┌────────────────────────────┐
 │      Mode Selection         │
 ├─────────────┬───────────────┤
 │             │               │
 ▼             ▼               ▼
Clock      Stopwatch      Countdown Timer
 │             │               │
 └───────┬─────┴───────────────┘
         ▼
 Display Multiplexer
         ▼
 Binary → BCD
         ▼
 Seven Segment Decoder
         ▼
 4-Digit Display
```

---

## 📂 Project Structure

```text
FPGA-Digital-Clock/
│
├── top.v
├── constraints.xdc
├── simulation/
│   └── testbench.v
├── images/
│   ├── hardware.jpg
│   └── waveform.png
└── README.md
```

---

## ▶ How to Run

1. Open the project in **Xilinx Vivado**.
2. Add the Verilog source file (`top.v`).
3. Add the FPGA constraints (`.xdc`) file.
4. Run synthesis and implementation.
5. Generate the bitstream.
6. Program the FPGA board.
7. Select the desired operating mode using switches.
8. Control the Stopwatch and Timer using the push buttons.

---

## 📊 Future Improvements

* Support for hours (HH:MM:SS)
* Adjustable clock setting buttons
* Multiple timer presets
* Alarm functionality
* Lap timing for stopwatch
* Pause and resume for digital clock
* Audible buzzer when timer expires
* AM/PM display mode
* Stopwatch with millisecond precision
* UART or Bluetooth time synchronization

---

## 📄 License

This project is released under the MIT License.

---

## 👨‍💻 Author

**Aadit**

If you found this project useful, consider giving the repository a ⭐ on GitHub.
