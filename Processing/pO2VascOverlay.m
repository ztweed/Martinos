%% pO2VascOverlay.m 
% Overlay grayscale vasculature and color po2 values...produces figure as
% used in grant report

%% Run setup
% simSetup(mouseID, cmro2, depth_lo, depth_hi, threshold)
simSetup('20120626', '2.3', 250)

%% Plot 
imagesc(ovrlp)
axis image
%title(strcat('pO2 and Vascular Structure (', mouseID, {', x = '},num2str(depth_lo),'-',...
%    num2str(depth_hi),'um, CMRO2=',cmro2,')'));
% xlabel('x');
% ylabel('y');
set(gca, 'XTickLabel', '')
set(gca, 'YTickLabel', '')
cmap = [jet(floor(gray_lo-1)); gray(ceil(gray_hi-gray_lo))];
colormap(cmap);
col = colorbar;
col.Limits = [1 floor(gray_lo-1)];
col.FontSize = 15;
ylabel(col, 'pO2 (mmHg)', 'FontSize', 15);
scalebar('Colour', [1 0 0], 'Location', 'southeast', 'ScaleLength',100,'bold',1)

%% Save
filename = strcat('VascAndpO2_Images/pO2AndVasc(',mouseID,',',num2str(depth_lo),'-',...
    num2str(depth_hi),'um,CMRO2=',cmro2,').png');

%saveUnique(gcf, filename)