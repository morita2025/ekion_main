clear ;
close all;
max_time = 1200;
dt = 1;
t = 0:dt:max_time;
ref = [3.8; 4];
liquidVelocity = 0.05;
alpah_l = 14;


prm =  CalcOperatorPrm_ekion(outsideTemperature=27.05,i_max=2,i_min=0,...
                             heatTransferCoef_air=270,heatTransferCoef_tube=270,heatTransferCoef_liquid=alpah_l,velocity = liquidVelocity,...
                           isRugekuttaMethodUse=true,isInterferrence=true);
variable= getVariableFunction(length(t),ref);

variable.u([1,3],1:600) = 0.3;
variable.u([1,3],601:end) = 0.5;

for cycleCount = 2:length(t)
        
    %% プラント(右分解)
    variable.y_a(:,cycleCount+1)= D_inv(cycleCount,dt,...
                [variable.u(:,cycleCount),variable.y_a(:,cycleCount),variable.y(:,cycleCount)],...
                prm);

    variable.y(:,cycleCount+1) = N(cycleCount,dt,...
        [variable.y_a(:,cycleCount),variable.y(:,cycleCount),variable.y_l(:,cycleCount)],...
        prm);

    variable.y_l(:,cycleCount+1) = LiquidPlant(cycleCount,dt,...
        [variable.y(:,cycleCount),variable.y_l(:,cycleCount),zeros(3,1)],...
        prm);

end

load("発表ゼミ1108速度変えたときのyl.mat")
ylSyuugou = [yl0;yl1;yl2;yl3;yl4];


%plotData
tempData = prm.experimentalSettings.outsideTemperature - transpose(ylSyuugou(:,1:end-1));
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
TEMPERATURE_LINE_WIDTH = [2,2,2,2,2];
TEMPERATURE_LABEL_NAME = ["Time [$\mathrm{s}]$","Temperature [$^{\circ}\mathrm{C}]$"];
TEMPERATURE_LINE_STYLE = ["-","-","-","-","-"];


CONTROLINPUT_GRAPH_TITLE = ["controlInput(ronbun_hikaku)"];
CONTROLINPUT_LINE_NAME = ["$u_1$","$u_3$"];
CONTROLINPUT_LABEL_NAME = ["Time [$\mathrm{s}]$","Current [$\mathrm{A}$]"];
%温度
% plotTempData = prm.settings.outsideTemperature-[transpose(variable.ref([1,3],:)) ,transpose(variable.y([1,3],:))]; %
makeGraph(t',plotTempData, ..."lineName",TEMPERATURE_LINE_NAME, ...
                    "lineStyle",TEMPERATURE_LINE_STYLE, ...
                    "lineWidth",TEMPERATURE_LINE_WIDTH, ...
                    "labelName",TEMPERATURE_LABEL_NAME, ...
                    "graphName",TEMPERATURE_GRAPH_TITLE, ...
                    "location","southWEST", ...
                    "lineWidth",[2,2,2,2,2], ..."yLimit",[22.4 27.5],...
                    "isSave",FILE_IS_SAVE,"outDir",OUT_DIR_PATH, ...
                    "fontSize",16,"LabelFontSize",30,"saveFileExt","jpg");
%制御入力
% plotInputData = transpose(variable.u([1,3],:)); %
makeGraph(t',plotInputData , ...
                    "lineName",CONTROLINPUT_LINE_NAME, ...
                    "lineWidth",[2,2], ...
                    "labelName",CONTROLINPUT_LABEL_NAME, ...
                    "yLimit",[0,0.6],...
                    "location","northwest",...
                    "graphName",CONTROLINPUT_GRAPH_TITLE, ...
                    "isSave",FILE_IS_SAVE,"outDir",OUT_DIR_PATH, ...
                    "fontSize",20,"LabelFontSize",30,"saveFileExt","jpg");




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
