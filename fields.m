% utility to do a whos on all fields in a struct
function fields(s)
    fn = fieldnames(s);
    for k=1:length(fn)
        c = class(s.(fn{k}));
        sz = size(s.(fn{k}));
        fprintf(1,'\t%s\t%s\t',fn{k},c);
        disp(sz);
    end
end
