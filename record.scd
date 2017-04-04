fork{
	var recFunc;

	SynthDef(\record, {arg inBus, posBus, bufnum, t_start, t_stop, t_reset,
		rate = 1, ovr = 0, feed = 0.8, replyID;
		var inSig, isRec, end, pos, pSig;
		inSig = [InFeedback.ar(inBus, 1), InFeedback.ar(inBus, 1)];

		isRec = SetResetFF.kr(t_start, t_stop);
		end = Gate.ar(Sweep.ar(t_start, BufSampleRate.ir(bufnum)), isRec);
		pos = Select.ar(isRec, [
			Phasor.ar(t_stop + t_reset, BufRateScale.kr(bufnum) * rate, 0, end, 0),
			end
		]).wrap(0, BufFrames.ir(bufnum));

		pSig = [BufRd.ar(1, bufnum, pos, 1, 4), BufRd.ar(1, bufnum+1, pos, 1, 4)];
		inSig = LeakDC.ar(inSig + (pSig * feed)) * (isRec+ovr).clip(0,1).tanh;
		BufWr.ar(inSig[0], bufnum, pos * (isRec + ovr).clip(0, 1));
		BufWr.ar(inSig[1], bufnum+1, pos * (isRec + ovr).clip(0, 1));
		SendReply.kr(t_stop, '/newLoop', end, replyID);
		SendReply.kr(A2K.kr(Trig.ar(HPZ1.ar(pos))), '/loop', end, replyID);
		// SendReply.kr(onset * isRec, '/onsets', pos, replyID);
	}).add;

	s.sync;

	recFunc = {arg inbus, bufnum, replyID, netAddr;
		var looplength = bufnum.numFrames;
		var newLoopFunc, loopFunc;
		var onsets = Dictionary.newFrom([0,0]);
		var synths, methods;

		synths = Synth(\record, [\inBus, inbus, \bufnum, bufnum, \replyID, replyID], addAction: 'addToHead');


		OSCdef(\newLoop++replyID, {arg msg;
			if (msg[2] == replyID) {
				looplength = msg[3];
				if (netAddr.notNil) { netAddr.sendMsg(\newLoop, [replyID, looplength]) }; //sendOSC
				if (newLoopFunc.isFunction) { newLoopFunc.(msg) };     //external function
			}
		}, '/newLoop');

		OSCdef(\loopFunc++replyID, {arg msg;
			if (msg[2] == replyID) {
				if (netAddr.notNil) { netAddr.sendMsg(\loop, [replyID, looplength]) }; //sendOSC
				if (loopFunc.isFunction) { loopFunc.(msg) };     //external function
			}
		}, '/loop');

		OSCdef(\onsets++replyID, {arg msg;
			if (msg[2] == replyID) {
				//if different from last onset position then store new onset position
				if (onsets[(onsets.size - 1).clip(0, inf)] != msg[4]) {
					onsets[onsets.size] = msg[4];
					[replyID, onsets.size, msg].postln;
				};
			}
		}, '/onsets');



		methods = (
			inbus: { inbus },
			bufnum: { bufnum },
			synths: { synths },
			looplength: { looplength },
			duration: { looplength / s.sampleRate },

			rec: {arg self, val;
				if (val > 0) {
					bufnum.zero;
					onsets = Dictionary.newFrom([0, 0]);
					synths.set(\t_start, 1);
				} {
					synths.set(\t_stop, 1);
				};
			},
			ovr: {arg self, val;
				synths.set(\ovr, val);
			},
			feed: {arg self, val;
				synths.set(\feed, val);
			},

			newLoopFunc: { newLoopFunc },
			loopFunc: { loopFunc },
			onsets: { onsets }
		);
	};

	s.sync;

	~rec = Array.fill(4, {arg i; recFunc.(~mix.sendbus[1], ~buf[i][0], i, ~sendOSC) });
}
