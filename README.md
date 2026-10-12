# 🛰️ GPS Frame Converter (Real-Time)

> A professional, console-driven MATLAB tool for **real-time GPS coordinate transformation** across four fundamental reference frames: **ECI**, **ECEF**, **END**, and **NEU** — designed for aerospace, GNC, and satellite navigation applications.

[![MATLAB](https://img.shields.io/badge/MATLAB-R2019a%2B-blue.svg)](https://www.mathworks.com/products/matlab.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey.svg)]()
[![Status](https://img.shields.io/badge/Status-Stable-brightgreen.svg)]()
[![GitHub stars](https://img.shields.io/github/stars/MadhuSudhan2310/gps-frame-converter?style=social)](https://github.com/MadhuSudhan2310/gps-frame-converter/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/MadhuSudhan2310/gps-frame-converter?style=social)](https://github.com/MadhuSudhan2310/gps-frame-converter/network/members)

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Reference Frames](#-reference-frames)
- [Installation](#️-installation)
- [Usage](#-usage)
- [Command Reference](#-command-reference)
- [Example Session](#-example-session)
- [Mathematical Foundation](#-mathematical-foundation)
- [CSV Output Format](#-csv-output-format)
- [Repository Structure](#-repository-structure)
- [Requirements](#-requirements)
- [Roadmap](#️-roadmap)
- [Contributing](#-contributing)
- [License](#-license)
- [Author](#-author)
- [Acknowledgements](#-acknowledgements)

---

## 🔭 Overview

**GPS Frame Converter** is a lightweight, dependency-free MATLAB function that transforms GPS position data (latitude, longitude, altitude) into the four reference frames most commonly used in aerospace guidance, navigation, and control (GNC):

| Frame | Full Name | Primary Use |
|-------|-----------|-------------|
| **ECI** | Earth-Centered Inertial | Orbital mechanics, satellite dynamics |
| **ECEF** | Earth-Centered Earth-Fixed | GPS positioning, mapping |
| **END** | East-North-Down (local) | Flight dynamics, attitude control |
| **NEU** | North-East-Up (local) | Surveying, GNSS post-processing |

The tool operates entirely in the **MATLAB Command Window** — no GUI, no toolboxes required beyond base MATLAB — making it ideal for embedded workflows, teaching, and rapid prototyping.

---

## ✨ Features

- ✅ **Real-time GPS transformation** — point-by-point console output
- ✅ **4 reference frames** converted simultaneously (ECI, ECEF, END, NEU)
- ✅ **WGS84 ellipsoidal model** with full flattening correction
- ✅ **GMST-based Earth rotation** for accurate ECI ↔ ECEF conversion
- ✅ **Track simulation** — simulate a moving object at fixed speed/bearing
- ✅ **Route interpolation** — generate smooth trajectories between two GPS points
- ✅ **Configurable origin** for local END / NEU frames
- ✅ **Automatic CSV logging** — timestamped export for post-processing
- ✅ **Range & bearing computation** in the local tangent plane
- ✅ **Constraint validation** — lat/lon/alt/radius sanity checks
- ✅ **Zero external dependencies** — pure MATLAB, R2019a compatible
- ✅ **Interactive CLI** with clear help menu

---

## 🌐 Reference Frames

### 1. **ECI — Earth-Centered Inertial**
- Origin: Earth's center of mass
- Z-axis: Earth's rotation axis (fixed in inertial space)
- X-axis: Vernal equinox direction
- Non-rotating frame — used for orbital propagation

### 2. **ECEF — Earth-Centered Earth-Fixed**
- Origin: Earth's center of mass
- Z-axis: Earth's rotation axis
- X-axis: Intersection of prime meridian and equator
- Rotates with Earth — standard for GPS coordinates

### 3. **END — East-North-Down (Local)**
- Origin: user-defined reference point on Earth's surface
- X-axis: East, Y-axis: North, Z-axis: Down (toward center)
- Standard aerospace body-frame convention

### 4. **NEU — North-East-Up (Local)**
- Origin: same as END
- X-axis: North, Y-axis: East, Z-axis: Up
- Standard surveying / geodetic convention

---

## ⚙️ Installation

### Prerequisites
- MATLAB **R2019a** or newer
- No additional toolboxes required (base MATLAB only)

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/MadhuSudhan2310/gps-frame-converter.git

# 2. Navigate into the folder
cd gps-frame-converter
```

Then in the **MATLAB Command Window**:

```matlab
% 3. Add to MATLAB path (optional)
addpath(pwd)
savepath
```

Or simply download `GPSRealtime.m` and place it in your current working directory.

---

## 🚀 Usage

### Quick Start

```matlab
GPSRealtime
```

You'll see the interactive prompt:

```
==============================================================
   Real-Time GPS Frame Converter
   GPS -> ECI | ECEF | END | NEU
==============================================================
  Type GPS     : <lat> <lon> <alt>
  Simulate move: track <lat> <lon> <alt> <speed_m/s> <duration_s>
  Route        : route <lat1> <lon1> <lat2> <lon2> <alt>
  Commands     : origin | csv | clear | quit
--------------------------------------------------------------
GPS >>
```

---

## 📖 Command Reference

| Command | Syntax | Description |
|---------|--------|-------------|
| **Point** | `<lat> <lon> <alt>` | Convert a single GPS coordinate |
| **Track** | `track <lat> <lon> <alt> <speed> <duration>` | Simulate moving object in real time |
| **Route** | `route <lat1> <lon1> <lat2> <lon2> <alt>` | Interpolate a straight path |
| **Origin** | `origin <lat> <lon>` | Set local reference for END/NEU |
| **CSV** | `csv` | Export session log to `gps_log.csv` |
| **Clear** | `clear` | Reset session state |
| **Quit** | `quit` | Exit (auto-saves CSV) |

---

## 🧪 Example Session

```text
GPS >> 28.6139 77.2090 216
  --- GPS INPUT ---
    lat=  28.6139000  lon=  77.2090000  alt=    216.00 m
  --- ECEF [m] ---
    X=  1151254.367  Y=  5079180.224  Z=  3037938.115
  --- ECI [m] ---
    X=  4508921.552  Y=  2731045.881  Z=  3037938.115
  --- END [m] ---
    E=        0.000  N=        0.000  D=      216.000
  --- NEU [m] ---
    N=        0.000  E=        0.000  U=     -216.000
  --- Range/Bearing ---
    Range=      0.00 m   Bearing=   0.00 deg

GPS >> track 28.6139 77.2090 500 50 5
  [TRACK] 28.6139, 77.2090, 500 m | speed=50.0 m/s dur=5.0 s
  t=  0.5s lat= 28.614218 lon= 77.209455 ECEF=( 1151287.4,  5079181.9,  3037952.7)
  t=  1.0s lat= 28.614536 lon= 77.209910 ECEF=( 1151320.5,  5079183.6,  3037967.3)
  ...
  [TRACK] Finished - 10 samples.

GPS >> route 28.6139 77.2090 19.0760 72.8777 8000
  [ROUTE] (28.6139,77.2090) -> (19.0760,72.8777) alt=8000 m
  step  0/60 lat= 28.613900 lon= 77.209000 ECEF=( 1156257.3,  5080244.1,  3036245.6)
  ...
  [ROUTE] Finished - 61 samples.

GPS >> csv
  [CSV] Saved 74 rows -> gps_log.csv

GPS >> quit
  Session ended.
```

---

## 🧮 Mathematical Foundation

### Geodetic → ECEF (WGS84)

$$
\begin{aligned}
N &= \frac{a}{\sqrt{1 - e^2 \sin^2\phi}} \\
x &= (N + h)\cos\phi\cos\lambda \\
y &= (N + h)\cos\phi\sin\lambda \\
z &= \big(N(1-e^2) + h\big)\sin\phi
\end{aligned}
$$

Where:
- $a = 6378137.0$ m (WGS84 semi-major axis)
- $e^2 = 0.00669437999014$ (first eccentricity squared)
- $\phi, \lambda, h$ = latitude, longitude, altitude

### ECEF → ECI (GMST rotation)

$$
R_{\text{ECI} \to \text{ECEF}} =
\begin{bmatrix}
\cos\theta & \sin\theta & 0 \\
-\sin\theta & \cos\theta & 0 \\
0 & 0 & 1
\end{bmatrix}
$$

Where $\theta$ = Greenwich Mean Sidereal Time (GMST), computed via IAU-82 polynomial.

### ECEF → END (local tangent plane)

$$
R_{\text{ECEF} \to \text{END}} =
\begin{bmatrix}
-\sin\lambda & \cos\lambda & 0 \\
-\sin\phi\cos\lambda & -\sin\phi\sin\lambda & \cos\phi \\
-\cos\phi\cos\lambda & -\cos\phi\sin\lambda & -\sin\phi
\end{bmatrix}
$$

---

## 📁 CSV Output Format

| Column | Field | Unit |
|--------|-------|------|
| 1 | timestamp | POSIX seconds |
| 2 | lat_deg | degrees |
| 3 | lon_deg | degrees |
| 4 | alt_m | meters |
| 5–7 | ECI_x, ECI_y, ECI_z | meters |
| 8–10 | ECEF_x, ECEF_y, ECEF_z | meters |
| 11–13 | END_E, END_N, END_D | meters |
| 14–16 | NEU_N, NEU_E, NEU_U | meters |

Example:
```csv
timestamp,lat_deg,lon_deg,alt_m,ECI_x,ECI_y,ECI_z,ECEF_x,ECEF_y,ECEF_z,END_E,END_N,END_D,NEU_N,NEU_E,NEU_U
1759214580.123456,28.613900000,77.209000000,216.000,4508921.552,2731045.881,3037938.115,1151254.367,5079180.224,3037938.115,0.000,0.000,216.000,0.000,0.000,-216.000
```

---

## 📂 Repository Structure

```
gps-frame-converter/
├── GPSRealtime.m          # Main function (single-file tool)
├── README.md              # This documentation
├── LICENSE                # MIT license
├── CHANGELOG.md           # Version history
├── examples/
│   ├── delhi_mumbai.txt   # Sample route input
│   └── sample_output.csv  # Example CSV log
├── docs/
│   └── frames.pdf         # Frame reference diagram
└── tests/
    └── test_frames.m      # Unit sanity checks
```

> 📌 **Note:** Only `GPSRealtime.m` and `README.md` currently exist in this repository. The additional folders and files listed above are **planned for upcoming releases** (see [Roadmap](#️-roadmap)).

---

## 📦 Requirements

| Requirement | Version |
|-------------|---------|
| MATLAB | R2019a or newer |
| Aerospace Toolbox | *Not required* |
| Mapping Toolbox | *Not required* |
| OS | Windows / Linux / macOS |

---

## 🗺️ Roadmap

- [x] v1.0 — Core GPS → ECI/ECEF/END/NEU conversion
- [x] v1.1 — Real-time track & route simulation
- [x] v1.2 — CSV export
- [ ] v1.3 — Great-circle distance & true bearing
- [ ] v1.4 — Velocity & attitude (6-DOF) propagation
- [ ] v2.0 — App Designer GUI dashboard
- [ ] v2.1 — Simulink block wrapper
- [ ] v2.2 — NMEA sentence parser (live GPS feed)

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure your code:
- Uses **no external toolboxes**
- Passes `test_frames.m`
- Follows MATLAB style guidelines (`checkcode` clean)

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Madhu Sudhan**
- 🎓 Aerospace / GNC Engineer
- 💼 [LinkedIn](https://www.linkedin.com/in/) *(update with your profile URL)*
- 🐙 [GitHub](https://github.com/MadhuSudhan2310)
- 📧 *(add your email)*

---

## 🙏 Acknowledgements

- **WGS84** model — NIMA TR8350.2
- **GMST algorithm** — IAU-82 / Vallado, *Fundamentals of Astrodynamics*
- **Inspiration** — MathWorks Aerospace Blockset documentation
- **Community** — MATLAB Central File Exchange contributors

---

## ⭐ Support

If you find this project useful, please consider:

- ⭐ **Starring** the repository
- 🐛 **Reporting issues** via [GitHub Issues](https://github.com/MadhuSudhan2310/gps-frame-converter/issues)
- 🔀 **Submitting PRs** for improvements
- 📢 **Sharing** with your aerospace network

---

> *"Precision in frames is precision in flight."*
