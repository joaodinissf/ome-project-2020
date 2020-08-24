function game = create_game()
    % Number of prisoners, generations and iterations
    game.num_prisoners = 50;
    game.num_generations = 20;
    game.num_iters = 10;
    game.max_retaliation_window = 10;
    game.channel_noise = 0.1;
    
    % Rewards
    game.cc = 2;
    game.cd_w = 3;
    game.cd_l = -1;
    game.dd = 0;
    
    % Intensity of mutations
    game.alpha_mutations = 0.35;
    game.alpha_mutations = game.alpha_mutations * 0.97 .^ ((1:game.num_generations) - 1);
    game.alpha_mutations = repmat(game.alpha_mutations', 1, game.num_prisoners);

    % How many parents generate offspring?
    game.alpha_reproducing = 0.2;
    game.num_reproducing = round(game.alpha_reproducing * game.num_prisoners);
    
    % How much more do the most fit elements of the population reproduce?
    game.alpha_fitness = 0.7;
    game.alpha_fitness = game.alpha_fitness .^ (1:game.num_reproducing);
    game.alpha_fitness = game.alpha_fitness / sum(game.alpha_fitness);    
    game.alpha_fitness = cumsum(game.alpha_fitness);
end
