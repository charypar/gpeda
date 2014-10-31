function [rnd, neval, errCode, nTolXErrors, maxLogPdf] = myslicesample(initial,nsamples,varargin)
%MYSLICESAMPLE Modified slice sampling method from Matlab/Stast toolbox
%   RND = SLICESAMPLE(INITIAL,NSAMPLES,'pdf',PDF) draws NSAMPLES random
%   samples from a target distribution with the density function PDF using
%   the slice sampling. INITIAL is a row vector or scalar containing the
%   initial value of the random sample sequences. INITIAL must be within
%   the domain of the target distribution. NSAMPLES is the number of
%   samples to be generated. PDF is a function handle created using @. PDF
%   takes only one argument as an input and this argument has the same type
%   and size as INITIAL. It defines a function that is proportional to the
%   target density function. If log density function is preferred, 'pdf'
%   can be replaced with 'logpdf'. The log density function is not
%   necessarily normalized, either. 
%  
%   RND = SLICESAMPLE(...,'width',W) performs slice sampling for the target
%   distribution with a typical width W. W is a scalar or vector. If it is
%   a scalar, all dimensions are assumed to have the same typical widths.
%   If it is a vector, each element of the vector is the typical width of
%   the marginal target distribution in that dimension. The default value
%   of W is 10.
% 
%   RND = SLICESAMPLE(...,'burnin',K) generates random samples with values
%   between the starting point and the K-th point omitted in the generated
%   sequence, but keep points after that. K is a non-negative integer. The
%   default value of K is 0. 
%
%   RND = SLICESAMPLE(...,'thin',M) generates random samples with M-1 out of
%   M values omitted in the generated sequence. M is a positive integer.
%   The default value of M is 1.
%
%   [RND, NEVAL] = SLICESAMPLE(...) also returns NEVAL as the averaged
%   number of function evaluations occurred in the slice sampling. NEVAL is
%   a scalar.
%   
%   Example: 
%    Generate random samples from a distribution with a user-defined pdf:
%      f = @(x) exp( -x.^2/2).* ...       % This is a function proportional  
%               (1+(sin(3*x)).^2).* ...   % to the pdf for a multi-modal 
%               (1+(cos(5*x).^2));        % distribution
%      x = slicesample(1,2000,'pdf',f,'thin',5,'burnin',1000);  
%      hist(x,50)
%      set(get(gca,'child'),'facecolor',[0.6 .6 .6]);
%      hold on 
%      xd = get(gca,'XLim');              % Gets the x-data of the bins.
%      binwidth = (xd(2)-xd(1));          % Finds the width of each bin.
%      y = 5.6398*binwidth* ...           % Normalization necessary to 
%          f(linspace(xd(1),xd(2),1000)); % overplot the histogram.
%      plot(linspace(xd(1),xd(2),1000),y,'r')
%   
%   See also: MHSAMPLE, RAND, HIST, PLOT.

%   Slice sampling algorithm is summarized as 
%   (a) Starting form x0. 
%   (b) Draw a real value, y, uniformly from (0, f(x0)). 
%   (c) Find an interval, around x0, that contains all, or much, of the 
%       slice S ={x : f(x)>f(x0)}. 
%   (d) Draw the new point, x1, uniformly from the part of the slice within
%       this interval as a sample from this distribution. 
%   (e) Assign x1-->x0, and go back to step (b). 
%   (f) Repeat until the requested number of samples are obtained. 
%     
%   There are different ways of implementing step (c). We employ a strategy
%   called stepping-out and shrinking-in suggested by Neal(2003).
%
%   Reference: 
%     R. Neal (2003), Slice Sampling, Annals of Statistics, 31(3), p705-767
 
% Copyright 2005-2011 The MathWorks, Inc.

narginchk(4,Inf);  % initial, nsamples and pdf or logpdf are required.

if isempty(initial)  % initial value is required to run the slice sampling.
    error(message('stats:slicesample:EmptyIni'));
end;
if ~isvector(initial)  % initial value is required to be a vector or scalar
    error(message('stats:slicesample:NonvectorIni'));
end;

initial = initial(:)';
% parse the information in the name/value pairs 
pnames = {'pdf' ,'logpdf', 'width','burnin','thin','dataset','minTolX', 'maxTolXErrors', 'model'};
dflts =  {[] [] 10 0 1, [], 0.002, nsamples, []};
[pdf,logpdf,width,burnin,thin,dataset,minTolX, maxTolXErrors, M] = ...
       internal.stats.parseArgs(pnames, dflts, varargin{:});
 
% pdf or logpdf for target distribution has to be provided.
if isempty(pdf)&& isempty(logpdf)
    error(message('stats:slicesample:EmptyTarget'));
end;
 
% log density is used for numercial stability
if  isempty(logpdf)
    checkFunErrs('pdf',pdf,initial); % error check for pdf function
    logpdf =@(x) mylog(pdf(x)); % log density
else
    checkFunErrs('logpdf',logpdf,initial); % error check for logpdf function
end;

if (logpdf(initial)==-Inf)
    % error(message('stats:slicesample:BadInitial'))
    errCode = 4;
end
%error checks for burnin and thin
if (burnin<0) || burnin~=round(burnin)
    error(message('stats:slicesample:BadBurnin'));
