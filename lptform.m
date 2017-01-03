function sampleGrid = lptform(wImg, hImg, nRho, nTheta, rminRatio)
%% function sampleGrid = lptform(wImg, hImg, nRho, nTheta, rminRatio)
% Log-Polar transformation framework
% Inputs:   wImg            input image width 
%           hImg            input image height
%           nRho            output image width
%           nTheta          output image height
%           rminRatio       minimum rho ratio of the the max rho
%           nPatch          number of the patches
% Outputs:  sampleGrid      sample grid of the Log-Polar coordinates to 
%                           interpolation in Cartisian coordinates
% 
% Copyright njustmxn@163.com
% Revised 2016.1.11
% Revised 2016.4.28

%%
% default origin(x0, y0) in Log-Polar coordinates is the image center
center = round([wImg, hImg] * 0.5);
% max rho is the half of the diagnoal rectangle
rmax = sqrt(hImg^2 + wImg^2) * 0.5;
% min rho omit the nearest point to avoid large-scale gradual change on
% plane but at a very little value range
rmin = rmax * rminRatio;
rho = exp(linspace(log(rmin),log(rmax),nRho));

thetaRange = [-pi, pi];
theta = linspace(thetaRange(1), thetaRange(2), nTheta+1);
theta(end) = [];
% convert polar coordinates to cartesian coordinates and center
xx = cos(theta)' * rho + center(1);
yy = sin(theta)' * rho + center(2);
sampleGrid = {xx, yy};
end