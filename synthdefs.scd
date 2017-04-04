(
//ADD REVERSE PLAYBACK
SynthDef(\wave, {arg outBus, bufnum;
//ADD OSCILLATOR / MOD  / WAVETABLE FM SYNTH
}).add;

SynthDef(\vosim, {arg outBus,
	tfreq = 1, freq = 330, n = 3, decay = 0.1,
	gate = 1, att = 0.1, rel = 0.1, amp = 1;
	var env, trig, sig;
	env = EnvGen.ar(Env.asr(att, 1, rel), gate, doneAction: 2);
	trig = Impulse.ar(tfreq);
	sig = VOSIM.ar(trig, freq, n, decay);
	sig = sig ! 2;
	Out.ar(outBus, (sig * env) * amp);
}).add;





SynthDef(\playWarp, {arg modBus, outBus, bufnum, start, end, t_reset, reverse = 0,
	tfreq = 0, speed = 1, rate = 1, transpose = 1, rateMod = 0,
	overlaps = 6, winSize = 0.2, winRand = 0.005,
	fMix = 0, ffreq = 18000, res = 0.75,
	gate = 1, att = 0.1, rel = 0.1, amp = 1;
	var env, mod, pos, sig;
	env = EnvGen.ar(Env.asr(att, 1, rel), gate, doneAction: 2);
	mod = InFeedback.ar(modBus);
	rate = rate + ((rate * mod) * rateMod);
	// rate = (rate * transpose) * (((reverse - 1) * 2) +1);
	rate = rate * transpose;

	pos = Phasor.ar(Impulse.ar(tfreq)+t_reset, BufRateScale.kr(bufnum) * speed, start, end, start);
	pos = pos / BufFrames.kr(bufnum);
	sig = [
		WarpZ.ar(1, bufnum, pos, rate, winSize, -1, overlaps, winRand, 4, 0.1),
		WarpZ.ar(1, bufnum+1, pos, rate, winSize, -1, overlaps, winRand, 4, 0.1)
	];
	// sig = Warp1.ar(2, bufnum, pos, rate, winSize, -1, overlaps, winRand 2);
	// sig = WarpOverlap.ar(2, bufnum, overlaps, start, 1, 1, winSize, 1, 0.11, 8, winRand)

	res = 1 - res;
	sig = SelectX.ar(fMix, [
		sig,
		BPF.ar(sig, ffreq, res, (res ** -1) * (400 / ffreq ** 0.5))
	]);

	Out.ar(outBus, (sig * env) * amp);
}).add;


SynthDef(\playGrains, {arg modBus, outBus,
	bufnum, start, end, t_reset,
	t_trig, tfreq = 0, size = 1,
	speed = 1, rate = 1, transpose = 1, lag = 0, noise = 0,
	freq = 10, ratio = 1, posMod = 0, tfreqMod = 0, sizeMod = 0, rateMod = 0, ffreqMod = 0,
	fMix = 0.1, ffreq = 12000, res = 0.3,
	gate = 1, att = 0.1, rel = 0.1, distort  = 0, pan = 0, amp = 1;
	var env, mod, pos, trig, sig;
	env = EnvGen.ar(Env.asr(att, 1, rel), gate, doneAction: 2);
	mod = InFeedback.ar(modBus);
	mod = SinOsc.ar(freq*ratio) + mod;

	pos = Phasor.ar(t_reset, BufRateScale.kr(bufnum) * speed, start, end, start).wrap(start, end) / end;
	pos = pos + ((pos * mod) * posMod);
	pos = pos.lag(lag);

	tfreq = tfreq + ((tfreq * mod) * tfreqMod);
	trig = Impulse.ar(tfreq) + t_trig;
	// trig = GaussTrig.ar(tfreq, tfreqDev) + t_trig;

	size = size * tfreq.reciprocal;
	size = size + ((size * mod) * sizeMod);
	size = 0.0001 + size;

	rate = rate + ((rate * mod) * rateMod);
	rate = rate * transpose;
	// pan = WhiteNoise.kr * pan;

	sig = [
		GrainBuf.ar(1, trig, size, bufnum, rate, pos + WhiteNoise.kr(0.001+noise), 4, -1 * pan),
		GrainBuf.ar(1, trig, size, bufnum+1, rate, pos + WhiteNoise.kr(0.001+noise), 4, 1 * pan)
	];

	//DISTORTION
	sig = SelectX.ar(distort.clip(0, 1), [
		sig,
		(sig*(distort*10)).distort
	]);


	//FILTER
	ffreq = ffreq + ((ffreq * mod) * ffreqMod);
	ffreq = ffreq.clip(20, 20000);
	res = (1 - res).clip(0,0.9999);
	sig = SelectX.ar(fMix, [
		sig,
		// BPF.ar(sig, ffreq, res, (res ** -1) * (400 / ffreq ** 0.5))
		BPF.ar(sig, ffreq, res, (res ** -1))
	]);

	Out.ar(outBus, (sig * env) * amp);
}).add;





SynthDef(\playLoop, {arg modBus, outBus, bufnum, start, end, t_reset, tfreq = 0, reverse = 0,
	rate = 1,  transpose = 1, rateMod = 0,
	fMix = 0, ffreq = 18000, res = 0.65,
	gate = 1, att = 1, rel  = 0.01, amp = 1;
	var env, mod, pos, trig, sig;
	env = EnvGen.ar(Env.asr(att, 1, rel), gate, doneAction: 2);
	mod = InFeedback.ar(modBus);
	rate = rate + ((rate * mod) * rateMod);
	rate = rate * transpose;
	// rate = (rate * transpose) * (((reverse - 1) * 2) +1);
	pos = Phasor.ar(t_reset + Impulse.ar(tfreq), BufRateScale.kr(bufnum) * rate, start, end, start);
	trig = HPZ1.ar(pos);
	sig = [
		PlayBuf.ar(1, bufnum, rate, trig, start, 1),
		PlayBuf.ar(1, bufnum+1, rate, trig, start, 1)
	];
	// sig = BufRd.ar(2, bufnum, pos);
	res = 1 - res;
	sig = SelectX.ar(fMix, [
		sig,
		BPF.ar(sig, ffreq, res, (res ** -1) * (400 / ffreq ** 0.5))
	]);
	sig = (sig * env) * amp;
	Out.ar(outBus, sig.tanh);
}).add;



SynthDef(\playHead, {arg outBus, bufnum, start, end,
	pos = 0, lag = 0, noise = 0, nFreq = 1.5,
	//bounce/wrap mode,  ,feedback?
	gate = 1, att = 0.1, rel = 0.1, amp  = 1;
	var env, sig;
	env = EnvGen.ar(Env.asr(att, 1, rel), gate, doneAction: 2);
	pos = pos.lag(lag);
	// pos = pos + ((Crackle.ar(1.5) + Dust.ar(10)) * noise);
	// noise = (LFNoise2.ar(nFreq, 0.5) + Dust.ar(100*noise)) * noise;
	noise = noise * (Dust.ar(nFreq));
	// noise = Gendy2.ar
	noise = noise.lag(rrand(0.01, lag));
	pos = pos + (pos * noise);


	pos = pos.wrap(start, end);
	sig = BufRd.ar(2, bufnum, pos, 1, 4);
	sig = LeakDC.ar(sig);

	//filter etc ???
	Out.ar(outBus, (sig * env) * amp);
}).add;

SynthDef(\grain, {arg outBus, pBus, bufnum, start, end,
	t_reset, posExt = 0, posMod = 0, posTime = 1, endMod = 0, endTime = 1,
	rate = 1, detune =0, transpose = 1, rateMod = 0,	rateTime= 1,
	fMix = 0.65, ffreq = 660, res = 0.75, pan = 0, amp = 1,
	ffreqMod = 0, ffreqTime = 1,
	modBus, mAmp = 1, modMode = 0, //0 == env, 1 == mod, 2 == mod * env
	mDur = 1, mSkew = 0.005, envDur = 1, envSkew = 0.5;
	var env, mSig, mEnv, rEnv, fEnv, eEnv, pEnv, pSig, pos, sig;

	// env = EnvGen.ar(Env.perc(envDur*envSkew, envDur*(1-envSkew)), doneAction: 2);
	env = EnvGen.ar(Env.new([0,1,0],[envDur*envSkew, envDur*(1-envSkew)]), doneAction: 2);
	mDur = mDur * envDur;
	mEnv  = Env.new([0,1,0], [mDur*mSkew, mDur * (1- mSkew)]);
	rEnv = EnvGen.ar(mEnv, timeScale: rateTime);
	fEnv = EnvGen.ar(mEnv, timeScale: ffreqTime);
	eEnv = EnvGen.ar(mEnv, timeScale: endTime);
	pEnv = EnvGen.ar(mEnv, timeScale: posTime);

	mSig = InFeedback.ar(modBus) * mAmp;
	rEnv = SelectX.ar(modMode, [rEnv, mSig, rEnv * mSig]);
	fEnv = SelectX.ar(modMode, [fEnv, mSig, fEnv * mSig]);
	eEnv = SelectX.ar(modMode, [eEnv, mSig, eEnv * mSig]);
	pEnv = SelectX.ar(modMode, [pEnv, mSig, pEnv * mSig]);

	rate = rate + ((rate*rEnv) * rateMod);
	rate = rate + detune;
	rate = rate * transpose;
	rate = rate.clip(1/512, 1024);
	ffreq = (ffreq + ((ffreq*fEnv) * ffreqMod)).clip(20, 18000);
	res = 1 - res ;

	end = (end + ((end * eEnv) * endMod)).clip(start+15, BufFrames.kr(bufnum));

	pos = Phasor.ar(t_reset, BufRateScale.kr(bufnum) * rate, start, end, start);
	pSig = InFeedback.ar(pBus, 1);
	pos = Select.ar(posExt, [pos,pSig]);
	pos = (pos + ((pos * pEnv) * posMod)).wrap(0, BufFrames.kr(bufnum));
	// (pos/BufFrames.kr(bufnum)).poll;
	// pos = pos + ((pos + (pos * InFeedback.ar(posIN))) * posMod);

	sig = BufRd.ar(1, bufnum, pos, 1, 4);
	// sig = WarpZ.ar(1, bufnum, pos, rate, 0.2, -1)


	ffreq = ffreq.clip(20, 18000).lag(0.1);
	res = 1 - res;
	sig = SelectX.ar(fMix, [
		sig,
		BPF.ar(sig, ffreq, res, (res ** -1) * (400 / ffreq ** 0.5))
	]);

	sig = sig * env;
	sig = Pan2.ar(sig.tanh, pan, amp);
	OffsetOut.ar(outBus, sig);
	// OffsetOut.ar(pBus, pos/BufFrames.kr(bufnum));
	// Out.ar(pBus, pos);
}).add;

)