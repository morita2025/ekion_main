p2 = 0.3;  % 任意の定数、ここでは1と仮定

% 最終伝達関数（5次LPF）
F = tf(p2^5, [1, 5*p2, 10*p2^2, 10*p2^3, 5*p2^4, p2^5]);

%ローパスとNinvの一部
FNum = tf([1],[1.066e-05, 3.205e-07]);

FDenJissou = F*FNum;

% 逆フィルタ（元の画像が示す形に一致）
F_inv =  tf([1, 0.4873, 0.08129, 0.006009, 0.000199, 2.372e-6], 1);

FNum = tf([1],[1.066e-05, 3.205e-07]);
FFinal = FDenJissou

t = 0:0.01:24;

step(FFinal)


%伝達関数のデバッグ


% plot(variable.unko7(1,:),"Color","r")
% hold on


% plot(t,variable.unko6(2,:),"Color","b",LineWidth=2,LineStyle="--")
% hold on
% plot(t,variable.unko6(1,:),"Color","r",LineWidth=2,LineStyle="--")
% % plot(t,zeros(length(variable.unko7(2,:)),1))
% 
% p2 = prm.p2;  % 任意の定数、ここでは1と仮定
% 
% % 最終伝達関数（5次LPF）
F = tf(p2^5, [1, 5*p2, 10*p2^2, 10*p2^3, 5*p2^4, p2^5]);
F1 = tf(p2^3, [1, 3*p2, 3*p2^2, p2^3]);
step(F,t)
step(F1,t)
% ylim([0.951,1])



% N2 = tf([1.066e-5, 2.475e-7], [1, 0.4804, 0.07815, 0.005545, 0.0001715, 1.814e-6]);
% 
% plot(t,variable.unko6(2,:),"Color","r",LineWidth=2,LineStyle="--")
% hold on
% step(N2,t)




% p2 = 0.3;  % 任意の定数、ここでは1と仮定
% 
% % 最終伝達関数（5次LPF）
% F = tf(p2^5, [1, 5*p2, 10*p2^2, 10*p2^3, 5*p2^4, p2^5]);
% 
% %ローパスとNinvの一部
% FNum = tf([1],[1.066e-05, 3.205e-07]);
% 
% FDenJissou = F*FNum;
% 
% % 逆フィルタ（元の画像が示す形に一致）
% F_inv =  tf([1, 0.4873, 0.08129, 0.006009, 0.000199, 2.372e-6], 1);
% 
% FNum = tf([1],[1.066e-05, 3.205e-07]);
% FFinal = FDenJissou*F_inv
% step(FFinal,t)
