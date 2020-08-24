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
mutations = rand(4, game.num_generations, game.num_prisoners) .* 2 - 1;
cooperations = zeros(game.num_generations, game.num_prisoners);
retaliations = zeros(game.num_generations, game.num_prisoners);
retaliations_windows = zeros(game.num_generations, game.num_prisoners);
forgiveness_windows = zeros(game.num_generations, game.num_prisoners);
scores = zeros(game.num_generations, game.num_prisoners, game.num_prisoners);

%% Prepare first generation
tic

cooperations(1, :) = rand(1, game.num_prisoners);
retaliations(1, :) = rand(1, game.num_prisoners);
retaliations_windows(1, :) = round(rand(1, game.num_prisoners) * game.max_retaliation_window);
forgiveness_windows(1, :) = round(rand(1, game.num_prisoners) .* retaliations_windows(1, :));

lastsize = fprintf('Running generation 1.');

% Create original ancestors
for i = 1:game.num_prisoners
    prisoners{i} = Strategy(cooperations(1, i), ...
                            retaliations(1, i), ...
                            retaliations_windows(1, i), ...
                            forgiveness_windows(1, i), ...
                            @df_retaliation);
end

% Forced initialization
for ix = 1:30
    cooperations(1, ix) = 1;
    retaliations(1, ix) = 1;
    retaliations_windows(1, ix) = 2;
    forgiveness_windows(1, ix) = 1;
    prisoners{ix} = Strategy(cooperations(1, ix), ...
                            retaliations(1, ix), ...
                            retaliations_windows(1, ix), ...
                            forgiveness_windows(1, ix), ...
                            @df_retaliation);
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

dims = 4;
plot_generation_multi_coops(1, dims, 1, game, prisoners, most_fit);
plot_generation_multi_retaliation(2, dims, 1, game, prisoners, most_fit);
plot_generation_multi_window(3, dims, 1, game, prisoners, most_fit);
plot_generation_multi_forgiveness_window(4, dims, 1, game, prisoners, most_fit);
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);

%% Advance generations
for gen = 2:game.num_generations
    fprintf(repmat('\b', 1, lastsize));
    lastsize = fprintf('Running generation %d.', gen);
    
    % Define offspring
    for i = 1:game.num_prisoners
        r = rand();
        parent = find(r < game.alpha_fitness);
        parent = most_fit(parent(1));
        
        r = rand();
        if r < 0.5
            cooperations(gen, i) = cooperations(gen-1, parent);
            retaliations(gen, i) = retaliations(gen-1, parent);
            retaliations_windows(gen, i) = retaliations_windows(gen-1, parent);
            forgiveness_windows(gen, i) = forgiveness_windows(gen-1, parent);
        else
            cooperations(gen, i) = cooperations(gen-1, parent) + ...
                            game.alpha_mutations(gen, i) .* mutations(1, gen, i);
            retaliations(gen, i) = retaliations(gen-1, parent) + ...
                            game.alpha_mutations(gen, i) .* mutations(2, gen, i);
            retaliations_windows(gen, i) = round(retaliations_windows(gen-1, parent) + ...
                            (game.alpha_mutations(gen, i) * game.max_retaliation_window) .* ...
                            mutations(3, gen, i));
            forgiveness_windows(gen, i) = round(forgiveness_windows(gen-1, parent) + ...
                            (game.alpha_mutations(gen, i) * retaliations_windows(gen, i)) .* ...
                            mutations(4, gen, i));
        end       
    end
    
    % Sanitize cooperation values
    cooperations(cooperations > 1) = 1;
    cooperations(cooperations < 0) = 0;
    retaliations(retaliations > 1) = 1;
    retaliations(retaliations < 0) = 0;
    retaliations_windows(retaliations_windows > game.max_retaliation_window) = game.max_retaliation_window;
    retaliations_windows(retaliations_windows < 0) = 0;
    forgiveness_windows(forgiveness_windows > retaliations_windows) = retaliations_windows(forgiveness_windows > retaliations_windows);
    forgiveness_windows(forgiveness_windows < 0) = 0;
    
    % Create offspring
    for i = 1:game.num_prisoners
        prisoners{i} = Strategy(cooperations(gen, i), ...
                                retaliations(gen, i), ...
                                retaliations_windows(gen, i), ...
                                forgiveness_windows(gen, i), ...
                                @df_retaliation);
    end
    
    % Nice guy injection
    if gen == 10
        for ix = 1:15
            cooperations(gen, ix) = 1;
            retaliations(gen, ix) = 1;
            retaliations_windows(gen, ix) = game.max_retaliation_window;
            forgiveness_windows(gen, ix) = 1;
            prisoners{ix} = Strategy(cooperations(gen, ix), ...
                                    retaliations(gen, ix), ...
                                    retaliations_windows(gen, ix), ...
                                    forgiveness_windows(gen, i), ...
                                    @df_retaliation);
        end
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
    
    dims = 4;
    plot_generation_multi_coops(1, dims, gen, game, prisoners, most_fit);
    plot_generation_multi_retaliation(2, dims, gen, game, prisoners, most_fit);
    plot_generation_multi_window(3, dims, gen, game, prisoners, most_fit);
    plot_generation_multi_forgiveness_window(4, dims, gen, game, prisoners, most_fit);
end

fprintf('\n')

toc

set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);

figure
plot(mean_scores, 'xk')
title('Scores vs. Generation', 'FontSize', 16)
ylabel('Scores', 'FontSize', 16)
xlabel('Generation', 'FontSize', 16)
xline(10)