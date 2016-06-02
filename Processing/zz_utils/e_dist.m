function [ e_dist ] = e_dist(p1, p2)
%% Calculate the euclidean distance between two points in space
%  
%   function [ e_dist ] = e_dist(point1, point2)
%    INPUT -
%      point1: a 1-by-N or N-by-1 array that represents a point in space
%      point2: a 1-by-N or N-by-1 array that represents a point in space
%      
%      (The dimensionality of both inputs must match)
%
%    OUTPUT - 
%      e_dist: a 1x1 double representing the Euclidean distance between
%              point1 and point2
%
%    EXAMPLE - 
%      >> p1 = [2 5 7];
%      >> p2 = [9 3 6];
%
%      >> e_dist(p1, p2)
%      ans =
%          7.3485
%
% Zachary Tweed - January 2016

%% Check for proper dimensional inputs
s1 = size(p1);
s2 = size(p2);

if ( (s1(1) > 1 && s1(2) > 1) ||  (s2(1) > 1 && s2(2) > 1) )
    error('e_dist can only take 1-by-N or N-by-1 arrays!')
end

if ( ~(s1(1) == s2(1)) || ~(s1(2) == s2(2)) )
    error('Dimension mismatch: make sure inputs are of the same dimensionality.')
end

%% Calculate
% Initialize array
dims = zeros(1,max(s1));

% Calculate elementwise distances
for i = 1:max(s1)
    
    dims(i) = (p1(i) - p2(i))^2;
    
end

% Calculate euclidean distance
e_dist = sqrt(sum(dims));

end