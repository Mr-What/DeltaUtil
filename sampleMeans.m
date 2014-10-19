% replace repeated samples at same XY location by their mean
function a = sampleMeans(b)
  bx = round(b(:,1)*100);  % prevent hash mis-matches from round-off
  by = round(b(:,2)*100);
  [hash,idx] = sort(by*100 + bx);
  a=b;
  m=0;n=0;pos=[0,0];
  hashPrev = -9e9;
  for i=1:length(idx)
%disp(sprintf('%3d %d %8.2f %8.2f %5.1f %5.1f',i,n,hash(i),hashPrev,pos(1:2)));
    if (hash(i) > hashPrev)
      hashPrev = hash(i);
      if (m>0)
        a(m,:) = pos;
        a(m,3) = z/n;
      end
      pos = b(idx(i),:);
      z = pos(3);
      n = 1;
      m = m+1;
    else
      z = z + b(idx(i),3);
      n=n+1;
    end
  end
  a=a(1:m,:);
end
