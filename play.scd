//add record sequences of 'playSynth' and store arguments
/*
scale args when setting sustained notes !!!!!!
--keep their relative relationships
--THIS NEEDS ARGS PER VOICE IN ~play
--also needed for oneshots*/



(
var playFunc = {arg key_ = \default, argsINIT = [\freq, 990], group;
	var key = key_;
	var synths = Dictionary.new;
	var args = Dictionary.newFrom(argsINIT);
	var currentArgs = Dictionary.new;
	var extFunc = [nil];
	var methods = (
		key: {arg self, val;
			if (val.isNil) { key  } { key = val };
		},
		synths: { synths },
		currentargs: { currentArgs },
		extFunc: { extFunc },
		args: {arg self, args_, id, mode = 2;
			if (args_.isNil) { args } {
				case
				{mode == 0} {
					args.putPairs(args_);
				}
				{mode == 1} {
					if (id.isNil) {
						args_.keysValuesDo{arg k, v;
							synths.keysValuesDo{arg id;
								id.postln;
								synths[id].set(k, v.value);
								if (currentArgs[id].notNil) { currentArgs[id][k] =  v.value; };
							};
						};  //set all

					} {
						args_.keysValuesDo{arg k, v; synths[id].set(k, v.value) };    //set one
						currentArgs[id].putPairs(args_);
					};
				}
				{mode == 2} {
					args.putPairs(args_);
					if (id.isNil) {
						args_.keysValuesDo{arg k, v;
							synths.keysValuesDo{arg id;
								id.postln;
								synths[id].set(k, v.value);
								if (currentArgs[id].notNil) { currentArgs[id][k] =  v.value; };
							};
						};  //set all
					} {
						args_.keysValuesDo{arg k, v; synths[id].set(k, v.value) };    //set one
						currentArgs[id].putPairs(args_);
					};
				}
			};
		},
		playSynth: {arg self, id, args_;
			if (id.isNil) { id = synths.size };
			if (args_.notNil) { args.putPairs(args_) };
			if (synths[id].notNil) { self.freeSynth(id) };
			synths[id] = Synth(key, args.asKeyValuePairs, group);
			currentArgs[id] = args.copy;
			if (extFunc[0].isFunction) { extFunc[0].(id, 1) };
		},
		freeSynth: {arg self, id;
			if (id.isNil) {
				// synths.collect( _.release );   //free all
				// group.set(\gate, 0);
				synths.keysValuesDo{arg k;
					if (extFunc[0].isFunction) { extFunc[0].(k, 0) };
					synths[k].release;
				};
				synths.clear;
				currentArgs.clear;
			} {
				synths[id].release;    //free one
				synths.removeAt(id);
				currentArgs.removeAt(id);
				if (extFunc[0].isFunction) { extFunc[0].(id, 0) };
			};
		}
	);

	methods;
};

~playG = Group.new;
~play = Array.fill(25, {arg i;
	if (i < 5) {
		//record buffers
		playFunc.(\playGrains, [
			\bufnum, ~buf[i][0], \start, 0, \end, ~buf[i][0].numFrames, \outBus, ~mix.inbus[2],
			\tfreq, 1, \size, 2, \transpose, 1, \speed, 1, \fMix, 0.1, \ffreq, 12000, \res, 0.28
		], ~playG);
	} {
		//stored buffers
		if (~buf[i][0].notNil) {
			playFunc.(\playGrains, [
				\bufnum, ~buf[i][0][0], \start, 0, \end, ~buf[i][0][0].numFrames, \outBus, ~mix.inbus[2],
				\tfreq, 1, \size, 2, \transpose, 1, \speed, 1, \fMix, 0.1, \ffreq, 12000, \res, 0.28
			], ~playG);
		} {
			//if no buffer then vosim
			playFunc.(\vosim, [\outBus, ~mix.inbus[2]]);
		}

	}
});

~play.size.do{arg i;
	~play[i].extFunc[0] = {arg id_, state_;
		if (~sendOSC.notNil) { ~sendOSC.sendMsg(\keys, i, id_, state_) }; 						//sendOSC
		[i, id_, state_].postln;
	}
}
)

/*
//MORE EFFICIENT less load onn language side
~synths = Dictionary.new
~synths[0] = s.nextNodeID
s.sendMsg("/s_new", \default, ~synths[0], 0, 0, \freq, 850);
s.sendMsg("/n_set", ~synths[0], \freq, 500);
s.sendMsg("/n_free", ~synths[0]);
*/
