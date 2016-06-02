function [ f, m0, rt ] = krogh(r_cap, p_cap, x_data, y_data)
%% Creates a fit, calculating CMRO2 and R_t, based on Krogh's equation: 
%
%                 /     m0    \  /             \     /  m0*r_t^2  \  /  /   r   \\
% P(r) = p_cap + (-------------)( r^2 - r_cap^2 ) - (--------------)(ln(---------))
%                 \ 4*d*alpha /  \             /     \  2*d*alpha /  \  \ r_cap //
%
% Input Variables and Units:
%  p_cap:
%    - Capillary pO2
%    - pO2 at closest grid point to center
%    - Unit: mmHg
%  r_cap:
%    - Capillary radius
%    - Avg. radius of points immediately surround the arteriole center
%    - Unit: cm
%  d:
%    - Tissue O2 diffusivity
%    - Constant: diffusivity of O2 in water at 40 Celsius
%    - Unit: cm^2/s
%  alpha:
%    - Tissue O2 solubility
%    - Constant: solubility of O2 in water at 40 Celsius, std. atm. pressure
%    - Unit: mol/cm^3/mmHg
%  
% Solved-for Variables and Units:
%  m0:
%    - Tissue O2 consumption rate
%    - Unit: mol/cm^3/s
%  r_t:
%    - Tissue radius
%    - Unit: cm
%
% function [ f, m0, rt ] = krogh(r_cap, p_cap, x_data, y_data)
%  Takes:
%    r_cap, p_cap: as described above
%    x_data: array of distances of grid points from center of arteriole
%    y_data: array of pO2 values corresponding to x_data
%
%  Returns:
%    f: cfit structure of curve to data using nonlinear least squares
%    m0, rt: as described above
%
%  Zachary Tweed - February 2016

%% Define constants, etc
d = 0.0000324; % diffusivity of O2 in water at 40 Celsius
alfa =   2e-7; % solubility  of O2 in water at 40 Celsius, std. atm. pressure

% Obtain all expressions needed in the equation
dalpha2 = 2*d*alfa;
dalpha4 = 4*d*alfa;
r_capSq = r_cap^2;

%% Convert numbers to strings for fittype
p_cap   = num2str(p_cap);
r_cap   = num2str(r_cap);
dalpha2 = num2str(dalpha2);
dalpha4 = num2str(dalpha4);
r_capSq = num2str(r_capSq);

%% Create Krogh Fit

% Create Custom fittype based on Krogh's Equation and our values
name = strcat(p_cap,'+(m0/',dalpha4,')*(x^2-(',r_capSq,'))-((m0*rt^2)/',dalpha2,')*log(x/',r_cap,')');
type = fittype(name);

% Set fit options (lower bound and starting points)
opt = fitoptions(type);
opt.StartPoint = [1e-8, 0.1];
opt.Lower = [0 0];

% Create fit
f = fit(x_data, y_data, type, opt);

% Get coefficients
m0 = f.m0;
rt = f.rt;
