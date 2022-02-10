% Plot_chosen_data_phases
% chosen_dat created beforehand
figure('units','normalized','Outerposition',[0 0 1 1]) 
subplot(211), hold all,
for kk = 1:length(chosen_dat) %length(vars)
    plot(vars(chosen_dat(kk)).time/60,vars(chosen_dat(kk)).phase) 
end
legend(vars(chosen_dat).name,'interpreter','none','location','east')
xlabel('Time (min)'), ylabel('Phase')
if exist('title_text','var')
    title(title_text)
end
% Normalized
am = 20; % Amount_of_samples to calculate max and min val
subplot(212), hold all,
for kk = 1:length(chosen_dat) %length(vars)
    dat = vars(chosen_dat(kk)).phase;
    dat_max = mean(maxk(dat,am));
    dat_min = mean(mink(dat,am));
    dat_diff = dat_max - dat_min;
    plot(vars(chosen_dat(kk)).time/60,(dat-dat_min)/dat_diff)
end
ylim([0 1.05]), 
% legend(vars(chosen_dat).name,'interpreter','none','location','east')
xlabel('Time (min)'), ylabel('Normalized Phase')
title('Normalized')
if exist('xlimit','var')
    subplot(211), xlim(xlimit)
    subplot(212), xlim(xlimit)
end
