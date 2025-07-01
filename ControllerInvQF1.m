classdef ControllerInvQF1 < handle & Operator & Integrator
    properties
    end

    properties (SetAccess = immutable, GetAccess=public)
    end


    properties (SetAccess = public, GetAccess = public) 
    end

    methods
        function obj = ControllerInvQF1(options)
            arguments                
                options.prm = [];
                options.dt  =1;
                options.cycleNum  = 1;
                options.comment = "";
            end
            obj.prm = options.prm;
            obj.dt = options.dt;
            obj.cycleNum = options.cycleNum;
            obj.comment = options.comment;

            obj.debugVectorCell = {};
            obj.stateVariable = zeros(2,1);
        end
        
        function dxdt = getDxdt(obj,Qtilde_d,tStateVariable)
            dxdt = 1 .* obj.prm.p1*(-tStateVariable + Qtilde_d); 
        end
        
        function operatorOutput =  calcNextCycle(obj,Qtilde_d)
            obj.stateVariable = cMoritaRungeKuttaMethod(obj,Qtilde_d);
            operatorOutput = obj.prm.tau .* obj.dxdtPreserved +obj.stateVariable;
        end
    end
end