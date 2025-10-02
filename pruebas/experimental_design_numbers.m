% Quick numbers for experimental design

clear
clc

nTrialsPerCondition = 10;
numBlocks = 5;
loss_rate = 0.3;

fullFactorialDesign = fullfact([3, ...
    2, ...
    1, ...
    1, ...
    nTrialsPerCondition]); 


seconds_per_trial = 3;
time_spent = numel(fullFactorialDesign) * seconds_per_trial;
clean_trials_per_condition = 2 * nTrialsPerCondition * numBlocks * (1 - loss_rate);


fprintf('Time per trial: %.2f\n',seconds_per_trial)
fprintf('Total trials presented: %i\n', numel(fullFactorialDesign))
fprintf('Minutes spent: %.3f\n', time_spent/60)
fprintf('Clean trials per load accounting loss: %i\n', round(clean_trials_per_condition))
fprintf('\n\n')

