# Starky Sattera — Max for Live Binaural Panner

A drag-onto-a-channel insert that binaurally pans whatever audio is on the track to an exact point around the listener's head, using the same engine as the HTML reference app (Woodworth ITD + Brown–Duda head-shadow + distance gain).

Two ways to get the device — try the file first, fall back to the manual build.

---

## Option A — open the ready-made patch (fastest)

1. Open **Max 9** (Ableton → any Max for Live device → **Edit**, or launch Max standalone).
2. **File → Open** → `StarkySattera_Binaural.maxpat` (in this folder).
3. If it loads cleanly, **File → Save As… → Max Audio Effect** and name it `StarkySattera Binaural.amxd`. Max writes the correct `.amxd` binary for you.
4. Drop the `.amxd` onto any audio track in Ableton.

> The `.maxpat` is experimental (authored without a live Max to test in). If Max reports an error on load, use Option B — it takes ~10 minutes and is guaranteed correct.

---

## Option B — build it by hand (reliable)

### 1. New device
In Ableton: **Create → Max Audio Effect** → **Edit** (opens the Max editor). You'll see `plugin~` and `plugout~` already wired — that's the host audio in/out.

### 2. Sum to mono
Binaural panning takes a **mono** point source. Add `[+~]` and feed both `plugin~` outlets into it:
```
plugin~  (outlet 0, L) ─┐
plugin~  (outlet 1, R) ─┴─> [+~] ─> (mono)
```

### 3. The gen~ panner
- Add a `[gen~]` object. Double-click it to open the gen patcher.
- Inside, add: `[in 1]`, a `[codebox]`, `[out 1]`, `[out 2]`.
- Open `binaural.genexpr` (this folder), copy **all** of it, and paste into the codebox.
- Wire: `in 1` → codebox inlet; codebox outlet 1 → `out 1`; codebox outlet 2 → `out 2`.
- Close the gen patcher. Connect the mono `[+~]` → `[gen~]` inlet.

### 4. Output
`gen~` outlet 1 → `plugout~` inlet 1 (Left); `gen~` outlet 2 → `plugout~` inlet 2 (Right).

### 5. Parameters (the controls)
Add three `[live.dial]`s. For each, set its range in the inspector, then send its value into `gen~` via a message box `set` of the named param:

| Dial label | Range        | Message box        | gen~ Param |
|------------|--------------|--------------------|-----------|
| Azimuth    | -180 … 180   | `az $1`            | `az`      |
| Elevation  | -90 … 90     | `el $1`            | `el`      |
| Distance   | 0.2 … 15     | `dist $1`          | `dist`    |
| (optional) Head | 6 … 11  | `headcm $1`        | `headcm`  |

Wire: `live.dial` → `[message: az $1]` → `gen~` inlet. (gen~ accepts `paramname value` messages on its inlet.)

Set the dials to **Parameter** mode (right-click → Edit/Parameter) so Ableton can automate them.

### 6. Save
**File → Save** — it's now a `.amxd` you can drop on any track.

---

## Motion (orbit / fly-through / etc.)

Two easy routes:

- **Automate the dials** directly in Ableton (draw azimuth/elevation/distance automation), or map Ableton's **LFO** Max device onto them.
- **Build LFOs inside the device:** a `[phasor~ 0.2]` → `[*~ 360]` → `[-~ 180]` → `az $1` gives a horizontal **orbit** at 0.2 Hz. Drive elevation with a second slow LFO for a **vertical / full orbit**; sweep distance with a triangle for **fly-through**; combine for spirals. Add a **speed** `live.dial` controlling the `phasor~` frequency.

The preset shapes from the app (orbit, vertical orbit, full orbit, helix, bounce, ping-pong, fly-through, spiral, figure-8) are all just parametric `az/el/dist` curves — the same formulas in `StarkySattera_3D_Reference.html` (`motionPos`) can be reproduced with `phasor~`/`cycle~` math feeding the three params.

---

## Notes
- This is a **single-source insert**: it spatializes the track it's on. Use one instance per source for a multi-source scene (each with its own az/el/dist).
- For **measured HRTF** (SOFA) in Max, the structural model here can be swapped for HRIR convolution using `[buffir~]` (load left/right impulse responses into `[buffer~]`) or partitioned convolution — a larger build; the structural model is a great, low-CPU default.
- The DSP in `binaural.genexpr` is byte-for-byte the same model verified in the reference app.
