classdef CalcOperatorPrm_ekion < handle 

    properties (Constant ,Access = private) %Constのproperty
        constPrivatePrm = struct("d",[0.12; 0.07; 0.03; 0.03; 0.02; 0.01; 0.01; 0.02; 0.03],...
                                 "S",[2.6e-3; 7e-4; 9.8e-3; 9e-4; pi*9e-6; pi*3e-4; 1.4e-3; 2.8e-4; pi*1.2e-4; 0.49*pi*9e-6; 0.7*pi*3e-4; 0.7*pi*1.2e-4; pi*3e-4; 0.4*pi*3e-4],...
                                 "aluminum", struct("density",2500,"thermalCond",150,"specificHeat",900,"emissivity",0.2),...
                                 "tube", struct("density",970.2,"thermalCond",0.2,"specificHeat",1600,"emissivity",0.7),...
                                 "liquid", struct("density",998.2,"thermalCond",0.602,"specificHeat",4182*0.52,"emissivity",0.93),...
                                 "quantity", struct("boltzmannConst",5.67*(10^(-8)),"absoluteTemperature",273.15),...
                                 "peltier",  struct("seebeck",0.04,"thermalConductance",0.63,"resistance",2,"absoluteTemperature",273.15)...
                                 );
    end

    properties  (SetAccess = immutable) %不変

    end

    properties (SetAccess = public, GetAccess = public) %書き換え可能＆外部からアクセスする用
        setAccessPiblicSettings;
        part34ProcessGain
        part1ProcessGain
    end

    properties (SetAccess = immutable, GetAccess=public) %読み取り専用＆外部からアクセスする用
        experimentalSettings;
        aluminum;
        tube;
        liquid;
        peltier;
        interferrencePrm;
        p1
        p2
        tau
        MOperatorConstPrm
        tildeNsys
    end


    methods
        function obj = CalcOperatorPrm_ekion(options)
            arguments
                options.isRugekuttaMethodUse = false;
                options.isinterferenceRejectionUse = true;
                options.isCompensateD1 = true;
                options.isCompensateD2 = true;
                options.isInterferrence = 1;

                %気温等
                options.outsideTemperature {mustBeNumeric} = 22;  %外気温
                options.initialLiquidTemperature {mustBeNumeric} = 22;  %T_l0

                %液体の速度
                options.velocity {mustBeNumeric} = 0.1; %[m/s]

                %BOX間のチューブ長
                options.dx4k {mustBeNumeric} = CalcOperatorPrm_ekion.constPrivatePrm.d(9);

                %熱伝達率
                options.heatTransferCoef_air  {mustBeNumeric} = 170; %α
                options.heatTransferCoef_tube {mustBeNumeric} = 440;%α_ω 
                options.heatTransferCoefAir_tube {mustBeNumeric} = 10;%α_ω 
                options.heatTransferCoef_liquid {mustBeNumeric} = 300;%20250324単位面積当たりの熱コンダクタンスという表現にした
   
                %ゲイン
                options.kp {mustBeNumeric} = [0; 0; 0];
                options.ki {mustBeNumeric} = [0; 0; 0];
                options.k {mustBeNumeric} = [1; 1]; %予備

                %電流上限
                options.i_max = 1;
                options.i_min = -0.5;

                %パラメータ
                options.p1 = 0.1;
                options.p2 = 0.1;
                options.tau = 20;
 
            end

            %% 読み取り専用実験条件
            obj.experimentalSettings =struct("isRugekuttaMethodUse",options.isRugekuttaMethodUse,...
                                             "isinterferenceRejectionUse",options.isinterferenceRejectionUse,...
                                             "isInterferrence",options.isInterferrence,...
                                             "outsideTemperature",options.outsideTemperature,...
                                             "T_0",options.outsideTemperature + CalcOperatorPrm_ekion.constPrivatePrm.peltier.absoluteTemperature,...
                                             "initialLiquidTemperature",options.initialLiquidTemperature,...
                                             "kp",options.kp,...
                                             "ki",options.ki,...
                                             "k",options.ki,...
                                             "isCompensateD1",options.isCompensateD1 ,...
                                             "isCompensateD2",options.isCompensateD2 ,...
                                             "i_max",options.i_max,...
                                             "i_min",options.i_min...
                                             );



            %% 書き換え可能実験条件
            SetAccessPiblicSettings = struct();


            %% ペルチェ
            obj.peltier = struct("seebeck",CalcOperatorPrm_ekion.constPrivatePrm.peltier.seebeck, ...
                                 "thermalConductance",CalcOperatorPrm_ekion.constPrivatePrm.peltier.thermalConductance, ...
                                 "resistance",CalcOperatorPrm_ekion.constPrivatePrm.peltier.resistance, ...
                                 "absoluteTemperature",CalcOperatorPrm_ekion.constPrivatePrm.peltier.absoluteTemperature ...
                                 );



            %% アルミ

            %dx
            dx13 = CalcOperatorPrm_ekion.constPrivatePrm.d(3,1) + CalcOperatorPrm_ekion.constPrivatePrm.d(6,1) + CalcOperatorPrm_ekion.constPrivatePrm.d(7,1); 
            dx2 = CalcOperatorPrm_ekion.constPrivatePrm.d(8,1);
            dx4k = CalcOperatorPrm_ekion.constPrivatePrm.d(9,1);
            dx = [dx13; dx2; dx13];
            dxThermalCond = (0.5*CalcOperatorPrm_ekion.constPrivatePrm.d(3,1) + CalcOperatorPrm_ekion.constPrivatePrm.d(7,1) + 0.5*CalcOperatorPrm_ekion.constPrivatePrm.d(8,1) )*ones(3,1);
            dxThermalCond4k = options.dx4k ;

            %パラメータ
            d = CalcOperatorPrm_ekion.constPrivatePrm.d;
            S = CalcOperatorPrm_ekion.constPrivatePrm.S;
            ma = dx * (d(3,1) - d(5,1)) * CalcOperatorPrm_ekion.constPrivatePrm.aluminum.density;
            


            obj.aluminum = struct("density",CalcOperatorPrm_ekion.constPrivatePrm.aluminum.density,...
                      "thermalCond",CalcOperatorPrm_ekion.constPrivatePrm.aluminum.thermalCond,...
                      "heatTransferCoef",options.heatTransferCoef_air,...
                      "specificHeat",CalcOperatorPrm_ekion.constPrivatePrm.aluminum.specificHeat,...
                      "emissivity",CalcOperatorPrm_ekion.constPrivatePrm.aluminum.emissivity,...
                      "dx",dx,...
                      "dxThermalCond",dxThermalCond,...
                      "ma",ma...
                      );





            %% チューブ

            obj.tube = struct("density",CalcOperatorPrm_ekion.constPrivatePrm.tube.density,...
                      "thermalCond",CalcOperatorPrm_ekion.constPrivatePrm.tube.thermalCond,...
                      "heatTransferCoef",options.heatTransferCoef_tube,...
                      "heatTransferCoefAir",options.heatTransferCoefAir_tube,...
                      "specificHeat",CalcOperatorPrm_ekion.constPrivatePrm.tube.specificHeat,...
                      "emissivity",CalcOperatorPrm_ekion.constPrivatePrm.tube.emissivity,...
                      "dx",dx,...
                      "dx4k",dx4k,...
                      "dxThermalCond",dxThermalCond,...
                      "dxThermalCond4k",dxThermalCond4k...
                      );



            %% 液体
            obj.liquid = struct("density",CalcOperatorPrm_ekion.constPrivatePrm.liquid.density,...
                      "heatTransferCoef",options.heatTransferCoef_liquid,...
                      "specificHeat",CalcOperatorPrm_ekion.constPrivatePrm.liquid.specificHeat,...
                      "emissivity",CalcOperatorPrm_ekion.constPrivatePrm.liquid.emissivity,...
                      "velocity",options.velocity,... 
                      "dx",dx,...
                      "dx4k",dx4k,...
                      "dxThermalCond",dxThermalCond,...
                      "dxThermalCond4k",dxThermalCond4k...
                      ..."mw",mw...
                      );



            %% 干渉の定数
            obj.interferrencePrm = struct("y_a",obj.aluminum.thermalCond*S(3,1) ./ obj.aluminum.dxThermalCond, ..../ obj.aluminum.dx,...
                                          "y_aw",obj.tube.heatTransferCoef.*[S(6,1);S(9,1);S(6,1)],...
                                          "y_w",obj.tube.thermalCond*(S(5,1) - S(10,1))./ obj.tube.dxThermalCond,... 
                                          "y_wl",obj.liquid.heatTransferCoef .* [S(11,1);S(12,1);S(11,1)],...
                                          "y_w4k",obj.tube.thermalCond*(S(5,1) - S(10,1))./ obj.tube.dxThermalCond4k,... 
                                          "y_wl4k",obj.liquid.heatTransferCoef * S(14,1),...
                                          "y_l",obj.liquid.velocity .* S(10,1) .* obj.liquid.density.* obj.liquid.specificHeat.* ones(3,1));



            %% アルミの定数
            A_a = zeros(3,4);
           
            
            %Aa_11
            b1 = 2*obj.peltier.thermalConductance;
            b2 = obj.aluminum.heatTransferCoef* (2*S(1,1) + 2*S(2,1) + S(3,1) -S(5,1));

            b5 = 4*( (obj.experimentalSettings.outsideTemperature+obj.peltier.absoluteTemperature)^3 )*obj.aluminum.emissivity * CalcOperatorPrm_ekion.constPrivatePrm.quantity.boltzmannConst*(2*S(1,1) + 2*S(2,1) + S(3,1) -S(5,1));
            c1 = obj.aluminum.ma(1,1) * obj.aluminum.specificHeat; 
            
            A_a(1,1) =(b1 + b2 + b5) / c1;
            
            %Aa_12
            b1 = 6*obj.aluminum.emissivity * CalcOperatorPrm_ekion.constPrivatePrm.quantity.boltzmannConst * (( obj.experimentalSettings.outsideTemperature+obj.peltier.absoluteTemperature)^2 );
            b2 = S(1,1) + S(2,1) + S(3,1) - 2*S(4,1) -S(5,1);
            c1 = obj.aluminum.ma(1,1) * obj.aluminum.specificHeat; 
            
            A_a(1,2) =(b1 * b2 ) / c1;
            
            %Aa_13
            b1 = 4*obj.aluminum.emissivity * CalcOperatorPrm_ekion.constPrivatePrm.quantity.boltzmannConst * ((obj.experimentalSettings.outsideTemperature+obj.peltier.absoluteTemperature)^(1));
            b2 = S(1,1) + S(2,1) + S(3,1) - 2*S(4,1) -S(5,1);
            c1 = obj.aluminum.ma(1,1) * obj.aluminum.specificHeat; 
            
            A_a(1,3) =(b1 * b2 ) / c1;
            
            %Aa_14
            b1 = obj.aluminum.emissivity * CalcOperatorPrm_ekion.constPrivatePrm.quantity.boltzmannConst ;
            b2 = S(1,1) + S(2,1) + S(3,1) - 2*S(4,1) -S(5,1);
            c1 = obj.aluminum.ma(1,1) * obj.aluminum.specificHeat; 
            
            A_a(1,4) =(b1 * b2 ) / c1;
            
            %Aa_21
            b1 = obj.aluminum.heatTransferCoef + 4*obj.aluminum.emissivity * CalcOperatorPrm_ekion.constPrivatePrm.quantity.boltzmannConst * ((obj.experimentalSettings.outsideTemperature+obj.peltier.absoluteTemperature)^(3));
            b2 = 2*S(7,1) + 2*S(8,1);
            c1 = obj.aluminum.ma(2,1) * obj.aluminum.specificHeat; 
            
            A_a(2,1) = (b1 * b2 ) / c1;
            
            %Aa_22
            b1 = 6*obj.aluminum.emissivity * CalcOperatorPrm_ekion.constPrivatePrm.quantity.boltzmannConst * ((obj.experimentalSettings.outsideTemperature+obj.peltier.absoluteTemperature)^(2));
            b2 = 2*S(7,1) + 2*S(8,1);
            c1 = obj.aluminum.ma(2,1) * obj.aluminum.specificHeat; 
            
            A_a(2,2) = (b1 * b2) / c1;
            
            
            %Aa_23
            b1 = 4*obj.aluminum.emissivity * CalcOperatorPrm_ekion.constPrivatePrm.quantity.boltzmannConst * ((obj.experimentalSettings.outsideTemperature+obj.peltier.absoluteTemperature)^(1));
            b2 = 2*S(7,1) + 2*S(8,1);
            c1 = obj.aluminum.ma(2,1) * obj.aluminum.specificHeat; 
            
            A_a(2,3) = (b1 * b2) / c1;
            
            %A_24
            b1 = obj.aluminum.emissivity * CalcOperatorPrm_ekion.constPrivatePrm.quantity.boltzmannConst;
            b2 = 2*S(7,1) + 2*S(8,1);
            c1 = obj.aluminum.ma(2,1) * obj.aluminum.specificHeat; 
            
            A_a(2,4) = (b1 * b2) / c1;
            
            %Aa_31
            b1 = 2*obj.peltier.thermalConductance;
            b2 = obj.aluminum.heatTransferCoef * (2*S(1,1) + 2*S(2,1) + S(3,1) -S(5,1));
            %b3 = obj.tube.heatTransferCoef*S(6,1);
            %b4 = obj.aluminum.thermalCond*S(3,1)/obj.aluminum.dx(1,1);
            b5 = 4*((obj.experimentalSettings.outsideTemperature+obj.peltier.absoluteTemperature)^(3))*obj.aluminum.emissivity * CalcOperatorPrm_ekion.constPrivatePrm.quantity.boltzmannConst*(2*S(1,1) + 2*S(2,1) + S(3,1) -S(5,1));
            c1 = obj.aluminum.ma(1,1) * obj.aluminum.specificHeat; 
            
            A_a(3,1) =(b1 + b2 + b5) / c1;
            
            %Aa_32
            b1 = 6*obj.aluminum.emissivity * CalcOperatorPrm_ekion.constPrivatePrm.quantity.boltzmannConst * ((obj.experimentalSettings.outsideTemperature+obj.peltier.absoluteTemperature)^(2));
            b2 = S(1,1) + S(2,1) + S(3,1) - 2*S(4,1) -S(5,1);
            c1 = obj.aluminum.ma(1,1) * obj.aluminum.specificHeat; 
            
            A_a(3,2) =(b1 * b2 ) / c1;
            
            %A_33
            b1 = 4*obj.aluminum.emissivity * CalcOperatorPrm_ekion.constPrivatePrm.quantity.boltzmannConst * ((obj.experimentalSettings.outsideTemperature+obj.peltier.absoluteTemperature)^(1));
            b2 = S(1,1) + S(2,1) + S(3,1) - 2*S(4,1) -S(5,1);
            c1 = obj.aluminum.ma(1,1) * obj.aluminum.specificHeat; 
            
            A_a(3,3) =(b1 * b2 ) / c1;
            
            %Aa_34
            b1 = obj.aluminum.emissivity * CalcOperatorPrm_ekion.constPrivatePrm.quantity.boltzmannConst ;
            b2 = S(1,1) + S(2,1) + S(3,1) - 2*S(4,1) -S(5,1);
            c1 = obj.aluminum.ma(1,1) * obj.aluminum.specificHeat; 
            
            A_a(3,4) =(b1 * b2 ) / c1;

            obj.aluminum.A_a = A_a;
            obj.aluminum.maca = obj.aluminum.specificHeat.* obj.aluminum.ma;








        %% チューブ
            %A_w_mn-----------------------------------------------------------------------------------
            A_w = zeros(3,1);
            m_w13  = obj.tube.dx(1,1) * (S(5,1) - S(10,1)) * obj.tube.density;
            m_w2  = obj.tube.dx(2,1) * (S(5,1) - S(10,1)) * obj.tube.density;
            obj.tube.mw = [m_w13; m_w2; m_w13];
            obj.tube.mwcw = obj.tube.specificHeat.* obj.tube.mw;

            %part4k (k=1,2,3...)
            A_w_4k = zeros(4,1);
            m_w_4k = zeros(3,1);
            m_w_4k = obj.tube.dx4k * (S(5,1) - S(10,1)) * obj.tube.density;
            obj.tube.mw4k = m_w_4k;
            obj.tube.mwcw4k = obj.tube.specificHeat.* obj.tube.mw4k;
            %m_w_4k1
            apxA_w_4k = (obj.tube.heatTransferCoefAir * S(13,1) ) / obj.tube.mwcw4k;
            b1 = 4*obj.tube.emissivity * CalcOperatorPrm_ekion.constPrivatePrm.quantity.boltzmannConst * ((obj.experimentalSettings.outsideTemperature+obj.peltier.absoluteTemperature)^(3))  / obj.tube.mwcw4k;
            A_w_4k(1,1) =apxA_w_4k + S(13,1)*b1;
            %m_w_4k2
            b1 = 6*obj.tube.emissivity * CalcOperatorPrm_ekion.constPrivatePrm.quantity.boltzmannConst * ((obj.experimentalSettings.outsideTemperature+obj.peltier.absoluteTemperature)^(2));
            A_w_4k(2,1) =(b1 * S(13,1) ) / obj.tube.mw4k;
            %m_w_4k3
            b1 = 4*obj.tube.emissivity * CalcOperatorPrm_ekion.constPrivatePrm.quantity.boltzmannConst * ((obj.experimentalSettings.outsideTemperature+obj.peltier.absoluteTemperature)^(1));
            A_w_4k(3,1) =(b1 * S(13,1) ) / obj.tube.mw4k;
            %m_w_4k4
            b1 = obj.tube.emissivity * CalcOperatorPrm_ekion.constPrivatePrm.quantity.boltzmannConst ;
            A_w_4k(4,1) = b1 * S(13,1) / obj.tube.mw4k;
            
            
            %代入
            obj.tube.A_w = A_w; %発散エネルギーがないため0
            obj.tube.apxA_w4k = apxA_w_4k;
            obj.tube.A_w4k = A_w_4k;
            obj.tube.tubeAirConstPrm = options.heatTransferCoefAir_tube *S(13,1) ;


       %% 液体
            A_l = zeros(3,1);
            ml13  = obj.liquid.dx(1,1) * S(10,1) * obj.liquid.density;
            ml2  = obj.liquid.dx(2,1) *  S(10,1) * obj.liquid.density;
            obj.liquid.ml = [ml13; ml2; ml13];
            obj.liquid.mlcl = obj.liquid.specificHeat.* obj.liquid.ml;

            %part4k (k=1,2,3...)
            A_l_4_k = zeros(1,1);
            ml4k  = obj.liquid.dx4k * S(10,1) * obj.liquid.density;
            obj.liquid.ml4k = ml4k;
            obj.liquid.mlcl4k = obj.liquid.specificHeat.* obj.liquid.ml4k;

            obj.liquid.A_l = A_l; %発散エネルギーがないため0
            obj.liquid.A_l4k = A_l_4_k; %発散エネルギーがないため0

             %%パラメータ代入
             obj.p1 = options.p1;
             obj.p2 = options.p2;
             obj.tau = options.tau;
    
             obj.tildeNsys = obj.calcTildeNSys();
             obj.MOperatorConstPrm =[obj.part1ProcessGain; 1; obj.part34ProcessGain]; 
             tf(obj.tildeNsys{1})
             tf(obj.tildeNsys{2})   


        end

        function tildeNsysOutput = calcTildeNSys(obj)

             %伝達関数を用いてMを計算
             %A3sys
             stateA3Gain = [1; obj.tube.mwcw(3); obj.tube.mwcw4k; obj.liquid.mlcl(3); obj.liquid.mlcl4k];
             stateA3Prm =  zeros(5,5);
             stateA3Prm(1,:) = [-1/obj.tau, 0, 0, 0, 0];
             stateA3Prm(2,:) = [obj.interferrencePrm.y_aw(3), -obj.interferrencePrm.y_aw(3)-obj.interferrencePrm.y_wl(3)-obj.interferrencePrm.y_w4k,...
                                obj.interferrencePrm.y_w4k, obj.interferrencePrm.y_wl(3), 0];
             stateA3Prm(3,:) = [0, obj.interferrencePrm.y_w4k, -obj.tube.tubeAirConstPrm-obj.interferrencePrm.y_wl4k-obj.interferrencePrm.y_w4k,...
                                0, obj.interferrencePrm.y_wl4k];
             stateA3Prm(4,:) = [0, obj.interferrencePrm.y_wl(3), 0, -obj.interferrencePrm.y_wl(3)-obj.interferrencePrm.y_l(1), 0];
             stateA3Prm(5,:) = [0, 0, obj.interferrencePrm.y_wl4k, obj.interferrencePrm.y_l(1), -obj.interferrencePrm.y_wl4k-obj.interferrencePrm.y_l(1)];
             
             %A1sys
             stateA1Gain = [1; obj.tube.mwcw(1); obj.liquid.mlcl(1)];
             stateA1Prm =  zeros(3,3);
             stateA1Prm(1,:) = [-1/obj.tau, 0, 0];
             stateA1Prm(2,:) = [obj.interferrencePrm.y_aw(1), -obj.interferrencePrm.y_aw(1)-obj.interferrencePrm.y_wl(1), obj.interferrencePrm.y_wl(1)];
             stateA1Prm(3,:) = [0, obj.interferrencePrm.y_wl(1), -obj.interferrencePrm.y_wl(1)-obj.interferrencePrm.y_l(1)];
             
             %A3gain
             stateA3 = 1 ./ stateA3Gain .* stateA3Prm;
             stateB3 = [+1/obj.tau; 0; 0; 0; 0];
             stateC3 = [0, 0, 0, 0, 1];
             stateD3 = 0;
             Part34Sys = ss(stateA3, stateB3, stateC3, stateD3);
             obj.part34ProcessGain = dcgain(tf(Part34Sys));
    
             %A1gain
             stateA1 = 1./ stateA1Gain .* stateA1Prm;
             stateB1 = [+1/obj.tau; 0; 0];
             stateC1 = [0, 1, 0];
             stateD1 = 0;
             Part1Sys = ss(stateA1, stateB1, stateC1, stateD1);
             obj.part1ProcessGain = dcgain(tf(Part1Sys));

             tildeNsysOutput={minreal(tf(Part1Sys)),minreal(tf(Part34Sys))};

        end




    end




end