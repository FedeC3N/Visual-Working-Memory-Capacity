%-------------------------------------------------------------------------
% PTB3 implementation of a color change detection task following Luck &
% Vogel (1997).
% Programmed by Kirsten Adam 2012 (updated June 2014)
%
%  "change" is "Ctrl Left", "no change" = "Control Right" key
%
%  RECENT UPDATES:
%   - added text reminder of key mapping that stays on the screen
%
%-------------------------------------------------------------------------
function ChangeDetection_Color_Function(prefs,win,stim)

    %----------------------------------------------------
    % Get screen params, build the display
    %----------------------------------------------------
    commandwindow; % select the command win to avoid typing in open scripts
    %ListenChar(2); % don't print things in the command window
    HideCursor;

    % set the random state to the random seed at the beginning of the experiment!!
    rng(prefs.rndSeed);

    instruct(win)

    %---------------------------------------------------
    % Begin Block loop
    %---------------------------------------------------
    %%%%%%% TRIGGER START %%%%%%%
    tStart_experiment = tic;
    send_trigger(prefs.parallel_port, 8);
    stim.triggers.block(end+1) = 1;
    stim.triggers.trial(end+1) = 1;
    stim.triggers.value(end+1) = 8;
    stim.triggers.onset(end+1) = toc(tStart_experiment);

    for b = 1:prefs.numBlocks

        % pick out the order of trials for this block
        prefs.order(:,b) = Shuffle(1:prefs.numTrials);
        stim.setSize(:,b) = prefs.setSizes(prefs.fullFactorialDesign(prefs.order(:,b),1));
        stim.change(:,b)  = prefs.change(prefs.fullFactorialDesign(prefs.order(:,b),2));

        % save the color list
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
            if nItems > 8
                win.colors = repmat(win.colors_9,2,1);
            end

            % random index into the color matrix
            colorIndex = randperm(size(win.colors,1));

            % stimulus locations
            [xPos,yPos] = getStimLocs(prefs,win,nItems);

            % save locations and colors
            stim.itemLocs{t,b}   = [xPos;yPos];
            stim.itemColors{t,b} = colorIndex(1:nItems);

            % ITI screen
            draw_screen_mask(win);
            Screen('FillOval',win.onScreen,win.black,win.fixRect);
            Screen('DrawingFinished',win.onScreen);
            Screen('Flip',win.onScreen);

            %%%%%%% TRIGGER ITI %%%%%%%
            send_trigger(prefs.parallel_port, 16);
            stim.triggers.block(end+1)  = b;
            stim.triggers.trial(end+1)  = t;
            stim.triggers.value(end+1)  = 16;
            stim.triggers.onset(end+1)  = toc(tStart_experiment);

            % fixation interval
            WaitSecs(prefs.ITI);

            % Draw sample squares
            draw_screen_mask(win);
            Screen('FillRect',win.onScreen,win.foreColor,win.foreRect);
            Screen('FillOval',win.onScreen,win.black,win.fixRect);
            for i = 1:nItems
                Screen('FillRect',win.onScreen, ...
                    win.colors(colorIndex(i),:), ...
                    [(xPos(i)-prefs.stimSize/2), (yPos(i)-prefs.stimSize/2), ...
                    (xPos(i)+prefs.stimSize/2), (yPos(i)+prefs.stimSize/2)]);
            end
            Screen('DrawingFinished',win.onScreen);
            Screen('Flip',win.onScreen);

            %%%%%%% TRIGGER MEMORY ARRAY %%%%%%%
            send_trigger(prefs.parallel_port, 24);
            stim.triggers.block(end+1)  = b;
            stim.triggers.trial(end+1)  = t;
            stim.triggers.value(end+1)  = 24;
            stim.triggers.onset(end+1)  = toc(tStart_experiment);

            % Wait sample duration
            WaitSecs(prefs.stimulusDuration);

            % Retention
            draw_screen_mask(win);
            Screen('FillRect',win.onScreen,win.foreColor,win.foreRect);
            Screen('FillOval',win.onScreen,win.black,win.fixRect);
            Screen('DrawingFinished',win.onScreen);
            Screen('Flip',win.onScreen);

            %%%%%%% TRIGGER Retention %%%%%%%
            send_trigger(prefs.parallel_port, 32);
            stim.triggers.block(end+1)  = b;
            stim.triggers.trial(end+1)  = t;
            stim.triggers.value(end+1)  = 32;
            stim.triggers.onset(end+1)  = toc(tStart_experiment);

            % wait ISI
            WaitSecs(prefs.retentionInterval);

            %------------------------------------------------------------------
            % Change selection
            %------------------------------------------------------------------
            changeIndex = randperm(nItems);
            changeLocX  = xPos(changeIndex(1));
            changeLocY  = yPos(changeIndex(1));
            sColor      = colorIndex(changeIndex(1));

            if sColor > 6
                sColor2 = sColor - 6;
            else
                sColor2 = sColor + 6;
            end

            while 1
                ind = randi(length(colorIndex));
                if ind ~= sColor && ind ~= sColor2
                    break;
                end
            end
            changeColor = win.colors(ind,:);

            % Probe screen
            draw_screen_mask(win);
            Screen('FillRect',win.onScreen,win.foreColor,win.foreRect);
            Screen('FillOval',win.onScreen,win.black,win.fixRect);

            if change == 1
                Screen('FillRect',win.onScreen,changeColor, ...
                    [(changeLocX-prefs.stimSize/2),(changeLocY-prefs.stimSize/2), ...
                    (changeLocX+prefs.stimSize/2),(changeLocY+prefs.stimSize/2)]);
                stim.probeColor(t,b) = ind;
                stim.probeLoc(t,b,:) = [changeLocX,changeLocY];
            else
                Screen('FillRect',win.onScreen,win.colors(sColor,:), ...
                    [(changeLocX-prefs.stimSize/2),(changeLocY-prefs.stimSize/2), ...
                    (changeLocX+prefs.stimSize/2),(changeLocY+prefs.stimSize/2)]);
                stim.probeColor(t,b) = sColor;
                stim.probeLoc(t,b,:) = [changeLocX,changeLocY];
            end
            stim.presentedColor(t,b) = sColor;

            Screen('DrawingFinished',win.onScreen);
            Screen('Flip',win.onScreen);

            %%%%%%% TRIGGER Probe %%%%%%%
            if change == 0
                send_trigger(prefs.parallel_port, 40);
                stim.triggers.value(end+1) = 40;
            else
                send_trigger(prefs.parallel_port, 48);
                stim.triggers.value(end+1) = 48;
            end
            stim.triggers.block(end+1) = b;
            stim.triggers.trial(end+1) = t;
            stim.triggers.onset(end+1) = toc(tStart_experiment);

            % Wait for response
            rtStart = GetSecs;
            while KbCheck; end;

            while 1
                [keyIsDown,secs,keyCode] = KbCheck;

                %%%%%%%%%%%%%%% RESTABLECER
                keyIsDown = 1;

                if keyIsDown
                    % escape = exit
                    if keyCode(prefs.keys.escape)
                        save(prefs.fileName,'p','stim','prefs');
                        Screen('CloseAll');
                        return;
                    end

                    %%%%%%%%%%%%%%% RESTABLECER
