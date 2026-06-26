// hrirloader.js  —  Max [js] / [v8] helper for the SOFA HRIR convolution device.
// Loads hrir_dirs.json (from sofa2max.py) and, given a direction, outputs the
// start sample of the nearest measured HRIR in the packed bank buffer~s.
//
//   inlet messages:
//     load                 -> read hrir_dirs.json, build the direction table
//     nearest <az> <el>    -> az/el in the device convention
//                             (az: + = right, 0 = front ; el: + = up)
//   outlets:
//     0 : start sample (into hrir_L.wav / hrir_R.wav) of the nearest HRIR
//     1 : taps (N)  — emitted after 'load', use it as the [uzi N] copy count

autowatch = 1;
outlets = 2;

var dirs = [];   // [ [sofaAz, sofaEl, startSample], ... ]
var taps = 256;

function load() {
    dirs = [];
    var f = new File("hrir_dirs.json", "read");
    if (!f.isopen) { post("hrirloader: hrir_dirs.json not found in search path\n"); return; }
    var s = "";
    while (f.position < f.eof) { s += f.readstring(16384); }
    f.close();
    var j = JSON.parse(s);
    taps = j.taps;
    for (var i = 0; i < j.dirs.length; i++) {
        dirs.push([j.dirs[i][0], j.dirs[i][1], i * taps]);
    }
    post("hrirloader: " + dirs.length + " directions, taps=" + taps + "\n");
    outlet(1, taps);
}

function nearest(az, el) {
    // device azimuth (+right, 0 front) -> SOFA azimuth (CCW, 0 front, +left)
    var saz = (((360 - az) % 360) + 360) % 360;
    var best = -1, bd = 1e9;
    for (var k = 0; k < dirs.length; k++) {
        var da = Math.abs(((dirs[k][0] - saz + 540) % 360) - 180); // wrapped angular dist
        var de = Math.abs(dirs[k][1] - el);
        var d = da + de * 1.2;                                      // weight elevation slightly
        if (d < bd) { bd = d; best = k; }
    }
    if (best >= 0) outlet(0, dirs[best][2]);
}
