function prefs = getPreferences

% Define answers and important keys
KbName('UnifyKeyNames');
prefs.keys.escape = KbName('ESCAPE');
prefs.keys.space = KbName('space');
prefs.keys.same_color = 162; % Left control
prefs.keys.different_color = 163; % Right control

% Design conditions
prefs.numBlocks = 4;
prefs.nTrialsPerCondition = 80;
prefs.setSizes = [4,6,8]; % Condition = Number of squares presented
prefs.change = [0,1];
prefs.change_label = {'No change', 'Change'};

% timing
prefs.stimulusDuration = [0.150]; % seconds. Time of the memory array
prefs.retentionInterval =  1.000; % seconds. Time before square question presented.
prefs.ITI = 1.000;  % InterTrial Time

% stimulus size & positions
prefs.stimSize = 72;
prefs.minDist = prefs.stimSize*1.5;
prefs.fixationSize = 6;

% randomize trial order of full factorial design order
prefs.fullFactorialDesign = fullfact([length(prefs.setSizes), ...
    length(prefs.change), ...
    length(prefs.retentionInterval), ...
    length(prefs.stimulusDuration), ...
    prefs.nTrialsPerCondition]);  %add prefs.numBlocks? No, because we are using fully counterbalanced blocks.

% total number of trials in each fully-crossed block.
prefs.numTrials = size(prefs.fullFactorialDesign,1);

end