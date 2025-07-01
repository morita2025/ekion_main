function pfig = debugMicoreactorPlotter(blockNum,t,variable)
        pfig =cell(2,1);

        %ya系列をyl系列に変換する処理
        variable.plotYa = NaN(4 * blockNum, length(variable.y_a));  
        variable.plotRef1 = NaN(4 * blockNum, length(variable.ref)); 
        variable.plotRef2 = NaN(4 * blockNum, length(variable.ref));  
        
        for i = 1:blockNum
            idx_in = (i-1)*3 + 1;
            idx_out = (i-1)*4 + 1;
            variable.plotYa(idx_out:idx_out+2,:) = variable.y_a(idx_in:idx_in+2,:);  
            variable.plotRef1(idx_out:idx_out+2,:) = variable.ref(idx_in:idx_in+2,:);
            variable.plotRef2(idx_out+1:idx_out+3,:) = variable.ref(idx_in:idx_in+2,:);
            variable.plotRef2(idx_out:idx_out+2,:) = NaN;
            variable.plotRef1(idx_out+1:idx_out+2,:) = NaN;
        end
        pfig{1} = figure(1);
        plot(variable.y_l(:,length(t)-3),"Color","r")
        hold on
        plot(variable.y(:,length(t)-3),"Color","b")
        plot(variable.ref(1,1)*ones(size(variable.y(:,length(t)-3))),"--")
        plot(variable.plotRef1(:,length(t)-3),"o","LineWidth",2,"Color","b")
        plot(variable.plotRef2(:,length(t)-3),"o","LineWidth",2,"Color","r")
        % legend("yl_{4n}[C^{\circ}]","y_{4n-3}[C^{\circ}]","ref_{3k-2}[C^{\circ}]","ref_{3k}[C^{\circ}]","fontsize",15,"location","northwest")
        title("t=" + string(length(t)-3) + "[s]" +"  All Box temperature","fontsize",18)
        % 
        
        % pfig{2} = figure('Position', [2000, 000, 1500*0.8, 1200*0.8]);
        pfig{2} = figure(2);
        try
            if blockNum <3
                plotBlockNum = blockNum;
            else
                plotBlockNum =3;
            end

            for blockId = 1:blockNum
                    % figure(blockId+30);
                    subplot(plotBlockNum,2,2*blockId-1)
                    plot(variable.y_l(4*blockId,:))
                    hold on
                    plot(variable.y(4*blockId-3,:),"Color","r")
                    plot(variable.y(4*blockId-1,:),"Color","b")
                    plot(variable.debug_NInvM(3*blockId-2,:),"--")
                    plot(variable.debug_NInvM(3*blockId,:),"--")
                    ylim([0 max(max(variable.y(:,end)),max(variable.y(4*blockNum-1,:)))])
                    legend("yl"+string(4*blockId)+"[C^{\circ}]","y"+string(4*blockId-3)+"[C^{\circ}]","y"+string(4*blockId-1)+"[C^{\circ}]","fontsize",12)
                    title("Box:" + string(blockId) +"  Temperature","fontsize",18)
            
                    subplot(plotBlockNum,2,2*blockId)
                    plot(variable.u(3*blockId-2,:))
                    hold on
                    plot(variable.u(3*blockId,:))
                    legend("u"+string(3*blockId-2)+"[A]","u"+string(3*blockId)+"[A]","fontsize",12)
                    title("Box:" + string(blockId) +"  Current","fontsize",18)
            end
        catch
            disp("データはblockId=3までしか表示できません")
        end
end