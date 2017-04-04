//rows of fifths? fourths?   like strings
//formants for filters
//times for delays etc
(
var intervals = [
	-12, -11, -10, -9, -8,
	-7, -6, -5, -4, -3,
	-2, -1, 0, 1, 2,
	3, 4, 5, 6, 7,
	8, 9, 10, 11, 12
];

var noteButtons = [
	1,17,33,49,65,
	2,18,34,50,66,
	3,19,35,51,67,
	4,20,36,52,68,
	5,21,37,53,69
];

// mode == 0:  play notes,   mode == 1: select buffer/args,   mode == 2: set looppoints
var mode = 0;
var modeButtons = [96, 16, 32];

var voice = 0;
var lastVoice = 0;


var octave = 3;
var octaveIntervals = [1/8, 1/4, 1/2, 1, 2, 4, 8];
var octaveButtons = [83, 82, 81];

var states =Array.fill(intervals.size, { Array.fill(intervals.size * octaveIntervals.size, {0}) });
var heldNotes = Array.fill(intervals.size, { Dictionary.new });
var sustainNotes = Array.fill(intervals.size, { Dictionary.new });

var sustainButton = 80;
var panicButton = 64;

/*var playFunc = {arg i;
	var id = i + (octave * intervals.size);
	~play[voice].playSynth(id, [\rate, intervals[i] * octaveIntervals[octave]]);                             //playSynth
	states[id] = 1;
};

var freeFunc = {arg i;
	var id = i + (heldNotes[i] * intervals.size);
	if (~play[voice].synths[id].notNil) { ~play[voice].freeSynth(id) };                                                      //freeSynth
	states[id] = 0;
};*/

noteButtons.do{arg val, i;
	~lp.setColor(val, 42, 20);
	~lp.setState(val, 0);
	~lp.setFunc(val, {arg k, v;
		case
		{ mode == 0 } {
			//PLAY NOTES
			if (v > 0) {
				var id = i + (octave * intervals.size);
				heldNotes[voice][i] = octave;                                                                                                           //store current octave when pressed note
				~play[voice].playSynth(id, [
					\rate, intervals[i].midiratio * octaveIntervals[octave],
					\ffreq, (60 - intervals[i]).midicps * octaveIntervals[octave],
					\freq,  intervals[i].midicps * octaveIntervals[octave] * 0.1
				]);                             //playSynth
				states[voice][id] = 1;                                                                                                                          //update state
				~lp.setState(k, 1);                                                                                                                   //set LED
				// if (~sendOSC.notNil) { ~sendOSC.sendMsg(\keys, voice,  i, octave, 1) }; 							//sendOSC
				// if (~sendOSC.notNil) { ~sendOSC.sendMsg(\keys, voice,  id, 1) }; 							//sendOSC

				if (voice != lastVoice) { lastVoice = voice };
			} {
				var id, voice_;
				if (voice != lastVoice) { voice_ = lastVoice; } { voice_ = voice; };

				if (heldNotes[voice_][i].notNil) {
					id = i + (heldNotes[voice_][i] * intervals.size);          //if held
				} {
					id = i + (sustainNotes[voice_][i] * intervals.size);       //if sustained
				};
				if (states[voice_][id] != 2) {
					if (~play[voice_].synths[id].notNil) { ~play[voice_].freeSynth(id) };                                                      //freeSynth
					states[voice_][id] = 0;                                                                                                                      //update state
					if (heldNotes[voice_][i] == octave) { ~lp.setState(k, 0) };                                                         //set LED (if from current octave)
					// if (~sendOSC.notNil) { ~sendOSC.sendMsg(\keys, voice_,  i, heldNotes[i], 0) }; 						//sendOSC
					// if (~sendOSC.notNil) { ~sendOSC.sendMsg(\keys, voice_, id, 0) }; 						//sendOSC
					heldNotes[voice_].removeAt(i);                                                                                                    //free note
				};
			};
		}
		{ mode == 1 } {
			//VOICE SELECT
			if (v > 0) {
				voice = i;
				noteButtons.do{arg vv, ii;   ~lp.setState(vv, (ii == voice).asInteger);    }; //show selected buffer
			};
		}
		{ mode == 2 } {
			//free sustained notes per voice
			sustainNotes[i].keysValuesDo{arg note, oct;
					var id = note + (oct * intervals.size);
					~play[i].freeSynth(id);                                                           //freeSynth
					if (oct == octave) { heldNotes[i].removeAt(note) };       //remove from heldNotes
					states[i][id] = 0;                                                                    //reset state
				// ~lp.setState(noteButtons[note], 0);                              //set leds
				// if (~sendOSC.notNil) { ~sendOSC.sendMsg(\keys, i,  note, oct, 0) }; 						//sendOSC
				// if (~sendOSC.notNil) { ~sendOSC.sendMsg(\keys, i,  id, 0) }; 						//sendOSC
				};
				sustainNotes[i].clear;                                                              //remove from sustainNotes
			~lp.setState(k, v);
		}
		{mode == 3} {
			// Pbind([])

		}
		{mode == 4} {
			//TRANSPOSE sustained NOTES USING KEYS
			sustainNotes.postln;
			//
			// // //free sustained notes
			// sustainNotes.keysValuesDo{arg note, oct;
			// 	var id = note + (oct * intervals.size);
			// 	var newid =  intervals[note] + (oct * intervals.size);
			// 	~play[voice].freeSynth(id);                                                           //freeSynth
			// 	if (oct == octave) { heldNotes.removeAt(note) };       //remove from heldNotes
			// 	sustainNotes.removeAt(note);
			// 	states[id] = 0;                                                                    //reset state
			// 	~lp.setState(noteButtons[note], 0);                              //set leds
			//
			// 	~play[voice].playSynth(newid);
			// 	states[newid] = 1;
			//
			// };
			//replace sustained notes with transposed notes
			//play new sustained notes

		}
		{mode == 5} {
			//SET LOOPPOINTS
			var frames = ~play[voice].args[\bufnum].numFrames;
			~play[voice].args([\start, frames * (i/25), \end, frames * (i+1)/25]);
			[frames * (i/25), frames * ((i+1)/25)].postln;
			// ~play[voice].args([\start, ~looppoints[???][i], \end, ~looppoints[???][i+1]]);
		}
		;


		// heldNotes.postln;
	});
};

modeButtons.do{arg val, i;
	~lp.setColor(val, 55, 53);
	~lp.setState(val, 0);
	~lp.setFunc(val, {arg k, v;
		if (v > 0) { mode = i+1; } { mode = 0;	};
		case
		{mode == 0} {
			noteButtons.do{arg vv, ii;   ~lp.setState(vv, states[voice][ii + (octave * intervals.size)]);    };  //show note states
		}
		{mode == 1} {
			noteButtons.do{arg vv, ii;   ~lp.setState(vv, (ii == voice).asInteger);    }; //show selected buffer
		}
		{mode == 2} {
			noteButtons.do{arg vv, ii;  ~lp.setState(vv, (sustainNotes[ii].size > 0).asInteger)}; //show if sustained notes
		};

		~lp.setState(k, v);
	});
};


octaveButtons.do{arg val, i;
	~lp.setColor(val, 55, 53);
	~lp.setState(val, (i == 1).asInteger);
	~lp.setFunc(val, {arg k, v;
		if (v > 0) {
			case
			{i == 0} {  octave = (octave + 1).clip(0, octaveIntervals.size - 1); }        //octave up
			{i == 1} {  octave = 3; }                                                                                      //octave reset
			{i == 2} {  octave = (octave - 1).clip(0, octaveIntervals.size - 1); };        //octave down

			//update leds
			octaveButtons.do{arg vv, ii;  ~lp.setState(octaveButtons[i], 0)  };
			case
			{octave > 3} { ~lp.setState(octaveButtons[0], 1) }
			{octave == 3} { ~lp.setState(octaveButtons[1], 1) }
			{octave < 3} { ~lp.setState(octaveButtons[2], 1) };

			noteButtons.do{arg vv, ii;   ~lp.setState(vv, states[voice][ii + (octave * intervals.size)]);    };
		};
	})

};



//SUSTAIN HELD NOTES
~lp.setColor(sustainButton, 90, 55);
~lp.setState(sustainButton, 0);
~lp.setFunc(sustainButton, {arg k, v;
	if (v > 0) {
		intervals.size.do{arg i;                                            //iterate through all voices
			heldNotes[i].keysValuesDo{arg note, oct;
				var id = note + (oct * intervals.size);
				sustainNotes[i][note] = oct;                          //add to sustainNotes
				states[i][id] = 2;                                               //set state
			};
			heldNotes[i].clear;
			sustainNotes.postln;
		}
	};
});

//FREE SUSTAINED NOTES
~lp.setColor(panicButton, 10, 10);
~lp.setState(panicButton, 0);
~lp.setFunc(panicButton, {arg k, v;
	if (v > 0) {
		// var flag = 0;

		// intervals.size.do{arg i;                                             //iterate through all voices
		var i = voice;       //CURRENT VOICE ONLY
			sustainNotes[i].size.postln;

			if (sustainNotes[i].size > 0) {
				sustainNotes[i].keysValuesDo{arg note, oct;
					var id = note + (oct * intervals.size);
					~play[i].freeSynth(id);                                                           //freeSynth
					if (oct == octave) { heldNotes[i].removeAt(note) };       //remove from heldNotes
					states[i][id] = 0;                                                                    //reset state
					~lp.setState(noteButtons[note], 0);                              //set leds
				// if (~sendOSC.notNil) { ~sendOSC.sendMsg(\keys, i,  note, oct, 0) }; 						//sendOSC
				// if (~sendOSC.notNil) { ~sendOSC.sendMsg(\keys, i, id, 0) }; 						//sendOSC
				};
				sustainNotes[i].clear;                                                              //remove from sustainNotes
				sustainNotes.postln;
				"sus".postln;
			// flag = 1;
				} {
	// };
		// if (flag == 0) {
				//IF NO MORE SUSTAINED NOTES (i.e button pressed twice)
			// FREE ALL SYNTHS
			intervals.size.do{arg i;
				"all".postln;
				~play[i].freeSynth; //free all synths
				heldNotes[i].clear;
				sustainNotes[i].clear;
				states[i] = states[i] * 0;
				noteButtons.do{arg vv, ii;   ~lp.setState(vv, states[voice][ii + (octave * intervals.size)]);    };
				// if (~sendOSC.notNil) { ~sendOSC.sendMsg(\keys, i, id, 0) }; 						//sendOSC
			}
		}
	};
});

~keys = (
	voice: { voice }, //currently selected buffer
	intervals: { intervals },
	octave: { octave },
	held: { heldNotes },
	sustained: { sustainNotes },
	states: { states },
);

)


UPDATE PAD MAPPING FOR DISTORTION
seperate mixer channel for sustained notes


TRANPOSE SUSTAINED NOTES  ---move play func outside?
(
var val = -1;
~keys.sustained.keysValuesDo{arg note, oct;
	var id = note + (oct * ~keys.intervals.size);
	var newid = note + ((oct+val) * ~keys.intervals.size);
	[note, oct, id].postln;
	~play.freeSynth(id);
	~keys.sustained[note] = ~keys.sustained[note] + val;
	~play.playSynth(newid, [\rate, ~keys.intervals[note] * (oct+val)])
}
)


STORE AND RECALL SUSTAINED NOTES
x = ~keys.sustained.copy
x.do{arg val, i;
	~keys.playSynth()
}



free last added note
free all sustained notes except current voice + current octave ?
free all sustained notes in current octave ?                                                           