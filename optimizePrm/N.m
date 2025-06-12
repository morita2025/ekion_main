function y = N(cycle_count,dt,prev_variable,prm,isInterferrence)
         arguments
             cycle_count
             dt
             prev_variable
             prm
             isInterferrence=prm.experimentalSettings.isInterferrence
         end


        if prm.experimentalSettings.isRugekuttaMethodUse == 0
            y = moritaEulerMethod(@getNDxdt,cycle_count,dt,prev_variable,prm,isInterferrence);
        end

        if prm.experimentalSettings.isRugekuttaMethodUse == 1
            y = moritaRungekuttaMethod(@getNDxdt,cycle_count,dt,prev_variable,prm,isInterferrence);
        end

end






