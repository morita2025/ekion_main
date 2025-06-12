function dxdt = getNDxdt(cycle_count,dt,input,prm,isInterferrence)
         arguments
             cycle_count
             dt
             input
             prm
             isInterferrence=prm.experimetalSettings.isInterferrence
         end
            y_a = input(:,1);
            y_prev = input(:,2);
            y_l_prev = input(:,3);
            %入力熱量
            dxdt = prm.interferrencePrm.y_aw .*(y_a  - y_prev)./prm.tube.mwcw;
            %プラント
            dxdt = dxdt - prm.tube.A_w.*y_prev;
            
            %a
            a=prm.interferrencePrm.y_wl .*(y_l_prev - y_prev)./prm.tube.mwcw

            %干渉
            if isInterferrence
                dxdt = dxdt ...
                        -1* prm.interferrencePrm.y_w.*(y_prev - [y_prev(2); y_prev(1)+y_prev(3)-y_prev(2); y_prev(2)])./prm.tube.mwcw...
                        +1* a;%prm.interferrencePrm.y_wl .*(y_l_prev - y_prev)./prm.tube.mwcw;
            end
        
end