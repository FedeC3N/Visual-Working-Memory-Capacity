function prefs = getPreferences

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Load the package needed
pkg load statistics

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Define answers and important keys
KbName('UnifyKeyNames');
prefs.keys.escape = KbName('ESCAPE');
prefs.keys.space = KbName('space');
prefs.keys.same_color = 162; % Left control
prefs.keys.different_color = 163; % Right control

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%Decide the screen to use
prefs.screenNumber = max(Screen('Screens'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Design conditions
prefs.numBlocks = 5;
prefs.nTrialsPerCondition = 10; % Per condition and block
prefs.setSizes = [4,6,8]; % Condition = Number of squares presented
prefs.change = [0,1];
prefs.change_label = {'No change', 'Change'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% timing
prefs.stimulusDuration = [0.150]; % seconds. Time of the memory array
prefs.retentionInterval =  1.000; % seconds. Time before square question presented.
prefs.ITI = 1.000;  % InterTrial Time

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% stimulus size & positions
prefs.stimSize = 72;
prefs.minDist = prefs.stimSize*1.5;
prefs.fixationSize = 6;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% randomize trial order of full factorial design order
prefs.fullFactorialDesign = fullfact([length(prefs.setSizes), ...
    length(prefs.change), ...
    length(prefs.retentionInterval), ...
    length(prefs.stimulusDuration), ...
    prefs.nTrialsPerCondition]);  %add prefs.numBlocks? No, because we are using fully counterbalanced blocks.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% total number of trials in each fully-crossed block.
prefs.numTrials = size(prefs.fullFactorialDesign,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Options
prefs.is_PC = ispc;  % ispc function detects if it's a pc computer or not
prefs.windowed = 0; % 1 = small win for easy debugging!
prefs.screenNumber = prefs.screenNumber;
prefs.parallel_port = 16360; % 3FE8
prefs.output_dir = fullfile('.','data','conductual');

end
