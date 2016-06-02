% Plot my simulation results
time = 4;
load(sprintf('20110408_PC_SS_OC_2.0_%d000msDenseMapTest.mat', time))
load('20110408_PC_wMeshDense.mat')

po2  = c(:,end) / 1.27e-15;
lims = [110 120];
idx  = find( (im2.Mesh.node(:,3) >= lims(1)) & ...
             (im2.Mesh.node(:,3) <= lims(2)) );
figure
plot3(im2.Mesh.node(idx,1),im2.Mesh.node(idx,2),po2(idx),'.')

% Plot existing mesh
simSetup('20110408','2.0', lims(1), lims(2))
hold on; plot3(x, y, po2,'r.')
title(sprintf('Simulation Results w/ PO_2 Mapping after %d seconds', time))
zlabel('PO2 (mmHg)')
legend('New Mesh', 'Old Mesh')
fig = gcf;
fig.Position = [175 430 650 420]; % convenient aspect ratio
fig.PaperPositionMode = 'auto';