function [prefs,win,stim] = init(prefs)

% Output directory
if ~exist(prefs.output_dir)
    mkdir(prefs.output_dir)
end

% Create the output file
not_valid = 1;
while not_valid

    % Ask for the code
    prompt = {'Subject Code'};
    box = inputdlg(prompt,'');
    prefs.subNum = box{1};
    fileName = [prefs.output_dir,filesep, prefs.subNum, '_ColorK.mat'];
    fileName_MATLAB = [prefs.output_dir,filesep, prefs.subNum, '_ColorK_MATLAB.mat'];

    % If exist, overwrite?
    if exist (fileName)

        overwrite = questdlg('Subject already exist. Do you want to Overwrite?', ...    % Question
            'Confirmation', ...                % Title
            'Yes', 'No', 'No');                % Buttons (default = 'No')

        if strcmp(overwrite,'Yes')
            not_valid = 0;
        end


    else
        not_valid = 0;
    end

end
prefs.fileName = fileName;
prefs.fileName_MATLAB = fileName_MATLAB;

% Initiate a random state
prefs.rndSeed = sum(100*clock);

% Build psychtoolbox window & hide the task bar
win = openWindow(prefs);

% set up fixation point rect (b/c uses both prefs and win)
win.fixRect = [(win.centerX - prefs.fixationSize),(win.centerY - prefs.fixationSize), ...
    (win.centerX  + prefs.fixationSize), (win.centerY + prefs.fixationSize)];

%Manually hide the task bar so it doesn't pop up because of flipping
%the PTB screen during GetMouse:
if prefs.is_PC
    ShowHideWinTaskbarMex(0);
end


% Define the task information
% Stimulus parameters:
stim.setSize = NaN(prefs.numTrials,prefs.numBlocks);
stim.change = NaN(prefs.numTrials,prefs.numBlocks);
% Response params
stim.response = NaN(prefs.numTrials,prefs.numBlocks);
stim.accuracy = NaN(prefs.numTrials,prefs.numBlocks);
stim.rt = NaN(prefs.numTrials,prefs.numBlocks);
% Location params
stim.probeLoc = NaN(prefs.numTrials,prefs.numBlocks,2); % 3rd dimension = (x,y) coordinates
stim.presentedColor = NaN(prefs.numTrials,prefs.numBlocks); % color originally presented at the probed location
stim.probeColor = NaN(prefs.numTrials,prefs.numBlocks); % color presented during the actual probe test
% Save triggers information
stim.triggers = struct('block', [],'trial',[],'value',[],'onset',[]);

% stim.itemLocs is a cell structure that will save the locations (centroids
% of all items. stim.itemLocs{trialNumber,blockNumber} = [xloc1 xloc2 ....; yloc1, yloc2 ...];
% stim.itemColors is a cell structure taht identifies the color of each
% item. stim.itemColors{trialNumber,blockNumber} = [col1,col2...]. To
% identify the RGB value, find the matching row in stim.colorList.
%---------------------------------------------------


end
