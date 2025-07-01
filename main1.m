clear ;
% close all;
max_time = 500;
dt = 1;
t = 0:dt:max_time;
blockNum = 3;
liquidVelocityGain = 1.00;
ref =0.4*[0.3, 0, 0.1;...
           0.3, 0, 0.18;...
           0.5, 0, 0.27];
liquidVelocity = 0.002*liquidVelocityGain;
alpah_l = 16;
heatTransferCoefAir_tube = 10;
tau = 50;
ref(:,3) = 1/liquidVelocityGain*ref(:,3);

% ref(3,:) = 0.4*ref(3,:);
% ref(3,3) = 1.5*ref(3,3);

prm =  CalcOperatorPrm_ekion(outsideTemperature=27.05,i_max=3,i_min=0,...
                             heatTransferCoef_air=270,heatTransferCoef_tube=270,heatTransferCoef_liquid=alpah_l,...
                             heatTransferCoefAir_tube = heatTransferCoefAir_tube,velocity = liquidVelocity,...
                             tau = tau, p1 = 0.2, p2= 0.3,... 
                           isRugekuttaMethodUse=false,isInterferrence=true);
variable= getVariableFunction(blockNum,length(t),ref(:,1));


refTimePrm = 1/30;

%% インスタンスの定義

%bezout identitiy
controlN = cell(blockNum,1);
controlInvD = cell(blockNum,1);
controlInvB = cell(blockNum,1);

%disturbunce comensator
controlCompensate = cell(blockNum,1);

%debugCell
debugN = cell(blockNum,1);
debugInvD = cell(blockNum,1);
debugInvB = cell(blockNum,1);
debugX2  = cell(blockNum,1);


for blockId = 1:blockNum
    variable.ref(3*blockId-2:3*blockId,:) = [ref(blockId, 1); 0; ref(blockId, 3)].* (1 - exp(-refTimePrm*t)  );
    controlN{blockId} = ControlN(prm=prm,dt=dt,cycleNum=length(t)); 
    controlInvD{blockId} = ControlInvD(prm=prm,dt=dt,cycleNum=length(t)); 
    controlInvB{blockId} = ControlInvB(prm=prm,dt=dt,cycleNum=length(t)); 
    controlCompensate{blockId} = DsiturbunceCompemsator(prm=prm,dt=dt,cycleNum=length(t)); 

    %debug
    debugN{blockId} = ControllerN(prm=prm,dt=dt,cycleNum=length(t));
    debugInvD{blockId} = ControlInvD(prm=prm,dt=dt,cycleNum=length(t)); 
    debugInvB{blockId} = ControlInvB(prm=prm,dt=dt,cycleNum=length(t)); 
    debugX2{blockId} = zeros(3,1);
end

addInterferenceElements = cell(blockNum,1);







%% debug variable
debugX3 = zeros(2,1);
% % % % debugInvQF1 = ControlInvQF1(prm=prm,dt=dt,cycleNum=length(t));
debugInvTildeNF2 = ControlInvTildeNF2(prm=prm,dt=dt,cycleNum=length(t));

variable.debug_y(:,2) = [0;0];
debugN{55} = ControlN(prm=prm,dt=dt,cycleNum=length(t)); 
debugX1 = zeros(3,1);


