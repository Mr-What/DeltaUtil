% Load definitions of  measurements of a standard test print
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
% DP        -- Delta parameters structure.  Must contain:
%                 RodLen    -- length of diagonal rod
%                 radius(3) -- distance from "center" to tower 1,2,3
%
% pointsFile-- defines ideal location of several identified points
%              on the test object.  Names are of form AN, one
%              letter followed by one number
% pairsFile -- Defines pairs of points which can be measured.
%              two point names, followed by a i if they are internal
%              caliper measurements instead of external
%
% RETURN:  structure containine points and pairs definitions in
%          standard format
function XYcal = loadXYcalDef(DP,pointFile,pairFile)

XYcal.points = loadCalPointsFile(DP,pointFile); % load points, compute tower offst
XYcal.pairs  = loadCalPairsFile(DP,XYcal.points,pairFile); % load pair file, compute ideal distances

end

%%------------------------------- private functions

% load points, compute commanded tower positions for those points
function points = loadCalPointsFile(DP,pointFile)
   disp(['Loading point definitions from ',pointFile]);
   fd = fopen(pointFile,'rt');
   if (fd < 0)
     disp(['Unable to read ',pointFile]);
     return;
   end
   count = 3;
   n = 0;
   while(count == 3)
      %[pNam,x,y,count,errMsg] = fscanf(fd,'%s %f %f','C');
      [pNam,x,y,count] = fscanf(fd,'%s %f %f','C');
      if (count == 3)
         n=n+1;
         name(n,:) = pNam;  % should be exactly 2 characters
         loc(n,:) = [x,y];
         twr(n,:) = cart2delta(DP,[x,y,0]);
      else
          disp('end of data');
          %disp(errMsg);
          disp(sprintf('After %d points loaded',n));
      end
   end
   fclose(fd);
   points.name = name;
   points.xy = loc;
   points.twr = twr;
end

% load pair definition file, and compute ideal distances
function pairs = loadCalPairsFile(DP,points,pairFile)
   fd = fopen(pairFile,'rt');
   done = 0;
   n = 0;
   while(~done)
      line = fgetl(fd);
      if (isnumeric(line))
          done=1;
      else
         line = strtrim(line);
         tok = strsplit(line,' ');
         if (length(tok)>=2)
            n=n+1;
            inside(n)=0;  % default is outer dimension measurement
            if (length(tok)==3)
               if (tok{3} == 'i')
                  inside(n) = 1;
               end
            end
            idxA = getIndex(points.name,tok{1});
            idxB = getIndex(points.name,tok{2});
            idx(n,:) = [idxA,idxB];
            dist(n) = norm(points.xy(idxA,:) - points.xy(idxB,:));
         else
           done=1;
         end
      end
   end
   fclose(fd);
   pairs.idx = idx;
   pairs.inside = inside;
   pairs.dist = dist;
end
