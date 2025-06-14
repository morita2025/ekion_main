function dxdt = getControlNDxdt(cycle_count,dt,input,prm,tubePartIndex,isInterferrence)
         arguments
             cycle_count
             dt
             input
             prm
             tubePartIndex=1
             isInterferrence=prm.experimetalSettings.isInterferrence
         end
            y_a = input(:,1);
            y_prev = input(:,2);
            y_l_prev = input(:,3);
            adjacentElementsY = input(:,4); %両サイドのy
            adjacentElementsYl = input(:,5);%両サイドのyl

            %dxdtの定義
            dxdt = zeros(5,1);


            %% partW1
                %入力熱量
                dxdt(1) = prm.interferrencePrm.y_aw(1) .*(y_a(1)  - y_prev(1))./prm.tube.mwcw(1);
                %プラント
                dxdt(1) = dxdt(1) - prm.tube.A_w(1).*y_prev(1);
                % %干渉
                % if isInterferrence
                %     dxdt = dxdt ...
                %             -1* prm.interferrencePrm.y_w.*(y_prev - [y_prev(2); y_prev(1)+y_prev(3)-y_prev(2); y_prev(2)])./prm.tube.mwcw...
                %             +1* prm.interferrencePrm.y_wl(1) .*(y_l_prev(1) - y_prev(1))./prm.tube.mwcw(1)
                %             -1* prm.interferrencePrm.y_w.*(y_prev - [addInterferenceElementsY(1); 0; addInterferenceElementsY(3)])./prm.tube.mwcw;
                % end

            %% partW3~%partL4を1まとまりにした処理を以下に実装する
                part3TubeLiquidDxdt  = zeros(2,2);

                %partW3
                part3TubeLiquidDxdt(1,1) =  +prm.interferrencePrm.y_aw * (-y_prev(3) + y_a(3))...
                                            +prm.interferrencePrm.y_wl * (-y_prev(3) + y_l_prev(3))...
                                            +prm.interferrencePrm.y_w4k * (-y_prev(3) + adjacentElementsY(3));

                part3TubeLiquidDxdt(1,2) = -prm.tube.tubeAirConstPrm * adjacentElementsY(3)...
                                           + prm.interferrencePrm.y_w4k * (-adjacentElementsY(3) + y_prev(3))...
                                           + prm.interferrencePrm.y_wl4k * (-adjacentElementsY(3) + adjacentElementsYl(3));

                %partL3
                part3TubeLiquidDxdt(2,1) = -prm.interferrencePrm.y_wl * (-y_l_prev(3) + y_prev(3))...
                                           +prm.interferrencePrm.y_l * (-y_l_prev(3));

                %partL4
                part3TubeLiquidDxdt(2,2) = -prm.interferrencePrm.y_wl4k * (-adjacentElementsYl(3)  + -adjacentElementsY(3))...
                                           +prm.interferrencePrm.y_l * (-adjacentElementsYl(3)  + -y_l_prev(3));



                %返り値用
                dxdt(2:5) = [part3TubeLiquidDxdt(1,1); part3TubeLiquidDxdt(1,2); part3TubeLiquidDxdt(2,1); part3TubeLiquidDxdt(2,1)];

            
        
end