% Reset execution environment
clear; close all; clc

% Ensure reproducibility + housekeeping
rng('default');
rng(1);
addpath('decision_functions');

% Create Prisoner's Dilemma game
cc = 2;
cd_w = 3;
cd_l = -1;
dd = 0;
num_iters = 20;
game = create_game(cc, cd_w, cd_l, dd, num_iters);

%% Create Prisoners
num_prisoners = 20;
num_generations = 15;

prisoners = cell(num_prisoners, 1);

alpha_mutations = 0.7;
alpha_mutations = alpha_mutations .^ ((1:num_generations) - 1);
alpha_mutations = repmat(alpha_mutations', 1, num_prisoners);

alpha_reproducing = 0.2;

mutations = rand(num_generations, num_prisoners);

coops = zeros(num_generations, num_prisoners);
mean_coop = zeros(num_generations, 1);

scores = zeros(num_generations, num_prisoners, num_prisoners);
mean_scores = zeros(num_generations, num_prisoners);

tic
% Prepare first generation
coops(1, :) = rand(1, num_prisoners);

lastsize = fprintf('Running generation 1.');

for i = 1:num_prisoners
    prisoners{i} = Strategy(coops(1, i), 0, @df_cooperation_factor);
end

for i = 1:num_prisoners
    for j = i+1:num_prisoners
        [s_a, s_b] = one_on_one(game, prisoners{i}, prisoners{j});
        scores(1, i, j) = s_a;
        scores(1, j, i) = s_b;
    end
end

mean_scores(1, :) = sum(scores(1, :, :), 3) / (num_prisoners - 1);
[sorted_score, most_fit] = sort(mean_scores(1, :), 'descend');

most_fit = most_fit(1:round(alpha_reproducing*length(most_fit)));

% Advance generations
for gen = 2:num_generations
    fprintf(repmat('\b', 1, lastsize));
    lastsize = fprintf('Running generation %d.', gen);
    
    coops(gen, :) = mean(coops(gen-1, most_fit)) + alpha_mutations(gen, :) .* mutations(gen, :);
    coops(coops > 1) = 1;
    coops(coops < 0) = 0;
    
    for i = 1:num_prisoners
        prisoners{i} = Strategy(coops(gen, i), 0, @df_cooperation_factor);
    end

    for i = 1:num_prisoners
        for j = i+1:num_prisoners
            [s_a, s_b] = one_on_one(game, prisoners{i}, prisoners{j});
            scores(gen, i, j) = s_a;
            scores(gen, j, i) = s_b;
        end
    end

    mean_scores(gen, :) = sum(scores(gen, :, :), 3) / (num_prisoners - 1);
    [sorted_score, most_fit] = sort(mean_scores(gen, :), 'descend');

    most_fit = most_fit(1:round(alpha_reproducing*length(most_fit)));
end

fprintf('\n')

toc

plot(repmat((1:num_generations)', 1, num_prisoners), coops, 'xb')

% TODO Plot best-performing of every generation in a different colour, maybe?
% hold on
% plot(