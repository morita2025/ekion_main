function nextCycleVariable = control_N(cycle_count,dt,prev_variable,prm,tubePartIndex,isInterferrence)
         arguments
             cycle_count
             dt
             prev_variable
             prm
             tubePartIndex=1
             isInterferrence=prm.experimentalSettings.isInterferrence
         end


        % if prm.experimentalSettings.isRugekuttaMethodUse == 0
        %     y = moritaEulerMethod(@getControlNDxdt,cycle_count,dt,prev_variable,prm,tubePartIndex,isInterferrence);
        % end
        % 
        % if prm.experimentalSettings.isRugekuttaMethodUse == 1
        %     y = moritaRungekuttaMethod(@getControlNDxdt,cycle_count,dt,prev_variable,prm,tubePartIndex,isInterferrence);
        % end

        %dxdt
        

        %euler
        dxdt = getControlNDxdt(cycle_count,dt,prev_variable,prm,tubePartIndex,isInterferrence);
        %nextCycleVariableの更新
        y_13Next = prev_variable([1,3],2) + dt* dxdt([1,2]);
        y_4Next = prev_variable(3,4) + dt* dxdt(3);
        yl_3Next = prev_variable(3,3) + dt*dxdt(4); 
        yl_4Next = prev_variable(3,5) + dt* dxdt(5);
        nextCycleVariable = [y_13Next; y_4Next; yl_3Next; yl_4Next];
        



end






