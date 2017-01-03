function [patch, corners] = imgPatch(img, bbox, method, angleRotate)
%% patch = imgPatch(img, bbox, method, angleRotate)
% Pick a image patch from specific bounding box([x,y,width,height]).
% Variable method has these values as follows : {'rect', 'center', 'point'}
% Each type of method correspond a specific type of description of bounding
% box. The default method is 'rect'. For detail, see "imgRect.m".
%
% Copyright: njustmxn@163.com
% Revised:   2016.1.11
% Revised:   2016.4.28
%% 
    if nargin == 2
        method = 'rect';
    elseif nargin < 4
        existRotate = 0;
    elseif isscalar(angleRotate)
        if method ~= 'center'
            error('The "method" must be "center" when angle has a non-zero value');
        end
        existRotate = 1;
    end
        
    h = size(img,1);
    w = size(img,2);    
    %% padding the source image
    switch method
        case 'point' 
            % bbox = [lt_x, lt_y, rb_x, rb_y]
            patch = img(bbox(2):bbox(4), bbox(1):bbox(3), :);            
        case 'rect'
            % bbox = [x,y,width,height]
            xs = floor(bbox(1)) + (1:bbox(3)) - 1;
            ys = floor(bbox(2)) + (1:bbox(4)) - 1;
            % check for out-of-bounds coordinates, and set them to the 
            % values at the borders
            xs(xs > w) = w;
            ys(ys > h) = h;
            patch = img(ys, xs, :);
%% here is another method for extracting patch at the method of 'rect'
%             if bbox(1)+bbox(3)-1 > w
%                 ra = bbox(1) + bbox(3) - 1 - w;
%             else
%                 ra = 0;
%             end
%             if bbox(2)+bbox(4)-1 > h
%                 ba = bbox(2) + bbox(4) - 1 - h;
%             else
%                 ba = 0;
%             end
%             imgExt = padarray(img,[ba,ra],'replicate','post');
%             patch = imgExt(bbox(2):(bbox(2)+bbox(4)-1), bbox(1):(bbox(1)+bbox(3)-1), :);                            
        case 'center' 
            % bbox = [center_x, center_y, width, height]                   
            if ~existRotate
                xs = floor(bbox(1)) + (1:bbox(3)) - floor(bbox(3)/2);
                ys = floor(bbox(2)) + (1:bbox(4)) - floor(bbox(4)/2);
                % check for out-of-bounds coordinates, and set them to the 
                % values at the borders
                xs(xs < 1) = 1;
                ys(ys < 1) = 1;
                xs(xs > w) = w;
                ys(ys > h) = h;
                patch = img(ys, xs, :);
            else
                w = bbox(3);
                h = bbox(4);
                l = sqrt((w^2 + h^2) * 0.25);
                theta = atan(h / w);
                angleRotate1 = angleRotate * pi / 180;
                wa = abs(l * cos(theta + angleRotate1) - w * 0.5);
                ha = abs(l * sin(theta + angleRotate1) - h * 0.5);
                bbox_new = round([bbox(1:2), w + wa * 2, h + ha * 2]);
                patch = imgPatch(img, bbox_new, 'center');
                patch = imrotate(patch, -angleRotate, 'bilinear', 'loose');
                bbox_new = round([size(patch, 2) * 0.5, size(patch, 1) * 0.5, w, h]);
                patch = imgPatch(patch, bbox_new, 'center');
                if nargout > 1
                    point(1,:) = [-w, -h] * 0.5;
                    point(2,:) = [w, -h] * 0.5;
                    point(3,:) = [w, h] * 0.5;
                    point(4,:) = [-w, h] * 0.5;
                    corners = zeros(2, 5);
                    tmpx = point(:,1) .* cos(angleRotate1) + point(:,2) .* sin(angleRotate1) + bbox(1);
                    tmpy = -point(:,1) .* sin(angleRotate1) + point(:,2) .* cos(angleRotate1) + bbox(2);
                    corners(:,1:4) = round([tmpx'; tmpy']);
                    corners(:,end) = corners(:,1);   
                end                  
            end   
    end    
end
    