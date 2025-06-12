function next_cycle_variable = moritaEulerMethod(functionPointer,cycle_count,dt,prev_variable,prm,tubePartIndex,isInterferrence)
         arguments
             functionPointer
             cycle_count
             dt
             prev_variable
             prm
             tubePartIndex=1
             isInterferrence=prm.settings.isInterferrence
         end

    dxdt = functionPointer(cycle_count,dt,prev_variable,prm,tubePartIndex,isInterferrence);
    next_cycle_variable = dxdt * dt + prev_variable(:,2);


end