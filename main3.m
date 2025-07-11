clear ;
close all;
addpath(pwd + "\plant\", pwd + "\Abstract\")
%% 実験条件
    max_time =1199;
    blockNum = 3;
    liquidVelocityGain = 1.00;
    dt = 1;

    t = 0:dt:max_time;
    liquidVelocity = 0.002*liquidVelocityGain;
    isCompensateD1 = true;
    isCompensateD2 = true;

%% 目標値 & パラメータ
    alpah_l = 16;
    tau = 40;
    p1 = 0.3;
    p2 = 0.3;
    refTimePrm = 1/30;  
    ref =0.4*[0.3, 0, 0.1/liquidVelocityGain;...
               0.3, 0, 0.18/liquidVelocityGain;...
               0.5, 0, 0.27/liquidVelocityGain];
%% 初期化
    prm =  CalcOperatorPrm_ekion(outsideTemperature=27.00,i_max=3,i_min=0,velocity=liquidVelocity,tau=tau,p1=p1,p2= p2,... 
                                 heatTransferCoef_air=270,heatTransferCoef_tube=270,heatTransferCoef_liquid=alpah_l,...
                                 isRugekuttaMethodUse=true,isInterferrence=true,isCompensateD1=isCompensateD1,isCompensateD2=isCompensateD2);
    variable= getVariableFunction(blockNum,t,refTimePrm,ref);
    plant = LegacyPlantAdapter(prm=prm,dt=dt,cycleNum=length(t),blockNum=blockNum);
    operator = struct("control",struct("InvB",{cell(blockNum,1)},"Compensate",{cell(blockNum,1)}),"debug",struct("NInvM",{cell(blockNum,1)},"Q",{cell(blockNum,1)}),...
                "bezoutCheck",struct("N",{ControllerN(prm=prm,dt=dt,cycleNum=length(t))}, "InvB",{ControllerInvB(prm=prm,dt=dt,cycleNum=length(t))}, ...
                                    "InvD",{ControllerInvD(prm=prm,dt=dt,cycleNum=length(t))},"Q",{ControllerQ(prm=prm,dt=dt,cycleNum=length(t))},  ...
                                    "NInvM",{ControllerN(prm=prm,dt=dt,cycleNum=length(t))}));
    
    for blockId = 1:blockNum
        operator.control.InvB{blockId} = ControllerInvB(prm=prm,dt=dt,cycleNum=length(t)); 
        operator.control.Compensate{blockId} = ControllerCompemsate(prm=prm,dt=dt,cycleNum=length(t));    
        %debug
        operator.debug.NInvM{blockId} = ControllerN(prm=prm,dt=dt,cycleNum=length(t));
        operator.debug.Q{blockId} = ControllerQ(prm=prm,dt=dt,cycleNum=length(t));
    end
    % tDebugX1 =  {zeros(3,1)};
    variable.debug_y(:,1) = zeros(2,1);
%% 作業用変数
    % debugInvQF1 = ControllerInvQF1(prm=prm,dt=dt,cycleNum=length(t));
    % debugInvTildeNF2 = ControllerInvTildeNF2(prm=prm,dt=dt,cycleNum=length(t));
    % debugN{55} = ControllerN(prm=prm,dt=dt,cycleNum=length(t)); 
    % debugN{54} = ControllerQ(prm=prm,dt=dt,cycleNum=length(t)); 

%%　外乱の定義
   variable.disturbunceYa(:,1) = 0;
   variable.disturbunceY(:,1) = 0;
   variable.disturbunceYl(:,1) = 0;

for cycleCount = 1:length(t)
   for blockId =1:blockNum
%% debug (NM^{-1})
        variable.debug_NInvM([3*blockId-2,3*blockId],cycleCount+1) ...
            = operator.debug.NInvM{blockId}.calcNextCycle(1./prm.MOperatorConstPrm([1,3],1).* operator.debug.Q{blockId}.calcNextCycle(variable.ref([3*blockId-2,3*blockId],cycleCount)));

%% comepensator
        if cycleCount == 1
            uPrevious = zeros(3,1);
        else
            uPrevious = variable.u(3*blockId-2:3*blockId,cycleCount-1);
        end
        compensatorOutput  = operator.control.Compensate{blockId}.calcNextCycle(uPrevious=uPrevious,yaMeasure=variable.y_a(3*blockId-2:3*blockId,cycleCount),...
                                                                        yMeasure=variable.y(4*blockId-3:4*blockId,cycleCount),ylMeasure=variable.y_l(4*blockId-3:4*blockId,cycleCount));
        variable.f_1([3*blockId-2,3*blockId],cycleCount) = compensatorOutput([1,2],1);
        variable.f_2([3*blockId-2,3*blockId],cycleCount) = compensatorOutput([3,4],1);
        variable.f(3*blockId-2:3*blockId,cycleCount) = variable.f_1(3*blockId-2:3*blockId,cycleCount) - variable.f_2(3*blockId-2:3*blockId,cycleCount);

%% operator main
        variable.e_asterisk(3*blockId-2:3*blockId,cycleCount) = variable.ref(3*blockId-2:3*blockId,cycleCount)...
                    - [variable.y(4*blockId-3,cycleCount); 0; variable.y_l(4*blockId,cycleCount)]...
                    + 1.* (variable.f_1(3*blockId-2:3*blockId,cycleCount) - variable.f_2(3*blockId-2:3*blockId,cycleCount));
        invBInput = variable.e_asterisk([3*blockId-2,3*blockId],cycleCount);
        vector2U = operator.control.InvB{blockId}.calcNextCycle(invBInput);
        variable.u(3*blockId-2:3*blockId,cycleCount) = [vector2U(1); 0; vector2U(2)];
   end

%% plnat
        plantVariable = plant.calcNextCycle(u =variable.u(:,cycleCount), disturbunceYa =variable.disturbunceYa(:,cycleCount),...
                                           disturbunceY =variable.disturbunceY(:,cycleCount),disturbunceYl =variable.disturbunceYl(:,cycleCount)); 
        variable.y_a(:,cycleCount+1) = plantVariable.y_a;
        variable.y(:,cycleCount+1) = plantVariable.y;
        variable.y_l(:,cycleCount+1) = plantVariable.y_l;

    %作業用
    % variable.unko7(:,cycleCount) =debugInvTildeNF2.calcNextCycle([1; 1]);
    % variable.unko5(:,cycleCount) =debugN{54}.calcNextCycle(variable.unko7(:,cycleCount)); %Q
    % variable.unko6(:,cycleCount) =debugN{55}.calcNextCycle(variable.unko5(:,cycleCount)); %N

    %Bezout check
    ref = 0.05*[1;1];
    variable.debug_e(:,cycleCount) = ref - variable.debug_y(:,cycleCount);
    variable.debug_u(:,cycleCount) =  operator.bezoutCheck.InvB.calcNextCycle(variable.debug_e(:,cycleCount));
    variable.debug_ya(:,cycleCount+1) = operator.bezoutCheck.InvD.calcNextCycle(variable.debug_u(:,cycleCount));
    variable.debug_y(:,cycleCount+1) = operator.bezoutCheck.N.calcNextCycle(variable.debug_ya(:,cycleCount+1));
    variable.debug_NInvMBezout(:,cycleCount+1) = operator.bezoutCheck.NInvM.calcNextCycle(1./prm.MOperatorConstPrm([1,3],1).* ...
                                                        operator.bezoutCheck.Q.calcNextCycle(ref));
end

%plot:debug
debugMicoreactorPlotter(blockNum,t,variable);

%Bezout等式確認
% plot(variable.debug_y(1,:))
% hold on
% plot(variable.debug_NInvMBezout(1,:))








