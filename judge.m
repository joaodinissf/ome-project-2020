function [s_a, s_b] = judge(game, d_a, d_b)
    if d_a == Actions.Cooperate && d_b == Actions.Cooperate
        s = [game.cc, game.cc];
    elseif d_a == Actions.Defect && d_b == Actions.Cooperate
        s = [game.cd_w, game.cd_l];
    elseif d_a == Actions.Cooperate && d_b == Actions.Defect
        s = [game.cd_l, game.cd_w];
    elseif d_a == Actions.Defect && d_b == Actions.Defect
        s = [game.dd, game.dd];
    end
    
    s_a = s(1);
    s_b = s(2);
end