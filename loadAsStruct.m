% loads an .m file which defines variables, collects
% the results, and returns them plut the file name (fileName) as a struct.
% Any variable name is OK, as long as it is NOT
% one of the RESERVED variable names:
%      varStruct, fileName, whosInfo, iCounter, RESERVED, varName
function varStruct = loadAsStruct(fileName)
    run(fileName);
    whosInfo = whos();
    %whosInfo(:).name
    RESERVED = {"varStruct","whosInfo","iCounter",...
                "RESERVED", "varName"};
    varStruct = struct();
    for iCounter = 1:numel(whosInfo)
        varName = whosInfo(iCounter).name;
        if any(strcmp(varName, RESERVED))
            fprintf(2,"%s is RESERVED.  Ignored.\n",varName);
            continue;
        end
        varStruct.(varName) = eval(varName);
    end
end
    
