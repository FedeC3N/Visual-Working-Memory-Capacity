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
function ChangeDetection_Color_Function(p,win,stim,prefs)

%----------------------------------------------------
% Get screen params, build the display
%----------------------------------------------------
commandwindow; % select the command win to avoid typing in open scripts
%ListenChar(2); % don't print things in the command window
HideCursor;

% set the random state to the random seed at the beginning of the experiment!!
rng(p.rndSeed);

%  Put up instructions
instruct(win)

%---------------------------------------------------
% Begin Block loop
%---------------------------------------------------
%%%%%%% TRIGGER START %%%%%%%
tStart_experiment = tic;
send_parallel_trigger(p.parallel_port, 4);
stim.triggers.block(end+1) = 1;
stim.triggers.trial(end+1) = 1;
stim.triggers.value(end+1) = 4;
stim.triggers.onset(end+1) = toc(tStart_experiment);

for b = 1:prefs.numBlocks

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

        % Characteristics of the current trial
        nItems = stim.setSize(t,b);
        change = stim.change(t,b);

        % Select the colors
        win.colors = win.colors_9;
        if nItems>8
            win.colors = repmat(win.colors_9,2,1);
        end

        % compute and grab a random index into the color matrix
        colorIndex = randperm(size(win.colors,1));

        % calculate the stimulus locations for this trial!
        %%% centroid coordinates for all items!!
        [xPos,yPos] = getStimLocs(prefs,win,nItems);

        %%%% save the locations of ALL items!!!!
        stim.itemLocs{t,b} = [xPos;yPos];
        stim.itemColors{t,b} = colorIndex(1:nItems);

        % ITI screen
        Screen('FillRect',win.onScreen,win.foreColor,win.foreRect);      % Draw the foreground win
        Screen('FillOval',win.onScreen,win.black,win.fixRect);           % Draw the fixation point
        Screen('DrawingFinished',win.onScreen);                          % Tell ptb we're done drawing for the moment (makes subsequent flip command execute faster)
        Screen('Flip',win.onScreen);

        %%%%%%% TRIGGER ITI %%%%%%%
        send_parallel_trigger(p.parallel_port, 8);
        stim.triggers.block(end+1) = b;
        stim.triggers.trial(end+1) = t;
        stim.triggers.value(end+1) = 8;
        stim.triggers.onset(end+1) = toc(tStart_experiment);

        % Wait the fixation interval
        WaitSecs(prefs.ITI);

        % Draw squares on the main win
        Screen('FillRect',win.onScreen,win.foreColor,win.foreRect);            % Draw the foreground win
        Screen('FillOval',win.onScreen,win.black,win.fixRect);           % Draw the fixation point
        for i = 1:nItems
            Screen('FillRect',win.onScreen,win.colors(colorIndex(i),:),[(xPos(i)-prefs.stimSize/2),(yPos(i)-prefs.stimSize/2),(xPos(i)+prefs.stimSize/2),(yPos(i)+prefs.stimSize/2)]);
        end
        Screen('DrawingFinished',win.onScreen);
        Screen('Flip',win.onScreen);

        %%%%%%% TRIGGER MEMORY ARRAY %%%%%%%
        send_parallel_trigger(p.parallel_port, 16);
        stim.triggers.block(end+1) = b;
        stim.triggers.trial(end+1) = t;
        stim.triggers.value(end+1) = 16;
        stim.triggers.onset(end+1) = toc(tStart_experiment);

        % Wait the sample duration, then wipe the screen
        WaitSecs(prefs.stimulusDuration);

        % Retention
        Screen('FillRect',win.onScreen,win.foreColor,win.foreRect);            % Draw the foreground win
        Screen('FillOval',win.onScreen,win.black,win.fixRect);           % Draw the fixation point
        Screen('DrawingFinished',win.onScreen);
        Screen('Flip',win.onScreen);

        %%%%%%% TRIGGER Retention %%%%%%%
        send_parallel_trigger(p.parallel_port, 24);
        stim.triggers.block(end+1) = b;
        stim.triggers.trial(end+1) = t;
        stim.triggers.value(end+1) = 24;
        stim.triggers.onset(end+1) = toc(tStart_experiment);

        % wait the ISI
        WaitSecs(prefs.retentionInterval);

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

        % Draw a new square on the screen, with the color value determined
        % by whether it's a change trial or not
        Screen('FillRect',win.onScreen,win.foreColor,win.foreRect);            % Draw the foreground win
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
        Screen('Flip',win.onScreen);

        %%%%%%% TRIGGER Presentation Same / Presentation Different %%%%%%%
        if change == 0
          send_parallel_trigger(p.parallel_port, 32);
          stim.triggers.value(end+1) = 32;

        else
          send_parallel_trigger(p.parallel_port, 40);
          stim.triggers.value(end+1) = 40;
        end
        stim.triggers.block(end+1) = b;
        stim.triggers.trial(end+1) = t;
        stim.triggers.onset(end+1) = toc(tStart_experiment);

        % Wait for a response
        rtStart = GetSecs;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % BORRAR

        % Creo respuesta automática
        response = rand();
        if response > 0.5
          kp =  prefs.keys.different_color;
        else
          kp =  prefs.keys.same_color;
        endif
        pause(response);

        %%%%%%% TRIGGER Answer Same / Answer Different %%%%%%%
        if kp == prefs.keys.same_color
          send_parallel_trigger(p.parallel_port, 1);
          stim.triggers.value(end+1) = 1;
        elseif kp == prefs.keys.different_color
          send_parallel_trigger(p.parallel_port, 2);
          stim.triggers.value(end+1) = 2;
        end
        stim.triggers.block(end+1) = b;
        stim.triggers.trial(end+1) = t;
        stim.triggers.onset(end+1) = toc(tStart_experiment);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % RESTABLECER

