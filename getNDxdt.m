function dxdt = getNDxdt(cycle_count,dt,input,prm,tubePartIndex,isInterferrence)
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
            addInterferenceElementsY = input(:,4); %両サイドのy
            addInterferenceElementsY_l = input(:,5);%両サイドのyl
            if rem(tubePartIndex,4) ~=0
                %入力熱量
                dxdt = prm.interferrencePrm.y_aw .*(y_a  - y_prev)./prm.tube.mwcw;
                %プラント
                dxdt = dxdt - prm.tube.A_w.*y_prev;
                %a
                a=prm.interferrencePrm.y_wl .*(y_l_prev - y_prev)./prm.tube.mwcw;
                %干渉
                if isInterferrence
                    dxdt = dxdt ...
                            -1* prm.interferrencePrm.y_w.*(y_prev - [y_prev(2); y_prev(1)+y_prev(3)-y_prev(2); y_prev(2)])./prm.tube.mwcw...
                            +1* a...%prm.interferrencePrm.y_wl .*(y_l_prev - y_prev)./prm.tube.mwcw;
                            -1* prm.interferrencePrm.y_w.*(y_prev - [addInterferenceElementsY(1); 0; addInterferenceElementsY(3)])./prm.tube.mwcw;
                end
            else %partW4k (k=1,2,3...)

                dxdt =  - prm.tube.apxA_w4k.*y_prev(2);
                % dxdt =  - prm.tube.apxA_w4k.*y_prev(2);
                % for i=1:3
                %     dxdt = dxdt + ((-1)^i) * prm.tube.A_w4k(i) * y_prev(2)^i;
                % end

                if isInterferrence
                    dxdt = dxdt ...
                            -1* prm.interferrencePrm.y_w4k*(2*y_prev(2) - y_prev(1) - y_prev(3))/prm.tube.mwcw4k...%左右の干渉
                            +1* prm.interferrencePrm.y_wl4k *(y_l_prev(2) - y_prev(2))/prm.tube.mwcw4k; %ここは合ってる
        
                end
            end
        
end