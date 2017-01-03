function kf = gaussCorrelationKernel(sigma, xf, yf)
%GAUSSIAN_CORRELATION Gaussian Kernel at all shifts, i.e. kernel correlation.
%   Evaluates a Gaussian kernel with bandwidth SIGMA for all relative
%   shifts between input images X and Y, which must both be MxN. They must 
%   also be periodic (ie., pre-processed with a cosine window). The result
%   is an MxN map of responses.
%
%   Inputs and output are all in the Fourier domain.
%
%   Joao F. Henriques, 2014
%   http://www.isr.uc.pt/~henriques/
%
%   Revised by njustmxn@163.com 2016.1.11

	N = size(xf, 1) * size(xf, 2);
    xx = xf(:)' * xf(:) / N;  %squared norm of x
	if nargin > 2,  %general case, x and y are different
		yy = yf(:)' * yf(:) / N;
	else
		%auto-correlation of x, avoid repeating a few operations
        yf = xf;
		yy = xx;
    end
	%cross-correlation term in Fourier domain
	xyf = sum(xf .* conj(yf),3);
	xy = real(ifft2(xyf));  %to spatial domain
	kf = fft2(exp(-1 / sigma^2 * max(0, (xx + yy - 2 * xy)) / N));
end
