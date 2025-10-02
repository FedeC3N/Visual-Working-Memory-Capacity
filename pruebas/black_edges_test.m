%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Text to paint black rectangles to simulate a smaller window
%
% Created 02/10/2025
% Author Federico Ramè´ørez Toraè´–o
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear
close all
sca;

addpath('..\\functions');

% Define a smaller window rect: [left top right bottom]
win = [];
[win.onScreen, windowRect] = Screen('OpenWindow', 0, [128 128 128]);


% Get screen dimensions
[win.screenX, win.screenY] = Screen('WindowSize', win.onScreen);

draw_screen_mask(win);


#% Black color
#black = BlackIndex(win.onScreen);
#
#% Define rectangles
#% Top bar
#topRect    = [0, 0, win.screenX, 98];
#
#% Bottom bar
#bottomRect = [0, 982, win.screenX, win.screenY];
#
#% Left bar
#leftRect   = [0, 98, 514, 982];
#
#% Right bar
#rightRect  = [1406, 98, win.screenX, 982];
#
#
#
##% Draw them
#Screen('FillRect', win.onScreen, black, topRect);
#Screen('FillRect', win.onScreen, black, bottomRect);
#Screen('FillRect', win.onScreen, black, leftRect);
#Screen('FillRect', win.onScreen, black, rightRect);

% Flip to screen
Screen('Flip', win.onScreen);

% Wait for key press
KbStrokeWait;

% Close window
sca;
