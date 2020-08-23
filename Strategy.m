classdef Strategy
    properties
        Cooperation {mustBeNumeric}
        Defection {mustBeNumeric}
        Retaliation {mustBeNumeric}
        decide
    end
    
    methods
        function obj = Strategy(cooperation, retaliation, decision_func)
            if nargin == 3
                obj.Cooperation = cooperation;
                obj.Defection = 1 - obj.Cooperation;
                obj.Retaliation = retaliation;
                obj.decide = decision_func;
            end
        end
    end
end