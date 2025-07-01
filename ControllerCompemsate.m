classdef ControllerCompemsate < handle & Operator & Integrator
    properties
        %デバッグ用
    end

    properties (SetAccess = immutable, GetAccess=public) %読み取り専用＆外部からアクセスする用
    end


    properties (SetAccess = public, GetAccess = public) %書き換え可能＆外部からアクセスする用
        yaTilde
        yTilde
        Q_tilde_d1
        tilde_d2
        f_m
        f_n
        f_1
        f_2

        %観測値の保持
        yaPrevious

        %インスタンス
        operatorInstanceN1
        operatorInstanceN2
        operatorInstanceInvD
        operatorInstanceInvQF1
        operatorInstanceInvTildeNF2

    end

    methods
        function obj = ControllerCompemsate(options)
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


            %所持インスタンス
            obj.operatorInstanceInvD = ControllerInvD(prm=obj.prm,dt=obj.dt,cycleNum=obj.cycleNum,comment="Has-a Compensator");
            obj.operatorInstanceN1 = ControllerN(prm=obj.prm,dt=obj.dt,cycleNum=obj.cycleNum,comment="Has-a Compensator");
            obj.operatorInstanceN2 = ControllerN(prm=obj.prm,dt=obj.dt,cycleNum=obj.cycleNum,comment="Has-a Compensator");
            obj.operatorInstanceInvQF1 = ControllerInvQF1(prm=obj.prm,dt=obj.dt,cycleNum=obj.cycleNum,comment="Has-a Compensator");
            obj.operatorInstanceInvTildeNF2 = ControllerInvTildeNF2(prm=obj.prm,dt=obj.dt,cycleNum=obj.cycleNum,comment="Has-a Compensator");


            %変数の初期化
            obj.debugVectorCell = {};


            %1ステップ前の値
            obj.yaPrevious = zeros(2,1); 

            %
            obj.yaTilde = zeros(2,1); 
            obj.yTilde = zeros(2,1); 
            obj.Q_tilde_d1= zeros(2,1); 
            obj.tilde_d2 = zeros(2,1); 
            obj.f_m = zeros(2,1); 
            obj.f_n = zeros(2,1); 
            obj.f_1 = zeros(2,1); 
            obj.f_2 = zeros(2,1); 
        end 

        %update
        function operatorOutput =  calcNextCycle(obj,options)
            arguments
                obj 
                options.uPrevious = zeros(3,1);
                options.yaMeasure = zeros(3,1);
                options.yMeasure = zeros(4,1);
                options.ylMeasure = zeros(4,1); 
            end

            uPrevious = options.uPrevious;
            yaMeasure = options.yaMeasure([1,3],1);
            yMeasure = options.yMeasure([1,4],1);
            ylMeasure = options.ylMeasure([1,4],1);


            %invD & Q_tilde_d1
            obj.yaTilde = obj.operatorInstanceInvD.calcNextCycle([uPrevious]);
            obj.Q_tilde_d1= yaMeasure - obj.yaTilde;
            

            %N & tilde_d2
            obj.yTilde = obj.operatorInstanceN2.calcNextCycle([obj.yaPrevious]);
            if obj.prm.experimentalSettings.isCompensateD2
                obj.tilde_d2 = [yMeasure(1); ylMeasure(2)] -  obj.yTilde;
            else
                obj.tilde_d2 = [0; 0;];
            end

            %f_m & M & invQ F1
            F1Output = obj.operatorInstanceInvQF1.calcNextCycle([obj.Q_tilde_d1]);
            obj.f_m = obj.prm.MOperatorConstPrm([1;3],1) .* F1Output;
            
            %N1 & f_n
            obj.f_n = obj.operatorInstanceN1.calcNextCycle([obj.Q_tilde_d1]);

            %f_1
            if obj.prm.experimentalSettings.isCompensateD1
                obj.f_1 = obj.f_n - obj.f_m + obj.tilde_d2;
            else
                obj.f_1 =  obj.tilde_d2;
            end

            %(NQ)^{-1} F2
            g = obj.operatorInstanceInvTildeNF2.calcNextCycle(obj.tilde_d2);
            obj.f_2 = obj.prm.MOperatorConstPrm([1;3],1) .* g;
            if ~obj.prm.experimentalSettings.isCompensateD2
                obj.f_2 = [0; 0;];
            end

            %1ステップ前の値として保持
            obj.yaPrevious = yaMeasure;

            operatorOutput = [obj.f_1; obj.f_2; F1Output];
        end



    end
end