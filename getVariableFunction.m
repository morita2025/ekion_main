function output_struct = getVariableFunction(blockNum,length,ref)

    AlmiNum = blockNum*3;
    TubeNum = blockNum*4;

    output_struct = struct;
    refs = repmat(ref,blockNum,1);
    output_struct.ref = refs.*ones(AlmiNum,length);
    output_struct.e=zeros(AlmiNum,length);
    output_struct.e_asterisk=zeros(AlmiNum,length);
    output_struct.r_asterisk=zeros(AlmiNum,length);
    output_struct.u=zeros(AlmiNum,length);
    output_struct.y_a=zeros(AlmiNum,length);
    output_struct.y_l=zeros(TubeNum,length);
    output_struct.y=zeros(TubeNum,length);
    output_struct.f=zeros(AlmiNum,length);
    output_struct.b=zeros(AlmiNum,length);
    output_struct.y_f=zeros(AlmiNum,length);
    output_struct.y_g=zeros(AlmiNum,length);



end