%% pO2Contour.m 
% Create pO2 maps at various CMRO2 values

%% Setup
cmro2 = {'1.5', '2.0', '2.5', '3.0'};
disp({'Loading mesh...'})
mesh = '20110408_NCES_wMesh.mat';
load(mesh);
disp({'Done!'})

mouseID = mesh(1:8);

% Set upper and lower bounds in z (in um)
depth_lo = 110;
depth_hi = 130;

figure;
col = colorbar;
ylabel(col, 'pO2 (mmHg)')

%% For each CMRO2...
for i = 1:length(cmro2)
    % Load file
    file = strcat('20110408_NCES_SS_OC_',cmro2{i},'_18000ms.mat');
    disp(strcat({'Loading CMRO2 '}, cmro2{i}, '...'))
    load(file);
    disp({'Done!'})
    
    % Extract po2 values from the final times step and scale up to mmHg
    po2_final = c(:,end);
    po2_final = po2_final / 1.27e-15;
    
    % Find xy coordinates and pO2 values within depth limits
    idx = find( (im2.Mesh.node(:,3) >= depth_lo) & (im2.Mesh.node(:,3) <= depth_hi) );
    z_range = im2.Mesh.node(idx,:);
    po2_val = po2_final(idx);
    
    % define dimensions for plotting
    x = z_range(:,1);
    y = z_range(:,2);
    po2 = po2_val;
    
    % Interpolate values into the scattered data
    [newX, newY] = meshgrid(min(x):0.3:max(x), min(y):0.3:max(y));
    
    % Create mesh from data and interpolations
    m = griddata(x,y,po2,newX,newY);
    
    % Create contour plot
    subplot(ceil(length(cmro2)/2),2,i)
    imagesc(m)
    axis image;
    title(strcat({'pO2 Values ('},mouseID,num2str(depth_lo),'-', num2str(depth_hi),...
        'um depth, CMRO2 = ',cmro2{i},')'), 'FontSize', 8)
    xlabel('x')
    ylabel('y')
    col = colorbar;
    caxis([0 90])
    ylabel(col, 'pO2 (mmHg)')
    
end

%% Save
filename = strcat('pO2_Contour_Images/po2contour(',mouseID,',',...
    num2str(depth_lo),'-', num2str(depth_hi),'um).jpg');

saveUnique(gcf, filename)

