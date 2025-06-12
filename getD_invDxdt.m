function dxdt = getD_invDxdt(cycleCount,dt,input,prm,tubePartIndex,isInterferrence)
         arguments
             cycleCount
             dt
             input
             prm
             tubePartIndex=1
             isInterferrence=prm.experimetalSettings.isInterferrence
         end

         
        inputCurr = input(:,1);
        y_a_prev = input(:,2);
        y_prev = input(:,3);

        ohmHeat = -prm.peltier.resistance*[1; 0; 1].*power(inputCurr,2);
        peltierHeat =  2*prm.peltier.seebeck*[1; 0; 1].*((prm.peltier.absoluteTemperature)- y_a_prev).*inputCurr;
        dxdt = (ohmHeat + peltierHeat)./prm.aluminum.maca;
        % 
        for i=1:4
            dxdt = dxdt + ((-1)^(i)) *prm.aluminum.A_a(:,i).* (y_a_prev.^i);
        end

        if isInterferrence
            dxdt = dxdt...
                    - prm.interferrencePrm.y_a .* (y_a_prev - [y_a_prev(2); y_a_prev(1)+y_a_prev(3)-y_a_prev(2); y_a_prev(2)]) ./ prm.aluminum.maca...
                    + prm.interferrencePrm.y_aw .* (y_prev -y_a_prev) ./ prm.aluminum.maca;
        end


end