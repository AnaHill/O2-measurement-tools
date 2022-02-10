% Plot_chosen_data: chosen_dat created beforehand
if~exist('fig_count','var')
    fig_count = 1;
end
hfig(fig_count) = figure('units','normalized','Outerposition',[0 0 1 1]) 
%% plot O2% and normalized O2%
subplot(221), hold all,
for kk = 1:length(chosen_dat) %length(vars)
    plot(vars(chosen_dat(kk)).time/60,vars(chosen_dat(kk)).o2) 
end
legend(vars(chosen_dat).name,'interpreter','none','location','east')
xlabel('Time (min)'), ylabel('O2 (%)')
if exist('title_text','var')
    title([title_text,': %'])
end
% Normalized
am = 20; % Amount_of_samples to calculate max and min val
subplot(223), hold all,
for kk = 1:length(chosen_dat) %length(vars)
    dat = vars(chosen_dat(kk)).o2;
    dat_max = mean(maxk(dat,am));
    dat_min = mean(mink(dat,am));
    dat_diff = dat_max - dat_min;
    plot(vars(chosen_dat(kk)).time/60,(dat-dat_min)/dat_diff)
end
ylim([0 1.05]), 
% legend(vars(chosen_dat).name,'interpreter','none','location','east')
xlabel('Time (min)'), ylabel('Normalized')
title('Normalized O2')
if exist('xlimit','var')
    subplot(221), xlim(xlimit)
    subplot(223), xlim(xlimit)
end

%% plot phase and phase_norm

subplot(222), hold all,
for kk = 1:length(chosen_dat) %length(vars)
    plot(vars(chosen_dat(kk)).time/60,vars(chosen_dat(kk)).phase) 
end
% legend(vars(chosen_dat).name,'interpreter','none','location','east')
xlabel('Time (min)'), ylabel('Phase')
title('Phase')
% if exist('title_text','var')
%     title(title_text)
% end
% Normalized
am = 20; % Amount_of_samples to calculate max and min val
subplot(224), hold all,
for kk = 1:length(chosen_dat) %length(vars)
    dat = vars(chosen_dat(kk)).phase;
    dat_max = mean(maxk(dat,am));
    dat_min = mean(mink(dat,am));
    dat_diff = dat_max - dat_min;
    plot(vars(chosen_dat(kk)).time/60,(dat-dat_min)/dat_diff)
end
ylim([0 1.05]), 
% legend(vars(chosen_dat).name,'interpreter','none','location','east')
xlabel('Time (min)'), ylabel('Normalized')
title('Normalized Phase')
if exist('xlimit','var')
    subplot(222), xlim(xlimit)
    subplot(224), xlim(xlimit)
end
fig_count = fig_count + 1;