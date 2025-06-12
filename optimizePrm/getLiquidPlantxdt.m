function dxdt = getLiquidPlantxdt(cycle_count,dt,input,prm,isInterferrence)
         arguments
             cycle_count
             dt
             input
             prm
             isInterferrence=prm.experimetalSettings.isInterferrence
         end
            y_w = input(:,1);
            y_l_prev = input(:,2);
            y_l_0 = 0; %水温(常温)




            %入力熱量
            dxdt = 1*prm.interferrencePrm.y_wl .*(y_w  - y_l_prev)./prm.liquid.mlcl;
            %プラント
            dxdt = dxdt - prm.liquid.A_l.*y_l_prev;
            %干渉
            if isInterferrence
                dxdt = dxdt + 1*prm.interferrencePrm.y_l .* ([y_l_0; y_l_prev(1); y_l_prev(2)] - y_l_prev) ./ prm.liquid.mlcl;
            end
        
end