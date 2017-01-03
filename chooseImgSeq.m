function videoPath = chooseImgSeq(basePath, specificName)
%% videoPath = chooseImgSeq(basePath, specificName)
% Choose image sequence in GUI manually or using the given one, and return
% the sequence path.
% Copyright: njustmxn@163.com
% Revised:   2016.1.11

%%
if nargin == 1
    specificName = [];
end
if ~strcmp(basePath(end), '\')
    basePath(end+1) = '\'; 
end
%list all files and select the sub-folders
contents = dir(basePath);
filename = {};
for i = 1:numel(contents)
    name = contents(i).name;
    if isdir([basePath name]) && ~strcmp(name, '.') && ~strcmp(name, '..')
        filename{end+1} = name;  
    end
end
% no sub-folders found
if isempty(filename)
    error('No image sequence found !');
end

if isempty(specificName)
    % open GUI
    choice = listdlg('ListString',filename, 'Name','Choose Image Sequence', 'SelectionMode','single');
    if isempty(choice)
        error('No image sequence loaded !');
    else
        videoPath = [basePath filename{choice} '\'];
    end
else
    for i = 1:numel(filename)
        if strcmp(specificName, filename{i})
            videoPath = [basePath filename{i} '\'];
        end
    end
end
end