%% control cycle
for cycleCount = 2:length(t)

    %% 右分解の確認
    % ref = 0.05*[1;1];
    % variable.debug_e(:,cycleCount) = 0.005*[1;1];%ref - variable.debug_y(:,cycleCount);
    % variable.debug_u(:,cycleCount) =  debugInvB{1}.calcNextCycle(variable.debug_e(:,cycleCount));
    % variable.debug_ya(:,cycleCount+1) = debugInvD{1}.calcNextCycle(variable.debug_u(:,cycleCount));
    % variable.debug_y(:,cycleCount+1) = debugN{1}.calcNextCycle([1,1]);%variable.debug_ya(:,cycleCount+1));
    % debugX1 = moritaEulerMethod(@getQDxdt,cycleCount,dt,[[ref(1); 0; ref(2)],debugX1,zeros(3,1)],prm,1,0);
    % variable.debug_NInvM(:,cycleCount+1) = debugN{2}.calcNextCycle(1./prm.MOperatorConstPrm([1,3],1).* debugX1([1,3],1));

    %% controller
    for blockId =1:blockNum
        %% debug (NM^{-1})
        debugX2{blockId} = moritaEulerMethod(@getQDxdt,cycleCount,dt,[variable.ref(3*blockId-2:3*blockId,cycleCount),debugX2{blockId},zeros(3,1)],prm,1,0);
        variable.debug_NInvM([3*blockId-2,3*blockId],cycleCount+1) = debugN{blockId}.calcNextCycle(1./prm.MOperatorConstPrm([1,3],1).* debugX2{blockId}([1,3],1));

        %% comepensator
        if cycleCount == 1
            uPrevious = zeros(3,1);
        else
            uPrevious = variable.u(3*blockId-2:3*blockId,cycleCount-1);
        end
        compensatorOutput  = controlCompensate{blockId}.calcNextCycle(uPrevious=uPrevious,...
                                                                        yaMeasure=variable.y_a(3*blockId-2:3*blockId,cycleCount),...
                                                                        yMeasure=variable.y(4*blockId-3:4*blockId,cycleCount),...
                                                                        ylMeasure=variable.y_l(4*blockId-3:4*blockId,cycleCount));
        variable.f_1([3*blockId-2,3*blockId],cycleCount) = compensatorOutput([1,2],1);
        variable.f_2([3*blockId-2,3*blockId],cycleCount) = compensatorOutput([3,4],1);

        variable.f(3*blockId-2:3*blockId,cycleCount) = variable.f_1(3*blockId-2:3*blockId,cycleCount) - variable.f_2(3*blockId-2:3*blockId,cycleCount);


        %% operator main
        variable.e_asterisk(3*blockId-2:3*blockId,cycleCount) = variable.ref(3*blockId-2:3*blockId,cycleCount)...
            - [variable.y(4*blockId-3,cycleCount); 0; variable.y_l(4*blockId,cycleCount)]...
            + 0.* (variable.f_1(3*blockId-2:3*blockId,cycleCount) - variable.f_2(3*blockId-2:3*blockId,cycleCount));
        invBInput = variable.e_asterisk([3*blockId-2,3*blockId],cycleCount);
        vector2U = controlInvB{blockId}.calcNextCycle(invBInput);
        variable.u(3*blockId-2:3*blockId,cycleCount) = [vector2U(1); 0; vector2U(2)];
    end



    %% debug
        % variable.unko4(:,cycleCount) =debugInvQF1.calcNextCycle([1;1]);
        variable.unko5(:,cycleCount) =debugN{55}.calcNextCycle([2;2]);
        variable.unko6(:,cycleCount) =debugInvTildeNF2.calcNextCycle(variable.unko5(:,cycleCount));
        variable.unko7(:,cycleCount) = compensatorOutput([5,6]);

    %% plnat
    for blockId =1:blockNum %addInterferenceElements  
            if blockId ==1
                addInterferenceElements{blockId} ...
                    = [[variable.y(1,cycleCount); 0; variable.y(4*blockId,cycleCount)] , [0; 0; variable.y_l(4*blockId,cycleCount)]];
            else
                addInterferenceElements{blockId} ...
                    = [[variable.y(4*blockId-4,cycleCount); 0; variable.y(4*blockId,cycleCount)] ,...
                      [variable.y_l(4*blockId-4,cycleCount); 0; variable.y_l(4*blockId,cycleCount)]];
            end
     end

    for blockId =1:blockNum  %box内のプラント
        variable.y_a(3*blockId-2:3*blockId,cycleCount+1)= D_inv(cycleCount,dt,...
                    [variable.u(3*blockId-2:3*blockId,cycleCount),variable.y_a(3*blockId-2:3*blockId,cycleCount),...
                    variable.y(4*blockId-3:4*blockId-1,cycleCount),addInterferenceElements{blockId}],prm);

        variable.y(4*blockId-3:4*blockId-1,cycleCount+1) = N(cycleCount,dt,...
                    [variable.y_a(3*blockId-2:3*blockId,cycleCount),variable.y(4*blockId-3:4*blockId-1,cycleCount),...
                    variable.y_l(4*blockId-3:4*blockId-1,cycleCount),addInterferenceElements{blockId}],prm);

        variable.y_l(4*blockId-3:4*blockId-1,cycleCount+1) = LiquidPlant(cycleCount,dt,...
                    [variable.y(4*blockId-3:4*blockId-1,cycleCount),variable.y_l(4*blockId-3:4*blockId-1,cycleCount),...
                    zeros(3,1),addInterferenceElements{blockId}],prm);
    end

    for blockId =1:blockNum %part4k (k=1,2,3...)
        if blockId~=blockId
            connectTubePlantElements = [zeros(3,1),variable.y(4*blockId-1:4*blockId+1,cycleCount),...
                   variable.y_l(4*blockId-1:4*blockId+1,cycleCount),zeros(3,2)];
            connectLiquidPlantElements = [variable.y(4*blockId-1:4*blockId+1,cycleCount),...
                   variable.y_l(4*blockId-1:4*blockId+1,cycleCount),zeros(3,1),zeros(3,2)];
        else
            connectTubePlantElements = [zeros(3,1),[variable.y(4*blockId-1:4*blockId,cycleCount);  variable.y(4*blockId,cycleCount)],...
                   [variable.y_l(4*blockId-1:4*blockId,cycleCount); variable.y_l(4*blockId,cycleCount)],zeros(3,2)];
            connectLiquidPlantElements = [[variable.y(4*blockId-1:4*blockId,cycleCount); variable.y(4*blockId,cycleCount)],...
                   [variable.y_l(4*blockId-1:4*blockId,cycleCount); variable.y_l(4*blockId,cycleCount)],zeros(3,1),zeros(3,2)];
        end
        variable.y(4*blockId,cycleCount+1) = N(cycleCount,dt,connectTubePlantElements,prm,4);
        variable.y_l(4*blockId,cycleCount+1) = LiquidPlant(cycleCount,dt,connectLiquidPlantElements,prm,4);
    end


