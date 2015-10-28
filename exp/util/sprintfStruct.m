function output = sprintfStruct(s, varargin)
  output = '';
  if (~isstruct(s)) return; end;
  fnames = fieldnames(s)';
  if (isempty(fnames)) return; end;

  if (nargin > 1 && strcmpi(varargin{1}, 'escape'))
    cr = '\\\\\\n';
  else
    cr = '\\n';
  end

  % go through all the fields
  for fname = fnames
    empty = true;
    str = '';
    value = s.(fname{1});
    % switch according to the value's type
    if (isnumeric(value))
      str = num2str(value);
    elseif (isstr(value))
      str = value;
    elseif (islogical(value))
      if (value)
        str = 'true';
      else
        str = 'false';
      end
    elseif (isstruct(value))
      % recursion
      if (nargin > 1)
        output = [output sprintfStruct(value, varargin{1})];
      else
        output = [output sprintfStruct(value)];
      end
    end
    if (~isempty(str))
      if (~isstruct(value))
        backN = cr;
      else
        backN = '';
      end
      output = [output sprintf(['%15s: %s' backN], fname{1}, str)];
    end
  end
end

