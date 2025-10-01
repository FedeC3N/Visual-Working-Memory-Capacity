%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Quick numbers for pilot
%
% Created 01/10/2025
% author Federico Ramírez-Toraño
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
clc
close all

load('../../data/conductual/HIQ_prueba_triggers_003_ColorK.mat');

% Get the index of the load
accuracy = stim.accuracy;
task_load = stim.setSize;
index_load = [4, 6, 8];

% Global accuracy
global_accuracy = [...
sum(accuracy(task_load == index_load(1)))/ numel(accuracy(task_load == index_load(1))),...
sum(accuracy(task_load == index_load(2)))/ numel(accuracy(task_load == index_load(2))),...
sum(accuracy(task_load == index_load(3)))/ numel(accuracy(task_load == index_load(3)))];

fprintf(1,'Global Index 4 accuracy: %.3f\n', global_accuracy(1))
fprintf(1,'Global Index 6 accuracy: %.3f\n', global_accuracy(2))
fprintf(1,'Global Index 8 accuracy: %.3f\n\n', global_accuracy(3))

% Accuracy per block
figure
block_accuracy = nan(3,4);
for iload = 1 : 3
  current_block_accuracy = accuracy(task_load == index_load(iload));
  current_block_accuracy = reshape(current_block_accuracy,[],4);
  block_accuracy(iload,:) = sum(current_block_accuracy,1)/size(current_block_accuracy,1);
  plot(1:4,block_accuracy(iload,:),'*-')
  hold on
end
legend('Set 4', 'Set 6', 'Set 8')
ylim([0 1])
xticks([1 2 3 4])
xlabel('Block number')
ylabel('Accuracy')

% K coefficient
[K,setSize] = computeK(stim);
figure;
plot(setSize, K, '-o', 'LineWidth', 2, 'MarkerSize', 8);
ylim([0 max(K)*1.2]);
xlim([min(setSize)-0.5, max(setSize)+0.5]);

xlabel('Set Size (# of items)');
ylabel('Estimated K');
title('Visual Working Memory Capacity (K) by Set Size');
grid on;

% Estética tipo paper
set(gca, 'FontSize', 12);


% Time spent on the task
fprintf(1,'Time elapsed: %.3f minutes. \n\n', stim.triggers.onset(end)/60)


