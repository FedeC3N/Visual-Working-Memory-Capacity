function instruct(win)

##InstructImage = imread([pwd,'/Instructions_CD'],'png','BackgroundColor',[win.gray/255,win.gray/255,win.gray/255]);
filename = fullfile(pwd, 'Instructions_CD.png');  % include extension
[img, ~, alpha] = imread(filename);

% Define gray background as RGB triplet
grayVal = uint8(win.gray);  % assuming win.gray ∈ [0,255]
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
    'Pulse "espacio" para empezar...'];


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
