function [] = simSetup(mouseID, cmro2, depth_lo, varargin)
%% Setup for analysis of simulation data
%
% function [] = simSetup(mouseID, cmro2, depth_lo, varargin)
%
%  Motivation -
%  - Consolidates a lot of repeated code to this function and prepares analysis
%    of simulations.
%  - Performs tasks necessary to run most scripts in this folder.
%
%  Tasks Performed -
%  - Loads appropriate files
%  - Gathers pO2, vasculature and pO2 node data in relevant depth range
%  - Interpolates pO2 node data, allowing us to work with continuous pO2 values
%  - Creates overlaid pO2 / vasculature plot: sets threshold, colormap
%    and merges data
%
% Input -
%  - mouseID:   string representing the desired mouse
%  - cmro2:     string representing the desired cmro2 level
%  - depth_lo:  number representing the lower depth limit to be used (in microns)
%  - depth_hi:  optional, number representing the upper depth limit to be
%               used. Defaults to depth_lo + 10. Must be fourth argument if used.
%  - threshold: name-value parameter. Number representing the cutoff for
%               vasculature. Defaults to 15 (on a scale from 0 to 32)
%  - plane:     name-value parameter. String representing the plane in
%               which we are interested. Can be 'xy', 'yz' or 'xz',
%               defaulting to 'xy'.
%
% Output -
%  - Saves all calculated variables to the workspace for later use
%
%
% Zachary Tweed - February 2016

%% Parse input
p = inputParser;

% set defaults for optional variables
defaultThreshold = 15;
defaultPlane = 'xy';
defaultHi = depth_lo + 10;

% set validation functions for optional arguments
pErr  = 'Must be one of ''xy'', ''yz'' or ''xz''.';
pEval = @(x) assert(strcmpi(x,'xy') || strcmpi(x,'yz') || strcmpi(x,'xz'), pErr);
tErr  = 'Threshold must be less than or equal to 32';
tEval = @(x) assert(x <= 32, tErr);
dErr  = 'depth_hi must be greater than depth_lo';
dEval = @(x) assert(x > depth_lo, dErr);

% establish possible inputs
addRequired(p, 'mouseID', @ischar)
addRequired(p, 'cmro2', @ischar)
addRequired(p, 'depth_lo', @isnumeric)
addOptional(p, 'depth_hi', defaultHi, dEval)
addParameter(p, 'threshold', defaultThreshold, tEval)
addParameter(p, 'plane', defaultPlane, pEval)

% parse input
parse(p, mouseID, cmro2, depth_lo, varargin{:});
depth_hi  = p.Results.depth_hi;
threshold = p.Results.threshold;
plane     = p.Results.plane;

%% Load files
% Get file names
file = strcat(mouseID,'_NCES_SS_OC_',cmro2,'_18000ms.mat');
mesh = strcat(mouseID,'_NCES_wMesh.mat');

% Load files
disp(strcat({'Loading '}, file, '...'))
load(file);
disp({'Complete!'})
disp({'Loading mesh...'})
load(mesh)
disp({'Complete!'})

%% Gather relevant data

% Extract po2 values from the final times step and scale up to mmHg
po2_final = c(:,end); %#ok
po2_final = po2_final / 1.27e-15;

% Find coordinates and pO2 values contained within the depth limits
switch plane
    case 'xy'
        idx = find((im2.Mesh.node(:,3) >= depth_lo) & ...
                   (im2.Mesh.node(:,3) <= depth_hi));
    case 'yz'
        idx = find((im2.Mesh.node(:,1) >= depth_lo) & ...
                   (im2.Mesh.node(:,1) <= depth_hi));
    case 'xz'
        idx = find((im2.Mesh.node(:,2) >= depth_lo) & ...
                   (im2.Mesh.node(:,2) <= depth_hi));
end

% Collect all points in the relevant z range
z_range = im2.Mesh.node(idx,:);

% define dimensions for plotting (node x pos, y pos, z pos, pO2)
if strcmpi(mouseID, '20110408')
    % don't need to adjust vox for this mouse
    x   = z_range(:,1);
    y   = z_range(:,2);
    z   = z_range(:,3);
    po2 = po2_final(idx);
else
    x   = z_range(:,1)/im2.Hvox(1);
    y   = z_range(:,2)/im2.Hvox(2);
    z   = z_range(:,3)/im2.Hvox(3);
    po2 = po2_final(idx);
