function y = LiquidPlant(cycle_count,dt,prev_variable,prm,isInterferrence)
         arguments
             cycle_count
             dt
             prev_variable
             prm
             isInterferrence=prm.experimentalSettings.isInterferrence
         end


        if prm.experimentalSettings.isRugekuttaMethodUse == 0
            y = moritaEulerMethod(@getLiquidPlantxdt,cycle_count,dt,prev_variable,prm,isInterferrence);
        end

        if prm.experimentalSettings.isRugekuttaMethodUse == 1
            y = moritaRungekuttaMethod(@getLiquidPlantxdt,cycle_count,dt,prev_variable,prm,isInterferrence);
        end

end






