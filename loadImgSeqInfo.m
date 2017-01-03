function [imgNames, pos, tgtSz, gt] = loadImgSeqInfo(videoPath, draw)
%% [imgNames, pos, tgtSz, gt] = loadImgSeqInfo(videoPath, draw)
% load image names and initialize the target.
% User will not initialize the target manually when there is a gt.txt, and
% draw = 0 as default. if draw = 1 or there no gt.txt in videoPath, user
% will draw a rectangle manually to initialize the target.
% Outputs:  imgNames    per image name in absolute path
%           pos         initial center position of the target
%           tgtSz       initial target size
%           gt          ground truth
%
% Copyright: njustmxn@163.com
% Revised:   2016.1.11

%%
if nargin < 2
    draw = 0;
end
content = dir(videoPath);
gtfile = {};
for i = 3:numel(content)
    if content(i).isdir
        imgPath = [videoPath, content(i).name];
        imgNames = imgList(imgPath);
        continue;
    elseif strcmp(content(i).name(end-2:end), 'txt') && ~content(i).isdir
        gtfile{end+1} = content(i).name;       
        continue;
    end
end
if isempty(imgNames)
    error('No image sequence loaded. Please cheak the dataset path !');
end
if isempty(gtfile)
    draw = 1;
end
if draw
    disp('No ground truth found.');
    disp('Please draw rectangle manually to initialize the target ...');
    p = imgRect(imgNames{1}, 'center');
elseif numel(gtfile) > 1
    % choose gui
    choice = listdlg('ListString',gtfile, 'Name','Choose GroundTruth', ...
                        'SelectionMode','single');
    if isempty(choice)  %user cancelled
        error('No ground truth loaded.');
    else
        gt = load([videoPath, gtfile{choice}]);
    end
else
    gt = load([videoPath, gtfile{1}]);
end

if draw
    pos = p([2,1]);
    tgtSz = p([4,3]);
    gt = [];
else
    gt1 = gt(1,:);
    tgtSz = gt1([4,3]);
    pos = gt1([2,1]) + floor(tgtSz/2);
end
end

function imgNames = imgList(dataPath)	
%% imgNames = imgList(dataPath)
% list all images in specific path
% Copyright: njustmxn@163.com
% Revised:   2016.1.11

ext = {'jpg', 'png', 'bmp'};

if ~strcmp(dataPath(end), '\')
    dataPath(end+1) = '\'; 
end
contents = dir(dataPath);
imgNames = {};
for i = 1:numel(contents)
    name = contents(i).name;
    if ~strcmp(name, '.') && ~strcmp(name, '..')
        switch name(end-2:end)
            case ext{1}, imgNames{end+1} = [dataPath, name];
            case ext{2}, imgNames{end+1} = [dataPath, name];
            case ext{3}, imgNames{end+1} = [dataPath, name];
        end        
    end
end
end

function bb = imgRect(I, method)
%% bb = imgRect(I, method)
% Draw rectangle manually to initialize the target.
% Inputs:   I           source image
%           method      {'rect', 'center', 'point'}
%                       Note:   lt = left-top,  lb = left-bottom
%                               rt = right-top, rb = right-bottom
%                               c = center
%                       'rect'      bb = [lt_x, lt_y, width, height]
%                       'center'    bb = [c_x, c_y, width, height]
%                       'point'     bb = [lt_x, lt_y, rb_x, rb_y]
% Outputs:  bb          bounding box
%
% Copyright: njustmxn@163.com
% Revised:   2016.1.11

%%
    if nargin == 1
        method = 'rect';
    end
    
    figure('NumberTitle', 'off', 'Menubar','none', 'Name', 'Choose the ROI'); 
    imshow(I, 'Border','tight');
    text(10,10,'Define bounding box.','color','red');
    h = imrect;
    p = getPosition(h);
    close ('Choose the ROI');
    switch method
        case 'rect',   bb = floor(p);
        case 'center', bb = floor([bbCenter(p), p(3), p(4)]);
        case 'point',  bb = floor([bbRectPoint(p), p(3),p(4)]);
        otherwise
            error(['Unknown bounding box expression method: ',method]);
    end    
end

function center = bbCenter(bb)
% return a bounding box's center
% center = [x, y];
    center = []; 
    if isempty(bb)	
        return;
    end
    % if width is odd, the center locate on absolute median pixel
    % if width is even, the center shift left half a pixel of the absolute 
    % middle pixel
    if bitget(floor(bb(3)),1) % odd
        center(1) = bb(1) + floor(bb(3)/2); 
    else   % even
        center(1) = bb(1) + floor(bb(3)/2) - 1;
    end
    
    if bitget(floor(bb(4)),1)
        center(2) = bb(2) + floor(bb(4)/2);
    else
        center(2) = bb(2) + floor(bb(4)/2) -1;
    end
end
    
function Point = bbRectPoint(bb)
% return a bounding box's left-top point and right-bottom point
% Point = [lt_x, lt_y, rb_x, rb_y]
    Point = [];
    if isempty(bb)	
        return;
    end
    Point = [bb(1), bb(2), bb(1)+bb(3)-1, bb(2)+bb(4)-1];
end
