function draw_screen_mask(win)

% Black color
black = BlackIndex(win.onScreen);

% Define rectangles
% Top bar
topRect    = [0, 0, win.screenX, 98];

% Bottom bar
bottomRect = [0, 982, win.screenX, win.screenY];

% Left bar
leftRect   = [0, 98, 514, 982];

% Right bar
rightRect  = [1406, 98, win.screenX, 982];



% Draw them
Screen('FillRect', win.onScreen, black, topRect);
Screen('FillRect', win.onScreen, black, bottomRect);
Screen('FillRect', win.onScreen, black, leftRect);
Screen('FillRect', win.onScreen, black, rightRect);



end
