# Starky Sattera — 3D Binaural Panner

Spatial panner inspired by the binaural "barbershop" recordings: place sounds at exact points around a listener's head so they feel physically present on headphones.

## What exists so far
`StarkySattera_3D_Reference.html` — a working, hearable reference engine. Multiple sources in a shared 3D room, draggable around a fixed listener, with three switchable engines:

1. **HRTF** — Web Audio `PannerNode` (`panningModel:'HRTF'`). Full 3D incl. front/back & height. This is the "most realistic" target.
2. **ITD/ILD math** — the raw Pythagorean model (below). Per-ear delay + inverse-distance level + head-shadow lowpass.
3. **Plain pan** — equal-power amplitude pan, reference only.

Use it to A/B the engines and tune parameter ranges before committing them to the plugin.

## The core math (validated)
Head radius `a` (default 0.0875 m). Ears at `(±a, 0, 0)`. Speed of sound `c = 343 m/s`.

- Distance to each ear: `dL = √((x+a)² + y² + z²)`, `dR = √((x−a)² + y² + z²)`
- **ITD** (delay per ear): `tL = dL/c`, `tR = dR/c`; subtract the min so latency stays low. Max around the head ≈ 0.5–0.66 ms.
- **ILD** (level per ear): inverse-distance `gL = 1/dL`, `gR = 1/dR` (clamped).
- **Head shadow**: lowpass on the *far* ear, cutoff falling from ~18 kHz (on-axis) toward ~2.2 kHz at 90° contralateral.

Limit of pure ITD/ILD: front vs. back and elevation are ambiguous (a dead-front and dead-back source give identical timing/level). Resolving them requires HRTF spectral cues — hence engine #1.

## Port to Max for Live (.amxd) — next session
Target: an audio-effect device usable standalone and in Ableton.

Recommended path for "most realistic":
- **HRTF convolution per source** using an open HRIR dataset (e.g. **SADIE II**, **CIPIC**, or **MIT KEMAR**). In Max: load left/right impulse responses into `buffer~` and convolve with `buffir~` (FIR) or partitioned convolution; cross-fade IRs as the source moves to avoid zipper noise.
- **Parameters** to expose: Azimuth, Elevation, Distance (or X/Y/Z), Source size, Dry/wet, plus per-source on a multi-source bus.
- Wrap DSP in **`gen~`** for the geometry/ITD/ILD path (sample-accurate delay + gain + 1-pole shadow filter) so the "math" engine is portable and CPU-light; use the convolution path for full HRTF.
- M4L UI: a top-down XY pad (like the HTML canvas) bound to `live.dial`/`pattr` for automation; map azimuth/elevation/distance to `live.remote~`-able parameters.

Open question to decide before building: ship the lightweight gen~ ITD/ILD device first (fast, no IR dependency), or go straight to HRTF convolution (heavier, needs bundling an HRIR set + license check on the dataset).

## Existing tools to learn from (not native M4L)
dearVR PRO / MICRO (free), Noisemakers Binauralizer 2, IRCAM HEar, and the free research suites **SPARTA** and **IEM Plug-in Suite** (good open references for HRTF convolution). The M4L-native gap is what this project fills.
