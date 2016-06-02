% Get relevant info (slopes, intercepts, cmro2 values)
slope = m2011.slope;
inter = m2011.inter;
error = m2011.error;
cmro2s = [1.5; 1.8; 2.0; 2.5; 3.0];

% Get each fitted equation
r  = 0:0.1:5;
s1 = (slope(1).*r) + inter(1);
s2 = (slope(2).*r) + inter(2);
s3 = (slope(3).*r) + inter(3);
s4 = (slope(4).*r) + inter(4);
s5 = (slope(5).*r) + inter(5);

% Plot each slope
figure
hold on
plot(r,s1)
plot(r,s2)
plot(r,s3)
plot(r,s4)
plot(r,s5)
title({'Comparing Fits for Different CMRO2 Values:'; 'Avg. pO2 v. Distance from Closest Arteriole'})
legend('CMRO2=1.5','CMRO2=1.8','CMRO2=2.0','CMRO2=2.5','CMRO2=3.0')
xlabel('Dist. from closest Arteriole (um)')
ylabel('pO2 (mmHg)')

% Fit slopes, get meta slope
mdl = fitlm(cmro2s, slope);
s = mdl.Coefficients{2,1};
i = mdl.Coefficients{1,1};
rsq = mdl.Rsquared.Ordinary;

% Plot slope of slopes
s6 = (s.*r) + i;
figure
ax = gca;
plot(r,s6,'linewidth',2)
hold on
errorbar(cmro2s,slope,error,'o')
ax.XTick = [1.5:0.5:3];
set(gca,'FontSize',20)
xlabel('CMRO2 (\mumol cm^{-3} min^{-1})', 'FontSize', 24)
ylabel('Slope (mmHg/\mum)', 'FontSize', 24)
xlim([1.2 3.3])
set(gca,'box','off')


