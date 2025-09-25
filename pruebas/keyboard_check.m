clear
clc

KbName('UnifyKeyNames');   % This command switches keyboard mappings to the OSX naming scheme, regardless of computer.
% unify key names so we don't need to mess when switching from mac
% to pc ...
escape = KbName('ESCAPE');  % Mac == 'ESCAPE' % PC == 'esc'
return_key = KbName('return');
prefs.changeKey = KbName('m'); % on mac, 56 % 191 == / pc
prefs.nochangeKey = KbName('z'); % on mac, 29  % 90 == z
space = KbName('space');

while 1
    [keyIsDown,secs,keyCode]=KbCheck;
    if keyIsDown
        if keyCode(escape)                              % if escape is pressed, bail out
            fprintf(1,'Salir\n')
            break
        end
        if keyCode(return_key)
            fprintf(1,'Intro. Ignorar.\n')
        end
        kp = find(keyCode);
        if numel(kp) > 1
            fprintf('Varios valores. No hacer nada.\n')
            
        elseif kp== prefs.changeKey || kp== prefs.nochangeKey  % previously 90/191, PC
            fprintf('Correcto\n')
        end
    end
end