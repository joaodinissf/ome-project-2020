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
max_retaliation_window = 10;

prisoners = cell(game.num_prisoners, 1);
mutations = rand(3, game.num_generations, game.num_prisoners) .* 2 - 1;
cooperations = zeros(game.num_generations, game.num_prisoners);
retaliations = zeros(game.num_generations, game.num_prisoners);
retaliations_windows = zeros(game.num_generations, game.num_prisoners);
scores = zeros(game.num_generations, game.num_prisoners, game.num_prisoners);

%% Prepare first generation
tic

cooperations(1, :) = rand(1, game.num_prisoners);
retaliations(1, :) = rand(1, game.num_prisoners);
retaliations_windows(1, :) = round(rand(1, game.num_prisoners) * max_retaliation_window);

lastsize = fprintf('Running generation 1.');

% Create original ancestors
for i = 1:game.num_prisoners
    prisoners{i} = Strategy(cooperations(1, i), ...
                            retaliations(1, i), ...
                            retaliations_windows(1, i), ...
                            @df_retaliation);
end

% Forced initialization
% for ix = 1:25
%     cooperations(1, ix) = 1;
%     retaliations(1, ix) = 1;
%     retaliations_windows(1, ix) = 1;
%     prisoners{ix} = Strategy(cooperations(1, 1), ...
%                             retaliations(1, 1), ...
%                             retaliations_windows(1, 1), ...
%                             @df_retaliation);
% end

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

plot_generation_multi_coops(1, 3, 1, game, prisoners, most_fit);
plot_generation_multi_retaliation(2, 3, 1, game, prisoners, most_fit);
plot_generation_multi_window(3, 3, 1, game, prisoners, most_fit);

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
        else
            cooperations(gen, i) = cooperations(gen-1, parent) + ...
                            game.alpha_mutations(gen, i) .* mutations(1, gen, i);
            retaliations(gen, i) = retaliations(gen-1, parent) + ...
                            game.alpha_mutations(gen, i) .* mutations(2, gen, i);
            retaliations_windows(gen, i) = round(retaliations_windows(gen-1, parent) + ...
                            (game.alpha_mutations(gen, i) * max_retaliation_window) .* ...
                            mutations(3, gen, i));
        end       
    end
    
    % Sanitize cooperation values
    cooperations(cooperations > 1) = 1;
    cooperations(cooperations < 0) = 0;
    retaliations(retaliations > 1) = 1;
    retaliations(retaliations < 0) = 0;
    retaliations_windows(retaliations_windows > max_retaliation_window) = max_retaliation_window;
    retaliations_windows(retaliations_windows < 0) = 0;
    
    % Create offspring
    for i = 1:game.num_prisoners
        prisoners{i} = Strategy(cooperations(gen, i), ...
                                retaliations(gen, i), ...
                                retaliations_windows(gen, i), ...
                                @df_cooperation);
    end
    
    % Nice guy injection
%     if gen == 10
%         for ix = 1:7
%             cooperations(gen, ix) = 1;
%             retaliations(gen, ix) = 1;
%             retaliations_windows(gen, ix) = 1;
%             prisoners{ix} = Strategy(cooperations(gen, 1), ...
%                                     retaliations(gen, 1), ...
%                                     retaliations_windows(gen, 1), ...
%                                     @df_retaliation);
%         end
%     end
    
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
    
    plot_generation_multi_coops(1, 3, gen, game, prisoners, most_fit);
    plot_generation_multi_retaliation(2, 3, gen, game, prisoners, most_fit);
    plot_generation_multi_window(3, 3, gen, game, prisoners, most_fit);
end

fprintf('\n')

toc

set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);