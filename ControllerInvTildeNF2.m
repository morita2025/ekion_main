classdef ControllerInvTildeNF2 < handle & Operator & Integrator
    properties
    end

    properties (SetAccess = immutable, GetAccess=public) %読み取り専用＆外部からアクセスする用
    end


    properties (SetAccess = public, GetAccess = public) %書き換え可能＆外部からアクセスする用
        aaa
        operatorInstanceSupportInvTildeNF2            
        tildeNNum1
        tildeNDeb1 
        tildeNNum2 
        tildeNDeb2 
        FDen1
        FDen2
        FGain
    end

    methods
        function obj = ControllerInvTildeNF2(options)
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
            obj.stateVariable = zeros(10,1);
            obj.dxdtPreserved = zeros(10,1);
            obj.aaa = zeros(2,1);

            %伝達関数関連
            obj.tildeNNum1 = obj.prm.tildeNsys{1,1}.Numerator{1,1};
            obj.tildeNDeb1 = obj.prm.tildeNsys{1,1}.Denominator{1,1};
            obj.tildeNNum2 = obj.prm.tildeNsys{1,2}.Numerator{1,1};
            obj.tildeNDeb2 = obj.prm.tildeNsys{1,2}.Denominator{1,1};



             p2 = obj.prm.p2;
             %分母のsの最高次数を1に正規化
             obj.FDen1 = tf(1,[obj.tildeNNum1(1,end-1),obj.tildeNNum1(1,end)]) * tf(p2^3, [1, 3*p2, 3*p2^2, p2^3]);
             obj.FDen2 = tf(1,[obj.tildeNNum2(1,end-1),obj.tildeNNum2(1,end)]) * tf(p2^5, [1, 5*p2, 10*p2^2, 10*p2^3, 5*p2^4, p2^5]);

             a1 = obj.FDen1.Denominator{1}(1);
             obj.FDen1 = tf(obj.FDen1.Numerator{1}/a1, obj.FDen1.Denominator{1}/a1);
             a2 = obj.FDen2.Denominator{1}(1);
             obj.FDen2 = tf(obj.FDen2.Numerator{1}/a2, obj.FDen2.Denominator{1}/a2);

             obj.FGain = [obj.FDen1.Numerator{1}(1,end) ./obj.FDen1.Denominator{1}(1,end);...
                          obj.FDen2.Numerator{1}(1,end) ./obj.FDen2.Denominator{1}(1,end);];

        end

        function dxdt = getDxdt(obj,Qtilde_d,tStateVariable)  
            dxdt = zeros(10,1);
            %part1
            % dxdt(1) = -3*obj.prm.p2.*tStateVariable(1) -3*obj.prm.p2^2.*tStateVariable(2)...
            %           -obj.prm.p2^3.*tStateVariable(3) +obj.prm.p2^3.*Qtilde_d(1)
            %part3
            % dxdt(4) = -5*obj.prm.p2.*tStateVariable(4) -10*obj.prm.p2^2.*tStateVariable(5)...
            %            -10*obj.prm.p2^3.*tStateVariable(6) -5*obj.prm.p2^4.*tStateVariable(7)...
            %            -obj.prm.p2^5.*tStateVariable(8) + obj.prm.p2^5.*Qtilde_d(2);


            dxdt(1) = obj.FDen1.Denominator{1,1}(1,end) *obj.FGain(1)* Qtilde_d(1);
            for i=1:4
                dxdt(1) = dxdt(1) - obj.FDen1.Denominator{1,1}(1,i+1) * tStateVariable(i);
            end

            dxdt(5) = obj.FDen2.Denominator{1,1}(1,end) *obj.FGain(2)* Qtilde_d(2);
            for i=1:6
                dxdt(5) = dxdt(5) - obj.FDen2.Denominator{1,1}(1,i+1) * tStateVariable(i+4);
            end
            dxdt(2:4) = tStateVariable([1:3],1);
            dxdt(6:10) = tStateVariable(5:9,1);
        end
        
        function operatorOutput =  calcNextCycle(obj,Qtilde_d)
            obj.stateVariable = cMoritaRungeKuttaMethod(obj,Qtilde_d);

            %Q^{-1} tildeN^{-1}をここで実装する
               tildeU1 = 0;
               for i = 1:4
                   tildeU1 = tildeU1 + obj.tildeNDeb1(1,i)*obj.stateVariable(i);
               end
               tildeU2 = 0;
               for i = 1:6
                   tildeU2 = tildeU2 + obj.tildeNDeb2(1,i)*obj.stateVariable(i+4);
               end
               tildeU = [tildeU1; tildeU2];
        
            operatorOutput =  tildeU;%obj.stateVariable([4,10]);
        end



    end
end