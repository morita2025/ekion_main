function y_a = D_inv(cycleCount,dt,input,prm,tubePartIndex,isInterferrence)
         arguments
             cycleCount
             dt
             input
             prm
             tubePartIndex=1
             isInterferrence=prm.experimentalSettings.isInterferrence
         end

        %%input
        % inputCurr = input(:,1);
        % y_a_prev = input(:,2);
        % y_prev = input(:,3)


        if prm.experimentalSettings.isRugekuttaMethodUse == 0
            y_a = moritaEulerMethod(@getD_invDxdt,cycleCount,dt,input,prm,tubePartIndex,isInterferrence);
        end

        if prm.experimentalSettings.isRugekuttaMethodUse == 1
            y_a = moritaRungekuttaMethod(@getD_invDxdt,cycleCount,dt,input,prm,tubePartIndex,isInterferrence);
        end


end


