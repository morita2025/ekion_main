function output_struct = getVariableFunction(length,ref)



    output_struct = struct;
    ref_3 = [ref(1,1); 0; ref(2,1)];
    output_struct.ref = ref_3.*ones(3,length);
    output_struct.e=zeros(3,length);
    output_struct.e_asterisk=zeros(3,length);
    output_struct.r_asterisk=zeros(3,length);
    output_struct.u=zeros(3,length);
    output_struct.y_a=zeros(3,length);
    output_struct.y_l=zeros(3,length);
    output_struct.y=zeros(3,length);
    output_struct.f=zeros(3,length);
    output_struct.b=zeros(3,length);
    output_struct.y_f=zeros(3,length);
    output_struct.y_g=zeros(3,length);



end