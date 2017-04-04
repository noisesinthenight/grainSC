(
~mixG = Group.tail;
~mix = (
	inbus: Array.fill(3, {arg i;   if (i < 2) { Bus.audio(s, 1); } { Bus.audio(s, 2); }   }),
	sendbus: Array.fill(2, { Bus.audio(s, 2) }),
	returnbus: Bus.audio(s, 2),
	masterbus: Bus.audio(s, 2)
);

~mix.ch = Array.fill(~mix.inbus.size, {arg i;
	if (~mix.inbus[i].numChannels == 1) {
		//MONO
		{arg post = 1, sendA = 0, sendB = 0, sendC = 0, sendD = 0, lag = 1,
			loFreq = 120, hiFreq = 1200, slope = 0.5, gain = 1,
			distort = 0, tone = 800, res = 0.3, pan = 0, mute = 1, amp = 1;
			var inSig, sig;
			inSig = InFeedback.ar(~mix.inbus[i], 1);
			inSig = SelectX.ar(distort.clip(0, 1), [
				inSig,
				BPF.ar((inSig*(distort*10)).distort,  tone.lag(0.1), 1 - res);
			]);
			inSig = LowShelf.ar(inSig, loFreq, gain.clip(0, 1), gain*(1 - (slope*2)));
			inSig = HighShelf.ar(inSig, hiFreq, gain.clip(0, 1),  (gain* ((slope*2)-1)));
			inSig = Pan2.ar(inSig, pan); //convert to stereo
			sig = SelectX.ar(post, [inSig, inSig * (amp * mute)]);
			OffsetOut.ar(~mix.sendbus[0], sig * sendA);		//to  FX
			OffsetOut.ar(~mix.sendbus[1], sig * sendB);		//to REC
			OffsetOut.ar(~mix.masterbus, (inSig * (amp * mute)).tanh);
		}.play(~mixG);
	} {
		//STEREO
		{arg post = 1, sendA = 0, sendB = 0, sendC = 0, sendD = 0, lag = 1,
			loFreq = 120, hiFreq = 1200, slope = 0.5, gain = 1,
			distort = 0, tone = 800, res = 0.3, pan = 0, mute = 1, amp = 1;
			var inSig, sig;
			inSig = InFeedback.ar(~mix.inbus[i], 1);
			inSig = SelectX.ar(distort.clip(0, 1), [
				inSig,
				BPF.ar((inSig*(distort*10)).distort,  tone.lag(0.1), 1 - res);
			]);
			inSig = LowShelf.ar(inSig, loFreq, gain.clip(0, 1), gain*(1 - (slope*2)));
			inSig = HighShelf.ar(inSig, hiFreq, gain.clip(0, 1),  (gain* ((slope*2)-1)));
			inSig = Pan2.ar(inSig, pan); //convert to stereo
			sig = SelectX.ar(post, [inSig, inSig * (amp * mute)]);
			OffsetOut.ar(~mix.sendbus[0], sig * sendA);		//to FX
			OffsetOut.ar(~mix.sendbus[1], sig * sendB);		//to REC
			OffsetOut.ar(~mix.masterbus, (inSig * (amp * mute)).tanh);
		}.play(~mixG);
	}
});


~mix.master = {arg mix = 0.5, amp = 1;
	var sig = LeakDC.ar(
		// In.ar(~mix.masterbus, 2);
		XFade2.ar(
			In.ar(~mix.masterbus, 2),
			InFeedback.ar(~mix.returnbus, 2),
			mix
		);
	);
	OffsetOut.ar(0, (sig * amp).tanh);
	OffsetOut.ar(2, (sig * amp).tanh);
}.play(addAction: 'addToTail');
)


