% based off the paper: https://docs.google.com/viewer?a=v&pid=forums&srcid=MTgyNjQwODAyMDkxNzQxMTUwNzIBMDc2NTg4NjQ0MjUxMTE1ODY5OTkBdmZiejRRR2phZjhKATAuMQEBdjI
%
%Johann C. Rocholl (Rostock) Style
%Delta Robot Kinematics
%by Steve Graves
%
% port to octave, Aaron Birenboim 27sep2014

function cart = delta2cart(DP,dZ)

  % junction points on towers
  s = 0.8660254037844386; % sind(60)
  c = 0.5;                % cosd(60)
  dColP = [-s * DP.radius(1), -c * DP.radius(1), dZ(1);...
            s * DP.radius(2), -c * DP.radius(2), dZ(2);...
                   0        ,      DP.radius(3), dZ(3)];

  %dColP now has the three points on the columns. Calculate the vectors
  %representing the sides of the triangle connecting these tower junctions
  dv01 = dColP(2,:) - dColP(1,:);
  dv02 = dColP(3,:) - dColP(1,:);
  dv12 = dColP(3,:) - dColP(2,:);

  dMag01 = norm(dv01);
  dMag02 = norm(dv02);
  dMag12 = norm(dv12);

  % This gives us a vector normal to the plane of the triangle
  dvZ = cross(dv02,dv01);
  dMagZ = norm(dvZ);

  dDeterminate = 2 * dMagZ*dMagZ;
  alpha = dMag12*dMag12 * dot(dv01, dv02) / dDeterminate;
  beta  =-dMag02*dMag02 * dot(dv12, dv01) / dDeterminate;
  gamma = dMag01*dMag01 * dot(dv02, dv12) / dDeterminate;

  pCircumcenter = dColP(1,:)*alpha + ...
                  dColP(2,:)*beta  + ...
                  dColP(3,:)*gamma;

  dvCircumcenter = pCircumcenter - dColP(1,:);
  
  % Find the length from the circumcenter to the carriage point on a column
  %  (by the definition of circumcenter the distance is the same to any column)
  dMag2Circumcenter = norm(dvCircumcenter);

  % Now use the Pythagorean theorum to calculate the distance
  dZLen = sqrt(DP.RodLen*DP.RodLen - dMag2Circumcenter*dMag2Circumcenter);

  % Create the new vector and add it to the circumcenter point
  cart = pCircumcenter + dvZ * (dZLen/dMagZ);
end

%% ------------------------------------------  original Java source:
%double[] forwardKinematics(double[] dZ){
%   double[] cartesian = new double[3];
%   double[][] dColP = new double[3][3];
%   //Create the three points from the X-Y for each column combined with
%   //the input Z values
%   for(int iIdx = 0; iIdx < 3; iIdx++){
%     dColP[iIdx][0] = dCol[iIdx][0];
%     dColP[iIdx][1] = dCol[iIdx][1];
%     dColP[iIdx][2] = dZ[iIdx];
%   }

%//dColP now has the three points on the columns. Calculate the vectors
%//representing the sides of the triangle
%   double[] dv01 = vectorSub(dColP[1], dColP[0]);
%   double[] dv02 = vectorSub(dColP[2], dColP[0]);
%   double[] dv12 = vectorSub(dColP[2], dColP[1]);
%   double dMag01 = vectorMag(dv01);
%   double dMag02 = vectorMag(dv02);
%   double dMag12 = vectorMag(dv12);
%   //This gives us a vector normal to the plane of the triangle
%   double[] dvZ = vectorCrossProd(dv02, dv01);
%   double dMagZ = vectorMag(dvZ);
%   double dDeterminate = 2 * Math.pow(dMagZ, 2);
%   double alpha = Math.pow(dMag12, 2) * vectorDotProd(dv01, dv02)/dDeterminate;
%   double beta = -Math.pow(dMag02, 2) * vectorDotProd(dv12, dv01)/dDeterminate;
%   double gamma = Math.pow(dMag01, 2) * vectorDotProd(dv02, dv12)/dDeterminate;
%   double[] pCircumcenter = vectorAdd(vectorMult(dColP[0], alpha), vectorMult(dColP[1], beta));
%   pCircumcenter = vectorAdd(pCircumcenter, vectorMult(dColP[2], gamma));
%   double[] dvCircumcenter = vectorSub(pCircumcenter, dColP[0]);
%   //Find the length from the circumcenter to the carriage point on a column
%   //(by the definition of circumcenter the distance is the same to any column)
%   double dMag2Circumcenter = vectorMag(dvCircumcenter);
%   //Now use the Pythagorem theorum to calculate the distance
%   double dZLen =
%      Math.sqrt(Math.pow(dArmLen, 2) - Math.pow(dMag2Circumcenter, 2));
%   //Create the new vector and add it to the circumcenter point
%   cartesian = vectorAdd(pCircumcenter, vectorMult(dvZ, dZLen/dMagZ));
%   return cartesian;
%}