end

debugMicoreactorPlotter(blockNum,t,variable);


% %ya系列をyl系列に変換する処理
% variable.plotYa = NaN(4 * blockNum, length(variable.y_a));  
% variable.plotRef1 = NaN(4 * blockNum, length(variable.ref)); 
% variable.plotRef2 = NaN(4 * blockNum, length(variable.ref));  
% 
% for i = 1:blockNum
%     idx_in = (i-1)*3 + 1;
%     idx_out = (i-1)*4 + 1;
%     variable.plotYa(idx_out:idx_out+2,:) = variable.y_a(idx_in:idx_in+2,:);  
%     variable.plotRef1(idx_out:idx_out+2,:) = variable.ref(idx_in:idx_in+2,:);
%     variable.plotRef2(idx_out+1:idx_out+3,:) = variable.ref(idx_in:idx_in+2,:);
%     variable.plotRef2(idx_out:idx_out+2,:) = NaN;
%     variable.plotRef1(idx_out+1:idx_out+2,:) = NaN;
% end
% figure(1);
% plot(variable.y_l(:,length(t)-3),"Color","r")
% hold on
% plot(variable.y(:,length(t)-3),"Color","b")
% % plot(variable.ref(1,1)*ones(size(variable.y(:,1000))),"--")
% plot(variable.plotRef1(:,length(t)-3),"o","LineWidth",2,"Color","b")
% plot(variable.plotRef2(:,length(t)-3),"o","LineWidth",2,"Color","r")
% legend("yl_{4n}[C^{\circ}]","y_{4n-3}[C^{\circ}]","ref_{3k-2}[C^{\circ}]","ref_{3k}[C^{\circ}]","fontsize",15,"location","northwest")
% title("t=" + string(length(t)-3) + "[s]" +"  All Box temperature","fontsize",18)
% 
% 
% figure('Position', [2000, 000, 1500*0.8, 1200*0.8]);
% for blockId = 1:blockNum
%         % figure(blockId+30);
%         subplot(3,2,2*blockId-1)
%         plot(variable.y_l(4*blockId,:))
%         hold on
%         plot(variable.y(4*blockId-3,:),"Color","r")
%         plot(variable.y(4*blockId-1,:),"Color","b")
%         plot(variable.debug_NInvM(3*blockId-2,:),"--")
%         plot(variable.debug_NInvM(3*blockId,:),"--")
%         ylim([0 max(max(variable.y(:,end)),max(variable.y(4*blockNum-1,:)))])
%         legend("yl"+string(4*blockId)+"[C^{\circ}]","y"+string(4*blockId-3)+"[C^{\circ}]","y"+string(4*blockId-1)+"[C^{\circ}]","fontsize",12)
%         title("Box:" + string(blockId) +"  Temperature","fontsize",18)
% 
%         subplot(3,2,2*blockId)
%         plot(variable.u(3*blockId-2,:))
%         hold on
%         plot(variable.u(3*blockId,:))
%         legend("u"+string(3*blockId-2)+"[A]","u"+string(3*blockId)+"[A]","fontsize",12)
%         title("Box:" + string(blockId) +"  Current","fontsize",18)
% end



