classdef (Abstract) Operator < handle
    properties
        prm
        dt
        comment
        cycleNum
        debugVectorCell
    end

    methods
        calcNextCycle(obj)
    end
end