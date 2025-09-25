%-------------------------------------------------------------------------
% Script to run 3 experimental scripts all in a row
%
% 1. Color Change Detection
% 2. Color Whole Report (set size 6)
% 3. End of experiment survey
%
% - color whole-report is updated to save locations and mouse coordinates
% (Test speed issues?)
%
% Programmed by Kirsten Adam, June 2014 (updated Oct 2014) 
%-------------------------------------------------------------------------
clear all;  % clear everything out!
close all;  % close existing figures
warning('off','MATLAB:dispatcher:InexactMatch');  % turn off the case mismatch warning (it's annoying)
dbstop if error  % tell us what the error is if there is one
AssertOpenGL;    % make sure openGL rendering is working (aka psychtoolbox is on the path)
%-------------------------------------------------------------------------
% Build a GUI to get subject number
%-------------------------------------------------------------------------
prompt = {'Subject Number', 'Random Seed'};            % what information do we want from the subject?
s = round(sum(100*clock));
defAns = {'',num2str(s)};                                           % fill in some stock answers - here the fields are left blank
box = inputdlg(prompt,'Enter Subject Info',1,defAns);       % build the GUI

if length(box) == length(defAns)                            % check to make sure something was typed in
    p.subNum = str2num(box{1});
    p.rndSeed = str2num(box{2});  % made random seed the same for all subjects!!!
    rand('state',p.rndSeed);
else
    return;                                                 % if nothing was entered or the subject hit cancel, bail out
end
%-------------------------------------------------------------------------
% Important options for all experments
%-------------------------------------------------------------------------
p.is_PC = ispc;  % ispc function detects if it's a pc computer or not
p.portCodes = 0;  %1 = use p.portCodes (we're in the booth)
p.multiColor = 0; 
p.windowed = 0; % 1 = small win for easy debugging!
p.startClick = 0; % in the discrete WR report experiment -- click to start trial if 1.
p.showInstruct = 0; % keep the instructions on the screen the whole time in the change detection experiment
%-------------------------------------------------------------------------
% Build an output directory & check to make sure it doesn't already exist
%-------------------------------------------------------------------------
p.root = pwd;
% if the subject data directory doesn't exist, make one!!
if ~exist([p.root,filesep,'Subject Data',filesep], 'dir');
    mkdir([p.root,filesep,'Subject Data',filesep]);
end
%-------------------------------------------------------------------------
% Build psychtoolbox window & hide the task bar
%-------------------------------------------------------------------------
win = openWindow(p);
%Manually hide the task bar so it doesn't pop up because of flipping
%the PTB screen during GetMouse:
if p.is_PC
    ShowHideWinTaskbarMex(0);
end
%-------------------------------------------------------------------------
% Run Experiment 1
%-------------------------------------------------------------------------
ChangeDetection_Color_Function(p,win);
%-------------------------------------------------------------------------
% Close psychtoolbox window & Postpare the environment
%-------------------------------------------------------------------------
sca;
ListenChar(0);
if p.is_PC
ShowHideWinTaskbarMex(1);
end
close all;
clear all;


