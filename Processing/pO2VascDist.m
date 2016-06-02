%% p02VascDist.m 
%
% 1) Plot pO2 and vasculature overlaid, as well as pO2vDist in one figure
% 2) Select an arteriole and plot pO2 v. distance within selected vicinity
% 3) Create a fit based on Krogh's equation to go with item 2).
%

%% Run Setup
% simSetup(mouseID, cmro2, depth_lo, threshold, depth_hi)
simSetup('20110408', '2.0', 110)

%% Dist. Plot: Manually select arteriole center and legs of triangle
% Plot overlaid pO2 map and vasculature
figure;
imagesc(ovrlp);
hold on; 
plot(x,y,'.')
set(gca, 'Ydir', 'Normal')
cmap = [jet(floor(gray_lo)); gray(ceil(gray_hi-gray_lo))];
colormap(cmap);
col = colorbar;
col.Limits = [1 floor(gray_lo-1)];

% User input: select arteriole center
disp({'Select arteriole center, please'})
[xc, yc] = ginput(1);
disp({'Thanks!'})
center = [ xc, yc ];
hold on; plot(xc, yc, 'x', 'MarkerSize', 10,...
                           'LineWidth', 2,...
                           'MarkerEdgeColor', 'k'); % Mark arteriole center
% User input: select triangle legs
disp({'Click twice to create the legs of a triangle'})
pts = ginput(2);
disp({'Well done'})
close(gcf)

%% Dist Plot: Calculate all distances

% Initialize euclidean distance array to store all grid point distances from arteriole center
dists = zeros(length(x), 1);

for i = 1:length(x)
    
    d = e_dist([x(i) y(i)], center);
    dists(i) = d;
    
end

%% Find the grid points inside the triangle created above

% Set the points that define the triangle
tri = [pts; center];

% Initialize interior distance and pO2 arrays
in_dist = zeros(length(x), 1);
in_pO2  = zeros(length(x), 1);

% If a point is inside the triangle, record its pO2 and distance from center
for i = 1:length(x)
    if inpolygon(x(i), y(i), tri(:,1), tri(:,2))
        
        in_dist(i) = dists(i);
        in_pO2(i)  = po2(i);
        
    end
end

% Eliminate rows of zeros from arrays
in_dist(all(in_dist==0,2),:) = [];
in_pO2(all(in_pO2==0,2),:)   = [];

%% Find values needed for Krogh fit, adjusting for proper units

% Capillary radius: take the average distance of the closest points to the center
r_cap = min(in_dist)*10e-4;
% Capillary pO2: find the pO2 value at the closest point to the center 
p_cap = z(find(dists==min(dists)));
% Convert distances for grid pts. inside triangle to cm
in_dist_cm = in_dist*10e-4;

% Get Krogh fit for this data
[k_fit, m0, rt] = krogh(r_cap, p_cap, in_dist_cm, in_pO2);

%% Dist. Plot: Plot pO2 v Distance
% figure
% subplot(4,2,[1 2])
% plot(dists, z, '.')
% xlim([0 120]) % Sava: limit radial distance to 120 um
% title(strcat({'pO2 v. Distance from Arteriole and Vasculature ('},mouseID,{', '},...
%     num2str(depth_lo),'-',num2str(depth_hi),'um, CMRO2=',cmro2,')'));
% xlabel('Distance from Arteriole (um)')
% ylabel('pO2 (mmHg)')
% 
% % Vasc. Plot: Create plot
% subplot(4,2,[3 4 5 6])
% imagesc(plt)
% hold on; plot(xc, yc, 'x', 'MarkerSize', 10,...
%                            'LineWidth', 2,...
%                            'MarkerEdgeColor', 'k'); % Mark arteriole center
% axis image
% xlabel('x');
% ylabel('y');
% cmap = [jet(floor(gray_lo)); gray(ceil(gray_hi-gray_lo))];
% colormap(cmap);
% col = colorbar;
% col.Limits = [1 floor(gray_lo-1)];
% ylabel(col, 'pO2 (mmHg)');
% set(gca, 'Ydir', 'Normal')
% hold on; plot(x,y,'.');
% line([xc pts(1,1)], [yc pts(1,2)], 'Color', 'w')
% line([xc pts(2,1)], [yc pts(2,2)], 'Color', 'w')
% line([pts(1,1) pts(2,1)], [pts(1,2) pts(2,2)], 'Color', 'w')
% 
% % Dist. Plot: Plot pO2 v Distance for points inside the selected area
% 
% subplot(4,2,[7 8])
% plot(in_dist, in_pO2, '.')
% %title('pO2 v. Distance from Arteriole for Selected Area')
% xlabel('Distance from Arteriole (um)')
% ylabel('pO2 (mmHg)')

%% Plot pO2 v. Distance for interior points with Krogh Fit

% Get function string to plot w/ ezplot
k_fit = formula(k_fit);
k_fit = strrep(k_fit, 'm0',num2str(m0));
k_fit = strrep(k_fit, 'rt',num2str(rt));

% Plot nodes inside triangle and krogh fit
figure
subplot(3,2,[1 2])
ezplot(k_fit, [r_cap 1]);
hold on
plot(in_dist_cm, in_pO2, '.')
xlabel('Distance from Arteriole Center (um)')
ylabel('pO2 (mmHg)')
xlim([0 0.12])
ylim([0 100])
legend(gca, 'off')
title(strcat({'Fitting of Krogh''s Equation ('},mouseID,{', '},num2str(depth_lo),...
    '-',num2str(depth_hi),'um, CMRO2=',cmro2,')'));
text(0.06,90,strcat({'Calculated m0: '},num2str((m0*60)*10e5), {' umol/cm^3/min'}));
text(0.06,75,strcat({'Calculated rt: '},num2str(rt*1000),{' um'}));

ax = gca;
ax.XTickLabels = num2str((str2double(ax.XTickLabels))*1000);

% Vasc. Plot
subplot(3,2,[3 4 5 6])
imagesc(ovrlp)
hold on;
plot(x,y,'.');
line([xc pts(1,1)], [yc pts(1,2)], 'Color', 'w')
line([xc pts(2,1)], [yc pts(2,2)], 'Color', 'w')
line([pts(1,1) pts(2,1)], [pts(1,2) pts(2,2)], 'Color', 'w')
plot(xc, yc, 'x', 'MarkerSize', 10,...
                  'LineWidth', 2,...
                  'MarkerEdgeColor', 'k'); % Mark arteriole center
axis image
xlabel('x');
ylabel('y');
cmap = [jet(floor(gray_lo)); gray(ceil(gray_hi-gray_lo))];
colormap(cmap);
col = colorbar;
col.Limits = [1 floor(gray_lo-1)];
ylabel(col, 'pO2 (mmHg)');
set(gca, 'Ydir', 'Normal')


%% Save figure using unique filename
filename = strcat('po2VascDist/po2VascDist(',mouseID,',',num2str(depth_lo),...
            '-',num2str(depth_hi),'um,CMRO2=',cmro2,').jpg');

%saveUnique(gcf, filename)