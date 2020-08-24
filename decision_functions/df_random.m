function d = df_random(it, decider_self, decider_other, decisions_self, decisions_other)
    r = rand();
    if r > 0.5
        d = Actions.Cooperate;
    else
        d = Actions.Defect;
    end
end