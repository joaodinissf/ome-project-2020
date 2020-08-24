function [score_a, score_b] = one_on_one(game, strategy_a, strategy_b)
    decisions_a = cell(1, game.num_iters);
    decisions_b = cell(1, game.num_iters);
    
    score_a = 0;
    score_b = 0;
    
    for i = 1:game.num_iters
        d_a = strategy_a.decide(i, strategy_a, strategy_b, decisions_a, decisions_b);
        d_b = strategy_b.decide(i, strategy_b, strategy_a, decisions_b, decisions_a);
        
        r = rand();
        if r < game.channel_noise
            d_a = ~d_a;
        end
        r = rand();
        if r < game.channel_noise
            d_b = ~d_b;
        end
        
        decisions_a{i} = d_a;
        decisions_b{i} = d_b;
        
        if d_a == Actions.Cooperate && d_b == Actions.Cooperate
            s_a = game.cc;
            s_b = game.cc;
        elseif d_a == Actions.Defect && d_b == Actions.Cooperate
            s_a = game.cd_w;
            s_b = game.cd_l;
        elseif d_a == Actions.Cooperate && d_b == Actions.Defect
            s_a = game.cd_l;
            s_b = game.cd_w;
        elseif d_a == Actions.Defect && d_b == Actions.Defect
            s_a = game.dd;
            s_b = game.dd;
        end

        score_a = score_a + s_a;
        score_b = score_b + s_b;
    end
end
