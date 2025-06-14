classdef ControlN < handle
    properties
        %デバッグ用
    end

    properties (SetAccess = immutable, GetAccess=public) %読み取り専用＆外部からアクセスする用
        prm
        dt
        isRugekuttaMethodUse
        comment
        cycleNum
        debugVectorCell
    end


    properties (SetAccess = public, GetAccess = public) %書き換え可能＆外部からアクセスする用
        %状態変数5個
        stateVariable


        %デバッグ用変数
    end

    methods
        %コンストラクタ
        function obj = ControlN(options)
            %設定の初期化
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


            %変数の初期化
            obj.debugVectorCell = {};
            obj.stateVariable = zeros(5,1);
        end





        
        %dxdtを取得する関数
        function dxdt = getDxdt(obj,ya13,tStateVariable)
            dxdt = zeros(5,1);
            y_prev = [tStateVariable(1); 0; tStateVariable(2)];
            y_l_prev = [0; 0; tStateVariable(4)];
            adjacentElementsY = [0; 0; tStateVariable(3)];%両サイドのy
            adjacentElementsYl = [0; 0; tStateVariable(5)];%両サイドのyl

            %% partW1
            dxdt(1) = obj.prm.interferrencePrm.y_aw(1) .*(ya13(1)  - y_prev(1))./obj.prm.tube.mwcw(1);
            dxdt(1) = dxdt(1) - obj.prm.tube.A_w(1).*y_prev(1);


            %% partW3~%partL4を1まとまりにした処理を以下に実装する

            %partW3 
            interferenceW3 = +obj.prm.interferrencePrm.y_aw(3) * (-y_prev(3) + ya13(2))...
                             +obj.prm.interferrencePrm.y_wl(3) * (-y_prev(3) + y_l_prev(3))...
                             +obj.prm.interferrencePrm.y_w4k * (-y_prev(3) + adjacentElementsY(3));
            dxdt(2) = - obj.prm.tube.A_w(3).*y_prev(3) + interferenceW3 /obj.prm.tube.mwcw(3);
            %partW4
            interferenceW4 = -obj.prm.tube.tubeAirConstPrm * adjacentElementsY(3)...
                                       + obj.prm.interferrencePrm.y_w4k * (-adjacentElementsY(3) + y_prev(3))...
                                       + obj.prm.interferrencePrm.y_wl4k * (-adjacentElementsY(3) + adjacentElementsYl(3));
            dxdt(3) = - obj.prm.tube.apxA_w4k.*adjacentElementsY(3) + interferenceW4 /obj.prm.tube.mwcw4k;
            % partL3 (A_lは発散エネルギーがないため省略)
            interferenceL3 = +obj.prm.interferrencePrm.y_wl(3) * (-y_l_prev(3) + y_prev(3))...
                             +obj.prm.interferrencePrm.y_l(3) * (-y_l_prev(3));
            dxdt(4) = interferenceL3 / obj.prm.liquid.mlcl(3);
            %partL4
            interferenceL4 = +obj.prm.interferrencePrm.y_wl4k * (-adjacentElementsYl(3)  + adjacentElementsY(3))...
                             +obj.prm.interferrencePrm.y_l(3) * (-adjacentElementsYl(3)  + y_l_prev(3));
            dxdt(5) = interferenceL4 / obj.prm.liquid.mlcl4k;

            % dxdt = dxdt ./ [1; obj.prm.tube.mwcw(3); obj.prm.tube.mwcw4k; obj.prm.liquid.mlcl(3); obj.prm.liquid.mlcl4k];

            
        end
        

        %update
        function operatorOutput =  calcNextCycle(obj,ya13)
            obj.stateVariable = cMoritaRungeKuttaMethod(obj,ya13);
            operatorOutput = obj.stateVariable([1,5],1);
        end



    end
end