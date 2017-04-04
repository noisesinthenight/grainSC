(
SynthDef(\filter, {arg inBus, outBus, freqBus, ampBus, modBus,
	freq = 1200, res = 0.89,
	track = 0, transpose = 1, ampMod = 0, extMod = 0,
	gate = 1, att = 0.1, rel = 0.1, mix = 1;
	var env, inSig, sig;
	env = EnvGen.ar(Env.asr(att, 1, rel), gate, doneAction: 2);

	freq =  (Select.kr(track, [freq, In.kr(freqBus)]) * transpose).lag(0.1); //pitch track
	freq = freq + ((freq * In.kr(ampBus)) * ampMod); //ampMod
	freq = freq + ((freq * In.ar(modBus)) * extMod); //mod input
	freq = freq.abs.clip(0, 22000);
	res = 1 - res;

	inSig = In.ar(inBus, 2);
	sig = BPF.ar(inSig, freq, res, (res ** -1) * (400 / freq ** 0.5));
		// Ringz
		// Resonz
		// Formlet
	// Out.ar(outBus, sig * env);
	// Out.ar(outBus, XFade2.ar(inSig, sig, env*mix));                              //DRY WET ENVELOPE
	Out.ar(outBus, XFade2.ar(inSig, sig, mix) * env);
}).add;


SynthDef(\ring, {arg inBus, outBus, freqBus, ampBus, modBus,
	freq = 1200, type = 0,
	track = 0, transpose = 1, ampMod = 0, extMod = 0,
	gate = 1, att = 0.1, rel = 0.1, mix = 1;
	var env, inSig, sig;
	env = EnvGen.ar(Env.asr(att, 1, rel), gate, doneAction: 2);

	freq =  (Select.kr(track, [freq, In.kr(freqBus)]) * transpose).lag(0.1); //pitch track
	freq = freq + ((freq * In.kr(ampBus)) * ampMod); //ampMod
	freq = freq + ((freq * In.ar(modBus)) * extMod); //mod input
	freq = freq.abs.clip(0, 22000);

	inSig = In.ar(inBus, 2);
	sig = SelectX.ar(type, [
		inSig * SinOsc.ar(freq).fold(-1, 1),
		FreqShift.ar(inSig, freq)
	]);
	// Out.ar(outBus, XFade2.ar(inSig, sig, env * mix));
	Out.ar(outBus, XFade2.ar(inSig, sig, mix) * env);
}).add;


SynthDef(\shift, {arg inBus, outBus, freqBus, ampBus, modBus,
	rate = 1, winSize =0.2, dev = 0.1,
	track = 0, transpose = 1, ampMod = 0, extMod = 0,
	gate = 1, att = 0.1, rel = 0.1, mix = 1;
	var env, inSig, sig;
	env = EnvGen.ar(Env.asr(att, 1, rel), gate, doneAction: 2);

	rate =  (Select.kr(track, [rate, (In.kr(freqBus).midicps - 60).midiratio]) * transpose).lag(0.1); //pitch track
	// rate = rate + ((rate* In.ar(ampBus)) * ampMod); //ampMod
	winSize = winSize + ((winSize * In.kr(ampBus)) * ampMod); //amplitude >>> window size
	rate = rate + ((rate * In.ar(modBus)) * extMod); //mod input

	inSig = In.ar(inBus, 2);
	sig = PitchShift.ar(inSig, winSize, rate, 0, 0);
	// Out.ar(outBus, XFade2.ar(inSig, sig, env * mix));
	Out.ar(outBus, XFade2.ar(inSig, sig, mix) * env);
}).add;


SynthDef(\delay, {arg inBus, outBus, freqBus, ampBus, modBus,
	time = 0.1, feed = 0.75, freq = 12000,
	ampMod = 0, extMod = 0, lag = 0,
	gate = 1, att = 0.1, rel = 0.1, mix = 1;
	var env, inSig, sig;
	env = EnvGen.ar(Env.asr(att, 1, rel), gate, doneAction: 2);

	//freqBus >>> feedback filter
	time = time + ((time * In.kr(ampBus)) * ampMod);
	time = time + ((time * In.ar(modBus)) * extMod);

	inSig = In.ar(inBus, 2);
	sig = inSig + (LocalIn.ar(2) * feed);

	//VARY MODULATION PER LEFT AND RIGHT CHANNEL

	// sig = DelayC.ar(sig, 3, time);
	sig = DelayL.ar(sig, 3, time.lag(lag));
	// sig = DelTapRd.ar(bufnum, pos, time);

	//ADD FILTER + COMPRESSION HERE
	sig = OnePole.ar(sig, freq / SampleRate.ir);
	LocalOut.ar(sig);
	// Out.ar(outBus, XFade2.ar(inSig, sig, env * mix));
	Out.ar(outBus, XFade2.ar(inSig, sig, mix) * env);
}).add;


/*SynthDef(\distort, {arg inBus, outBus, freqBus, ampBus,
	gain = 1, tone = 0.7,
	gate = 1, att = 0.1, rel = 0.1, mix = 1;
var env, inSig, sig;
	env = EnvGen.ar(Env.asr(att, 1, rel), gate, doneAction: 2);
	inSig = In.ar(inBus, 2);
	// sig = Index
	// sig = Wavetable
	//bit reduction
// Out.ar(outBus, XFade2.ar(inSig, sig, env * mix));
	Out.ar(outBus, XFade2.ar(inSig, sig, mix) * env);
}).add;*/
)