##        while KbCheck; end;
##
##        % Check the answer
##        while 1
##
##            % Check the keyboard
##            [keyIsDown,secs,keyCode]=KbCheck;
##
##            if keyIsDown
##
##                % if escape is pressed, bail out
##                if keyCode(prefs.keys.escape)
##
##                    %ListenChar(0);
##
##                    % save data file at the end of each block
##                    save(p.fileName,'p','stim','prefs');
##
##                    Screen('CloseAll');
##
##                    return;
##
##                end
##
##                % Get the code
##                kp = find(keyCode);
##
##                % Some keys (as Control) have two numbers. The important
##                % one is the second
##                if numel(kp) > 1
##                    kp = kp(2);
##                end
##
##                % Only consider the answer buttons
##                if kp == prefs.keys.different_color || kp == prefs.keys.same_color % previously 90/191, PC
##
##                    stim.response(t,b)=kp;
##                    rtEnd = GetSecs;
##                    stim.rt(t,b) = rtEnd-rtStart;
##
##                    %%%%%%% TRIGGER Answer Same / Answer Different %%%%%%%
##                    if kp == prefs.keys.same_color
##                      send_parallel_trigger(p.parallel_port, 1);
##                      stim.triggers.value(end+1) = 1;
##                    elseif kp == prefs.keys.different_color
##                      send_parallel_trigger(p.parallel_port, 2);
##                      stim.triggers.value(end+1) = 2;
##                    end
##                    stim.triggers.block(end+1) = b;
##                    stim.triggers.trial(end+1) = t;
##                    stim.triggers.onset(end+1) = toc(tStart_experiment);
##
##                    break
##
##                end
##            end
##        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Draw a empty screen with a fixation point again
        Screen('FillRect',win.onScreen,win.foreColor,win.foreRect);            % Draw the foreground win
        Screen('FillOval',win.onScreen,win.black,win.fixRect);           % Draw the fixation point
        Screen('DrawingFinished',win.onScreen);
        Screen('Flip',win.onScreen);


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

        %%%%%%% TRIGGER Break %%%%%%%
        send_parallel_trigger(p.parallel_port, 128);
        stim.triggers.block(end+1) = b;
        stim.triggers.trial(end+1) = t;
        stim.triggers.value(end+1) = 128;
        stim.triggers.onset(end+1) = toc(tStart_experiment);

        % Plot the message
        Screen('TextSize',win.onScreen,120);
        Screen('TextFont',win.onScreen,'Arial');
        Text1 = 'DESCANSO';
        DrawFormattedText(win.onScreen, Text1, 'center',win.centerY-150,win.white);

        Screen('TextSize',win.onScreen,32);
        Text2 = ['Bloque ',num2str(b),' de ',num2str(prefs.numBlocks),' completado.'];
        DrawFormattedText(win.onScreen, Text2, 'center',win.centerY,win.white);

        Screen('TextSize',win.onScreen,32);
        Text2 = 'Pulse "espacio" para empezar un nuevo bloque.';
        DrawFormattedText(win.onScreen, Text2, 'center',win.centerY+50,win.white);

        Screen('Flip', win.onScreen);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % BORRAR
        pause(30);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % RESTABLECER

        % Wait for a spacebar press to continue with next block
##        while 1
##            [keyIsDown,secs,keyCode]=KbCheck;
##            if keyIsDown
##                kp = find(keyCode);
##                if numel(kp) > 1
##                    kp = kp(2);
##                end
##                if kp == prefs.keys.space
##                    break;
##                end
##            end
##        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end

    if b == prefs.numBlocks

        %%%%%%% TRIGGER End %%%%%%%
        send_parallel_trigger(p.parallel_port, 252);
        stim.triggers.block(end+1) = b;
        stim.triggers.trial(end+1) = t;
        stim.triggers.value(end+1) = 252;
        stim.triggers.onset(end+1) = toc(tStart_experiment);

        % Plot the message
        Screen('TextSize',win.onScreen,60);
        Screen('TextFont',win.onScreen,'Arial');
        Text1 = '¡El experimento ha terminado!';
        DrawFormattedText(win.onScreen, Text1, 'center',win.centerY-50,win.white);

        Screen('TextSize',win.onScreen,32);
        Text2 = 'Por favor, avise al investigador.';
        DrawFormattedText(win.onScreen, Text2, 'center',win.centerY+50,win.white);

        Screen('Flip', win.onScreen);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % BORRAR
        pause(30);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % RESTABLECER

        % Wait for a spacebar press to continue with next block
##        while 1
##            [keyIsDown,secs,keyCode]=KbCheck;
##            if keyIsDown
##                kp = find(keyCode);
##                if numel(kp) > 1
##                    kp = kp(2);
##                end
##                if kp == prefs.keys.space
##                    break;
##                end
##            end
##        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end


end    % end of the block loop


end