% figure(4);
% plot(variable.y_l(8,:))
% hold on
% plot(variable.y(5,:),"Color","r")
% % plot(variable.y(7,:),"Color","b")
% plot(variable.debug_NInvM(4,:),"--")
% plot(variable.debug_NInvM(6,:),"--")
% 
% figure(5);
% plot(variable.y_l(12,:))
% hold on
% plot(variable.y(9,:),"Color","r")
% % plot(variable.y(11,:),"Color","b")
% plot(variable.debug_NInvM(7,:),"--")
% plot(variable.debug_NInvM(9,:),"--")

% figure(4)
% hold on
% plot(variable.u(4,:),"Color","r")
% plot(variable.u(6,:),"Color","b")


%Dが取れているかの確認
% figure(3);
% plot(debugInvB{1}.debugVectorCell{1,4}(1,:))
% hold on
% plot(variable.debug_ya(1,:),"Color","r")
% plot(variable.debug_NInvM(2,:),"--")
% unko55 = variable.debug_ya(2,1:end-1) - controlInvB{1}.debugVectorCell{1,4}(3,:);

%Nの逆取れているか
% figure()
% plot(variable.unko6(1,:))
% hold on 
% plot(variable.unko6(2,:))




% plotData
tempData = prm.experimentalSettings.outsideTemperature - transpose([variable.y([1,3],1:end-1); variable.y_l(3,1:end-1)]);
timeData = transpose(t);
inputData = transpose(variable.u([1,3],:)); 
RefData = prm.experimentalSettings.outsideTemperature - transpose(variable.ref([1,3],:)); 
plotTempData = [tempData];
plotInputData = inputData;


