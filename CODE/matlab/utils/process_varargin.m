function varargs=process_varargin(args)
    assert(mod(length(args),2)==0);
    varargs = containers.Map();
    for i=1:2:length(args)
        varargs(args{i})=args{i+1};
    end
end
