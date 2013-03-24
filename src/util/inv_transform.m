function xout = inv_transform(xin, scale, shift)
% scale - scale for each coordinate
% shift - shift for each coordinate (in the original scale)
% returns xout = (xin - shift) * scale

l = size(xin, 1);
scale = repmat(scale, l, 1);
shift = repmat(shift, l, 1);

xout = xin ./ scale + shift;

