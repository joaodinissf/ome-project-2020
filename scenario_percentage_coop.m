% Reset execution environment
clear; close all; clc

%% Ensure reproducibility + housekeeping
rng('default');
rng(1);
addpath('decision_functions');
addpath('plotting');

% Create Prisoner's Dilemma game
game = create_game();

%% Create Prisoners
prisoners = cell(game.num_prisoners, 1);
mutations = rand(game.num_generations, game.num_prisoners) .* 2 - 1;
cooperations = zeros(game.num_generations, game.num_prisoners);
scores = zeros(game.num_generations, game.num_prisoners, game.num_prisoners);

%% Prepare first generation
tic

cooperations(1, :) = rand(1, game.num_prisoners);

lastsize = fprintf('Running generation 1.');

% Create original ancestors
for i = 1:game.num_prisoners
    prisoners{i} = Strategy(cooperations(1, i), 0, 0, @df_cooperation);
end

% Run game
for i = 1:game.num_prisoners
    for j = i+1:game.num_prisoners
        [s_a, s_b] = one_on_one(game, prisoners{i}, prisoners{j});
        scores(1, i, j) = s_a;
        scores(1, j, i) = s_b;
    end
end

mean_scores(1, :) = sum(scores(1, :, :), 3) / (game.num_prisoners - 1);
[sorted_score, most_fit] = sort(mean_scores(1, :), 'descend');

most_fit = most_fit(1:game.num_reproducing);

plot_generation(1, game, prisoners, most_fit);

%% Advance generations
for gen = 2:game.num_generations
    fprintf(repmat('\b', 1, lastsize));
    lastsize = fprintf('Running generation %d.', gen);
    
    % Define offspring
    for i = 1:game.num_prisoners
        r = rand();
        parent = find(r < game.alpha_fitness);
        parent = most_fit(parent(1));
        cooperations(gen, i) = cooperations(gen-1, parent) + game.alpha_mutations(gen, i) .* mutations(gen, i);
    end
    
    % Sanitize cooperation values
    cooperations(cooperations > 1) = 1;
    cooperations(cooperations < 0) = 0;
    
    % Create offspring
    for i = 1:game.num_prisoners
        prisoners{i} = Strategy(cooperations(gen, i), 0, 0, @df_cooperation);
    end
    
    % Run game
    for i = 1:game.num_prisoners
        for j = i+1:game.num_prisoners
            [s_a, s_b] = one_on_one(game, prisoners{i}, prisoners{j});
            scores(gen, i, j) = s_a;
            scores(gen, j, i) = s_b;
        end
    end

    mean_scores(gen, :) = sum(scores(gen, :, :), 3) / (game.num_prisoners - 1);
    [sorted_score, most_fit] = sort(mean_scores(gen, :), 'descend');

    most_fit = most_fit(1:round(game.alpha_reproducing*length(most_fit)));
    
    plot_generation(gen, game, prisoners, most_fit);
end

fprintf('\n')

toc

title('Cooperation', 'FontSize', 20)
xlabel('Generation', 'FontSize', 16)
ylabel('% Cooperation', 'FontSize', 16)
xlim([0 game.num_generations + 1])
xticks(1:game.num_generations)
ylim([0 1])
