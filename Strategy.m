classdef Strategy
    properties
        Cooperation {mustBeNumeric}
        Defection {mustBeNumeric}
        Retaliation {mustBeNumeric}
        GrudgePeriod {mustBeNumeric}
        % GrudgePeriod {mustBeNumeric}
        decide
    end
    
    methods
        function obj = Strategy(cooperation, retaliation, grudge_period, decision_func)
            if nargin == 4
                obj.Cooperation = cooperation;
                obj.Defection = 1 - obj.Cooperation;
                obj.Retaliation = retaliation;
                obj.GrudgePeriod = grudge_period;
                obj.decide = decision_func;
            end
        end
    end
end