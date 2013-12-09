function M = modelInitGPS(dim, X, y, varargin)
% modelInitGPS Creates a new, untrained, GP model for Lawrence's GP Software
%
% M = modelInitGPS(dim, X, y) initializes an squared exp. RBF-based kernel
%                       GP model without approximations for y --> f(X)
% M = modelInitGPS(dim, X, y, options) initializes GP model with specific
%                       options
%
% See also modelInit

% Set up the model
if (nargin > 3)
  options = gpOptions('ftc');
else
  options = varargin{1};
end

% Scale outputs to variance 1.
options.scale2var1 = true;

% Use the full Gaussian process model.
q = size(X, 2);
d = size(y, 2);
M = gpCreate(q, d, X, y, options);

if (nargin > 3 && isstruct(varargin{1}))
  if (isfield(varargin{1}, 'mean'))
    M.mean = varargin{1}.mean;
  end
end
