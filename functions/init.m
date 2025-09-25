function [p,win] = init()

% Options
p.is_PC = ispc;  % ispc function detects if it's a pc computer or not
p.portCodes = 0;  %1 = use p.portCodes (we're in the booth)
p.multiColor = 0; 
p.windowed = 1; % 1 = small win for easy debugging!
p.startClick = 0; % in the discrete WR report experiment -- click to start trial if 1.
p.showInstruct = 0; % keep the instructions on the screen the whole time in the change detection experiment

% Output directory
p.output_dir = fullfile('.','data','conductual');
if ~exist(p.output_dir)
    mkdir(p.output_dir)
end

% Create the output file
not_valid = 1;
while not_valid
    
    % Ask for the code
    prompt = {'Subject Code'};
    box = inputdlg(prompt,'');
    p.subNum = box{1};
    fileName = [p.output_dir,filesep, p.subNum, '_ColorK.mat'];
    
    % If exist, overwrite?
    if exist (fileName)
        
        overwrite = questdlg('Subject already exist. Do you want to Overwrite?', ...    % Question
            'Confirmation', ...                % Title
            'Yes', 'No', 'No');                % Buttons (default = 'No')
        
        if strcmp(overwrite,'Yes')
            not_valid = 0;
        end
        
        
    end
end

% Initiate a random state
p.rndSeed = round(sum(100*clock));
rand('state',p.rndSeed);

% Build psychtoolbox window & hide the task bar
win = openWindow(p);

%Manually hide the task bar so it doesn't pop up because of flipping
%the PTB screen during GetMouse:
if p.is_PC
    ShowHideWinTaskbarMex(0);
end


end