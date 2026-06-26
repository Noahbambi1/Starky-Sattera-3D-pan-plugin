# Starky Sattera — Session Handoff

Quick-start context for continuing this project in a fresh session (e.g. on another machine). Read this first, then the files listed below.

## What this is
A from-scratch **binaural 3D spatialization engine** inspired by the binaural "barbershop" recordings — place sounds at exact points around a listener's head so they feel physically present on headphones. Two deliverables:
1. **`StarkySattera_3D_Reference.html`** — the working, verified reference app (open in a browser, use headphones). This is the source of truth for the algorithm.
2. **`max-for-live/`** — a kit to port the engine into a Max for Live audio-effect device for Ableton.

## Read these first (in order)
1. `README.md` — overview.
2. `StarkySattera_3D_Reference.html` — the app + engine (skim the `<script>`; key fns below).
3. `PLAN_MaxForLive_port.md` — original port design notes.
4. `max-for-live/MAX_FOR_LIVE_BUILD.md` — build the structural-model device (+ motion, in-head, reverb, migration steps).
5. `max-for-live/MAX_SOFA_BUILD.md` — the measured-HRTF (SOFA) convolution device.

## App: key functions (in the HTML `<script>`)
- `genHRIR(az,el,a,sr)` — structural HRIR: Woodworth ITD + Brown–Duda head-shadow + pinna/torso. Per-source dual-`ConvolverNode` crossfade.
- `loadSOFA(file)` / `sofaNearest()` — measured HRIR via jsfive; nearest-direction lookup.
- `buildIR()` — image-source room reverb (pre-delay + early reflections + damped tail).
- `updateAudio()` — per-frame: direction → HRIR update, distance gain, air absorption, distance-driven reverb send, in-head crossfade.
- `motionPos()` / `tickMotion()` — motion presets (orbit, vorbit, fullorbit, helix, bounce, pingpong, flythrough, spiral, figure8) + path recorder/looper. Motions only drive their own axes (others stay user-editable); Range, exponential Speed (to 100×), and BPM-sync.
- `saveScene()` / `loadScene()` — scene JSON. `exportWAV()` / `toggleRec()` — live bounce to WAV.

## Status — verified vs. needs testing
**Verified here (browser / Node / Python):**
- The whole app (HRTF model + measured SOFA, reverb, in-head, motion, scenes, WAV bounce).
- `max-for-live/sofa2max.py` — SOFA→Max asset converter (tested on a synthetic SOFA).
- `motion.js`, `hrirloader.js` — syntax + path/lookup math.
- `binaural.genexpr` — DSP math (ITD/ILD/in-head/reverb) checked numerically.

**NOT yet tested (no Max available in the build environment) — validate first on the Ableton machine:**
- The gen~ wiring, `buffir~` convolution patch, and `StarkySattera_Binaural.maxpat` semantics.
- Suggested order: build the structural gen~ device first (fastest path to sound) → confirm it pans → add SOFA convolution → add the motion engine.

## Conventions
- Coordinates: **+X = right, +Y = up, front = −Z**. `az = atan2(x, −z)` (+ = right); `el = atan2(y, hypot(x,z))`.
- Measured datasets (`.sofa`) are **not committed** (see `.gitignore`); load them in-app or convert with `sofa2max.py`. Free sources: sofacoustics.org, SADIE II, CIPIC. (Tested with MIT KEMAR.)

## Environment gotcha (this session only)
The Windows build sandbox served a **stale/truncated mirror** of the main HTML, so commits had to be run by the user in a real terminal. On the Mac this won't apply — normal git works.

## Next up
- Validate the Max devices in Ableton (see above).
- Optional: port the app's motion axis-freeing / BPM-sync into `motion.js` for the device; swap the device reverb for a nicer FDN.
