# Starky Sattera — 3D Binaural Spatial Studio

A from-scratch binaural spatialization engine inspired by the binaural "barbershop" recordings: place sounds at exact points around a listener's head so they feel physically present on headphones.

## Files
- `StarkySattera_3D_Reference.html` — the working reference app (open in a browser, use headphones).
- `PLAN_MaxForLive_port.md` — design notes for porting the engine to a Max for Live device.

## What the app does
- **Per-source HRIR convolution** in a 3D room you can orbit around, with a dummy-head model at the center.
- **Two HRTF sources:** a self-contained *structural model* (Woodworth ITD + Brown–Duda head-shadow + pinna/torso reflections) and *measured `.sofa` datasets* you load in-app (e.g. MIT KEMAR, SADIE II, CIPIC).
- **Room reverb** (image-source early reflections + frequency-damped tail), air absorption, and distance-driven wet/dry for externalization.
- **In-head localization:** sources collapse to mono inside the head and lateralize.
- **Motion library:** orbit, vertical orbit, full 3D orbit, helix, bouncing ball, ping-pong, fly-through, spiral, figure-8 — plus a path recorder/looper for custom movements.

## HRIR datasets
Measured `.sofa` files are loaded at runtime (not committed — see `.gitignore`). Free sources: sofacoustics.org, SADIE II (York), CIPIC (UC Davis).