end
if (thin<=0)|| thin~=round(thin)
    error(message('stats:slicesample:BadThin'));
end
 
% MAXITER is used to limit the total number of iterations for each step.
maxiter = 500;
dim = size(initial,2); % dimension of the distribution
outclass = superiorfloat(initial); %single or double
rnd = zeros(nsamples,dim,outclass); % place holder for the random sample sequence

neval = nsamples;  % one function evaluation is needed for each slice of the density.

% e = exprnd(1,nsamples*thin+burnin,1); % needed for the vertical position of the slice.
% RW = rand(nsamples*thin+burnin,dim); % factors of randomizing the width
% RD = rand(nsamples*thin+burnin,dim); % uniformly draw the point within the slice
x0 = initial; % current value 

% bool function indicating whether the point is inside the slice.
inside = @(x,th) (logpdf(x) > th); 

nSampled = 0;
nTolXErrors = 0;
maxLogPdf = -Inf;

if (exist('errCode') && errCode > 0)
  rnd = [];
  return;
else
  errCode = 0;
end

while ((nSampled < nsamples) && (nTolXErrors < maxTolXErrors))
  for j = 1:thin
    % A vertical level is drawn uniformly from (0,f(x0)) and used to define
    % the horizontal "slice".
    % z = logpdf(x0) - e(i+burnin);
    curr_logpdf = logpdf(x0);
    z = curr_logpdf - exprnd(1);
    maxLogPdf = max(maxLogPdf, curr_logpdf);

    % An interval [xl, xr] of width w is randomly position around x0 and then
    % expanded in steps of size w until both size are outside the slice.   
    % The choice of w is usually tricky.  
    % r = width.*RW(i+burnin,:); % random width/stepsize
    r = width.*rand(1,dim); % random width/stepsize
    xl = x0 - r;
 
    xr = xl + width; 
    iter = 0;
    
    % step out procedure is performed only when univariate samples are drawn.
    if dim==1 
        % step out to the left.
        while inside(xl,z) && iter<maxiter
            xl = xl - width;
            iter = iter +1;
        end       
        if iter>=maxiter || any(xl<-sqrt(realmax)) % It takes too many iterations to step out.
            error(message('stats:slicesample:ErrStepout')) 
        end;
        neval = neval +iter;
        % step out to the right
        iter = 0;  
        while (inside(xr,z)) && iter<maxiter
            xr = xr + width;
            iter = iter+1;        
        end
        if iter>=maxiter || any(xr>sqrt(realmax)) % It takes too many iterations to step out.
             error(message('stats:slicesample:ErrStepout')) 
        end;
    end;
    neval = neval +iter;
    
    % A new point is found by picking uniformly from the interval [xl, xr].
    % xp = RD(i+burnin,:).*(xr-xl) + xl;
    xp = rand(1,dim).*(xr-xl) + xl;
    
    % shrink the interval (or hyper-rectangle) if a point outside the
    % density is drawn.
    iter = 0;  
    while(~inside(xp,z))&& iter<maxiter 
        rshrink = (xp>x0);
        xr(rshrink) = xp(rshrink);
        lshrink = ~rshrink;
        xl(lshrink) = xp(lshrink);
        xp = rand(1,dim).*(xr-xl) + xl; % draw again
        iter = iter+1;
    end
    if iter>=maxiter % It takes too many iterations to shrink in.
             error(message('stats:slicesample:ErrShrinkin')) 
    end

    x0 = xp; % update the current value 

    neval = neval +iter;
  end   % for j = 1:thin

  % Check the TolX condition:
  dataset_s = [dataset; rnd(1:nSampled,:)];
  min_d = min(distToDataset(x0, dataset_s));
  if ((min_d >= minTolX) && isCovarianceSPD(M, dataset_s, 'bool'))
    nSampled = nSampled + 1;
    rnd(nSampled,:) = x0;
  else
    nTolXErrors = nTolXErrors + 1;
  end
end

% neval = neval/(nsamples*thin+burnin); % averaged number of evaluations

if (nSampled < (nsamples));
  rnd((nSampled+1):end,:) = [];
  disp(['sampleSlice(): Not enough (only ' num2str(nSampled) ' out of ' num2str(nsamples) ...
     ') draws can be sampled far enough from the dataset.']);
  errCode = 2;
  return;
end


%-------------------------------------------------
function  y = mylog(x)
% MYLOG function is defined to avoid Log of Zero warnings. 
y = -Inf(size(x));
y(x>0) = log(x(x>0));
 
%----------------------------------------------------
function checkFunErrs(type,fun,param)
%CHECKFUNERRS Check for errors in evaluation of user-supplied function
if isempty(fun), return; end
try 
    out=fun(param);
catch ME
    m = message('stats:slicesample:FunEvalError',type,func2str(fun));
    throwAsCaller(addCause(MException(m.Identifier,'%s',getString(m)),ME));
end
 
% check finite values
switch type
case 'logpdf'
    if any(isnan(out))||any(isinf(out) & out>0 )
        error(message('stats:slicesample:NonfiniteLogpdf'));
    end;
case 'pdf'
    if any(~isfinite(out))
        error(message('stats:slicesample:NonfinitePdf', func2str( fun )));
    end;    
   if any(out<0)
        error(message('stats:slicesample:NegativePdf', func2str( fun )));
    end;    
end;
 
 


