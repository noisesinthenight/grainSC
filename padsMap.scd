(
var qnFunc = {
	var midiUID = MIDIIn.findPort("QUNEO", "QUNEO").uid;
	var padData = Array.fill(16, { [nil, nil ,nil, nil] });  //GATE, X, Y, Z
	var padFunc = Array.fill(16, { [nil, nil ,nil, nil] });  //GATE, X, Y, Z
	var sliderFunc = Array.fill(11, { [nil, nil, nil] });  //GATE, X, Z
	var switchFunc = Array.fill(16, { [nil, nil] }); //GATE, Z
	var methods;

	MIDIdef.noteOn(\qnON, {arg vel, pitch, ch;
		case
		{(pitch >= 0) && (pitch < 17)} {  if (padFunc[pitch][0].isFunction) { padFunc[pitch][0].(1) }; padData[pitch][0] = 1;  }
		{(pitch >= 17) && (pitch < 28)} { pitch = pitch - 17; if (sliderFunc[pitch][0].isFunction) { sliderFunc[pitch][0].(1) }  }
		{(pitch >= 28) && (pitch < 44)} { pitch = pitch - 28; if (switchFunc[pitch][0].isFunction) { switchFunc[pitch][0].(1) }  };
	}, srcID: midiUID);

	MIDIdef.noteOff(\qnOFF, {arg vel, pitch, ch;
		case
		{(pitch >= 0) && (pitch < 17)} {  if (padFunc[pitch][0].isFunction) { padFunc[pitch][0].(0) }; padData[pitch][0] = 0; }
		{(pitch >= 17) && (pitch < 28)} { pitch = pitch - 17; if (sliderFunc[pitch][0].isFunction) { sliderFunc[pitch][0].(0) }  }
		{(pitch >= 28) && (pitch < 44)} { pitch = pitch - 28; if (switchFunc[pitch][0].isFunction) { switchFunc[pitch][0].(0) }  };
	}, srcID: midiUID);

	MIDIdef.cc(\padCC, {arg vel, pitch, ch;
		vel = vel / 127;   //scale between 0 and 1
		case
		//X AND Y ARE INVERTED TO BECAUSE USING CONTROLLER SIDEWAYS
		{(pitch >= 0) && (pitch < 16)} { vel = 1-vel; if (padFunc[pitch][2].isFunction) { padFunc[pitch][2].(vel) }; padData[pitch][2] = vel; }
		{(pitch >= 16) && (pitch < 32)} { pitch = pitch - 16;  if (padFunc[pitch][1].isFunction) { padFunc[pitch][1].(vel) }; padData[pitch][1] = vel; }
		{(pitch >= 32) && (pitch < 48)} { pitch = pitch - 32; if (padFunc[pitch][3].isFunction) { padFunc[pitch][3].(vel) }; padData[pitch][3] = vel; }
		{(pitch >= 48) && (pitch < 59)} { pitch = pitch - 48; if (sliderFunc[pitch][1].isFunction) { sliderFunc[pitch][1].(vel) };  }
		//SLIDER Z VALUE
		// {(pitch >= 48) && (pitch < 59)} { pitch = pitch - 48; if (sliderFunc[pitch][2].isFunction) { sliderFunc[pitch][2].(vel) };  }
		// {(pitch >= 48) && (pitch < 59)} { pitch = pitch - 48; if (switchFunc[pitch][1].isFunction) { switchFunc[pitch][1].(vel) }; }
		;
		if ((~sendOSC.notNil) && (pitch <48)) { ~sendOSC.sendMsg(\pads, pitch,  padData[pitch][0], padData[pitch][1], padData[pitch][2], padData[pitch][3]) }; 							//sendOSC
	}, srcID: midiUID);

	methods = (
		padFunc: { padFunc },
		sliderFunc: { sliderFunc },
		switchFunc: { switchFunc },

		padXFunc: { padFunc[1] },
		padYFunc: { padFunc[2] },
		padZFunc: { padFunc[3] },
		sliderXFunc: { sliderFunc[1] },
		sliderZFunc: { sliderFunc[2] },
		switchZFunc: { switchFunc[1] },

		padNoteFunc: { padFunc[0] },
		sliderNoteFunc: { sliderFunc[0] },
		switchNoteFunc: { switchFunc[0] }
	);
};

~qn = qnFunc.();
)



