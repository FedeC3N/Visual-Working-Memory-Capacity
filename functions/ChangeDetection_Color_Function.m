%-------------------------------------------------------------------------
% PTB3 implementation of a color change detection task following Luck &
% Vogel (1997).
% Programmed by Kirsten Adam 2012 (updated June 2014)
%
%  "change" is "m", "no change" = "z" key
%
%  RECENT UPDATES: 
%   - added text reminder of key mapping that stays on the screen 
%
%  OPTIONS:
%  p.multiColor: randomly chooses some far-apart colors on the colorwheel! this way, we
%  can make sure that the colors aren't easily memorizable but "highly"
%  discriminable (NOTE: you can change prefs.minColorDist for a minimum
%  distance between the colors in the array, and you can change when repeat
%  colors are allowed)
%-------------------------------------------------------------------------
function ChangeDetection_Color_Function(p,win,prefs)

%----------------------------------------------------
% Get screen params, build the display
%----------------------------------------------------
commandwindow; % select the command win to avoid typing in open scripts
% ListenChar(2); % don't print things in the command window
HideCursor; 

% set the random state to the random seed at the beginning of the experiment!!
rng(p.rndSeed); 

% set up fixation point rect (b/c uses both prefs and win)
win.fixRect = [(win.centerX - prefs.fixationSize),(win.centerY - prefs.fixationSize), ...
    (win.centerX  + prefs.fixationSize), (win.centerY + prefs.fixationSize)];


%-------------------------------------------------------------------------
% Port Settings - % booth 1 p.portCodes: event DCC8 / response
if p.portCodes
    event_port = ['DCC8'];
    response_port = ['DCD8'];
end


%--------------------------------------------------------
% Preallocate some variable structures! :)
%--------------------------------------------------------
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

