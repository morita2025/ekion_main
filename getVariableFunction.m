function output_struct = getVariableFunction(blockNum,t,refTimePrm,ref) 

    AlmiNum = blockNum*3;
    TubeNum = blockNum*4;
    tLength = length(t);

    output_struct = struct;
    refs = repmat(transpose(ref(1,:)),blockNum,1);
    output_struct.ref = refs.*ones(AlmiNum,tLength);
    output_struct.e=zeros(AlmiNum,tLength);
    output_struct.e_asterisk=zeros(AlmiNum,tLength);
    output_struct.r_asterisk=zeros(AlmiNum,tLength);
    output_struct.u=zeros(AlmiNum,tLength);
    output_struct.y_a=zeros(AlmiNum,tLength);
    output_struct.y_l=zeros(TubeNum,tLength);
    output_struct.y=zeros(TubeNum,tLength);
    output_struct.f=zeros(AlmiNum,tLength);
    output_struct.f_1=zeros(AlmiNum,tLength);
    output_struct.f_2=zeros(AlmiNum,tLength);
    output_struct.b=zeros(AlmiNum,tLength);
    output_struct.disturbunceYa=zeros(AlmiNum,tLength);
    output_struct.disturbunceY=zeros(TubeNum,tLength);
    output_struct.disturbunceYl=zeros(TubeNum,tLength);
    output_struct.y_f=zeros(AlmiNum,tLength);
    output_struct.y_g=zeros(AlmiNum,tLength);

    if blockNum<4
        for blockId=1:blockNum
            output_struct.ref(3*blockId-2:3*blockId,:) = [ref(blockId, 1); 0; ref(blockId, 3)].* (1 - exp(-refTimePrm*t)  );
        end
    else
        %blocKNum=40などref設定が大変な場合の簡易初期化
        tRefTimePrm = 1/40;
        output_struct.ref((1:3:AlmiNum-2),:) = 0.12 + 0.2*0.09*transpose(1:1:blockNum) .* ones(1,tLength);
        output_struct.ref((3:3:AlmiNum),:) =  0.03 + 0.2*0.09*transpose(1:1:blockNum) .* ones(1,tLength);
        output_struct.ref(:,:) = output_struct.ref(:,1) .*  (1 - exp(-tRefTimePrm*t)  );
        warndlg ({"boxNum>3のため仮目標値が設定されます"; "この表示は勝手に消えます(演算中)"},"oshirase");
    end
end