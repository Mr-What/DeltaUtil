% Given a set of measurements of a standard test print, guess
% the individual tower radii, and delta rod length that was most
% likely to have caused this distortion.
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
% DeltaParams struct must contain:
%      radius(3) -- Marlin DELTA_RADIUS, which is radius from tip to center
%                   of tower pivot for diagonal arm, minus effector offset
%                   (kind of a radius - effector_offset)
%       RodLen   -- length between center of pivots on diagonal rods
%
% RETURN:  values to SUBTRACT from DELTA_RADIUS1,2,3
%          and diagonal rod length
%          settings to calibrate print bed
%          ... and the spread of the 3D printer
function [radiusErr, diagErr, spread,DP] = guessDeltaXYerr(DP1,pointFile,pairFile,measFile)

DP = DP1;
DP.verbose=1;
DP.cal.points = loadCalPointsFile(DP,pointFile); % load points, compute tower offst
DP.cal.pairs  = loadCalPairsFile(DP,pairFile); % load pair file, compute ideal distances
DP.meas = loadMeasurements(DP,measFile);

%err=deltaGuessErrXY([0,0,0,.05,.1],DP)
[dErr,nEval,status,err] = SimplexMinimize(...
              @(p) deltaGuessErrXY(p,DP),...
              [0 0 0 0 0], 0.1*[1 1 1 1 0.3], 0.005*[1 1 1 1 .5], 300)
radiusErr =-dErr(1:3);
diagErr   =-dErr(4);
spread    = dErr(5);

end

% Error metric for minimization
function err = deltaGuessErrXY(p,DP)
err = deltaErrXY(p,DP);
err = mean(err .* err);
disp(sqrt(err))
end

% retrieve whole error vector
function err = deltaErrXY(p,GP)
DP = struct('RodLen',GP.RodLen+p(4),...
            'radius',GP.radius+p(1:3));
n = length(GP.meas.dist);
errD = zeros(n,1);
spread = p(5);
for i=1:n
  iPair = GP.meas.idx(i);  % index of point pair measured
  pIdx = GP.cal.pairs.idx(iPair,:);  % indices of two points measured
  ta = GP.cal.points.twr(pIdx(1),:); % tower commands, point a
  tb = GP.cal.points.twr(pIdx(2),:); % tower commands, point b
  a = delta2cart(DP,ta); % recover position with err
  b = delta2cart(DP,tb);
  d = norm(a-b); % simulated expected measurement

  % adjust simulted measurement by print spread, to match physical
  if (GP.cal.pairs.inside(iPair))
     d = d - 2*spread;
  else
     d = d + 2*spread;
  end
  err(i) = d - GP.meas.dist(i);
end
end

%%------------------------------- private functions

% load points, compute commanded tower positions for those points
function points = loadCalPointsFile(DP,pointFile)
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
function pairs = loadCalPairsFile(DP,pairFile)
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
            idxA = getIndex(DP.cal.points.name,tok{1});
            idxB = getIndex(DP.cal.points.name,tok{2});
            idx(n,:) = [idxA,idxB];
            dist(n) = norm(DP.cal.points.xy(idxA,:) - DP.cal.points.xy(idxB,:));
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

function i = getIndex(name,key)
  for i=1:size(name,1)
    if(strcmp(name(i,:),key))
      return;
    end
  end
  i=0;
end

% load pair distance measurements
function meas = loadMeasurements(DP,measFile)
   fd = fopen(measFile,'rt');
   [idx,dist]=loadMeasData(DP,fd);
   fclose(fd);
   meas.idx = idx;
   meas.dist = dist;
end

function [idx,dist]=loadMeasData(DP,fd)
   n = 0;
   while(1)
      line = fgetl(fd);
      if (isnumeric(line)), return; end  % end of data
      %[aNam,bNam,d,count,errMsg] = fscanf(fd,'%s %s %f','C');
      [aNam,bNam,d,count] = sscanf(line,'%s %s %f','C');
      if (DP.verbose), disp(sprintf('%s %s %f',aNam,bNam,d)); end
      if (count != 3)
         return;
      end
      if (d <= 0)
         disp(['Measurement ',aNam,' ',bNam,' skipped.']);
      else
         ix = findPairIndex(DP,aNam,bNam);
         if (ix > 0)
            n=n+1;
            idx(n) = ix;
            dist(n) = d;
         end
      end
   end
end

% find the pair index for a measurement between the two named points
function idx = findPairIndex(DP,aNam,bNam)
   idx=0;
   idxA = getIndex(DP.cal.points.name,aNam);
   if (idxA<=0)
      disp([aNam,' is not a valid point name']);
      return;
   end
   idxB = getIndex(DP.cal.points.name,bNam);
   if (idxB<=0)
      disp([bNam,' is not a valid point name']);
      return;
   end

   idx = findPairByIndex(DP.cal.pairs.idx,idxA,idxB);
   if (idx > 0)
      return;  % found it
   end
   % try other way around
   idx = findPairByIndex(DP.cal.pairs.idx,idxB,idxA);
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