end

%% Interpolate values into the scattered data
switch plane
    case 'xy'
        % Interpolate values into the scattered data
        [newX, newY] = meshgrid(min(x):1:max(x), min(y):1:max(y));
        % Create mesh from data and interpolations
        m = griddata(x,y,po2,newX,newY);
        % Gather relevant intensity range (adjusting for pixel-to-um ratio)
        vasc = squeeze(max(im2.I(:,:,floor(depth_lo/im2.Hvox(3)):floor(depth_hi/im2.Hvox(3))),[],3));
    case 'yz'
        % Similarly
        [newY, newZ] = meshgrid(min(y):1:max(y), min(z):1:max(z));
        m = griddata(y,z,po2,newY,newZ);
        vasc = squeeze(max(im2.I(floor(depth_lo/im2.Hvox(1)):ceil(depth_hi/im2.Hvox(1)), :, :),[],1));
    case 'xz'
        % Similarly
        [newX, newZ] = meshgrid(min(x):1:max(x), min(z):1:max(z));
        m = griddata(x,z,po2,newX,newZ);
        vasc = squeeze(max(im2.I(:, floor(depth_lo/im2.Hvox(2)):ceil(depth_hi/im2.Hvox(2)), :),[],2));
end

%% Set vasculature threshold and scale up (for colorbar)

% Set vascular intensity threshold, make everything below zero
vasc(vasc < threshold) = 0;

% Convert to double type
vasc = double(vasc);

% Scale vasc to be 'on top' of pO2 mesh data (for colormap purposes)
gray_lo = max(max(m));
gray_hi = max(max(m)) + max(max(vasc));

switch plane
    case 'xy'
        new_vasc = scaleTo(vasc, gray_lo, gray_hi);
    otherwise
        % need transpose for other planes...?
        new_vasc = transpose(scaleTo(vasc, gray_lo, gray_hi));
end

%% Place pO2 values where vasc is zero to merge plots

% Replace all zeros in new_vasc with corresponding pO2 values
ovrlp = new_vasc;

% If vasc is below threshold, replace it w/ pO2
switch plane
    case 'xy'
        % Find all indices below vascular threshold
        [a,b] = find(ovrlp == gray_lo);
        a     = [b a];
        % Restrict to indices within po2 range
        a = a(a(:,1) > fix(min(x)) & a(:,1) < fix(max(x)) & a(:,2) > fix(min(y)) & a(:,2) < fix(max(y)),:);
        % Create array of local indices with which to reference po2 map
        a_m = [a(:,1) - fix(min(x)) a(:,2) - fix(min(y))];
        % Replace vascular indices with corresponding po2 values
        ovrlp(sub2ind(size(ovrlp), a(:,2), a(:,1))) = m(sub2ind(size(m), a_m(:,2), a_m(:,1)));
    case 'xz'
        % Similarly
        [a,b] = find(ovrlp == gray_lo);
        a     = [b a];
        a = a(a(:,1) > fix(min(x)) & a(:,1) < fix(max(x)) & a(:,2) > fix(min(z)) & a(:,2) < fix(max(z)),:);
        a_m = [a(:,1) - fix(min(x)) a(:,2) - fix(min(z))];
        ovrlp(sub2ind(size(ovrlp), a(:,2), a(:,1))) = m(sub2ind(size(m), a_m(:,2), a_m(:,1)));
    case 'yz'
        % Similarly
        [a,b] = find(ovrlp == gray_lo); 
        a     = [b a];
        a = a(a(:,1) > fix(min(y)) & a(:,1) < fix(max(y)) & a(:,2) > fix(min(z)) & a(:,2) < fix(max(z)),:);
        a_m = [a(:,1) - fix(min(y)) a(:,2) - fix(min(z))];
        ovrlp(sub2ind(size(ovrlp), a(:,2), a(:,1))) = m(sub2ind(size(m), a_m(:,2), a_m(:,1)));
end

%% Save desired variables to workspace
% Clear unwanted variables
clear a b a_m m1 m2 val i j defaultHi defaultThreshold defaultPlane varargin...
      pErr pEval tErr tEval dErr dEval p po2_final newX newY dilation defaultDilation

% Save all other variables
W = who;
putvar(W{:});

disp({'Setup is complete!'})

end

