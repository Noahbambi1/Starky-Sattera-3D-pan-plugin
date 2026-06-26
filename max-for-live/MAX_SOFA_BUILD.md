# Measured HRTF (SOFA) in Max — convolution device

This upgrades the binaural panner from the structural model to **real measured HRIRs** convolved per sample, using your `.sofa` dataset (e.g. `mit_kemar_normal_pinna.sofa`).

Max can't read `.sofa` (HDF5) directly, so the flow is: **convert once → load the baked assets → convolve with `buffir~`.**

---

## 1. Convert the SOFA (once)

```
pip install h5py numpy
python sofa2max.py mit_kemar_normal_pinna.sofa
```

Produces `mit_kemar_normal_pinna_max/`:

| File | What it is |
|------|------------|
| `hrir_L.wav` / `hrir_R.wav` | every left/right HRIR concatenated (32-bit float, mono) |
| `hrir.coll` | `index, azimuth elevation startSample;` per direction |
| `hrir_dirs.json` | `{ fs, taps(N), count(M), dirs:[[az,el],…] }` |

Direction *i* lives at samples **[i·N, i·N+N)** in each WAV. For MIT KEMAR: M≈710 directions, N=512 taps, fs=44100.

Put that folder (plus `hrirloader.js`) next to your device, or anywhere in Live's file search path.

---

## 2. Device signal flow

```
plugin~ ─(L)─┐
plugin~ ─(R)─┴► [+~] ──► mono ──► [buffir~ hrirActiveL] ─► gain ─► plugout~ (L)
                              └──► [buffir~ hrirActiveR] ─► gain ─► plugout~ (R)
```

`buffir~` convolves the incoming mono signal with whatever is in its `buffer~`. We keep a small **active** buffer per ear and copy the nearest measured HRIR into it whenever the direction changes.

### Buffers
- `[buffer~ hrirBankL hrir_L.wav]` and `[buffer~ hrirBankR hrir_R.wav]` — the full banks.
- `[buffer~ hrirActiveL 512 samps]` and `[buffer~ hrirActiveR 512 samps]` — sized to **N** (set N to your dataset's taps).

### Direction → start sample
- `[v8 hrirloader.js]` (or `[js hrirloader.js]`). On `loadbang` send it `load` → it reads `hrir_dirs.json`, prints the count, and emits **N** out outlet 1 (use it to size the active buffers / the `uzi` below).
- Two `[live.dial]`s **Azimuth** (-180…180) and **Elevation** (-90…90) → `[pak nearest 0. 0.]` → `hrirloader`. It outputs the **start sample** of the nearest measured HRIR out outlet 0.

### Copy the chosen HRIR into the active buffers
On each new start sample `S`, copy N samples from the bank into the active buffer:

```
[uzi 512]              // bang count = N ; outputs index 0..N-1
   │  (index i)        ── [+ S] ──► [peek~ hrirBankL] ─► [poke~ hrirActiveL i]
   └──────────────────  [+ S] ──► [peek~ hrirBankR] ─► [poke~ hrirActiveR i]
```

Trigger the `uzi` right after `hrirloader` reports a new start sample (use `[t b l]` to grab S into the `[+ ]` first, then bang the uzi).

> **Click-free upgrade (recommended):** keep **two** active buffers per ear (A/B) and two `buffir~` per ear. Copy the new HRIR into the *inactive* pair, then crossfade the two `buffir~` outputs with a short `[line~]` (≈20 ms). Swap which pair is active each change. This avoids zipper noise during motion — exactly what the HTML app does with its dual convolvers.

### Distance + output
- `[live.dial]` **Distance** (0.2…15) → `min(1, 1.5/max(0.4,d))` (a `[expr]`) → multiply both ear signals (`*~`). HRIRs carry direction; distance is just this gain (add the room reverb send from the structural-device guide for depth).

---

## 3. Motion, multi-source, caveats
- **Motion** (orbit / fly-through / etc.): drive the Azimuth/Elevation/Distance dials with LFOs — see `MAX_FOR_LIVE_BUILD.md`. The `motionPos` formulas in the HTML app are the exact curves.
- **One instance per source** for a multi-source scene.
- **Sample rate:** the IRs are baked at the dataset's fs (KEMAR = 44.1 kHz). If your Live set runs at a different rate, `buffir~` still uses them tap-for-tap — fidelity is fine; only a hair of timing scaling. Re-export with a resampled SOFA if you want it exact.
- **Azimuth convention** is handled in `hrirloader.js` (device +right ↔ SOFA CCW +left). If front/back feels mirrored for a given dataset, flip the sign of `az` in the `nearest` call.

---

The structural model (`binaural.genexpr`) stays as the zero-dependency default; this convolution path is the "measured, production-grade" mode — same idea as the app's Model ↔ Measured switch.
