%% dist2vessel.m
% Calculate distance to closest vessel for each node, then plot this v. pO2

%% Run setup
simSetup('20110408', '1.5', 100, 550)

%% Extract vessels

% % Get all xy coordiantes that belong to a vessel
% ves_coord = [];
%
% for i = 1:p1
%     for j = 1:p2
%
%         if new_vasc(i,j) > gray_lo
%             ves_coord = [ves_coord; [i j]]; %#ok
%         end
%
%     end
% end
%
% % Group collected coordinates by adjacency
% ves_xy = ves_coord;
% vessels = {};
% ves_count = 1;
%
% % Retreive all vessels
% while size(ves_xy, 1) > 0
%
%     nAdded = 1;
%     this_ves  = ves_xy(1,:);
%
%     % retreive all points associated with this vessel until all are collected
%     while nAdded > 0
%         % Get all pts adjacent to this vessel
%         adj = getAdjacent(this_ves);
%         % Restrict to the pts that are in ves_xy
%         adj = intersect(adj, ves_xy, 'rows');
%         % Add said points to this vessel
%         this_ves = [this_ves; adj]; %#ok
%         % count how many points were added
%         nAdded = length(adj);
%         % remove used points from ves_xy
%         ves_xy = setdiff(ves_xy, this_ves, 'rows', 'stable');
%     end
%
%     % disregard if it's just one point
%     if size(this_ves,1) > 1
%         % if this_ves is more than one point, add it to the cell array, advance count
%         vessels{ves_count} = this_ves; %#ok
%         ves_count = ves_count + 1;
%     end
%
% end
%
% clear ves_xy
% disp({'Vessels extracted!'})

% Calculate vessel centers, create vessel structure

% % init vessel center array
% centers = zeros(length(vessels), 2);
%
% for i = 1:length(vessels)
%
%     % get xy coords for center by taking average values
%     xc = mean([min(vessels{i}(:,2)) max(vessels{i}(:,2))]);
%     yc = mean([min(vessels{i}(:,1)) max(vessels{i}(:,1))]);
%
%     centers(i,:) = [xc yc];
%
%     % Create vessel structure with center and array of points, save in cell array
%     v.center = [xc yc];
%     v.points = vessels{i};
%
%     vessels{i} = v; %#ok
%
% end
%
% disp({'Structure created!'})

%% Restrict vessels to just arterioles over 15 um

% Find all arteriole nodes
segIdx = find(im2.segVesType == 1);
segIdx = find(ismember(im2.nodeSegN, segIdx));

% Find all arterioles w/ diameter above 15 um
diaIdx = find(im2.segDiam >= 15);
diaIdx = find(ismember(im2.nodeSegN, diaIdx));

% Take intersection of those two sets
artIdx = intersect(diaIdx, segIdx);
arts   = im2.nodePos(artIdx,:);

artX   = arts(:,1);
artY   = arts(:,2);

%% Find distances from all nodes to their closest arteriole

% Manually select area to be used in xy plane
% disp({'Choose the Region of Interest, please...'})
% imagesc(ovrlp)
% hold on
% plot(artX,artY,'r.')
% cmap = [jet(floor(gray_lo-1)); gray(ceil(gray_hi-gray_lo))];
% colormap(cmap);
% [~, polyX, polyY] = roipoly;

% Find po2 nodes in polygon
in = inpolygon(x,y,polyX,polyY);
inIdx = find(in);

% Find vasc. nodes in polygon
artIn = inpolygon(artX,artY,polyX,polyY);
artInIdx = find(artIn);

close all
disp({'Nice.'})

% restrict dimensions to points inside selected area
x    = x(inIdx);
y    = y(inIdx);
z    = z(inIdx);
po2  = po2(inIdx);
artX = artX(artInIdx);
artY = artY(artInIdx);

% init final distance array, waitbar
dists = zeros(length(x), 1);
h = waitbar(0, 'iteration');

for i = 1:length(x)
    
    % calculate distance from each mesh node to each vasculature node
    locX = artX - x(i);
    locY = artY - y(i);
    
    locX = locX.^2;
    locY = locY.^2;
    locDists = sqrt(locX + locY);
    
    % take the minimum distance for final use
    least = min(locDists);
    dists(i) = least;
    
    % display wait bar for convenience
    waitbar(i/length(x), h, sprintf('Distance Acquisition \n %.1f%% Complete', 100*(i/length(x))))
    
end

% Delete waitbar
delete(h)

disp({'Distances found!'})

%% Get binned averages and standard deviations

% Set parameters and initialize stats matrix
binwidth = 2.5;
binStats = zeros(ceil(max(dists)/binwidth), 3);
binCount = 1;

