~in = {arg outBus_, replyID, group, netAddr;
	var outBus = outBus_;
	var freqBus = Bus.control(s, 1);
	var ampBus = Bus.control(s, 1);
	var onsetFunc = Dictionary.new;
	var synths, methods;

	synths = {arg thresh = 0.08, smooth = 0.23, amp = 1,
		track = 1,  div = 1, lag = 0.01, rFreqMod = 0, rAmpMod = 0.2,
		rFreq = 1200, rType = 0.7, rMix = 0;
		var inSig, freqSig, hasFreq, ampSig, onset;

		inSig = SoundIn.ar(replyID);
		//ANALYSIS
		#freqSig, hasFreq = Tartini.kr(inSig, thresh);
		ampSig = Amplitude.ar(inSig, 0.01, smooth);
		onset = ampSig > thresh;
		onset = (Timer.ar(Changed.ar(onset)) > 0.06) * onset;  //time threshold

		Out.ar(outBus, inSig * amp);
		Out.kr(freqBus, freqSig);
		Out.kr(ampBus, ampSig);
		SendReply.ar(Changed.ar(onset), '/input', [onset, freqSig, ampSig], replyID);
	}.play(group);



	OSCdef(\input++replyID, {arg msg;
		if (msg[2] == replyID) {
			//sendOSC
			if (netAddr.notNil) {  netAddr.sendMsg(\onset, replyID, msg[3.. 4]);  };
			//external function
			if (onsetFunc.isFunction)  {
				onsetFunc.(msg[3.. 4]);
			} {
				onsetFunc.asArray.do{arg v, i; v.(msg[3.. 4]) };
			};
		}
	}, '/input');


	methods = (
		outbus: { outBus },
		freqbus: { freqBus },
		ampbus: { ampBus },
		synths: { synths },
		onsetFunc: { onsetFunc }
	);

};

~inG = Group.new;
~in = Array.fill(2, {arg i; ~in.(~mix.inbus[i], i, ~inG, ~sendOSC); });