% stim.itemLocs is a cell structure that will save the locations (centroids
% of all items. stim.itemLocs{trialNumber,blockNumber} = [xloc1 xloc2 ....; yloc1, yloc2 ...];
% stim.itemColors is a cell structure taht identifies the color of each
% item. stim.itemColors{trialNumber,blockNumber} = [col1,col2...]. To
% identify the RGB value, find the matching row in stim.colorList.
%---------------------------------------------------


%  Put up instructions
instruct(win)

%%%%%%% PUT-TRIGGER %%%%%%% 
%


%--------------------------------s-------------------
%  if multiColor, pick out new colors from the colorwheel
%---------------------------------------------------
if p.multiColor
    %%%%% colorwheel details
    prefs.originalcolorwheel = load('colorwheel360.mat', 'fullcolormatrix');
    prefs.originalcolorwheel = prefs.originalcolorwheel.fullcolormatrix;
    % pick colors for all trials! because if not NOW ..
    for blocks = 1:prefs.numBlocks
        for trials = 1:prefs.numTrials
            prefs.color(trials,1,blocks) = ceil(rand(1,1)*360);
            remainingcolors = 1:360;
            for c = 2:6
                prefs.minColorDist = 29;  % the minimum distance (in degrees) that the second color is from the first. 40 = around 2 sd's for set size 2, usually.
                greater = prefs.color(trials,c-1,blocks)+prefs.minColorDist;
                lesser = prefs.color(trials,c-1,blocks)-prefs.minColorDist;
                if greater>360
                    greater = greater-360;
                end
                if lesser<0
                    lesser = lesser+360;
                end
                remainingcolors = remainingcolors(remainingcolors<lesser|remainingcolors>greater);
                prefs.color(trials,c,blocks) = RandSample(remainingcolors);
            end
        end
    end
   
end


%---------------------------------------------------
% Begin Block loop
%---------------------------------------------------
for b = 1:prefs.numBlocks
    
    if p.multiColor
        blockColor = squeeze(prefs.color(:,:,b));
    end
    
    %%%% pick out the order of trials for this block, based on
    %%%% full Factorial Design
    prefs.order(:,b) = Shuffle(1:prefs.numTrials);
    stim.setSize(:,b) = prefs.setSizes(prefs.fullFactorialDesign(prefs.order(:,b), 1));
    stim.change(:,b) = prefs.change(prefs.fullFactorialDesign(prefs.order(:,b),2));
    
    % save the color list!! for later use!!!
    stim.colorList = repmat(win.colors_9,2,1);
    %-------------------------------------------------------
    % Begin Trial Loop
    %-------------------------------------------------------
    for t = 1:prefs.numTrials
        %--------------------------------------------------------
        % Figure out the conditions for this  trial!
        %--------------------------------------------------------
        nItems = stim.setSize(t,b);
        change = stim.change(t,b);
        
        if p.multiColor
            %--------------------------------------------------------
            % pick out colors if we're using the colorwheel.
            %--------------------------------------------------------
            win.colors = prefs.originalcolorwheel(blockColor(t,:),:);
            if nItems>= 4 % only duplicate the matrix if we've got  or more items
                win.colors = repmat(win.colors,2,1); % duplicate and concatenate the win.colors matrix.
            end
        else
            win.colors = win.colors_9;
            if nItems>8
                win.colors = repmat(win.colors_9,2,1);
            end
        end
        %--------------------------------------------------------
        % Create and flip up the basic stimulus display
        %--------------------------------------------------------
        Screen('FillRect',win.onScreen,win.foreColor,win.foreRect);      % Draw the foreground win
        
        if p.showInstruct
            textSize = 18; 
            showInstructText = ['Si el color es el mismo, pulse "z".\n'...
                'Si el color es diferente, pulse "m". \n'];
            Screen('TextSize', win.onScreen, textSize); % 24 = number pixels
            DrawFormattedText(win.onScreen, showInstructText,win.centerX-150,15,win.white); 
        end
        Screen('FillOval',win.onScreen,win.black,win.fixRect);           % Draw the fixation point
        Screen('DrawingFinished',win.onScreen);                          % Tell ptb we're done drawing for the moment (makes subsequent flip command execute faster)
        Screen('Flip',win.onScreen);                                     % Flip all the stuff we just drew onto the main display
        
        % compute and grab a random index into the color matrix
        colorIndex = randperm(size(win.colors,1));
        
        % calculate the stimulus locations for this trial!
        %%% centroid coordinates for all items!!
        [xPos,yPos] = getStimLocs(prefs,win,nItems);
        
        %%%% save the locations of ALL items!!!!
        stim.itemLocs{t,b} = [xPos;yPos];
        stim.itemColors{t,b} = colorIndex(1:nItems);
        
        if p.portCodes  % trial is starting block Code!
            %         Baseline period begins... 99 = after click, ITI begins
            write_parallel(event_port,99);
        end
        
        % Wait the fixation interval
        %         Screen('WaitBlanking',win.onScreen,prefs.ITI); % for old
        %         method with refresh rate
        WaitSecs(prefs.ITI); %
        
        if p.portCodes  % send some block and trial codes
            write_parallel(event_port,blockIndex+200);
            
            WaitSecs(.1);
            
            write_parallel(event_port,trialIndex+100);
        end
        
        % Draw squares on the main win
        Screen('FillRect',win.onScreen,win.foreColor,win.foreRect);            % Draw the foreground win
        if p.showInstruct
            DrawFormattedText(win.onScreen, showInstructText,win.centerX-150,15,win.white); 
        end
        Screen('FillOval',win.onScreen,win.black,win.fixRect);           % Draw the fixation point
        for i = 1:nItems
            Screen('FillRect',win.onScreen,win.colors(colorIndex(i),:),[(xPos(i)-prefs.stimSize/2),(yPos(i)-prefs.stimSize/2),(xPos(i)+prefs.stimSize/2),(yPos(i)+prefs.stimSize/2)]);
        end
        Screen('DrawingFinished',win.onScreen);
        
        if p.portCodes % items appear port Code
            write_parallel(event_port,40+nItems);
        end
        Screen('Flip',win.onScreen);
        
        % Wait the sample duration, then wipe the screen
        %         Screen('WaitBlanking',win.onScreen,prefs.stimulusDuration);
        WaitSecs(prefs.stimulusDuration); % stimulus Dur + retention, since not a memory task ...
        Screen('FillRect',win.onScreen,win.foreColor,win.foreRect);            % Draw the foreground win
        if p.showInstruct       
            DrawFormattedText(win.onScreen, showInstructText,win.centerX-150,15,win.white); 
        end
        Screen('FillOval',win.onScreen,win.black,win.fixRect);           % Draw the fixation point
        Screen('DrawingFinished',win.onScreen);
        Screen('Flip',win.onScreen);
        
        %------------------------------------------------------------------
        % Figure out the change stuff
        %------------------------------------------------------------------
        changeIndex = randperm(nItems);
        changeLocX = xPos(changeIndex(1)); changeLocY = yPos(changeIndex(1));
        
        sColor = colorIndex(changeIndex(1));  % sColor is the square-of-interest's color if NOT a change condition!
        
        % is this loop making sure it doesn't "change" to the same color???
        % why is it breaking??
        
        if sColor > 6
            sColor2 = sColor - 6;
        elseif sColor < 7
            sColor2 = sColor + 6;
        end
        
        % this makes sure that the index chosen for the change color does
        % NOT equal the original color???
        while 1
            ind = randi(length(colorIndex));
            if ind ~= sColor && ind ~= sColor2
                break;
                % we WANT to break out of the while loop as soon as we
                %               % find an index for a color that is different from the one
                %               shown!!
            end
        end
        changeColor = win.colors(ind,:); % now we use the index to pick the change color!
        
        % wait the ISI
        %         Screen('WaitBlanking',win.onScreen,prefs.retentionInterval); % this   method uses frame rate instead ...
        WaitSecs(prefs.retentionInterval); % stimulus Dur + retention, since not a memory task ...
        
        % Draw a new square on the screen, with the color value determined
        % by whether it's a change trial or not
        Screen('FillRect',win.onScreen,win.foreColor,win.foreRect);            % Draw the foreground win
        if p.showInstruct
            DrawFormattedText(win.onScreen, showInstructText,win.centerX-150,15,win.white); 
        end
        Screen('FillOval',win.onScreen,win.black,win.fixRect);           % Draw the fixation point
        if change == 1
            Screen('FillRect',win.onScreen,changeColor,[(changeLocX-prefs.stimSize/2),(changeLocY-prefs.stimSize/2),(changeLocX+prefs.stimSize/2),(changeLocY+prefs.stimSize/2)]); 
            stim.probeColor(t,b) = ind;
            stim.probeLoc(t,b,:) = [changeLocX,changeLocY];
        else
            Screen('FillRect',win.onScreen,win.colors(sColor,:),[(changeLocX-prefs.stimSize/2),(changeLocY-prefs.stimSize/2),(changeLocX+prefs.stimSize/2),(changeLocY+prefs.stimSize/2)]);
            stim.probeColor(t,b) = sColor;
            stim.probeLoc(t,b,:) = [changeLocX,changeLocY];
        end
        
        stim.presentedColor(t,b) = sColor; 
        
        Screen('DrawingFinished',win.onScreen);
        
        if p.portCodes % end of retention, test square shown!!
            write_parallel(event_port,98);
        end
        Screen('Flip',win.onScreen);
        
        % Wait for a response
        rtStart = GetSecs;
        
        while KbCheck; end;
        
        % Check the answer
        while 1
            [keyIsDown,secs,keyCode]=KbCheck;
            if keyIsDown
                if keyCode(prefs.keys.escape)                              % if escape is pressed, bail out
                    ListenChar(0);
                    % save data file at the end of each block
                    save(p.fileName,'p','stim','prefs');
                    Screen('CloseAll');
                    return;
                end
                kp = find(keyCode);
                if numel(kp) > 1
                    kp = kp(2);
                end
                if kp== prefs.keys.different_color || kp== prefs.keys.same_color % previously 90/191, PC
                    stim.response(t,b)=kp;
                    rtEnd = GetSecs;
                    break
                end
            end
        end
        
        Screen('FillRect',win.onScreen,win.foreColor,win.foreRect);            % Draw the foreground win
        if p.showInstruct
            DrawFormattedText(win.onScreen, showInstructText,win.centerX-150,15,win.white); 
        end
        Screen('FillOval',win.onScreen,win.black,win.fixRect);           % Draw the fixation point
        Screen('DrawingFinished',win.onScreen);
        if p.portCodes % port code for response made!
            write_parallel(response_port,10);
        end
        Screen('Flip',win.onScreen);
        stim.rt(t,b) = rtEnd-rtStart;
        
        % Check accuracy
        if change == 1
            if stim.response(t,b) == prefs.keys.different_color
                stim.accuracy(t,b)=1;
            else
                stim.accuracy(t,b)=0;
            end
        else
            if stim.response(t,b) == prefs.keys.same_color 
                stim.accuracy(t,b)=1;
            else
                stim.accuracy(t,b)=0;
            end
        end
        
    end    % end of trial loop
    
    % save data file at the end of each block
    save(p.fileName,'p','stim','prefs');
    
    % tell subjects that they've finished the current block / the experiment
    if b<prefs.numBlocks
        
        
        Screen('TextSize',win.onScreen,60);
        Screen('TextFont',win.onScreen,'Arial');
        Screen(win.onScreen, 'DrawText', 'DESCANSO', win.centerX-170, win.centerY-200);
        Screen('TextSize',win.onScreen,32);
        Screen(win.onScreen, 'DrawText', ['Bloque ',num2str(b),' de ',num2str(prefs.numBlocks),' completado.'], win.centerX-200, win.centerY, [255 255 255]);
        
        Screen(win.onScreen, 'DrawText', 'Pulse "espacio" para empezar un nuevo bloque.', win.centerX-320, win.centerY+50, [255 255 255]);
        Screen('TextSize',win.onScreen,32);
        Screen('Flip', win.onScreen);
        
        % Wait for a spacebar press to continue with next block
        while 1
            [keyIsDown,secs,keyCode]=KbCheck;
            if keyIsDown
                kp = find(keyCode);
                if numel(kp) > 1
                    kp = kp(2);
                end
                if kp == prefs.keys.space
                    break;
                end
            end
        end
        
    end
    
    if b == prefs.numBlocks
        
        Screen('TextSize',win.onScreen,32);
        Screen('TextFont',win.onScreen,'Arial');
        Screen(win.onScreen, 'DrawText', '¡El experimento ha terminado!', win.centerX-250, win.centerY-20, [255 255 255]);
        Screen('TextSize',win.onScreen,24);
        Screen(win.onScreen, 'DrawText', 'Por favor, avise al investigador.', win.centerX-200, win.centerY+20, [255 255 255]);
        Screen('Flip', win.onScreen);
        
        % Wait for a spacebar press to continue with next block
        while 1
            [keyIsDown,secs,keyCode]=KbCheck;
            if keyIsDown
                kp = find(keyCode);
                if numel(kp) > 1
                    kp = kp(2);
                end
                if kp == prefs.keys.space
                    break;
                end
            end
        end
        
    end
    
    

    if p.portCodes % port code for space pressed to begin next block!
        write_parallel(response_port,30);
    end
    
end    % end of the block loop

% % pack up and go home
% Screen('CloseAll');
% ShowCursor;
end



%-------------------------------------------------------------------------
%  ADDITIONAL FUNCTIONS EMBEDDED IN SCRIPT !!
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function [xPos,yPos] = getStimLocs(prefs,win,nItems)
% segment the inner window into four quadrants - for xCoords, 1st
% row = positions in left half of display, 2nd row = right half.
% For yCoords - 1st row = top half, 2nd row = bottom half
xCoords = [linspace((win.foreRect(1)+prefs.stimSize),win.centerX-prefs.stimSize,300); linspace(win.centerX+prefs.stimSize,(win.foreRect(3)-prefs.stimSize),300)];
yCoords = [linspace((win.foreRect(2)+prefs.stimSize),win.centerY-prefs.stimSize,300); linspace(win.centerY+prefs.stimSize,(win.foreRect(4)-prefs.stimSize),300)];
xLocInd = randperm(size(xCoords,2)); yLocInd = randperm(size(yCoords,2));

% Pick x,y coords for drawing stimuli on this trial, making sure
% that all stimuli are seperated by >= prefs.minDist
if nItems ==1
    xPos = [xCoords(randi(2),xLocInd(1))];  % pick randomly from first and second x rows (L/R halves)
    yPos = [yCoords(randi(2),yLocInd(1))];  % pick randomly from first and second y rows (Top/Bottom).
elseif nItems ==2
    randomPosition = randi(2);
    if randomPosition == 1
        xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2))]; % pick one left and one right item
        yPos = [yCoords(randi(2),yLocInd(1)),yCoords(randi(2),yLocInd(2))]; % pick randomly, top or bottom
    else
        xPos = [xCoords(randi(2),xLocInd(1)),xCoords(randi(2),xLocInd(2))]; % pick randomly, left or right!
        yPos = [yCoords(1,yLocInd(1)),yCoords(2,yLocInd(2))]; % pick one top, one bottom!
    end
