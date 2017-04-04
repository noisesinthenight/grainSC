(
var fxFunc = {arg inbus, outbus, keys, groups;
	var args = Array.fill(keys.size, {arg i; Dictionary.new });
	var synths = Array.fill(keys.size, { Dictionary.new });
	var outSynth, methods;

	if (groups.isNil) {
		groups = Array.fill(keys.size + 1, {
				Group.before(~mix.master);
		});
	};

	keys.do{arg val, i; args[i].putPairs([\inBus, inbus, \outBus, inbus]) };                             //INIT ARGS
	outSynth = {arg amp = 1; Out.ar(outbus, In.ar(inbus, 2) * amp)}.play(groups[keys.size]);    //OUTPUT SYNTH

	methods = (
		groups: { groups },
		key: { keys },
		synths: { synths },
		outSynth: { outSynth },

		args: {arg self, args_, id, mode = 2;
			if (args_.isNil) { args } {
				case
				{mode == 0} {
					if (id.isNil) {
						args.collect(_.putPairs(args_)); //set all
					} {
						args[id].putPairs(args_); //set one
					}
				}
				{mode == 1} {
					if (id.isNil) {
						args_.keysValuesDo{arg k, v;
							synths.do{arg vv, ii;
								if (synths[ii][0].notNil) {  synths[ii][0].set(k, v.value); };
							} ;
						};  //set all
					} {
						if (synths[id].notNil) {
							args_.keysValuesDo{arg k, v; synths[id][0].set(k, v.value) };    //set one
						};
					};

				}
				{mode == 2} {
					if (id.isNil) {
						args.collect(_.putPairs(args_));
						args_.keysValuesDo{arg k, v;
							synths.do{arg vv, ii;
								if (synths[ii][0].notNil) {  synths[ii][0].set(k, v.value) };
							}
						};  //set all
					} {
						args[id].putPairs(args_);
						if (synths[id].notNil) {
							args_.keysValuesDo{arg k, v; synths[id][0].set(k, v.value) };    //set one
						};
					};
				}
			};
		},
		playSynth: {arg self, id, args_;
			if (args_.notNil) { args[id].putPairs(args_) };
			if (synths[id][0].notNil) { synths[id][0].release };
			synths[id][0] = Synth(keys[id], args[id].asKeyValuePairs, groups[id]);
		},
		freeSynth: {arg self, id;
			if (id.isNil) {
				synths.collect( _[0].release );   //free all
				groups.collect(_.set(\gate, 0));
				synths = Array.fill(keys.size, { Dictionary.new });
			} {
				synths[id][0].release;    //free one
				synths[id].removeAt(0);
			};


		}
	);

};

~fx = fxFunc.(~mix.sendbus[0], ~mix.returnbus, [\ring, \delay]);
)
