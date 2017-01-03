function [pattern, resizedPatch] = patch2pattern(patch, patternSz, cosWindow, featureType, varargin)
%% pattern = patch2pattern(patch, patternSz, cosWindow, featureType, varargin)
% Transform the patch to specific pattern(feature)
% Inputs:   patch           input image, value type of uint8, single & 
%                           double are support
%           patternSz       specific size of resized patch, or the size of
%                           pattern, scalar or 2-element vector are support
%                           [row, col]
%           cosWindow       pre-defined window function to reduce edge
%                           effects in Fourier Transform, hanning or
%                           hamming window are available
%           featureType     features that transform patch to, following
%                           types are support: 
%                           'raw'       raw grayscale, [row, col]
%                           'hog'       Histograms of Oriented Gradients
%                                       [row, col, 31]
%                           'hograw'    'hog' + 'raw', [row, col, 32]
%                           'log'       Log-Polar transform of raw grayscale                                       
%                                       [row, col]
%                           'loghog'    'hog' of 'log'
%                                       [row, col, 31]
%                           'loghogV2'  4 main orients of LPT,
%                                       {'a','ac','bd', 'abcd'} are
%                                       availible. The figure below shows
%                                       the 4 situation.
%                                       +---b---+
%                                       |       |
%                                       a       c
%                                       |       |
%                                       +---d---+
%           varargin        acoording to the featureType, it has different
%                           value, details as follows:
%                           {'hog','hograw'}   cellsize(binsize),see fhog.m
%                           {'log'}     sample grid of log-polar transformation
%                                       see lptform.m, logpolar.m
%                           {'loghog'}  sample grid and cellsize
%                           {'loghogV2'}sample grid, cellsize and one of 
%                                       {'a', 'ac', 'bd', 'abcd'}
% Outputs:  pattern         output feature, it has different size when
%                           choose different feature type
% 
% Copyright njustmxn@163.com
% Revised 2016.1.11
% Revised 2016.4.28  Add the featureType of 'loghogV2'

%% get the size of pattern
if isscalar(patternSz)
    h = patternSz;
    w = patternSz;
else
    h = patternSz(1);
    w = patternSz(2);
end
%% resize the patch to specific size
% patch = imresize(patch, [h,w], 'bilinear'); 
if patternSz ~= size(patch)
    patch = mexResize(patch, [h,w], 'auto'); % 'mexResize' is much faster than 'imresize'
end
resizedPatch = patch;
%% calculate different feature according to 'featureType'
switch featureType
    case 'raw'
        pattern = im2double(patch) - 0.5;    
    case 'hog'
        cellSz = varargin{1};
        pattern = im2double(fhog(im2single(patch), cellSz));
        pattern(:, :, end) = [];
    case 'hograw'
        cellSz = varargin{1};
        pattern = im2double(fhog(im2single(patch), cellSz));
        hraw = h/cellSz;
        wraw = w/cellSz;
        patch = mexResize(patch, [hraw, wraw], 'auto');
        pattern(:, :, end) = im2double(patch) * 0.5;      
    case 'log'
        sampleGrid = varargin{1};
        pattern = logpolar(patch, sampleGrid) - 0.5;
    case 'loghog'
        sampleGrid = varargin{1};
        cellSz = varargin{2};
        lpPatch = logpolar(patch, sampleGrid);    
        pattern = im2double(fhog(im2single(lpPatch), cellSz));            
        pattern(:,:,end) = [];
    case 'loghogV2'
        sampleGrid = varargin{1};
        cellSz = varargin{2};
        orient = varargin{3};
        lpPatch = logpolar(patch, sampleGrid);
        switch orient
            case 'a'
                pattern = im2double(fhog(im2single(lpPatch), cellSz));
                pattern(:,:,end) = [];
            case 'ac'
                tmpC = circshift(lpPatch, floor(size(lpPatch, 1)/2));
                patternA = im2double(fhog(im2single(lpPatch), cellSz));
                patternA(:,:,end) = [];
                patternC = im2double(fhog(im2single(tmpC), cellSz));
                patternC(:,:,end) = [];
                pattern = cat(3, patternA, patternC);
            case 'bd'
                tmpB = circshift(lpPatch, floor(size(lpPatch, 1)/4));
                tmpD = circshift(lpPatch, -floor(size(lpPatch, 1)/4));
                patternB = im2double(fhog(im2single(tmpB), cellSz));
                patternB(:,:,end) = [];
                patternD = im2double(fhog(im2single(tmpD), cellSz));
                patternD(:,:,end) = [];
                pattern = cat(3, patternB, patternD);
            case 'abcd'
                tmpB = circshift(lpPatch, floor(size(lpPatch, 1)/4));
                tmpC = circshift(lpPatch, floor(size(lpPatch, 1)/2));
                tmpD = circshift(lpPatch, -floor(size(lpPatch, 1)/4));
                patternA = im2double(fhog(im2single(lpPatch), cellSz));
                patternA(:,:,end) = [];
                patternB = im2double(fhog(im2single(tmpB), cellSz));
                patternB(:,:,end) = [];
                patternC = im2double(fhog(im2single(tmpC), cellSz));
                patternC(:,:,end) = [];
                patternD = im2double(fhog(im2single(tmpD), cellSz));
                patternD(:,:,end) = [];
                pattern = cat(3, patternA, patternB, patternC, patternD);
        end
end
%% apply window function(hanning or hamming) to to reduce edge effects
if ~isempty(cosWindow)    
    pattern = bsxfun(@times, pattern, cosWindow);
end
end


