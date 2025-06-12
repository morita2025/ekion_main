%実機データ
load("C:\Users\mykot\OneDrive - Tokyo University of Agriculture and Technology (1)\60MATLAB_sagyou\MicroreactorSystem1\data\1005_step_processPrmOpmize.mat");
tempData = data.data.temperature.sensor(3:end,:);
timeData = data.data.time(3:end,:);
RefData = data.data.temperature.ref(3:end,:);
inputData = data.data.other(3:end,[1,2]);


tubeTempData = tempData(:,[1,3]);
almiTempData = tempData(:,[4,6]);

teijouTime = 300;
tubeTempOffset = 0.3813;%( mean(tubeTempData(teijouTime:end,1)) - mean(tubeTempData(teijouTime:end,2)) ) /2;
almiTempOffset = -0.0417;%( mean(almiTempData(teijouTime:end,1)) - mean(almiTempData(teijouTime:end,2)) ) /2;

calibedTubeData = tubeTempData + [-tubeTempOffset, tubeTempOffset];
calibedAlmiData = almiTempData + [-almiTempOffset, almiTempOffset];

plot(calibedTubeData(:,2),LineWidth=2);
hold on
plot(calibedTubeData(:,1),LineWidth=2);

plot(calibedAlmiData(:,2));
plot(calibedAlmiData(:,1));
