~mix.ch[0].set(\amp, 0, \sendA, 0, \sendB, 1, \post, 0);
~mix.ch[1].set(\amp, 0, \sendA, 0, \sendB, 1, \post, 0);
~mix.ch[2].set(\amp, 1, \sendA, 0.5, \sendB, 1, \post, 0);

~in[0].onsetFunc[0] = {arg val;  ~rec.rec(val[0], 2); }; //ONSET RECORDING
~rec[0].newLoopFunc[0] = {arg val; val.postln;  ~play[0].args([\bufnum, ~rec[0].bufnum, \start, 0, \end, ~rec[0].looplength])  }

~play[0].playSynth(2)
~play[0].args([\t_reset, 1, \end, ~rec[0].looplength*0.5, \tfreq, ~rec[0].duration.reciprocal*2.postln,  \size, 4, \speed, 0.01, \transpose, 12, \rate, 1], 0)
~play[~keys.voice].args([\tfreq, 13, \speed, 0.1, \transpose, 12])
~play[0].args([\pan, 0, \amp, 0.1])
~play[~keys.voice].args([\att, 0, \rel, 6])
~play[0].freeSynth

~play.collect(_.args([\tfreq, 10, \speed, 0.05, \amp, 0.5, \distort, 1]))
~play.do{arg v; v.synths.size.postln}
~play.collect(_.freeSynth)
~play[5].args[\bufnum]
~play[5].synths.size


~play[~keys.voice].args[\bufnum]
~play[~keys.voice].args([\start, 0.5 * ~play[~keys.voice].args[\bufnum].numFrames])
~sus
~held

//SEND A
~fx.key
~fx.playSynth(0, [\freq, 7000, \type, 0.6, \freqBus, ~in[0].freqbus, \ampBus, ~in[0].ampBus, \modBus, ~modBus[0]])
~fx.playSynth(1, [\time, 3, \feed, 0.76, \freqBus, ~in[0].freqbus, \ampBus, ~in[0].ampBus, \modBus, ~modBus[0]])
~fx.playSynth(0, [\mix, 0.9, \freq, 0.7, \type, 0.6, \freqBus, ~in[0].freqbus, \ampBus, ~in[0].ampBus])
~fx.playSynth(1, [\time, 3, \feed, 0.76, \freqBus, ~in[0].freqbus, \ampBus, ~in[0].ampBus])
~fx.args([\mix, 0.6, \ampMod, 100, \extMod, 0.1, \track, 1, \transpose, 0.001], 0)
~fx.args([\ampMod, 0.1, \lag, 3, \extMod, 0.01, \time, 0.013, \feed, 0.7, \freq, 1300], 1)
~fx.freeSynth(0)

//SEND B
~rec[0].rec(0)
~rec[0].ovr(0)
~rec[0].feed(0.6)
~rec[0].looplength
~rec[0].newLoopFunc
~rec[0].loopFunc

~rec[0].bufnum.plot
~buf[0][0].play
~rec[0].bufnum.zero



~buf[0.. 4][0]  //sustained
~buf[5.. 9]  //oneshots
~buf[10]    //locations
// ~bufgroup






//keysMap
~keys.intervals
~keys.octave
~keys.held
~keys.sustain

~keys.playNote
~keys.freeNote


//padsMap
~qn.padFunc
~qn.sliderFunc
~qn.switchFunc










//oneshots
sample/args per key
~play.args[0]
~play.args[1]
~play.args[2]
//OR
store args outside of playsynth?








TRANSPOSE SUSTAINED NOTES
transpose by octaves only ????  shift + octave buttons
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
~play.freeSynth

s.makeGui