#!/usr/bin/env python3
"""
sofa2max.py - convert a SOFA HRIR dataset into Max-friendly assets.

Max can't read .sofa (HDF5) natively, so this bakes one into files the
device loads with [buffer~] + [coll].

Usage:
    pip install h5py numpy
    python sofa2max.py mit_kemar_normal_pinna.sofa
    python sofa2max.py input.sofa  myoutdir/

Outputs (into outdir, default = <input basename>_max/):
    hrir_L.wav      32-bit float mono, all LEFT  HRIRs concatenated (M*N samples)
    hrir_R.wav      32-bit float mono, all RIGHT HRIRs concatenated
    hrir.coll       Max [coll]:  index, azimuth elevation startSample;
    hrir_dirs.json  { fs, taps(N), count(M), dirs:[[az,el],...] }

Direction i occupies samples [i*N, i*N + N) in each WAV.
Azimuth/elevation come straight from SOFA SourcePosition
(SimpleFreeFieldHRIR convention: azimuth CCW, 0=front, 90=left; elevation -90..90).
"""
import sys, os, json, struct
import numpy as np
import h5py


def write_float_wav(path, samples, fs):
    data = np.asarray(samples, dtype='<f4').tobytes()
    with open(path, 'wb') as f:
        f.write(b'RIFF'); f.write(struct.pack('<I', 36 + len(data))); f.write(b'WAVE')
        f.write(b'fmt '); f.write(struct.pack('<I', 16))
        f.write(struct.pack('<HHIIHH', 3, 1, fs, fs * 4, 4, 32))  # IEEE float, mono, 32-bit
        f.write(b'data'); f.write(struct.pack('<I', len(data))); f.write(data)


def main():
    if len(sys.argv) < 2:
        print("usage: python sofa2max.py input.sofa [outdir]"); sys.exit(1)
    src = sys.argv[1]
    base = os.path.splitext(os.path.basename(src))[0]
    outdir = sys.argv[2] if len(sys.argv) > 2 else base + "_max"
    os.makedirs(outdir, exist_ok=True)

    with h5py.File(src, 'r') as f:
        ir = np.array(f['Data.IR'])          # [M, R, N]
        pos = np.array(f['SourcePosition'])  # [M, 3] az, el, radius
        try:
            fs = int(np.array(f['Data.SamplingRate'][()]).flatten()[0])
        except Exception:
            fs = 44100

    M, R, N = ir.shape
    if R < 2:
        raise SystemExit("expected 2 receivers (ears) in Data.IR, got %d" % R)

    write_float_wav(os.path.join(outdir, "hrir_L.wav"),
                    ir[:, 0, :].astype(np.float32).reshape(-1), fs)
    write_float_wav(os.path.join(outdir, "hrir_R.wav"),
                    ir[:, 1, :].astype(np.float32).reshape(-1), fs)

    with open(os.path.join(outdir, "hrir.coll"), "w") as c:
        for i in range(M):
            c.write("%d, %.2f %.2f %d;\n" % (i, float(pos[i, 0]), float(pos[i, 1]), i * N))

    json.dump({"fs": fs, "taps": int(N), "count": int(M),
               "dirs": [[float(pos[i, 0]), float(pos[i, 1])] for i in range(M)]},
              open(os.path.join(outdir, "hrir_dirs.json"), "w"))

    print("OK  M=%d directions  N=%d taps  fs=%d Hz  ->  %s/" % (M, N, fs, outdir))


if __name__ == "__main__":
    main()
