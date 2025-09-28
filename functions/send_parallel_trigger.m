function send_parallel_trigger(address,value)

    % Send the trigger
    out32_mex(address, value);

    % Wait 5 ms to be sure that it is received
    pause(0.005);  % 5 ms pulse

    % Reset the trigger port
    out32_mex(address, 0);

end
