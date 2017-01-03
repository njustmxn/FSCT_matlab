function [positions, gt, fps, scale] = FSCT(specificVideo)
%% [positions, gt, fps, scale] = FSCT(specificVideo)
% Fast Scale-adaptive Correlation Tracking
% Copyright: njustmxn@163.com
% Revised:   2016.1.11
% Revised:   2016.4.28

%% base option
basePath = 'D:\Dataset\';
if nargin == 0
    specificVideo = [];
end
manualInitialize    = false;
lambda              = 1e-4;
visualize           = true;
groundtruthShow     = true;
%% translational tracking option
transPadding        = 1.5;
transSigma          = 0.5;
transSigmaFactor    = 1/25;
transLearningRate   = 0.02;
transCellSz         = 4;
transHogDcpSz       = 32;
%% scale variantion tracking option
scaleSwitch         = true;
scaleSigma          = 0.5;
scaleSigmaFactor    = 1/26;
scaleLearningRate   = 0.02;
scalePatchSz        = 40;
scaleCellSz         = 4;
scaleHogDcpSz       = [32,32];
rhoMinCoef          = 0.2;
logpolarMode        = 'a';
%% other initializing parameter
% normalized size of the seaching window patch
transPatchNormSz = transHogDcpSz * transCellSz;
% normalized size of the target patch in log-polar coordinate
scalePatchNormSz = scaleCellSz * scaleHogDcpSz;
%% get the log-polar transform framework
sampleGrid = lptform(scalePatchSz,scalePatchSz,scalePatchNormSz(2),scalePatchNormSz(1), rhoMinCoef);
%% get the image sequence and initialize the 1st frame
videoPath = chooseImgSeq(basePath, specificVideo);
[imgName, pos, tgtSz, gt] = loadImgSeqInfo(videoPath, manualInitialize);
% initialize the target bounding box
tgtBox = [pos(2),pos(1),tgtSz(2),tgtSz(1)]; % [x, y, width, height]
% window size, taking padding into account
winSz = round(tgtSz * (1+transPadding));
% initialize the searching window bounding box
winBox = [pos(2),pos(1),winSz(2),winSz(1)]; % [x, y, width, height]
% zoom facter in x and y direction
xZoom = winSz(2) / transHogDcpSz;
yZoom = winSz(1) / transHogDcpSz;
%% get pre-computed gaussian-shape labels
transYSigma = transHogDcpSz * transSigmaFactor;
yt = gaussLabel(transYSigma, transHogDcpSz);
ytf = fft2(yt);

if scaleSwitch
    scaleYSigma = sqrt(prod(scaleHogDcpSz)) * scaleSigmaFactor;
    ys = gaussLabel(scaleYSigma, scaleHogDcpSz);
    ysf = fft2(ys);
end
%% get pre-computed cosine window
cosWinTrans = hann(transHogDcpSz) * hann(transHogDcpSz)';
if scaleSwitch
    cosWinScale = hamming(scaleHogDcpSz(1)) * hamming(scaleHogDcpSz(2))';
end
%% pre-define some parameters for log-polar transform
if scaleSwitch    
    rhoMax = log(sqrt((scaleHogDcpSz(2)^2 + scaleHogDcpSz(1)^2) * 0.25));
    rhoMin = rhoMax + log(rhoMinCoef);
end
%% pre-alloc space for  the result
positions = zeros(numel(imgName), 4);
time = 0;
if scaleSwitch
    scale = ones(numel(imgName), 1);    
end

