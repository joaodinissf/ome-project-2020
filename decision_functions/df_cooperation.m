function d = df_cooperation(it, decider_self, decider_other, decisions_self, decisions_other)
    r = rand();
    if r < decider_self.Cooperation
        d = Actions.Cooperate;
    else
        d = Actions.Defect;
    end
end