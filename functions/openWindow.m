function win = openWindow(prefs) % open up the window!

win.screenNumber = prefs.screenNumber;

if prefs.windowed

    % Get the screen resolution
    [screenWidth, screenHeight] = Screen('WindowSize', win.screenNumber);

    % Define desired window size (┬╝ of screen)
    winWidth = round(screenWidth / 2);
    winHeight = round(screenHeight / 2);

    % Position: left-center of the screen
    left = 0;
    top = round((screenHeight - winHeight) / 2);
    right = left + winWidth;
    bottom = top + winHeight;

    % Build the window rectangle
    winRect = [left, top, right, bottom];

    % Open the window in that position and size
    [win.onScreen, rect] = Screen('OpenWindow', win.screenNumber, [128 128 128], winRect);
    win.screenX = winWidth;
    win.screenY = winHeight;
    win.screenRect = winRect;
    win.centerX = win.screenX/2; % center of screen in X direction
    win.centerY = win.screenY/2; % center of screen in Y direction
    win.centerXL = floor(mean([0 win.centerX]/2)); % center of left half of screen in X direction
    win.centerXR = floor(mean([win.centerX win.screenX]/2)); % center of right half of screen in X direction
        % % Compute foreground and fixation rectangles
    win.foreRect = round(win.screenRect./1.35);
    win.foreRect = CenterRect(win.foreRect,win.screenRect);

else

    % Open a gray windows
    [win.onScreen rect] = Screen('OpenWindow', win.screenNumber, [128 128 128],[],[],[],[]);
    [win.screenX, win.screenY] = Screen('WindowSize', win.onScreen); % check resolution (pixel)
    win.screenRect  = [0 0 win.screenX win.screenY]; % screen rect

    % === Define the central visible area (replace numbers with your case: 12бы or 14бы) ===
    win.visibleRect = [580 162 1340 918];   % <-- or [514 98 1406 982] for 14бы

    % === Redefine centers relative to visibleRect ===
    win.centerX = mean([win.visibleRect(1) win.visibleRect(3)]); % center X of visible window
    win.centerY = mean([win.visibleRect(2) win.visibleRect(4)]); % center Y of visible window

    % Optional: centers of halves relative to visible area
    win.centerXL = floor(mean([win.visibleRect(1) win.centerX]));
    win.centerXR = floor(mean([win.centerX win.visibleRect(3)]));

    % === Foreground and fixation rectangles ===
    % Instead of scaling by full screen, scale inside visible area:
    win.foreRect = round(win.visibleRect ./ 1.35);
    win.foreRect = CenterRect(win.foreRect, win.visibleRect);

    HideCursor; % hide the cursor since we're not debugging
end

Screen('BlendFunction', win.onScreen, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% basic drawing and screen variables
win.black    = BlackIndex(win.onScreen);
win.white    = WhiteIndex(win.onScreen);
win.gray     = mean([win.black win.white]);
win.backColor = win.gray;
win.foreColor = win.gray;

%%% 9 colors mat
win.colors_9 = [255 0 0; ... % red
    0 255 0; ...% green
    0 0 255; ...% blue
    255 255 0; ... % yellow
    255 0 255; ... % magenta
    0 255 255; ... % cyan
    255 255 255; ... % white
    1 1 1; ... %black
    255 128 0]; % orange!

%%%% 7 colors mat
win.colors_7 = [255 0 0;... % red
    0 255 0;... %green
    0 0 255;... % blue
    255 255 0;... % yellow
    255 0 255; ... % magenta
    255 255 255;... % white
    0 0 0]; % black

win.fontsize = 24;

% make a dummy call to GetSecs to load the .dll before we need it
dummy = GetSecs; clear dummy;
end
