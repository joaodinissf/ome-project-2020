function d = decision_to_double(decision)
    if decision == Actions.Cooperate
        d = 1;
    elseif decision == Actions.Defect
        d = 0;
    end
end