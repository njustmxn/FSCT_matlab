function label = gaussLabel(sigma, sz)
%% label = gaussLabel(sigma, sz)
% Generate a gaussian shaped label to be a expected response
% Inputs:   sigma   .....
%           sz      Size of the label window, scalar or 2-element vector
%                   are support. If sz is scalar, a square window will
%                   output.
%
% Copyright: njustmxn@163.com
% Revised:   2016.1.11

%%
if isscalar(sz)
    w = sz;
    h = sz;
else
    h = sz(1);
    w = sz(2);
end
[cs, rs] = meshgrid((1:w) - floor(w/2), (1:h) - floor(h/2));
label = exp(-0.5 * (((cs.^2 + rs.^2) / sigma^2)));
end