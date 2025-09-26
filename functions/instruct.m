function instruct(win)

InstructImage = imread([pwd,'/Instructions_CD'],'png','BackgroundColor',[win.gray/255,win.gray/255,win.gray/255]);

sizeInstruct = size(InstructImage);
rectInstruct = [0 0 sizeInstruct(2) sizeInstruct(1)];
rectTestCoor = [win.centerX,win.centerY-round(sizeInstruct(1)*0.18)]; 


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
    'Pulsa "espacio" para empezar...'];

% Show instructions
Screen('FillRect', win.onScreen, win.gray);
Screen('PutImage',win.onScreen,InstructImage,CenterRectOnPoint(rectInstruct,rectTestCoor(1),rectTestCoor(2)));
Screen('TextSize', win.onScreen, 32); 
Screen('TextStyle', win.onScreen, 1);
DrawFormattedText(win.onScreen, InstructText1, 'center',win.centerY-330,win.white);
Screen('TextSize', win.onScreen, 18);
Screen('TextStyle', win.onScreen, 0);
DrawFormattedText(win.onScreen, InstructText2, 'center',win.centerY-290,win.white,[],[],[],1.5);
DrawFormattedText(win.onScreen, InstructText3, 'center',win.centerY+130,win.white,[],[],[],1.2);
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