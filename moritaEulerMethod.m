function next_cycle_variable = moritaEulerMethod(functionPointer,cycle_count,dt,prev_variable,prm,tubePartIndex,isInterferrence)
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
        dxdt = functionPointer(cycle_count,dt,prev_variable,prm,tubePartIndex,isInterferrence);
        next_cycle_variable = dxdt * dt + prev_variable(:,2);

    else
        dxdt = functionPointer(cycle_count,dt,prev_variable,prm,tubePartIndex,isInterferrence);
        next_cycle_variable = dxdt * dt  + prev_variable(2,2);
    end

end