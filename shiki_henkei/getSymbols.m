function outputSymbols =  getSymbols()
        % シンボリック変数の定義
        syms tau_2 real
        % syms G_aw1 G_wl1 G_w4 G_0 G_wl4 G_l4 real
        % syms m_w3 m_w4 m_l3 m_l4 real
        
        % 行列 A の定義
        A = sym(zeros(5));
        
        A(1,1) = -1 / tau_2;
        % 
        % A(2,1) =  G_aw1 / m_w3;
        % A(2,2) = -(G_aw1 + G_wl1 + G_w4) / m_w3;
        % A(2,3) =  G_w4 / m_w3;
        % A(2,4) =  G_wl1 / m_w3;
        % 
        % A(3,2) =  G_w4 / m_w4;
        % A(3,3) = -(G_0 + G_wl4 + G_w4) / m_w4;
        % A(3,5) =  G_wl4 / m_w4;
        % 
        % A(4,2) =  G_wl1 / m_l3;
        % A(4,4) = -(G_wl1 + G_l4) / m_l3;
        % 
        % A(5,3) =  G_wl4 / m_l4;
        % A(5,4) =  G_l4 / m_l4;
        % A(5,5) = -(G_wl4 + G_l4) / m_l4;


        %簡略化
        syms G_w_41 G_w_42 G_w_31 G_w_32 G_w_33 G_w_0  G_l_41 G_l_42 G_l_31 G_l_32 real
        % syms m_w3 m_w4 m_l3 m_l4 real
        A(2,1) =  G_w_31;
        A(2,2) = -G_w_31 - G_w_32 - G_w_33;
        A(2,3) =  G_w_33 ;
        A(2,4) =  G_w_32;
        
        A(3,2) =  G_w_41 ;
        A(3,3) = -G_w_0 - G_w_42 - G_w_41;
        A(3,5) =  G_w_42;
        
        A(4,2) =  G_l_31;
        A(4,4) = -G_l_31 - G_l_32;
        
        A(5,3) =  G_l_41 ;
        A(5,4) =  G_l_42 ;
        A(5,5) = -G_l_41 - G_l_42;

        b = sym(zeros(5,1));
        b(1) = 1 / tau_2;

        c = sym(zeros(1,5));
        c(1,5) = 1;
        
        % % 行列の表示（整形）
        % disp('行列 A =');
        % pretty(A)

        outputSymbols.A = A;
        outputSymbols.b = b;
        outputSymbols.c = c;

    
end