elseif nItems ==3
    xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4))]; % one L one R
    yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4))]; % one top one bottom for e/ L/R
    % let's use the same scheme as 4 items, but randomly leave one
    % out!
    randomOrder = randperm(4);
    xPos = xPos(randomOrder(1:3));
    yPos = yPos(randomOrder(1:3));
elseif nItems ==4
    xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4))]; % one L one R
    yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4))]; % one top one bottom for e/ L/R
elseif nItems ==5
    randomPosition = randi(2); % pick one of two quadrants to stick the second item
    while 1
        if randomPosition == 1
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(1,xLocInd(5))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt(abs(xPos(1)-xPos(5))^2+abs(yPos(1)-yPos(5))^2)>prefs.minDist
                %             if sqrt((xPos(2)-xPos(6))^2+(yPos(2)-yPos(6))^2)>prefs.minDist
                break;
            end
        elseif randomPosition == 2
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(2,xLocInd(5))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt((xPos(2)-xPos(5))^2+(yPos(2)-yPos(5))^2)>prefs.minDist
                break;
            end
        end
    end
elseif nItems ==6
    randomPosition = randi(2); % put extra squares in top or bottom half;
    while 1
        if randomPosition == 1
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(1,xLocInd(5)),xCoords(2,xLocInd(6))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5)),yCoords(1,yLocInd(6))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt(abs(xPos(1)-xPos(5))^2+abs(yPos(1)-yPos(5))^2)>prefs.minDist
                if sqrt((xPos(2)-xPos(6))^2+(yPos(2)-yPos(6))^2)>prefs.minDist
                    break;
                end
            end
        else
            xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
            xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(1,xLocInd(5)),xCoords(2,xLocInd(6))];
            yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(2,yLocInd(5)),yCoords(2,yLocInd(6))];
            % make sure that w/in quadrant points satisfy the minimum
            % distance requirement
            if sqrt(abs(xPos(3)-xPos(5))^2+abs(yPos(3)-yPos(5))^2)>prefs.minDist
                if sqrt((xPos(4)-xPos(6))^2+(yPos(4)-yPos(6))^2)>prefs.minDist
                    break;
                end
            end
        end
    end
