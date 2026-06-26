// motion.js  —  Max [js]/[v8] motion engine for the binaural device.
// Reproduces the HTML app's preset paths and outputs azimuth / elevation /
// distance for the panner's dials (or straight into gen~ / hrirloader).
//
//   inlet messages:
//     settype <name>   orbit | vorbit | fullorbit | helix | bounce |
//                      pingpong | flythrough | spiral | figure8 | none
//     setspeed <x>     speed multiplier (0.1 .. 3)
//     setradius <r>    path radius in metres
//     reset            phase = 0
//     bang             advance one 25 ms step  (drive with [metro 25] -> [js])
//     tick <dt>        advance by dt seconds   (if you prefer your own clock)
//
//   outlets (right to left fire order): 0 = azimuth(deg), 1 = elevation(deg), 2 = distance(m)

autowatch = 1;
outlets = 3;

var type = "orbit", speed = 1.0, rad = 2.5, phase = 0.0;
var RATE = { orbit:0.9, vorbit:0.9, fullorbit:0.7, bounce:3.2, pingpong:1.6,
             flythrough:0.6, spiral:0.8, figure8:1.0, helix:0.8 };

function settype(s)   { type = s; phase = 0; }
function setspeed(v)  { speed = v; }
function setradius(v) { rad = v; }
function reset()      { phase = 0; }
function bang()       { step(0.025); }
function tick(dt)     { step(dt); }

function motionPos(t, p, r) {
    var TAU = Math.PI * 2;
    if (t === "orbit")     return [r*Math.sin(p), 0, -r*Math.cos(p)];
    if (t === "vorbit")    return [0, r*Math.sin(p), -r*Math.cos(p)];
    if (t === "fullorbit") return [r*Math.sin(p), r*0.7*Math.sin(p*3), -r*Math.cos(p)];
    if (t === "bounce")    return [r*0.5*Math.sin(p*0.31), r*Math.abs(Math.sin(p))-r*0.35, -r];
    if (t === "pingpong")  { var tri = 2*Math.abs(((p/Math.PI)%2+2)%2-1)-1; return [r*tri, 0, -r*0.8]; }
    if (t === "flythrough"){ var fr = ((p/TAU)%1+1)%1; return [0, -r*0.3, -r*1.6+fr*r*3.2]; }
    if (t === "spiral")    { var rr = r*(0.4+0.6*(0.5+0.5*Math.sin(p*0.2))); return [rr*Math.sin(p), 0, -rr*Math.cos(p)]; }
    if (t === "figure8")   return [r*Math.sin(p), 0, -r*Math.sin(2*p)/2];
    if (t === "helix")     { var f2 = ((p/TAU)%1+1)%1; return [r*Math.sin(p), (f2*2-1)*r, -r*Math.cos(p)]; }
    return null;
}

function step(dt) {
    if (type === "none") return;
    phase += dt * speed * (RATE[type] || 1);
    var pos = motionPos(type, phase, rad);
    if (!pos) return;
    var x = pos[0], y = pos[1], z = pos[2];
    var az = Math.atan2(x, -z) * 57.29578;
    var el = Math.atan2(y, Math.sqrt(x*x + z*z)) * 57.29578;
    var dist = Math.sqrt(x*x + y*y + z*z);
    outlet(2, dist);
    outlet(1, el);
    outlet(0, az);
}
