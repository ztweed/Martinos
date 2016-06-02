function [ bool ] = adjacentTo( arr, pt )
%% Returns true if the given euclidean point is adjacent to any point in the array of points
%
% function [ bool ] = adjacentTo(arr, pt)
%   INPUT - 
%     arr: array of euclidean points of any dimension
%      pt: euclidean point
%
%   OUTPUT - 
%    bool: boolean
%
%   EXAMPLE - 
%     >> arr = [2 4; 1 5; 3 1];
%     >> pt = [4 1];
%     >> adjacentTo(arr, pt)
%     ans = 
%           1
%
%   Zachary Tweed - Feb. 2016

%% Check input for legitimacy

% ensure array has right dimensions
if ~(size(arr,1) == 2 || size(arr,2) ==2)
    error('Input must be a 2-by-n or n-by-2 numerical array')
end

% for simplicity, convert to a 2-by-n matrix, if needed
if (size(arr,1) == 2) && (size(arr,2) ~= 2)
    arr = transpose(arr);
end

%% Check adjacency

s = size(arr,1);
log_arr = zeros(1,s);

% check adjacency for each point in array
for i = 1:s
    if abs(arr(i,1) - pt(1)) <= 1 && abs(arr(i,2) - pt(2)) <= 1
        log_arr(i) = 1;
    else
        log_arr(i) = 0;
    end
end

% take max of logical array in final determination
bool = max(log_arr);

