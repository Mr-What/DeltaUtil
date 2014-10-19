% find the index of a fixed-length string in a list
function i = getIndex(name,key)
  for i=1:size(name,1)
    if(strcmp(name(i,:),key))
      return;
    end
  end
  i=0;
end
