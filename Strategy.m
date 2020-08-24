classdef Strategy
    properties
        Cooperation {mustBeNumeric}
        Defection {mustBeNumeric}
        Retaliation {mustBeNumeric}
        GrudgePeriod {mustBeNumeric}
        ForgivenessPeriod {mustBeNumeric}
        decide
    end
    
    methods
        function obj = Strategy(cooperation, retaliation, grudge_period, forgiveness_period, decision_func)
            if nargin == 5
                obj.Cooperation = cooperation;
                obj.Defection = 1 - obj.Cooperation;
                obj.Retaliation = retaliation;
                obj.GrudgePeriod = grudge_period;
                obj.ForgivenessPeriod = forgiveness_period;
                obj.decide = decision_func;
            end
        end
    end
end