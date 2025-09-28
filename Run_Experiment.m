%-------------------------------------------------------------------------
% Run a Visual Working Memory Capacity task based on Luck and Vogel (1997)
% Modifications to "Kirsten Adam, June 2014 (updated Oct 2014) "
%
% Federico Ramírez-Toraño 09/2025
%-------------------------------------------------------------------------
clc
clear
close all
warning('off','MATLAB:dispatcher:InexactMatch');  % turn off the case mismatch warning (it's annoying)
AssertOpenGL;    % make sure openGL rendering is working (aka psychtoolbox is on the path)

% Add the paths of interest
addpath('./functions')

% Config options
prefs = getPreferences();

% Init options
[prefs,win,stim] = init(prefs);

% Run Experiment
ChangeDetection_Color_Function(prefs,win,stim);

% Close psychtoolbox window & Postpare the environment
sca;
%ListenChar(0);
if p.is_PC
    ShowHideWinTaskbarMex(1);
end