#                    kp = find(keyCode);
                    kp = prefs.keys.different_color;
                    if numel(kp) > 1, kp = kp(2); end

                    if kp == prefs.keys.different_color || kp == prefs.keys.same_color
                        stim.response(t,b) = kp;
                        rtEnd = GetSecs;
                        stim.rt(t,b) = rtEnd - rtStart;

                        if kp == prefs.keys.same_color
                            send_trigger(prefs.parallel_port, 1);
                            stim.triggers.value(end+1) = 1;
                        else
                            send_trigger(prefs.parallel_port, 2);
                            stim.triggers.value(end+1) = 2;
                        end
                        stim.triggers.block(end+1) = b;
                        stim.triggers.trial(end+1) = t;
                        stim.triggers.onset(end+1) = toc(tStart_experiment);

                        break
                    end
                end
            end

            % fixation again
            draw_screen_mask(win);
            Screen('FillRect',win.onScreen,win.foreColor,win.foreRect);
            Screen('FillOval',win.onScreen,win.black,win.fixRect);
            Screen('DrawingFinished',win.onScreen);
            Screen('Flip',win.onScreen);

            % accuracy
            if change == 1
                stim.accuracy(t,b) = (stim.response(t,b) == prefs.keys.different_color);
            else
                stim.accuracy(t,b) = (stim.response(t,b) == prefs.keys.same_color);
            end

        end % trial loop

        % break or end block
        if b < prefs.numBlocks
            % Break screen
            send_trigger(prefs.parallel_port, 64);
            stim.triggers.block(end+1) = b;
            stim.triggers.trial(end+1) = t;
            stim.triggers.value(end+1) = 64;
            stim.triggers.onset(end+1) = toc(tStart_experiment);

            Screen('TextSize',win.onScreen,120);
            Screen('TextFont',win.onScreen,'Arial');
            DrawFormattedText(win.onScreen, 'DESCANSO', 'center',win.centerY-150,win.white);

            Screen('TextSize',win.onScreen,32);
            DrawFormattedText(win.onScreen, ...
                ['Bloque ',num2str(b),' de ',num2str(prefs.numBlocks),' completado.'], ...
                'center',win.centerY,win.white);

            DrawFormattedText(win.onScreen, ...
                'Pulse "espacio" para empezar un nuevo bloque.', ...
                'center',win.centerY+50,win.white);

            Screen('Flip', win.onScreen);

%%%%%%%%%%%%%%% RESTABLECER
#            while 1
#                [keyIsDown,secs,keyCode] = KbCheck;
#                if keyIsDown
#                    kp = find(keyCode);
#                    if numel(kp) > 1, kp = kp(2); end
#                    if kp == prefs.keys.space
#                        break;
#                    end
#                end
#            end

        else
            % End of experiment
            send_trigger(prefs.parallel_port, 72);
            stim.triggers.block(end+1) = b;
            stim.triggers.trial(end+1) = t;
            stim.triggers.value(end+1) = 72;
            stim.triggers.onset(end+1) = toc(tStart_experiment);

            Screen('TextSize',win.onScreen,60);
            Screen('TextFont',win.onScreen,'Arial');
            DrawFormattedText(win.onScreen, 'è¢¬El experimento ha terminado!', 'center',win.centerY-50,win.white);

            Screen('TextSize',win.onScreen,32);
            DrawFormattedText(win.onScreen, 'Por favor, avise al investigador.', 'center',win.centerY+50,win.white);
            Screen('Flip',win.onScreen);

%%%%%%%%%%%%%%% RESTABLECER
#            while 1
#                [keyIsDown,secs,keyCode] = KbCheck;
#                if keyIsDown
#                    kp = find(keyCode);
#                    if numel(kp) > 1, kp = kp(2); end
#                    if kp == prefs.keys.space
#                        break;
#                    end
#                end
#            end

        end % If end of blocks

    end % end block loop

    % Save the file in several versions
    save(prefs.fileName, "prefs", "stim");               % formato binario por defecto
    save("-mat7-binary", prefs.fileName_MATLAB, "prefs", "stim"); % formato MATLAB v7 (mè´°s compatible)

end % end function

