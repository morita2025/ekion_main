function dxdt = getQDxdt(cycleCount,dt,input,prm,tubePartIndex,isInterferrence)
         arguments
             cycleCount
             dt
             input
             prm
             tubePartIndex=1
             isInterferrence=prm.settings.isInterferrence
         end


        x_1 = input(:,1);
        x_2 = input(:,2);

        dxdt = (x_1 - x_2) / prm.tau;



end