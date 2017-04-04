ADD SEQUENCE RECORDING
>>>>> ARPEGGIATER / NOTE REPEAT / SEQ MODE   (record sequences, select patterns for arpeggiator)
--retrigger, bounce, fibb etc??, pulsar

---last n notes used for arpegiattor



(
if (~sendOSC.isNil) { ~sendOSC = NetAddr("127.0.0.1", 9001) };
~path = "/Users/dan/!PROJECTS/grainSC";
s.waitForBoot{
	fork{
		(~path +/+ "buffers.scd").loadPaths[0];
		s.sync;
		(~path +/+ "synthdefs.scd").loadPaths[0];
		(~path +/+ "synthdefsFX.scd").loadPaths[0];
		(~path +/+ "mix.scd").loadPaths[0];
		s.sync;
		(~path +/+ "record.scd").loadPaths[0];
		(~path +/+ "fx.scd").loadPaths[0];
		s.sync;
		(~path +/+ "input.scd").loadPaths[0];
		(~path +/+ "play.scd").loadPaths[0];
		// (~path +/+ "mod.scd").loadPaths[0];
		s.sync;

		~mix.ch[0].set(\amp, 0, \sendA, 0, \sendB, 1,  \post, 0);
		~mix.ch[1].set(\amp, 0, \sendA, 0, \sendB, 1, \post, 0);
		~mix.ch[2].set(\amp, 0.4, \sendA, 1, \sendB, 1, \post, 0);

		MIDIClient.init;
		MIDIIn.connectAll;
		~lp = LaunchPad.new("Launchpad MINI", zSize: 3);
		// ~qn = QuNeo.new("QUNEO");
		(~path +/+ "mixMap.scd").loadPaths[0];
		// (~path +/+ "keysMap.scd").loadPaths[0];
		// (~path +/+ "padsMap.scd").loadPaths[0];


	}
}
)








MAKE BETTER PLAYBACK SYNTH
// ADD REVERSE make reverse if startpoint moving backwards  FOR GRAINS
// >>>>> BUFFER SELECT (index + deviation)
--- (sample per key     like Drum Rack in ableton)


MAKE BETTER FX SYNTHS
add noise to delay time  (deviation for all fx synths)
tap delay time (momentary)
add lag  (map to pad acceleration)
// add POLYPHONY to FX





ADD VOSIM / PULSAR / OSC / MOD   MODE to keysMap
---impulse >>> filter >>> feedback   (spring model)






MAKE BUFFER SLICER GUI
---- store looppoints to text file    SIMILAR to WARPPOINTS in ableton
---- onset detection/analysis






// master resampler
// pre OR post fx  recording

//MAKE INTERCONNECTED CHAOTIC WEB OF MOD SYNTHS so different per voice?
// springs
mover, particle
gravity, lag/friction
trajectories, phase spaces


s.meter