elseif nItems == 8
    while 1
        xLocInd = Shuffle(xLocInd); yLocInd = Shuffle(yLocInd);
        xPos = [xCoords(1,xLocInd(1)),xCoords(2,xLocInd(2)),xCoords(1,xLocInd(3)),xCoords(2,xLocInd(4)),xCoords(1,xLocInd(5)),xCoords(2,xLocInd(6)),xCoords(1,xLocInd(7)),xCoords(2,xLocInd(8))];
        yPos = [yCoords(1,yLocInd(1)),yCoords(1,yLocInd(2)),yCoords(2,yLocInd(3)),yCoords(2,yLocInd(4)),yCoords(1,yLocInd(5)),yCoords(1,yLocInd(6)),yCoords(2,yLocInd(7)),yCoords(2,yLocInd(8))];
        % make sure that w/in quadrant points satisfy the minimum
        % distance requirement
        if sqrt(abs(xPos(1)-xPos(5))^2+abs(yPos(1)-yPos(5))^2)>prefs.minDist
            if sqrt((xPos(2)-xPos(6))^2+(yPos(2)-yPos(6))^2)>prefs.minDist
                if sqrt((xPos(3)-xPos(7))^2+(yPos(3)-yPos(7))^2)>prefs.minDist
                    if sqrt((xPos(4)-xPos(8))^2+(yPos(4)-yPos(8))^2)>prefs.minDist
                        break;
                    end
                end
            end
        end
    end
end

end

