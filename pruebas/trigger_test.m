%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Send different triggers until ESCAPE is pressed
%
% 30/09/2025
% Author: Federico Ramírez-Toraño
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear

% Add pathsep
addpath('../functions/');

% Define the triggers and the output port
triggers = [4, 8, 16, 24, 32, 40 , 1, 2, 128 , 252];
triggers = [8, 16, 24, 32, 40, 48, 1, 2, 64, 72];
parallel_port = 16360; %hex2dec('3FE0'); %16360 3FE8
trigger_index = 1;

% Important keys
KbName('UnifyKeyNames');
escape = KbName('ESCAPE');

% Loop for sending triggers until ESCAPE is pressed
while 1

    % Check if SCAPE is pressed
    [keyIsDown,secs,keyCode]=KbCheck;
    if keyIsDown
        if keyCode(escape)                              % if escape is pressed, bail out
            fprintf(1,'Salir\n')
            break
        end
    end

    % Send next trigger
    current_trigger = triggers(trigger_index);
    out = send_trigger(parallel_port,current_trigger);
    fprintf(1, '%s %i\n',out, current_trigger)
    pause(1)


    % Update the index
    if trigger_index == numel(triggers)
      trigger_index = 1;
    else
      trigger_index = trigger_index + 1;
    endif


end
