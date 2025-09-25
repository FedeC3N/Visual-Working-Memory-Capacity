function instruct(win)

InstructImage = imread([pwd,'/Instructions_CD'],'png','BackgroundColor',[win.gray/255,win.gray/255,win.gray/255]);
textOffset = 200;
textSize = 18;

sizeInstruct = size(InstructImage);
rectInstruct = [0 0 sizeInstruct(2) sizeInstruct(1)];
rectTestCoor = [win.centerX,win.centerY-round(sizeInstruct(1)*.2)]; 


InstructText = ['¡Recuerda los colores! \n'...
    ...
    'En este experimento aparecerán distintos cuadrados de colores.\n'...
    'Usted tendrá que recordar esos colores. Después de un corto intervalo\n'...
    'reaparecerá uno de los cuadrados. Usted tendrá que decidir si el color\n'...
    'del cuadrado ha cambiado\n\n\n'...
    ...
    'INSTRUCCIONES\n'...
    '1. Espera a que aparezcan los cuadrados.\n'...
    '2. Observa los cuadrados. \n'...
    '3. Recuerda los colores de los cuadrados cuadrados. \n'...
    '4. Observe el nuevo cuadrado que se presenta\n\n'...
    '5. ¿Es el mismo color que el cuadrado anterio? \n'...
    'Si el color es el mismo, pulsa "z".\n'...
    'Si el color es distinto, pulsa "m". \n\n'...
    'Pulsa "espacio" para empezar.'];

% Show image again, but with explanatory text
Screen('FillRect', win.onScreen, win.gray);
Screen('TextSize', win.onScreen, win.fontsize);

Screen('PutImage',win.onScreen,InstructImage,CenterRectOnPoint(rectInstruct,rectTestCoor(1),rectTestCoor(2)));
Screen('TextSize', win.onScreen, textSize); % 24 = number pixels
DrawFormattedText(win.onScreen, InstructText, win.centerX-textOffset,win.centerY+(sizeInstruct(1)*.35),win.white);
Screen('Flip', win.onScreen);

% GetClicks(win.onScreen);

% Screen('FillRect', win.onScreen, win.gray);
% Screen('TextSize', win.onScreen, win.fontsize);
% Screen(win.onScreen, 'DrawText', 'Remember the colors.', win.centerX-250, win.centerY-150, [255 255 255]);
% Screen(win.onScreen, 'DrawText', ['Press "z" if the color does not change'], win.centerX-250, win.centerY-75, [255 255 255]);
% Screen(win.onScreen, 'DrawText', ['Press "/" if the color changes'], win.centerX-250, win.centerY-50, [255 255 255]);
% Screen(win.onScreen, 'DrawText', 'Press space to begin.', win.centerX-250, win.centerY+30, [255 255 255]);
% Screen('FillOval',win.onScreen,win.black,win.fixRect);           % Draw the fixation point
% Screen('Flip', win.onScreen);

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