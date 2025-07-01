classdef ControllerInvD < handle & Operator & Integrator
    properties
        %デバッグ用
    end

    properties (SetAccess = immutable, GetAccess=public) 
       
    end

    properties (SetAccess = public, GetAccess = public) 
        %デバッグ用変数
    end

    methods
        function obj = ControllerInvD(options)
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

        function dxdt = getDxdt(obj,u13,tStateVariable)
            inputCurr = [u13(1); 0; u13(2)];
            y_a_prev = [tStateVariable(1); 0; tStateVariable(2)];

            ohmHeat = -obj.prm.peltier.resistance*[1; 0; 1].*power(inputCurr,2);
            peltierHeat =  2*obj.prm.peltier.seebeck*[1; 0; 1].*((obj.prm.peltier.absoluteTemperature+ obj.prm.experimentalSettings.outsideTemperature)- y_a_prev).*inputCurr;
            tDxdt = (ohmHeat + peltierHeat)./obj.prm.aluminum.maca;

            for i=1:4
                tDxdt = tDxdt + ((-1)^(i)) *obj.prm.aluminum.A_a(:,i).* (y_a_prev.^i);
            end

            %応答改善のためアルミ干渉を含めた右分解を行う場合は有効にする
            % tDxdt = tDxdt - obj.prm.interferrencePrm.y_a .* y_a_prev ./ obj.prm.aluminum.maca;

            dxdt = tDxdt([1,3]);
        end
        
        function operatorOutput =  calcNextCycle(obj,ya13)
            obj.stateVariable = cMoritaRungeKuttaMethod(obj,ya13);
            operatorOutput = obj.stateVariable;
        end
    end
end