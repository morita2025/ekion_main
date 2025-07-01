function y = N(cycle_count,dt,prev_variable,prm,tubePartIndex,isInterferrence)
         arguments
             cycle_count
             dt
             prev_variable
             prm
             tubePartIndex=1
             isInterferrence=prm.experimentalSettings.isInterferrence
         end


        if prm.experimentalSettings.isRugekuttaMethodUse == 0
            y = moritaEulerMethod(@getNDxdt,cycle_count,dt,prev_variable,prm,tubePartIndex,isInterferrence);
        end

        if prm.experimentalSettings.isRugekuttaMethodUse == 1
            y = moritaRungekuttaMethod(@getNDxdt,cycle_count,dt,prev_variable,prm,tubePartIndex,isInterferrence);
        end

end






