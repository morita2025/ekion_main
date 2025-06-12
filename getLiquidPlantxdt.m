function dxdt = getLiquidPlantxdt(cycle_count,dt,input,prm,tubePartIndex,isInterferrence)
         arguments
             cycle_count
             dt
             input
             prm
             tubePartIndex=1
             isInterferrence=prm.experimetalSettings.isInterferrence
         end
            y_w = input(:,1);
            y_l_prev = input(:,2);
            %y_l_0 = 0; %水温(常温)
            addInterferenceElementsY = input(:,4); %両サイドのy
            addInterferenceElementsY_l = input(:,5);%両サイドのyl
            
            if rem(tubePartIndex,4) ~=0
                %入力熱量
                dxdt = 1*prm.interferrencePrm.y_wl .*(y_w  - y_l_prev)./prm.liquid.mlcl;
                %プラント
                dxdt = dxdt - prm.liquid.A_l.*y_l_prev;
                if isInterferrence %干渉
                    dxdt = dxdt ...
                           + prm.interferrencePrm.y_l .* ([addInterferenceElementsY_l(1); y_l_prev(1); y_l_prev(2)] - y_l_prev) ./ prm.liquid.mlcl;
                end
            else %partW4k (k=1,2,3...)
                dxdt = 1*prm.interferrencePrm.y_wl4k .*(y_w(2)  - y_l_prev(2))./prm.liquid.mlcl4k;
                dxdt = dxdt - prm.liquid.A_l4k.*y_l_prev(2);
                if isInterferrence %干渉
                    dxdt = dxdt ...
                           + prm.interferrencePrm.y_l(2) .* (y_l_prev(1) - y_l_prev(2)) ./ prm.liquid.mlcl4k;
                end
                dxdt=dxdt;
            end


        
end