%% start loop
for i = 1:numel(imgName)
	% load image
	frameOrg = imread(imgName{i});    
    frame = frameOrg;
	if size(frame,3) > 1
		frame = rgb2gray(frame);
    end	
    % start count
    tic();
    if i == 1  
       %% first frame, train translation filter with initialization
		% extract searching window patch
        transPatch = imgPatch(frame, winBox, 'center');
        % extract HOG feature of searching window patch
        transX = patch2pattern(transPatch, transPatchNormSz, cosWinTrans, 'hog',  transCellSz);
        % train the translational filter
        transModel = fft2(transX);
        transKf = gaussCorrelationKernel(transSigma, transModel);
        transAlphaf = ytf ./ (transKf + lambda);
       %% fisrt frame, train scale filter
        if scaleSwitch
            % extract target patch
            scalePatch = imgPatch(frame, tgtBox, 'center');
            % extract HOG feature of target patch in log-polar coordinate
            scaleX = patch2pattern(scalePatch, scalePatchSz, cosWinScale, 'loghogV2', sampleGrid, scaleCellSz, logpolarMode);
            % train the scale filter
            scaleModel = fft2(scaleX);
            scaleKf = gaussCorrelationKernel(scaleSigma, scaleModel);
            scaleAlphaf = ysf ./ (scaleKf + lambda);                 
            scale(i) = 1;
        end
    else
       %% detect translation sample
        transPatch = imgPatch(frame, winBox, 'center');
        transX = patch2pattern(transPatch, transPatchNormSz, cosWinTrans, 'hog',  transCellSz);
        transXf = fft2(transX);
        transKf = gaussCorrelationKernel(transSigma, transXf, transModel);
        transResponse = real(ifft2(transAlphaf .* transKf));
        [row, col] = find(transResponse == max(transResponse(:)), 1);
		pos = round(pos - winSz/2 + [row * yZoom, col * xZoom]);
        winBox = [pos(2), pos(1), winSz(2), winSz(1)];  
       %% detect scale sample
        if scaleSwitch
            % update target bounding box
            tgtBox = [pos(2),pos(1),tgtSz(2),tgtSz(1)];
            % estimate the scale factor
            scalePatch = imgPatch(frame, tgtBox, 'center');
            scaleX = patch2pattern(scalePatch, scalePatchSz, cosWinScale, 'loghogV2', sampleGrid, scaleCellSz, logpolarMode);
            scaleXf = fft2(scaleX);
            scaleKf = gaussCorrelationKernel(scaleSigma, scaleXf, scaleModel);
            scaleResponse = real(ifft2(scaleAlphaf .* scaleKf));
            [~, col] = find(scaleResponse == max(scaleResponse(:)), 1);
            scale(i) = exp((col - scaleHogDcpSz(2)/2) * ( - log(rhoMinCoef)) / scaleHogDcpSz(2));            
            % update target size and searching window size
            tgtSz = round(tgtSz * scale(i));
            winSz = round(tgtSz * (1+transPadding));
            % update the bounding boxes
            tgtBox = [pos(2),pos(1),tgtSz(2),tgtSz(1)];           
            winBox = [pos(2), pos(1), winSz(2), winSz(1)];
            % update zoom factor in both direction
            xZoom = winSz(2) / transHogDcpSz;
            yZoom = winSz(1) / transHogDcpSz;
        end
       %% retrain translation filter in new searching window size at the most similar position
        transPatch = imgPatch(frame, winBox, 'center');
        transX = patch2pattern(transPatch, transPatchNormSz, cosWinTrans, 'hog',  transCellSz);
        transModel_new = fft2(transX);
        transKf = gaussCorrelationKernel(transSigma, transModel_new);
        transAlphaf_new = ytf ./ (transKf + lambda);
       %% retrain scale filter in new searching window size at the most similar position
        if scaleSwitch            
            scalePatch = imgPatch(frame, tgtBox, 'center');
            scaleX = patch2pattern(scalePatch, scalePatchSz, cosWinScale, 'loghogV2', sampleGrid, scaleCellSz, logpolarMode);
            scaleModel_new = fft2(scaleX);
            scaleKf = gaussCorrelationKernel(scaleSigma, scaleModel_new);
            scaleAlphaf_new = ysf ./ (scaleKf + lambda);
        end
       %% update filters
        transModel = (1 - transLearningRate) * transModel + transLearningRate * transModel_new;
        transAlphaf = (1 - transLearningRate) * transAlphaf + transLearningRate * transAlphaf_new;        
        if scaleSwitch
            scaleAlphaf = (1 - scaleLearningRate) * scaleAlphaf + scaleLearningRate * scaleAlphaf_new;
            scaleModel = (1 - scaleLearningRate) * scaleModel + scaleLearningRate * scaleModel_new;
        end
    end
   %% save tracking result
    positions(i,:) = round([pos([2,1]), tgtSz([2,1])]);
    time = time +  toc();
    fps = i/time;  

   %% visualization
    if visualize
        rectPosition = round([pos([2,1]) - tgtSz([2,1])/2, tgtSz([2,1])]);
        if i == 1
            fHandle = figure('NumberTitle', 'off', 'Menubar','none', 'Name', ['Tracking-', specificVideo]);
            imHandle = imshow(frameOrg, 'Border','tight');
            rectHandle = rectangle('Position',rectPosition, 'EdgeColor','r', 'LineWidth',2);
            tHandle_frame = text(5, 12, ['#',num2str(i)], 'Color','r', 'FontWeight','bold', 'FontSize',12);
            tHandle_fps = text(5, 24, ['fps: ',sprintf('%d',round(fps))], 'Color','r', 'FontWeight','bold', 'FontSize',12);
            % add something new to watch here
            % .......................
            if ~isempty(gt) && groundtruthShow
                rectHandle_gt = rectangle('Position',gt(i,:), 'EdgeColor','g', 'LineWidth',2, 'LineStyle', '--');
            end
            if scaleSwitch
                tHandle_scale = text(5, 36, ['scale: ',sprintf('%.3f',prod(scale))], 'Color','r', 'FontWeight','bold', 'FontSize',12);
    %             tHandle_rotate = text(5, 72, ['theta: ',num2str(theta(i))], 'Color','y', 'FontWeight','bold', 'FontSize',12);
            end
            % .......................
        else
            try
                set(imHandle, 'CData', frameOrg);
                set(rectHandle, 'Position', rectPosition);
                set(tHandle_frame, 'String', ['#',num2str(i)]);
                set(tHandle_fps, 'String', ['fps: ',sprintf('%d',round(fps))]);
                % add something new to watch here
                % .......................
                if exist('rectHandle_gt')
                    set(rectHandle_gt, 'Position', gt(i,:));
                end
                if scaleSwitch
                    set(tHandle_scale, 'String', ['scale: ',sprintf('%.3f',prod(scale))]);
    %                 set(tHandle_rotate, 'String', ['theta: ',num2str(theta(i))]);
                end                
                % .......................
            catch
                close all;
                return;
            end
        end
        pause(0.005);
    end
end
close all;
end