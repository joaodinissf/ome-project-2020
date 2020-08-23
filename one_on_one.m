function [score_a, score_b] = one_on_one(game, strategy_a, strategy_b)
    decisions_a = zeros(1, game.num_iters);
    decisions_b = zeros(1, game.num_iters);
    
    score_a = 0;
    score_b = 0;
    
    for i = 1:game.num_iters
        decision_a = strategy_a.decide(strategy_a, strategy_b, decisions_a(1:i-1), decisions_b(1:i-1));
        decision_b = strategy_b.decide(strategy_b, strategy_a, decisions_b(1:i-1), decisions_a(1:i-1));
        
        decisions_a(i) = decision_to_double(decision_a);
        decisions_b(i) = decision_to_double(decision_b);
        
        [s_a, s_b] = judge(game, decision_a, decision_b);
        score_a = score_a + s_a;
        score_b = score_b + s_b;
    end
    
end