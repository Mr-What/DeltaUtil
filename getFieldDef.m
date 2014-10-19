% Like MatLab's getfield() function, but allows user to define a default
% return value (default=0) if the field does not exist.
%
%      val = getFieldDef(structVar,'fieldname'[,defaultValue]);
function a=getFieldDef(s,f,d)
if(isfield(s,f))
  a = getfield(s,f);
else
  if(nargin < 3), d=0; end  % default default value
  a=d;
end