// trajectories
// gesture looping


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<         PLAY
(
var envDur = 0.5, envSkew = 0.5;
~qn.sliderFunc[0][1] = {arg v;
	envDur = v.linexp(0,1,0.1,28);
	~play.collect(_.args([\att, envDur * envSkew, \rel, envDur * (1 - envSkew)]));
};

~qn.sliderFunc[1][1] = {arg v;
	envSkew = v;
	~play.collect(_.args([\att, envDur * envSkew, \rel, envDur * (1 - envSkew)]));
};



~sus = 0; ~held = 0;
~qn.switchFunc[15][0] = {arg v; ~sus = v; ["sus", ~sus].postln; };
~qn.switchFunc[14][0] = {arg v; ~held = v; ["held", ~held].postln; };


~setFunc = {arg k = \amp, v = 1, held = ~held, sus = ~sus, rel = 1;
	if (held > 0) { ~play[~keys.voice].args([k, v], nil, 0); };  //set init args
	~keys.states.do{arg voice, vi;
		voice.do{arg vv, id;
			case
			{(vv == 1) && (held > 0)} {
				// [vi, id, "init/held notes"].postln;
				// ~play[~keys.voice].args([k, v], id);
				~play[vi].args([k, v], id);
			}
			{(vv == 2) && (sus > 0) && (rel == 0)} {
				// [vi, id, "sustained note"].postln;
				~play[vi].args([k, v], id, 1);

			}
			{(vv == 2) && (sus > 0) && (rel > 0)} {
				// [vi, id, "sustained note"].postln;
				~play[vi].synths[id].set(k, ~play[vi].currentargs[id][k]  *  v);     //set RELATIVE

			};
		};
	}
};





//gate == reset pitch,  y == pitchbend
// ~qn.padFunc[14][0] = {arg v;  	~setFunc.(\transpose, 1); };
// ~qn.padFunc[14][2] = {arg v;  	~setFunc.(\transpose, (v*v).linlin(0,1,0.5,2)); };



// seperate pads for modifying sustain and held voices!!!!

/*// [13, 9,5,1]  second row    ---sustained voices only
//x == distortion, y == tone, z == amp
~qn.padFunc[13][3] = {arg v;  ~setFunc.(\amp, v*v*v, 0, 1); };
//x == tfreq, y == size,
~qn.padFunc[9][1] = {arg v; ~setFunc.(\tfreq, (v*v).linlin(0,1,0,60), 0, 1); };
~qn.padFunc[9][2] = {arg v; ~setFunc.(\size, (v*v).linlin(0,1,0,4), 0, 1); };
//filter   //x == mix, y == freq, z == mix / res
~qn.padFunc[5][1] = {arg v;  ~setFunc.(\fMix, (1 -v), 0, 1); };
~qn.padFunc[5][2] = {arg v;  ~setFunc.(\ffreq, v.linexp(0,1,120,8000), 0, 1); };
~qn.padFunc[5][3] = {arg v;  ~setFunc.(\res, (v*v).linlin(0,1,0.38,0.98), 0, 1); };
// y == speed
~qn.padFunc[1][2] = {arg v; ~setFunc.(\speed, v * 2, 0, 1); };*/
// [13, 9,5,1]  second row    ---sustained voices only                       RELATIVE
//x == distortion, y == tone, z == amp
~qn.padFunc[13][3] = {arg v;  ~setFunc.(\amp, v*2, 0, ~sus); };
//x == tfreq, y == size,
~qn.padFunc[9][1] = {arg v; ~setFunc.(\size, v*2, 0, ~sus); };
~qn.padFunc[9][2] = {arg v; ~setFunc.(\tfreq, v*2, 0, ~sus); };
//filter   //x == mix, y == freq, z == mix / res
~qn.padFunc[5][1] = {arg v;  ~setFunc.(\fMix, (1 -v)*2, 0, ~sus); };
~qn.padFunc[5][2] = {arg v;  ~setFunc.(\ffreq, v*2, 0, ~sus); };
~qn.padFunc[5][3] = {arg v;  ~setFunc.(\res, v, 0, ~sus); };
// y == speed
~qn.padFunc[1][2] = {arg v; ~setFunc.(\speed, v * 2, 0, ~sus); };



// [14, 10,6,2]   third row   ---held voices only
//x == distortion, y == tone, z == amp
~qn.padFunc[14][1] = {arg v; v = 1 - v; ~mix.ch[2].set(\distort, (v*v*v)*11, \res, v * 0.12); };
~qn.padFunc[14][2] = {arg v; ~mix.ch[2].set(\tone,  v.linexp(0, 1, 120, 12000)); };
~qn.padFunc[14][3] = {arg v;  ~setFunc.(\amp, v*v*v, 1, 0); v.postln };
//x == tfreq, y == size,
~qn.padFunc[10][1] = {arg v;  ~setFunc.(\size, (v*v).linlin(0,1,0,4), 1, 0); };
~qn.padFunc[10][2] = {arg v; ~setFunc.(\tfreq, (v*v).linlin(0,1,0,60), 1, 0); };
//filter   //x == mix, y == freq, z == mix / res
~qn.padFunc[6][1] = {arg v;  ~setFunc.(\fMix, (1 -v), 1, 0); };
~qn.padFunc[6][2] = {arg v;  ~setFunc.(\ffreq, v.linexp(0,1,120,8000), 1, 0); };
~qn.padFunc[6][3] = {arg v;  ~setFunc.(\res, (v*v).linlin(0,1,0.38,0.98), 1, 0); };
// y == speed
~qn.padFunc[2][2] = {arg v; ~setFunc.(\speed, v * 2, 1, 0); };





//buffer index
~index = 0; ~dev = 0;
~qn.sliderFunc[6][1] = {arg v;
	if (~buf[~keys.voice][0][0].isNil) {
		//single buffer
		~setFunc.(\bufnum, ~buf[~keys.voice][0]);
		~setFunc.(\end, ~buf[~keys.voice][0].numFrames);
	} {
		//group buffers
		~index = v * (~buf[~keys.voice].size - 1);
		~index = ~index.floor;
		~setFunc.(\bufnum, ~buf[~keys.voice][~index][0]);
		~setFunc.(\end, ~buf[~keys.voice][~index][0].numFrames);
	};

	// ~play.collect(_.args([\bufnum, ~buf[~keys.voice-5][rrand(~index - ~dev, ~index + ~dev).clip(0, (~buf[~keys.voice-5].size - 1)).floor] ]);
};

//buffer deviation
/*~sliderFunc[7] = {arg v;
	~index = ~index * (~buf[~keys.voice].size - 1);
	~buf[~keys.voice][rrand(~index - ~dev, ~index + ~dev).clip(0, (~buf[~keys.voice].size - 1)).floor]	;
};*/



//slider start position
//add zoom
//quantise to stored onsets
// control position directly (noise + lag?)
~qn.sliderFunc[10][1] = {arg v;
	case
	//record buffers
	{(~keys.voice < 5)} { v = v.linlin(0,1,0,~rec[~keys.voice].looplength); }
	//single buffers
	{(~keys.voice >= 5) && (~buf[~keys.voice][0][0].isNil)} { v = v.linlin(0,1,0, ~buf[~keys.voice][0].numFrames); }
	//group buffers
	{(~keys.voice >= 5) && (~buf[~keys.voice][0][0].notNil)} {	 v = v.linlin(0,1,0,	~buf[~keys.voice][0][0].numFrames); };

	// ~play[~keys.voice].args([\start, v, \t_reset, 1]);
	~setFunc.(\start, v);
	~setFunc.(\t_reset, 1);
};




//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<         FX
//if feedback == 0 then bypass delay
// --hold to set delay time

~fxDur = 0.5; ~fxSkew = 0.5;
~qn.sliderFunc[2][1] = {arg v;
	~fxDur = v.linexp(0,1,0.01,28); ~fx.args([\att, ~fxDur * ~fxSkew, \rel, ~fxDur * (1 - ~fxSkew)]);
};
~qn.sliderFunc[3][1] = {arg v;
	~fxSkew = v; ~fx.args([\att, ~fxDur * ~fxSkew, \rel, ~fxDur * (1 - ~fxSkew)]);
};

~qn.sliderFunc[8][1] = {arg v; ~mix.master.set(\mix, v) };    //dry / wet





[11,12].do{arg val, i;
	~qn.padFunc[val][0] = {arg v;
		if (v > 0) {
			// ~fx.playSynth(i); ["fx", ~keys[i], "ON"].postln
		} {
			// ~fx.freeSynth(i); ["fx", ~keys[i], "OFF"].postln
		}
	};
	case
	{i == 0} {
		//ring
		~qn.padFunc[val][1] = {arg v; ~fx.args([\type, v], i) };
		~qn.padFunc[val][2] = {arg v; ~fx.args([\freq, v.linexp(0,1,120,1200)], i) };
	}
	{i == 1} {
		//delay
		~qn.padFunc[val][1] = {arg v; ~fx.args([\feed, v ], i)};
		~qn.padFunc[val][2] = {arg v; ~fx.args([\time, (1 - v).linexp(0,1,0.01, 2)], i) };
	};

};







//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<         MIXER

//input freq shift
// [11, 8].do{arg val, i;
// 	~padFunc[val][0] = {arg v; ~in[i].synths.set(\rType, v); };
// 	// ~padFunc[val][1] = {arg v; ~in[i].synths.set(\track, 0, \rFreq, v.linexp(0, 1, 1, 6000)); };
// 	~padFunc[val][1] = {arg v; ~in[i].synths.set(\track, 1, \div, v.linlin(0,1,1/32,32)); };
// 	//trigger modulation envelope on onset ?????
// 	//use 	LagUD.ar ????
//
// 	~padFunc[val][2] = {arg v; ~in[i].synths.set(\rMix, v*v, \rFreqMod, v); };
// };

// ~in[0].synths.set(\lag, 10)

//input distortion
[15, 11].do{arg val, i;
	~qn.padFunc[val][1] = {arg v;
		if (i == 0) {v = 1 - v; };
		~mix.ch[i].set(\res, v * 0.12);
	};
	~qn.padFunc[val][2] = {arg v; ~mix.ch[i].set(\tone, v.linexp(0, 1, 120, 12000)); };
	~qn.padFunc[val][3] = {arg v; ~mix.ch[i].set(\distort, (v*v*v)*11); };
};

)