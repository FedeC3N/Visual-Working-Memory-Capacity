function instructions()

    % Define prefs and wins
    prefs = get_instructions_prefs();
    [prefs,win,stim] = get_instructions_init(prefs);

    % Call the first instruct window
    first_instruction(win)

    % Start the test
    test(prefs,win,stim);
    sca;


end


function prefs = get_instructions_prefs()

    pkg load statistics

    KbName('UnifyKeyNames');
    prefs.keys.escape = KbName('ESCAPE');
    prefs.keys.space = KbName('space');
    prefs.keys.same_color = 162;
    prefs.keys.different_color = 163;

    prefs.screenNumber = max(Screen('Screens'));
    prefs.numBlocks = 1;
    prefs.nTrialsPerCondition = 3;
    prefs.setSizes = [2,3];
    prefs.change = [0,1];
    prefs.change_label = {'No change', 'Change'};
    prefs.stimulusDuration = 0.150;
    prefs.retentionInterval = 1.000;
    prefs.ITI = 1.000;
    prefs.stimSize = 72;
    prefs.minDist = prefs.stimSize*1.5;
    prefs.fixationSize = 6;

    prefs.fullFactorialDesign = fullfact([length(prefs.setSizes), ...
        length(prefs.change), ...
        length(prefs.retentionInterval), ...
        length(prefs.stimulusDuration), ...
        prefs.nTrialsPerCondition]);

    prefs.numTrials = size(prefs.fullFactorialDesign,1);
    prefs.is_PC = ispc;
    prefs.windowed = 0;
end



function [prefs,win,stim] = get_instructions_init(prefs)


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


end


function first_instruction(win)

##InstructImage = imread([pwd,'/Instructions_CD'],'png','BackgroundColor',[win.gray/255,win.gray/255,win.gray/255]);
filename = fullfile('.','functions','Instructions_CD.png');  % include extension
[img, ~, alpha] = imread(filename);

% Define gray background as RGB triplet
grayVal = uint8(win.gray);  % assuming win.gray  [0,255]
background = uint8(ones(size(img)) * grayVal);

% If alpha channel exists, blend image over background
if ~isempty(alpha)
    alpha = double(alpha) / 255;
    img = uint8(double(img) .* alpha + double(background) .* (1 - alpha));
end

InstructImage = img;

sizeInstruct = size(InstructImage);
rectInstruct = [0 0 sizeInstruct(2) sizeInstruct(1)];
rectTestCoor = [win.centerX,win.centerY-round(sizeInstruct(1)*0.18)];

% Instruction text to plot
InstructText1 = ['¡Recuerda los colores!'];
InstructText2 = [...
    'En este experimento aparecerán distintos cuadrados de colores. Usted tendrá que recordar esos colores.\n'...
    'Después de un corto intervalo reaparecerá uno de los cuadrados. Usted tendrá que decidir si el color\n'...
    'del cuadrado ha cambiado.'];
InstructText3 = [...
    'INSTRUCCIONES\n'...
    '1. Espere a que aparezcan los cuadrados.\n'...
    '2. Observe los cuadrados. \n'...
    '3. Recuerde los colores de los cuadrados cuadrados. \n'...
    '4. Observe el nuevo cuadrado que se presenta\n\n'...
    '¿Es el mismo color que el cuadrado anterior? \n'...
    'Si el color es el mismo, pulse "Control Izquierdo".\n'...
    'Si el color es distinto, pulse "Control Derecho". \n\n'...
    'Pulse "espacio" para empezar un bloque de entrenamiento...'];


% Convert the text to one supported by Psychtoolbox
latin1_bytes = unicode2native(InstructText1, 'ISO-8859-1');
InstructText1_converted = char(latin1_bytes);
latin1_bytes = unicode2native(InstructText2, 'ISO-8859-1');
InstructText2_converted = char(latin1_bytes);
latin1_bytes = unicode2native(InstructText3, 'ISO-8859-1');
InstructText3_converted = char(latin1_bytes);

