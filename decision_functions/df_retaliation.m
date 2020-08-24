function d = df_retaliation(it, decider_self, decider_other, decisions_self, decisions_other)
    r = rand();
    if it > 1 && any([decisions_other{1:it-1}] == Actions.Defect)
        if r < decider_self.Retaliation
            d = Actions.Defect;
        else
            d = Actions.Cooperate;
        end
        return
    end

    r = rand();
    if r < decider_self.Cooperation
        d = Actions.Cooperate;
    else
        d = Actions.Defect;
    end
end