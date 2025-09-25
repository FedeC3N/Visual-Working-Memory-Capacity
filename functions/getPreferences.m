function prefs = getPreferences
%%%% Design conditions
prefs.numBlocks = 4;
prefs.nTrialsPerCondition = 40;
prefs.setSizes = [4,6,8]; % only set size 2 for this experiment right now.
prefs.change = [0,1]; % 0 = no change, 1 = change!

%%%%% timing
prefs.retentionInterval =  [1.000]; % win.refRate;% 1 sec  (or, if we don't do this we can jitter .... )
prefs.stimulusDuration = [.150];%win.refRate/2;% 500 ms
prefs.ITI = 1.000;  %prefs.retentionInterval;
prefs.breakLength = .5; % number of minutes for block

prefs.setSizes = [1,2,3]; 
prefs.stimulusDuration = [1.0];
prefs.retentionInterval =  [0.1000];
prefs.ITI = .5000; 

%%%%% stimulus size & positions
prefs.stimSize = 72;
prefs.minDist = prefs.stimSize*1.5;
prefs.fixationSize = 6;

%%%%% randomize trial order of full factorial design order
prefs.fullFactorialDesign = fullfact([length(prefs.setSizes), ...
    length(prefs.change), ...
    length(prefs.retentionInterval), ...
    length(prefs.stimulusDuration), ...
    prefs.nTrialsPerCondition]);  %add prefs.numBlocks? No, because we are using fully counterbalanced blocks.

%%%%% total number of trials in each fully-crossed block.
prefs.numTrials = size(prefs.fullFactorialDesign,1);
end