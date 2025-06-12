clear ;
close all;



liquidVelocity = 0.002;
alpah_l = 14;


%クラス定義のoptionsに書いてあるパラメータは初期値を指定できる
prm =  CalcOperatorPrm_ekion(outsideTemperature=28,i_max=2,i_min=0,...
                             heatTransferCoef_air=270,heatTransferCoef_tube=270,heatTransferCoef_liquid=alpah_l,velocity = liquidVelocity,...
                           isRugekuttaMethodUse=true,isInterferrence=true);



%prm.aluminum.A_a(1,3)　のようにアクセスすればOK!(書き換えはエラーが出るはず)