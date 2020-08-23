% Reset execution environment
clear; close all; clc

% Ensure reproducibility + housekeeping
rng('default');
rng(0);
addpath('decision_functions');

% Create Prisoner's Dilemma game
default_game = create_game();

%% Create Prisoners
cooperative_carl = Strategy(1, 0, @df_always_cooperate);
stingy_sally = Strategy(1, 0, @df_always_defect);
random_roger = Strategy(1, 0, @df_random);

% Coop + Defect
[score_a, score_b] = one_on_one(default_game, cooperative_carl, stingy_sally);
disp([score_a, score_b])

% Coop + Random
[score_a, score_b] = one_on_one(default_game, cooperative_carl, random_roger);
disp([score_a, score_b])

% Defect + Random
[score_a, score_b] = one_on_one(default_game, stingy_sally, random_roger);
disp([score_a, score_b])