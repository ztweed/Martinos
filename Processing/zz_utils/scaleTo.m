function [ new ] = scaleTo( v, new_min, new_max )
%% Scale an array to a new minimum and maximum while retaining overall structure
%  
%   function [ new ] = scale( v, new_min, new_max )
%     INPUT - 
%       v       - numerical array
%       new_min - double, minimum of output array
%       new_max - double, maximum of output array
%       
%     OUTPUT - 
%       new     - new array, scaled as previously specified
%
%     EXAMPLE - 
%       >> v = [2 5 4 8];
%       >> min = 14;
%       >> max = 25;
%
%       >> scaleTo(v, min, max)
%       ans = 
%           [ 14.000 19.500 17.667 25.000 ] 
%
%     Zachary Tweed - January 2016

%% 

% Assign variables for simplicity
a = min(min(v));
b = max(max(v));
c = new_min;
d = new_max;

% Make sure input args make sense
if c >= d
    error('Input argument new_min must be strictly greater than new_max. See: help scaleTo')
end

% Calculate new array
new = ((d-c).*(v-a)) / (b-a);
new = (new + c);

end