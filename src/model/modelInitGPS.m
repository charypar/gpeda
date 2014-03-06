function M = modelInitGPS(dim, varargin)
% modelInitGPS Creates a new, untrained, GP model for Lawrence's GP Software
%
% M = modelInitGPS(dim, X, y) initializes an squared exp. RBF-based kernel
%                       GP model without approximations for y --> f(X)
% M = modelInitGPS(dim, X, y, options) initializes GP model with specific
%                       options
%
% See also modelInit

% Set up the model
options = gpOptions('ftc');
if (nargin > 3)
  if (isstruct(varargin{1}))
    fn = fieldnames(varargin{1});
    for i = 1:length(fn)
      options = setfield(options, fn{i}, getfield(varargin{1}, fn{i}));
    end
  elseif (isstring(varargin{1}))
    options = gpOptions(varargin{1});
  end
end

% Scale outputs to variance 1.
options.scale2var1 = true;

M.options = options;
M.dim = dim;

%{
% Use the full Gaussian process model.
q = size(X, 2);
d = size(y, 2);
M = gpCreate(q, d, X, y, options);

if (nargin > 3 && isstruct(varargin{1}))
  if (isfield(varargin{1}, 'mean'))
    M.mean = varargin{1}.mean;
  end
end
%}
