clear
syms t
n = 5;

% シンボリック状態変数 x1(t), x2(t), ..., x5(t)
syms x_1(t) x_2(t) x_3(t) x_4(t) x_5(t)
x = [x_1; x_2; x_3; x_4; x_5];
dx = diff(x,t,1);


% シンボリックスカラー入力 u(t)
syms u(t)
syms y(t)
dotVectorY = sym(zeros(n,1));
dotVectorU = sym(zeros(n,1));
dotVectorY(1) = y(t);
dotVectorU(1) = u(t);
for i=2:n %u,yを微分した行列の準備
    dotVectorY(i) = diff(dotVectorY(i-1));
    dotVectorU(i) = diff(dotVectorU(i-1));
end
pretty(dotVectorU)



% シンボリック定数行列
symbolStruct = getSymbols();
    A = symbolStruct.A; 
    b = symbolStruct.b; 
    c = symbolStruct.c; 


% 初期の出力 y = c * x(t)
y_list = sym(zeros(n+1, 1));
y_list(1) = c * x; %y=cxそのまま
dotX = A*x + b*u;

for i = 2:n+1
    y_list(i) = diff(y_list(i-1),t,1);
    y_list(i) = subs(y_list(i),diff(x,t,1),dotX);
end

%xを消去するための行列
dashY = y_list([1:5]);
dashA = sym(zeros(n,n));
dashB = sym(zeros(n,n));
tCoefX = sym(zeros(1,n));
tCoefU = sym(zeros(1,n));

% unko = coeffs(dashY(2),x_1(t))
for i=1:n
    tCoefX = jacobian(dashY(i), x);
    tCoefU = jacobian(dashY(i), dotVectorU);
    dashA(i,:) = tCoefX; 
    dashB(i,:) = tCoefU; 
end

%x = dashA^{-1} (y - dashB u)
syms symsX [n 1] real
syms symsU [n 1] real
syms symsY [n 1] real
eqn = symsY == dashA * symsX + dashB * symsU;
tempXSol = solve(eqn, symsX);
xSol = simplify([tempXSol.symsX1; tempXSol.symsX2; tempXSol.symsX3; tempXSol.symsX4; tempXSol.symsX5]);

%y = solvCoefY * VectorY + solvCoefU * VectorU を計算
solvCoefY = sym(zeros(n,n));
solvCoefU = sym(zeros(n,n));
tSolvCoefY = sym(zeros(1,n));
tSolvCoefU = sym(zeros(1,n));
for i=1:n
    tSolvCoefY =  jacobian(xSol(i),symsY);
    tSolvCoefU =  jacobian(xSol(i),symsU);
    solvCoefY(i,:) = tSolvCoefY;
    solvCoefU(i,:) = tSolvCoefU;
end

%diff(y,t,5)の式のxを置き換える
y5CoefX = solvCoefY * dotVectorY  + solvCoefU * dotVectorU; %合ってる
ordinaryDifferentialY = y_list(6);

ordinaryDifferentialY = subs(ordinaryDifferentialY,x_1(t),y5CoefX(1,:));
disp("a")
ordinaryDifferentialY = subs(ordinaryDifferentialY,x_2(t),y5CoefX(2,:));
disp("a")
ordinaryDifferentialY = subs(ordinaryDifferentialY,x_3(t),y5CoefX(3,:));
ordinaryDifferentialY = subs(ordinaryDifferentialY,x_4(t),y5CoefX(4,:));
disp("b")
ordinaryDifferentialY = simplify(subs(ordinaryDifferentialY,x_5(t),y5CoefX(5,:)));

latexNoShiki = latex(ordinaryDifferentialY);
% 結果の表示
fprintf('5階の微分方程式:\n');

fid = fopen('long_equation.tex', 'w');
fprintf(fid, '%s\n', latexNoShiki);
fclose(fid);


%u(t)の係数を計算
targetU = u(t);
targetY = y(t);
% coeffU = sym(zeros(n,1));
% coeffY = sym(zeros(n,1));
    coeffU1 = feval(symengine, 'coeff', ordinaryDifferentialY, diff(u(t),t,1));
    coeffU2 = feval(symengine, 'coeff', ordinaryDifferentialY, diff(u(t),t,2));
    coeffU3 = feval(symengine, 'coeff', ordinaryDifferentialY, diff(u(t),t,3));
    % targetU = diff(targetU,t,1);    
    % coeffY(i,1) = feval(symengine, 'coeff', ordinaryDifferentialY, targetY);
    % targetY = diff(targetY,t,1);