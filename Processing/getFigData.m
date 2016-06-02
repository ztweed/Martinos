%{
 This script copies data from saved matlab figures and places them into a
      single figure. Useful for comparing results from different analyses
      with distinct parameters. Run simSetup first
%}

% load
close all
t      = hgload('dist2vessel(20110408,10-550um,CMRO2=1.5).fig');
t_axes = findobj(gcf,'type','axes');
k      = hgload('dist2vessel(20110408,10-550um,CMRO2=2.0).fig');
k_axes = findobj(gcf,'type','axes');
b      = hgload('dist2vessel(20110408,10-550um,CMRO2=2.5).fig');
b_axes = findobj(gcf,'type','axes');
q      = hgload('dist2vessel(20110408,10-550um,CMRO2=3.0).fig');
q_axes = findobj(gcf,'type','axes');

nAxes = 4;

% prep figure
figure
h(1)=subplot(nAxes,3,[1 2]);
h(2)=subplot(nAxes,3,3);
h(3)=subplot(nAxes,3,[4 5]);
h(4)=subplot(nAxes,3,6);
h(5)=subplot(4,3,[7 8]);
h(6)=subplot(4,3,9);
h(7)=subplot(4,3,[10 11]);
h(8)=subplot(4,3,12);

% get figure attributes
copyobj(allchild(t_axes(2)),h(1));
copyobj(allchild(t_axes(1)),h(2));
copyobj(allchild(k_axes(2)),h(3));
copyobj(allchild(k_axes(1)),h(4));
copyobj(allchild(b_axes(2)),h(5));
copyobj(allchild(b_axes(1)),h(6));
copyobj(allchild(q_axes(2)),h(7));
copyobj(allchild(q_axes(1)),h(8));

%% Format plot
% subplot 1
subplot(nAxes,3,[1 2])
title(h(1),'pO2 v. Distance from Closest Vessel, 20110408')
l(1) = legend(h(1),'CMRO2 = 1.5', 'Location', 'southeast');
xlim([0 90])
ylim([0 100])

%subplot 2
subplot(nAxes,3,3);
title(h(2), 'Selected Areas')
set(h(2),'Ydir','reverse')
set(h(2),'XTick',[],'YTick',[])
axis image
cmap = [jet(floor(gray_lo-1)); gray(ceil(gray_hi-gray_lo))];
colormap(cmap);
col = colorbar;
col.Limits = [1 floor(gray_lo-1)];
ylabel(col, 'pO2 (mmHg)');
%set(gca, 'Position', [0.65, 0.6, 0.22, 0.35])

% subplot 3
subplot(nAxes,3,[4 5]);
l(2) = legend(h(3),'CMRO2 = 2.0');
xlim([0 90])
ylim([0 100])

% subplot 4
subplot(nAxes,3,6);
set(h(4),'Ydir','reverse')
set(h(4),'XTick',[],'YTick',[])
axis image
col = colorbar;
col.Limits = [1 floor(gray_lo-1)];
ylabel(col, 'pO2 (mmHg)');
%set(gca, 'Position', [0.65, 0.1, 0.22, 0.35])

% subplot 5
subplot(nAxes,3,[7 8]);
l(2) = legend(h(5),'CMRO2 = 2.5');
xlim([0 90])
ylim([0 100])

% subplot 6
subplot(nAxes,3,9);
set(h(6),'Ydir','reverse')
set(h(6),'XTick',[],'YTick',[])
axis image
col = colorbar;
col.Limits = [1 floor(gray_lo-1)];
ylabel(col, 'pO2 (mmHg)');
%set(gca, 'Position', [0.65, 0.1, 0.22, 0.35])

% subplot 7
subplot(nAxes,3,[10 11]);
l(2) = legend(h(7),'CMRO2 = 3.0');
xlabel('Distance from closest Vessel (um)')
ylabel('pO2 (mmHg)')
xlim([0 90])
ylim([0 100])

% subplot 8
subplot(nAxes,3,12);
set(h(8),'Ydir','reverse')
set(h(8),'XTick',[],'YTick',[])
axis image
col = colorbar;
col.Limits = [1 floor(gray_lo-1)];
ylabel(col, 'pO2 (mmHg)');
%set(gca, 'Position', [0.65, 0.1, 0.22, 0.35])

close(t)
close(k)
close(b)
close(q)

