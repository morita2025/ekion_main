clear ;
close all;
max_time = 1200;
dt = 1;
t = 0:dt:max_time;
ref = [3.8; 4];
liquidVelocity = 0.002;
alpah_l = 14;


prm =  CalcOperatorPrm_ekion(outsideTemperature=28,i_max=2,i_min=0,...
                             heatTransferCoef_air=270,heatTransferCoef_tube=270,heatTransferCoef_liquid=alpah_l,velocity = liquidVelocity,...
                           isRugekuttaMethodUse=true,isInterferrence=true);
variable= getVariableFunction(length(t),ref);
variable.u([1,3],1:600) = 0.7;
variable.u([1,3],601:end) = 1;

for cycleCount = 2:length(t)
        
    %% プラント(右分解)
    variable.y_a(:,cycleCount)= D_inv(cycleCount,dt,...
                [variable.u(:,cycleCount-1),variable.y_a(:,cycleCount-1),variable.y(:,cycleCount-1)],...
                prm);

    variable.y(:,cycleCount) = N(cycleCount,dt,...
        [variable.y_a(:,cycleCount-1),variable.y(:,cycleCount-1),variable.y_l(:,cycleCount-1)],...
        prm);

    variable.y_l(:,cycleCount) = LiquidPlant(cycleCount,dt,...
        [variable.y(:,cycleCount-1),variable.y_l(:,cycleCount-1),zeros(3,1)],...
        prm);

end

%実機データ
load("C:\Users\mykot\OneDrive - Tokyo University of Agriculture and Technology (1)\60MATLAB_sagyou\MicroreactorSystem1\data\1002_unko.mat");
tempData = data.data.temperature.sensor(3:end,[4,6,5]);
timeData = data.data.time(3:end,:);
RefData = data.data.temperature.ref(3:end,:);
inputData = data.data.other(3:end,[1,2]);


plot(variable.y_a(1,:),LineWidth=2);
hold on 

%jikki
plot(tempData(1,3) - tempData(:,1),LineWidth=1);
plot(tempData(1,3) - tempData(:,2),LineWidth=1);
plot(tempData(1,3) - tempData(:,3),LineWidth=1);

plot(variable.y_a(2,:),LineWidth=2);
% plot(variable.y_a(3,:));
% plot(variable.y(1,:),LineWidth=2)
% plot(variable.y(2,:),LineWidth=2)
% plot(variable.y(3,:),LineWidth=2)
plot(variable.y_l(3,:),LineWidth=2);


