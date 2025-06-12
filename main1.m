clear ;
close all;
max_time = 4000;
dt = 1;
t = 0:dt:max_time;
blockNum = 10;
ref = [3.8; 0; 4];
liquidVelocity = 0.002*3.75*0.1;
alpah_l = 14;


sum =0;
p=1;
i=0.005;

prm =  CalcOperatorPrm_ekion(outsideTemperature=27.05,i_max=2,i_min=0,...
                             heatTransferCoef_air=270,heatTransferCoef_tube=270,heatTransferCoef_liquid=alpah_l,velocity = liquidVelocity,...
                           isRugekuttaMethodUse=true,isInterferrence=true);
variable= getVariableFunction(blockNum,length(t),ref);
addInterferenceElements = cell(blockNum,1);
variable.u(1:12,1:end) = 0.5;
% variable.u([1,3,4,6,7,9],601:end) = 0.5;


for cycleCount = 2:length(t)

    %% controller
    % variable.e(1,cycleCount) = 0.2 -variable.y_l(20,cycleCount);
    % sum = sum + dt*variable.e(1,cycleCount);
    % variable.u(1:3,cycleCount) = p*variable.e(1,cycleCount) + sum*i;


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

plot(variable.y_l(:,1000),"Color","r")
hold on
plot(variable.y(:,1000),"Color","b")

figure(2);
plot(variable.y_l(20,:));







%plotData
tempData = prm.experimentalSettings.outsideTemperature - transpose([variable.y([1,3],1:end-1); variable.y_l(3,1:end-1)]);
timeData = transpose(t);
inputData = transpose(variable.u([1,3],:)); 
RefData = prm.experimentalSettings.outsideTemperature - transpose(variable.ref([1,3],:)); 
plotTempData = [tempData];
plotInputData = inputData;


%% makeGraph
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
