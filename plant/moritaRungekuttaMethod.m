function next_cycle_variable = moritaRungekuttaMethod(functionPointer,cycle_count,dt,prev_variable,prm,tubePartIndex,isInterferrence)
         arguments
             functionPointer
             cycle_count
             dt
             prev_variable
             prm
             tubePartIndex=1
             isInterferrence=prm.experimentalSettings.isInterferrence
         end

        if rem(tubePartIndex,4) ~=0
            half_dt = dt/2;
            k1 = functionPointer(cycle_count,dt,prev_variable,prm,tubePartIndex,isInterferrence);
            k2 = functionPointer(cycle_count,dt,prev_variable+half_dt*[zeros(3,1),k1,zeros(3,1),zeros(3,1),zeros(3,1)],prm,tubePartIndex,isInterferrence);
            k3 = functionPointer(cycle_count,dt,prev_variable+half_dt*[zeros(3,1),k2,zeros(3,1),zeros(3,1),zeros(3,1)],prm,tubePartIndex,isInterferrence);
            k4 = functionPointer(cycle_count,dt,prev_variable+dt*[zeros(3,1),k3,zeros(3,1),zeros(3,1),zeros(3,1)],prm,tubePartIndex,isInterferrence);
            next_cycle_variable = (k1 + 2*k2 + 2*k3 +k4) * (dt/6) + prev_variable(:,2);
        else
            half_dt = dt/2;
            k1 = functionPointer(cycle_count,dt,prev_variable,prm,tubePartIndex,isInterferrence);
            k2 = functionPointer(cycle_count,dt,prev_variable+half_dt*[zeros(3,1),[0;k1;0],zeros(3,1),zeros(3,1),zeros(3,1)],prm,tubePartIndex,isInterferrence);
            k3 = functionPointer(cycle_count,dt,prev_variable+half_dt*[zeros(3,1),[0;k2;0],zeros(3,1),zeros(3,1),zeros(3,1)],prm,tubePartIndex,isInterferrence);
            k4 = functionPointer(cycle_count,dt,prev_variable+dt*[zeros(3,1),[0;k3;0],zeros(3,1),zeros(3,1),zeros(3,1)],prm,tubePartIndex,isInterferrence);
            next_cycle_variable = (k1 + 2*k2 + 2*k3 +k4) * (dt/6) + prev_variable(2,2);
        end
 
        


end