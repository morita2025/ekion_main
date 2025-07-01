function y = LiquidPlant(cycle_count,dt,prev_variable,prm,tubePartIndex,isInterferrence)
         arguments
             cycle_count
             dt
             prev_variable
             prm
             tubePartIndex=1
             isInterferrence=prm.experimentalSettings.isInterferrence
         end


        if prm.experimentalSettings.isRugekuttaMethodUse == 0
            y = moritaEulerMethod(@getLiquidPlantxdt,cycle_count,dt,prev_variable,prm,tubePartIndex,isInterferrence);
        end

        if prm.experimentalSettings.isRugekuttaMethodUse == 1
            y = moritaRungekuttaMethod(@getLiquidPlantxdt,cycle_count,dt,prev_variable,prm,tubePartIndex,isInterferrence);
        end

end






