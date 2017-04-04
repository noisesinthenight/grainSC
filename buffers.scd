(
~paths = [
	//SUSTAINED
	[
		"/Users/dan/!PROJECTS/grainSC/samples/sustained/reedsAccordian.wav",
		"/Users/dan/!PROJECTS/grainSC/samples/sustained/reedsClarinet.wav",
		"/Users/dan/!PROJECTS/grainSC/samples/sustained/reedsSax.wav",
		"/Users/dan/!PROJECTS/grainSC/samples/sustained/reedsSax2.wav"
	],
	[
		"/Users/dan/!PROJECTS/grainSC/samples/sustained/stringsViolin.wav"
	],
	[
		"/Users/dan/!PROJECTS/grainSC/samples/sustained/metalCymbal.wav",
		"/Users/dan/!PROJECTS/grainSC/samples/sustained/metalCelloharm.wav"
	],
	[
		"/Users/dan/!PROJECTS/grainSC/samples/sustained/creakViolin.wav",
		"/Users/dan/!PROJECTS/grainSC/samples/sustained/creakDoor.wav",
		"/Users/dan/!PROJECTS/grainSC/samples/sustained/creakCellocan.wav",
		"/Users/dan/!PROJECTS/grainSC/samples/sustained/creakCellocan2.wav"
	],

	[ nil ],


	//HITS, PLUCKS, ONE SHOTS
	[
		"/Users/dan/!PROJECTS/grainSC/samples/oneshots/woodHIT.wav"
	],

	[
		"/Users/dan/!PROJECTS/grainSC/samples/oneshots/stringHITviolin.wav",
		"/Users/dan/!PROJECTS/grainSC/samples/oneshots/stringHITzither.wav",
		"/Users/dan/!PROJECTS/grainSC/samples/oneshots/stringHITpiano.wav"
	],


	[
		"/Users/dan/!PROJECTS/grainSC/samples/oneshots/glassHITkalimba.wav",
		"/Users/dan/!PROJECTS/grainSC/samples/oneshots/glassHITvase.wav",
		"/Users/dan/!PROJECTS/grainSC/samples/oneshots/glassHITglock.wav"
	],

	[
		"/Users/dan/!PROJECTS/grainSC/samples/oneshots/metalHITtankardsmooth.wav",
		"/Users/dan/!PROJECTS/grainSC/samples/oneshots/metalHITtankard.wav",
		"/Users/dan/!PROJECTS/grainSC/samples/oneshots/metalHITlamp.wav"
	],

	[ nil ],


	//LOCATIONS, FIELD RECORDINGS, IMPROVISATIONS

	["/Users/dan/!PROJECTS/grainSC/samples/locations/creakychair.wav"],
	["/Users/dan/!PROJECTS/grainSC/samples/locations/creakygardendoor.wav"],
	["/Users/dan/!PROJECTS/grainSC/samples/locations/singingbowls.wav"],
	["/Users/dan/!PROJECTS/grainSC/samples/locations/uprightpiano.wav"],
	[ nil ]

	//ONESHOTS

];


~buf = Array.fill(25, {arg i;
	if (i < 5) {
		[Buffer.alloc(s, 6 * s.sampleRate, 1), Buffer.alloc(s, 6 * s.sampleRate, 1)] ;
		//use fifth buffer for delay
	} {
		Array.fill(~paths[i-5].size, {arg ii;
			// SPLIT INTO DOUBLE MONO      [voiceid][sample][channel]
			[Buffer.readChannel(s, ~paths[i-5][ii], channels:0), Buffer.readChannel(s, ~paths[i-5][ii], channels:1)];

		});
	}
});


)