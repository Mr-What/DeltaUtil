% Load a set of measurements of a standard test print
%
% Measurements should be a pair of two-character measurement
% point pneumonics, followed by the distance between them in mm
%
% Skipped measurements can be indicated by a <= 0 length
%
% Assumes delta bed coordinates are:
%
%      +Y                       3(RAMPS-Z)
%       ^                          X
%       |  Card coords            / \          Tower name/number
%       |                        /   \
%       +-->+X       (RAMPS-X)1 +-----+ 2 (RAMPS-Y)
%
%
% XYcal is struct returned by loadXYcalDef()
%
% RETURN:  Structure of measured distances, and their relationship
%          to entries in XYcal
function meas = loadXYcalMeas(XYcal,measFile)
   fd = fopen(measFile,'rt');
   [idx,dist]=loadMeasData(XYcal,fd);
   fclose(fd);
   meas.idx = idx;
   meas.dist = dist;
end

function [idx,dist]=loadMeasData(XYcal,fd)
   n = 0;
   while(1)
      line = fgetl(fd);
      if (isnumeric(line)), return; end  % end of data
      %[aNam,bNam,d,count,errMsg] = fscanf(fd,'%s %s %f','C');
      [aNam,bNam,d,count] = sscanf(line,'%s %s %f','C');
      disp(sprintf('%s %s %f',aNam,bNam,d));
      if (count != 3)
         return;
      end
      if (d <= 0)
         disp(['Measurement ',aNam,' ',bNam,' skipped.']);
      else
         ix = findPairIndex(XYcal,aNam,bNam);
         if (ix > 0)
            n=n+1;
            idx(n) = ix;
            dist(n) = d;
         end
      end
   end
end

% find the pair index for a measurement between the two named points
function idx = findPairIndex(XYcal,aNam,bNam)
   idx=0;
   idxA = getIndex(XYcal.points.name,aNam);
   if (idxA<=0)
      disp([aNam,' is not a valid point name']);
      return;
   end
   idxB = getIndex(XYcal.points.name,bNam);
   if (idxB<=0)
      disp([bNam,' is not a valid point name']);
      return;
   end

   idx = findPairByIndex(XYcal.pairs.idx,idxA,idxB);
   if (idx > 0)
      return;  % found it
   end
   % try other way around
   idx = findPairByIndex(XYcal.pairs.idx,idxB,idxA);
   if (idx <= 0)
      disp(['Pair ',aNam,' ',bNam,' not defined']);
   end
end

function ix = findPairByIndex(pIdx,ia,ib)
   ix = -1;
   ja=(ia==pIdx(:,1));
   jb=(ib==pIdx(:,2));
   j = find(ja .* jb == 1);
   if (length(j) > 1)
      disp(sprintf('Multiply defined pair, point index %d and %d',ia,ib));
      return;
   end
   if (length(j)==1)
      ix = j;
   end
end
