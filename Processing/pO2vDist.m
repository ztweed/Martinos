%% pO2vDist.m
% Create plot of distance to center of selected arteriole for all pO2 points in
%   a given range of depth (approx. 10 um)

%% Run Setup
% simSetup(mouseID, cmro2, depth_lo, threshold, depth_hi)
simSetup('20110408', '3.0', 100)

%% User input: select arteriole center

figure;
imagesc(vasc);
disp({'Click on arteriole center, please'})
[xc, yc] = ginput(1);
disp({'Thanks!'})
center = [ xc, yc ];
close(gcf)

%% Calulate Distances

% Initialize euclidean distance array and calculate all distances from center
dists = zeros(length(x), 1);

switch mouseID
    case '20110408' % Special case for this mouse: convert vox to um
        for i = 1:length(x)
            d = e_dist([(x(i)*1.18) (y(i)*1.18)], [xc yc]);
            dists(i) = d;
        end
        
    otherwise % Now, for all other mice
        for i = 1:length(x)
            d = e_dist([x(i) y(i)], center);
            dists(i) = d;
        end
end

%% Plot pO2 v Distance

figure
plot(dists, po2, '.')
title(strcat({'pO2 v Distance from Center of Arteriole ('},mouseID,{', '},num2str(depth_lo),...
             '-',num2str(depth_hi),'um, CMRO2=',cmro2,')'));
xlabel('Distance from Arteriole (um)')
ylabel('pO2 (mmHg)')

%% Save with unique filename

filepath = strcat('pO2vDist_Images/pO2vDist(',mouseID,',',num2str(depth_lo),...
    '-',num2str(depth_hi),'um,CMRO2=',cmro2,').png');

saveUnique(gcf, filepath)
