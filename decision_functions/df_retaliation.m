function d = df_retaliation(it, decider_self, decider_other, decisions_self, decisions_other)

    start_grudge = it - decider_self.GrudgePeriod;
    end_grudge = it - decider_self.ForgivenessPeriod-1;
    
    start_grudge = max(1, start_grudge);
    
    if end_grudge > start_grudge
        been_defected_on = any([decisions_other{start_grudge:end_grudge}] == Actions.Defect);
    else
        been_defected_on = 0;
    end
    
    r = rand();
    if it > 1 && been_defected_on
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