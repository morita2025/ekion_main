classdef LegacyPlantAdapter  < handle & Operator
    properties
        blockNum
        prevYa
        prevY
        prevYl
        prevTildeYa
        prevTildeY
        prevTildeYl
        

    end

    methods
        function obj = LegacyPlantAdapter(options)
            arguments                
                options.prm = [];
                options.dt  =1;
                options.cycleNum  = 1;
                options.comment = "";
                options.blockNum = 1;
            end
            obj.prm = options.prm;
            obj.dt = options.dt;
            obj.cycleNum = options.cycleNum;
            obj.comment = options.comment;
            obj.blockNum = options.blockNum;
            
            obj.debugVectorCell = {};
            obj.prevYa = zeros(obj.blockNum*3,1);
            obj.prevY = zeros(obj.blockNum*4,1);
            obj.prevYl = zeros(obj.blockNum*4,1);
            obj.prevTildeYa = zeros(obj.blockNum*3,1);
            obj.prevTildeY = zeros(obj.blockNum*4,1);
            obj.prevTildeYl = zeros(obj.blockNum*4,1);
           

        end

        function nextPlantVariable = calcNextCycle(obj,prevPlantVariableOpt) %u,disturbunce → y, ya ,yl
            arguments
                obj 
                prevPlantVariableOpt.u = zeros(3*obj.blockNum,1);
                prevPlantVariableOpt.disturbunceYa = zeros(4*obj.blockNum,1);
                prevPlantVariableOpt.disturbunceY = zeros(4*obj.blockNum,1);
                prevPlantVariableOpt.disturbunceYl = zeros(4*obj.blockNum,1); 
            end

            inputCurrent = prevPlantVariableOpt.u;
            disturbunceYa = prevPlantVariableOpt.disturbunceYa;
            disturbunceY = prevPlantVariableOpt.disturbunceY;
            disturbunceYl = prevPlantVariableOpt.disturbunceYl;
            


            %% LegacyPlant      
            nextTildeYa = zeros(size(obj.prevTildeYa));
            nextTildeY = zeros(size(obj.prevTildeY));
            nextTildeYl = zeros(size(obj.prevTildeYl));
            addInterferenceElements = cell(obj.blockNum,1);
            % connectTubePlantElements = cell(obj.blockNum,1);
            dummyCycleCount = 2;

            for blockId =1:obj.blockNum %y addInterferenceElements  
                if blockId ==1
                    addInterferenceElements{blockId} ...
                        = [[obj.prevY(1); 0; obj.prevY(4*blockId)] , ... %y 干渉
                          [0; 0; obj.prevYl(4*blockId)]]; %yl 干渉
                else
                    addInterferenceElements{blockId} ...
                        = [[obj.prevY(4*blockId-4);  0; obj.prevY(4*blockId)] ,...
                          [obj.prevYl(4*blockId-4); 0; obj.prevYl(4*blockId)]];
                end
            end

            for blockId =1:obj.blockNum  %box内のプラント
                nextTildeYa(3*blockId-2:3*blockId)= D_inv(dummyCycleCount,obj.dt,...
                            [inputCurrent(3*blockId-2:3*blockId),obj.prevTildeYa(3*blockId-2:3*blockId),...
                            obj.prevYl(4*blockId-3:4*blockId-1),addInterferenceElements{blockId}],obj.prm);
        
                nextTildeY(4*blockId-3:4*blockId-1)  = N(dummyCycleCount,obj.dt,...
                            [obj.prevYa(3*blockId-2:3*blockId),obj.prevTildeY(4*blockId-3:4*blockId-1),...
                             obj.prevYl(4*blockId-3:4*blockId-1),addInterferenceElements{blockId}],obj.prm);
        
                nextTildeYl(4*blockId-3:4*blockId-1) = LiquidPlant(dummyCycleCount,obj.dt,...
                            [obj.prevY(4*blockId-3:4*blockId-1),obj.prevTildeYl(4*blockId-3:4*blockId-1),...
                            zeros(3,1),addInterferenceElements{blockId}],obj.prm);
            end

            for blockId =1:obj.blockNum %part4k (k=1,2,3...)
                if blockId~=blockId
                    connectTubePlantElements = [zeros(3,1),obj.prevTildeY(4*blockId-1:4*blockId+1),...
                           obj.prevYl(4*blockId-1:4*blockId+1),zeros(3,2)];
                    connectLiquidPlantElements = [obj.prevY(4*blockId-1:4*blockId+1),...
                           obj.prevTildeYl(4*blockId-1:4*blockId+1),zeros(3,1),zeros(3,2)];
                else
                    connectTubePlantElements = [zeros(3,1),[obj.prevTildeY(4*blockId-1:4*blockId);  obj.prevTildeY(4*blockId)],...
                           [obj.prevYl(4*blockId-1:4*blockId); obj.prevYl(4*blockId)],zeros(3,2)];
                    connectLiquidPlantElements = [[obj.prevY(4*blockId-1:4*blockId); obj.prevY(4*blockId)],...
                           [obj.prevTildeYl(4*blockId-1:4*blockId); obj.prevTildeYl(4*blockId)],zeros(3,1),zeros(3,2)];
                end
                nextTildeY(4*blockId) = N(dummyCycleCount,obj.dt,connectTubePlantElements,obj.prm,4);
                nextTildeYl(4*blockId) = LiquidPlant(dummyCycleCount,obj.dt,connectLiquidPlantElements,obj.prm,4);
            end


            %% output

            %外乱 
            nextYa = nextTildeYa + disturbunceYa;
            nextY = nextTildeY + disturbunceY;
            nextYl = nextTildeYl + disturbunceYl;

            %objに保存
            obj.prevYa =  nextYa;
            obj.prevY = nextY;
            obj.prevYl = nextYl;
            obj.prevTildeYa = nextTildeYa;
            obj.prevTildeY = nextTildeY;
            obj.prevTildeYl = nextTildeYl;
            
            nextPlantVariable = struct("y_a",nextYa,"y",nextY,"y_l",nextYl,...
                                "debug",struct("tildeYa",nextTildeYa,"tildeY",nextTildeY,"tildeYl",nextTildeYl));

            

        end
    end
end