% makeGraph
FILE_IS_SAVE=false;
graphToolPath="C:\Users\mykot\OneDrive - Tokyo University of Agriculture and Technology (1)\60MATLAB_sagyou\makeGraph";
addpath(graphToolPath);
DATA_DIR_PATH = "C:\Users\mykot\OneDrive - Tokyo University of Agriculture and Technology (1)\60MATLAB_sagyou\kato_simulation\graph"; %exp 
OUT_DIR_PATH = "C:\Users\mykot\OneDrive - Tokyo University of Agriculture and Technology (1)\60MATLAB_sagyou\kato_simulation\graph\";
TEMPERATURE_GRAPH_TITLE = ["temperature(ronbun_hikaku)"];
TEMPERATURE_LINE_NAME = ["$\mathrm{Part} \mathrm{W_1}$","$$\mathrm{Part} \mathrm{W_3}$","$$\mathrm{Part} \mathrm{L_3}$"];
TEMPERATURE_LINE_WIDTH = [2,2,2];
TEMPERATURE_LABEL_NAME = ["Time [$\mathrm{s}]$","Temperature [$^{\circ}\mathrm{C}]$"];
TEMPERATURE_LINE_STYLE = ["-","-","-",];


CONTROLINPUT_GRAPH_TITLE = ["controlInput(ronbun_hikaku)"];
CONTROLINPUT_LINE_NAME = ["$u_1$","$u_3$"];
CONTROLINPUT_LABEL_NAME = ["Time [$\mathrm{s}]$","Current [$\mathrm{A}$]"];
% %温度
% % plotTempData = prm.settings.outsideTemperature-[transpose(variable.ref([1,3],:)) ,transpose(variable.y([1,3],:))]; %
% makeGraph(t',plotTempData, ...
%                     "lineName",TEMPERATURE_LINE_NAME, ...
%                     "lineStyle",TEMPERATURE_LINE_STYLE, ...
%                     "lineWidth",TEMPERATURE_LINE_WIDTH, ...
%                     "labelName",TEMPERATURE_LABEL_NAME, ...
%                     "graphName",TEMPERATURE_GRAPH_TITLE, ...
%                     "location","southWEST", ...
%                     "lineWidth",[1,1,1,1], ..."yLimit",[22.4 27.5],...
%                     "isSave",FILE_IS_SAVE,"outDir",OUT_DIR_PATH, ...
%                     "fontSize",16,"LabelFontSize",30,"saveFileExt","jpg");
% %制御入力
% % plotInputData = transpose(variable.u([1,3],:)); %
% makeGraph(t',plotInputData , ...
%                     "lineName",CONTROLINPUT_LINE_NAME, ...
%                     "lineWidth",[2,2], ...
%                     "labelName",CONTROLINPUT_LABEL_NAME, ...
%                     "yLimit",[0,0.6],...
%                     "location","northwest",...
%                     "graphName",CONTROLINPUT_GRAPH_TITLE, ...
%                     "isSave",FILE_IS_SAVE,"outDir",OUT_DIR_PATH, ...
%                     "fontSize",20,"LabelFontSize",30,"saveFileExt","jpg");




% %実機データ
% load("C:\Users\mykot\OneDrive - Tokyo University of Agriculture and Technology (1)\60MATLAB_sagyou\MicroreactorSystem1\data\1002_unko.mat");
% tempData = data.data.temperature.sensor(3:end,[4,6,5]);
% timeData = data.data.time(3:end,:);
% RefData = data.data.temperature.ref(3:end,:);
% inputData = data.data.other(3:end,[1,2]);
% 
% 
% % plot(variable.y_a(1,:),LineWidth=2);
% hold on 
% 
% % %jikki
% % plot(tempData(1,3) - tempData(:,1),LineWidth=1);
% % plot(tempData(1,3) - tempData(:,2),LineWidth=1);
% % plot(tempData(1,3) - tempData(:,3),LineWidth=1);
% 
% %simulation
% % plot(variable.y_a(2,:),LineWidth=2);
% % plot(variable.y_a(3,:));
%  plot( prm.experimentalSettings.outsideTemperature - variable.y(1,:),LineWidth=2)
% % plot(variable.y(2,:),LineWidth=2)
% plot(prm.experimentalSettings.outsideTemperature - variable.y(3,:),LineWidth=2)
% plot(prm.experimentalSettings.outsideTemperature - variable.y_l(3,:),LineWidth=2);
% 
% 