% Show instructions
Screen('FillRect', win.onScreen, win.gray);
Screen('PutImage',win.onScreen,InstructImage,CenterRectOnPoint(rectInstruct,rectTestCoor(1),rectTestCoor(2)));
Screen('TextSize', win.onScreen, 32);
Screen('TextStyle', win.onScreen, 1);
DrawFormattedText(win.onScreen, InstructText1_converted, 'center',win.centerY-330,win.white);
Screen('TextSize', win.onScreen, 18);
Screen('TextStyle', win.onScreen, 0);
DrawFormattedText(win.onScreen, InstructText2_converted, 'center',win.centerY-290,win.white,[],[],[],1.5);
DrawFormattedText(win.onScreen, InstructText3_converted, 'center',win.centerY+130,win.white,[],[],[],1.2);
Screen('Flip', win.onScreen);


% Wait for a spacebar press to continue with next block
while KbCheck; end;
KbName('UnifyKeyNames');   % This command switches keyboard mappings to the OSX naming scheme, regardless of computer.
space = KbName('space');
while 1
    [keyIsDown,secs,keyCode]=KbCheck;
    if keyIsDown
        kp = find(keyCode);
        if kp == space
            break;
        end
    end
end

clear InstructImage

end



function test(prefs,win,stim)

    %----------------------------------------------------
    % Get screen params, build the display
    %----------------------------------------------------
    commandwindow; % select the command win to avoid typing in open scripts
    %ListenChar(2); % don't print things in the command window
    HideCursor;

    % set the random state to the random seed at the beginning of the experiment!!
    rng(prefs.rndSeed);

    %---------------------------------------------------
    % Begin Block loop
    %---------------------------------------------------
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

            % Wait sample duration
            WaitSecs(prefs.stimulusDuration);

            % Retention
            draw_screen_mask(win);
            Screen('FillRect',win.onScreen,win.foreColor,win.foreRect);
            Screen('FillOval',win.onScreen,win.black,win.fixRect);
            Screen('DrawingFinished',win.onScreen);
            Screen('Flip',win.onScreen);

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

            % Wait for response
            rtStart = GetSecs;
            while KbCheck; end;

            while 1
                [keyIsDown,secs,keyCode] = KbCheck;

                if keyIsDown
                    % escape = exit
                    if keyCode(prefs.keys.escape)
                        save(prefs.fileName,'p','stim','prefs');
                        Screen('CloseAll');
                        return;
                    end

                    kp = find(keyCode);
                    if numel(kp) > 1, kp = kp(2); end

                    if kp == prefs.keys.different_color || kp == prefs.keys.same_color
                        stim.response(t,b) = kp;
                        rtEnd = GetSecs;
                        stim.rt(t,b) = rtEnd - rtStart;

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


        % Instruction text
        InstructText1 = 'El bloque de prueba ha terminado.';
        InstructText2 = 'Cuando esté listo para comenzar, pulse ESPACIO...'

        % Convert the text to one supported by Psychtoolbox
        latin1_bytes = unicode2native(InstructText1, 'ISO-8859-1');
        InstructText1_converted = char(latin1_bytes);
        latin1_bytes = unicode2native(InstructText2, 'ISO-8859-1');
        InstructText2_converted = char(latin1_bytes);

        Screen('TextSize',win.onScreen,60);
        Screen('TextFont',win.onScreen,'Arial');
        DrawFormattedText(win.onScreen, InstructText1_converted, 'center',win.centerY-50,win.white);

        Screen('TextSize',win.onScreen,32);
        DrawFormattedText(win.onScreen, InstructText2_converted, 'center',win.centerY+50,win.white);
        Screen('Flip',win.onScreen);

        while 1
            [keyIsDown,secs,keyCode] = KbCheck;
            if keyIsDown
                kp = find(keyCode);
                if numel(kp) > 1, kp = kp(2); end
                if kp == prefs.keys.space
                    break;
                end
            end
        end



    end % end block loop


end % end function