for i = 0:(binwidth):max(dists)
    
    % Get indices of relevant distances
    binIdx = find( (dists >= i) & (dists <= i+binwidth) );
    
    % Now get corresponding pO2 values and stats
    bin = po2(binIdx);
    avg = median(bin);
    dev = std(bin);
    
    % Place stats into the matrix
    binStats(binCount,1) = mean([i, i+binwidth]);
    binStats(binCount,2) = avg;
    binStats(binCount,3) = dev;
    
    % Advance count
    binCount = binCount + 1;
    
end

% delete unwanted variables
clear locDists locVasc range xyz least bw h diaIdx bin avg dev binIdx binCount2

%% Plot
% Plot desired pO2 v closest dist w/ averages and std errors
% figure
% subplot(3,2,[1 2])
% plot(dists, po2, '.')
% title(strcat({'pO2 v. Distance from Closest Arteriole ('},mouseID,{', '},...
%     num2str(depth_lo),'-',num2str(depth_hi),'um, CMRO2=',cmro2,')'));
% xlabel('Distance from Closest Arteriole (um)')
% ylabel('pO2 (mmHg)')
% hold on
% errorbar(binStats(:,1),binStats(:,2), binStats(:,3))
% 
% % Plot selected area
% subplot(3,2,[3 4 5 6])
% imagesc(ovrlp)
% axis image
% xlabel('x');
% ylabel('y');
% cmap = [jet(floor(gray_lo-1)); gray(ceil(gray_hi-gray_lo))];
% colormap(cmap);
% col = colorbar;
% col.Limits = [1 floor(gray_lo-1)];
% ylabel(col, 'pO2 (mmHg)');
% hold on
% plot(polyX,polyY, 'k', 'LineWidth', 1.5)
% plot(artX,artY,'x')

%% Fit for nodes closer than 15 um from closest arteriole

% Get stats for nodes >= 15 um away from an arteriole
locStats = binStats(binStats(:,1) <= 15,:);
f = fitlm(locStats(:,1),locStats(:,2));

% CMRO2
switch cmro2
    case '1.5'
        cmro2Idx = 1;
    case '1.8'
        cmro2Idx = 2;
    case '2.0'
        cmro2Idx = 3;
    case '2.5'
        cmro2Idx = 4;
    case '3.0'
        cmro2Idx = 5;
end

% Gather relevant fit details
m2011.slope(cmro2Idx) = f.Coefficients.Estimate(2); % Estimated Slope
m2011.inter(cmro2Idx) = f.Coefficients.Estimate(1); % Estimated Intercept
m2011.error(cmro2Idx) = f.Coefficients.SE(2);       % Std. Err. of the Estimate of Slope
m2011.rSqrd(cmro2Idx) = f.Rsquared.Ordinary;        % R-squared value of fit

%% Plot

% Plot each data point
% fig = figure('Position', [1 scrSize(4)/3, scrSize(3), scrSize(4)/3]);
% fig.PaperPositionMode = 'auto';
% subplot(1,3,1)
% metaf = fitlm(mets, slope(:,1));
% metaslope(1) = metaf.Coefficients.Estimate(2);
% s = (metaf.Coefficients.Estimate(2).*r) + metaf.Coefficients.Estimate(1);
% plot(mets, slope(:,1), 'o');
% hold on
% p1 = plot(r,s);
% 
% metaf = fitlm(mets, slope(:,2));
% metaslope(2) = metaf.Coefficients.Estimate(2);
% s = (metaf.Coefficients.Estimate(2).*r) + metaf.Coefficients.Estimate(1);
% plot(mets, slope(:,2), 'o');
% p2 = plot(r,s);
% 
% metaf = fitlm(mets, slope(:,3));
% metaslope(3) = metaf.Coefficients.Estimate(2);
% s = (metaf.Coefficients.Estimate(2).*r) + metaf.Coefficients.Estimate(1);
% plot(mets, slope(:,3), 'o');
% p3 = plot(r,s);
% hold off
% 
% title(strcat(mouseID,{' Slope v. CMRO_2'}))
% xlabel('CMRO_2')
% ylabel('Slope')
% leg = legend([p1 p2 p3], arrayfun(@num2str, rFlow(1,:), 'Uniform', false));
% legendTitle(leg, 'Flow', 'Position', [0.5, -0.85, 0.5]);
% 
% % Plot metaslope
% subplot(1,3,2)
% plot(rFlow(1,:), metaslope, 'o')
% xlabel('Flow (ml/min/100g)')
% ylabel('Slope')
% 
% % Plot ROI
% subplot(1,3,3)
% imagesc(ovrlp)
% hold on
% plot(polyX,polyY,'-ro')
% plot(artX, artY, 'm.')
% xlabel('ROI')
% cmap = [jet(floor(gray_lo)); gray(ceil(gray_hi-gray_lo))];
% colormap(cmap);

% saveUnique(fig, strcat('dist2vessel_images/', mouseID,'SlopevCMRO2.png'))
