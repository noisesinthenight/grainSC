//toggle fx send
[87, 103, 119].do{arg val, i;
	~lp.setColor(val, 30, 100);
	~mix.ch[i].get(\sendA, {arg v; ~lp.setState(val, v) });
	~lp.setFunc(val, {arg k, v;
		if (v > 0) {
			~lp.setState(k, 1 - ~lp.getState(k));
			~mix.ch[i].set(\sendA, ~lp.getState(k));
		}
	});
};

//rec send
[86, 102, 118].do{arg val, i;
	~lp.setColor(val, 30, 100);
	~mix.ch[i].get(\sendB, {arg v; ~lp.setState(val, v) });
	~lp.setFunc(val, {arg k, v;
		if (v > 0) {
			~lp.setState(k, 1 - ~lp.getState(k));
			~mix.ch[i].set(\sendB, ~lp.getState(k));
		}
	});
};


//rec on/off
[7, 23, 39, 55].do{arg val, i;
	~lp.setColor(val, 15, 9);
	~rec[i].synths.get(\rec, {arg v; ~lp.setState(val, v); });
	~lp.setFunc(val, {arg k, v;
		if (v > 0) {
			~lp.setState(k, 1 - ~lp.getState(k));
			~rec[i].rec( ~lp.getState(k));
		}
	});
};



//ovr on/off
[6, 22, 38, 54].do{arg val, i;
	~lp.setColor(val, 55, 17);
	~rec[i].synths.get(\ovr, {arg v; ~lp.setState(val, v); });
	~lp.setState(val, 0);
	~lp.setFunc(val, {arg k, v;
		if (v > 0) {
			~lp.setState(k, 1 - ~lp.getState(k));
			~rec[i].ovr( ~lp.getState(k), i);
		}
	});
};