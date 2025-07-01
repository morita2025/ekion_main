classdef ControllerInvB < handle & Operator & Integrator
    properties
        %デバッグ用
    end

    properties (SetAccess = immutable, GetAccess=public)
        operatorInstanceN
        operatorInstanceQN
        operatorInstanceQD
    end


    properties (SetAccess = public, GetAccess = public)
        x_1
        x_2
        x_3
        x_4
        cycleCount
    end

    methods
        function obj = ControllerInvB(options)
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
            obj.x_1 = zeros(3,1);
            obj.x_2 = zeros(3,1);
            obj.x_3 = zeros(3,1);
            obj.x_4 = zeros(3,1);

            obj.operatorInstanceN = ControllerN(prm=obj.prm,dt=obj.dt,cycleNum=obj.cycleNum,comment="Has-a invB");
            obj.operatorInstanceQN = ControllerQ(prm=obj.prm,dt=obj.dt,cycleNum=obj.cycleNum,comment="Has-a invB");
            obj.operatorInstanceQD = ControllerQ(prm=obj.prm,dt=obj.dt,cycleNum=obj.cycleNum,comment="Has-a invB");
            obj.cycleCount =1;
           
            for i = 1:4
                obj.debugVectorCell{i} = zeros(3,obj.cycleNum);
            end
        end

        %update
        function operatorOutput =  calcNextCycle(obj,e13)
           
            %N_LPF
            vector2X_1 = obj.operatorInstanceQN.calcNextCycle(obj.x_3([1,3]));
            obj.x_1 = [vector2X_1(1); 0; vector2X_1(2)];
            
            %N
            vector2X_2 = obj.operatorInstanceN.calcNextCycle([obj.x_1(1); obj.x_1(3)]);
            obj.x_2 = [vector2X_2(1); 0; vector2X_2(2)];

            %invM
            obj.x_3 = (obj.x_2 + [e13(1); 0; e13(2)]) ./ obj.prm.MOperatorConstPrm;

            %Q_D
            vector2X_4 = obj.operatorInstanceQD.calcNextCycle(obj.x_3([1,3]));
            obj.x_4 = [vector2X_4(1); 0; vector2X_4(2)];
            x_4_dot =  (obj.x_3 - obj.x_4) ./ (obj.prm.tau);

            %D
            ma_ca13 = obj.prm.aluminum.maca(1);
            ma_ca2 = obj.prm.aluminum.maca(2);
            a1 = obj.prm.peltier.resistance *ones(3,1);
            a2 = 2*obj.prm.peltier.seebeck * (obj.x_4 - (obj.prm.peltier.absoluteTemperature + obj.prm.experimentalSettings.outsideTemperature));
            a3 = [ma_ca13; ma_ca2; ma_ca13].*x_4_dot;
            for i=1:4
                a3 = a3 + ((-1)^(i+1)) *obj.prm.aluminum.A_a(:,i).*[ma_ca13; ma_ca2; ma_ca13] .* (obj.x_4.^i);
            end
            %応答改善のためアルミ干渉を含めた右分解を行う場合は有効にする
            % a3 = a3 + obj.prm.interferrencePrm.y_a .* obj.x_4;

            b1 = -a2;
            b2 = sqrt(power(a2,2) - 4*a1.*a3);
            b3 = 2*a1;
            b = [1; 0; 1].*(b1 - b2)./b3;
            operatorOutput = b([1,3]);

            %debug
            obj.debugVectorCell{1}(:,obj.cycleCount) = obj.x_1;
            obj.debugVectorCell{2}(:,obj.cycleCount) = obj.x_2;
            obj.debugVectorCell{3}(:,obj.cycleCount) = obj.x_3;
            obj.debugVectorCell{4}(:,obj.cycleCount) = obj.x_4;
            obj.cycleCount = obj.cycleCount +1;

        end

    end
end