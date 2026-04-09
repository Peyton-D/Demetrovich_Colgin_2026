% % dentate spike methods figure
% %data from 9_22_24 sleep_1
% load('LFP_all_corrected.mat')
% load('ds_alt_method_corrected_shank0_v2.mat')
% lfp = shank0(1:2:end,:);
% clear shank0 shank3
% ds1Times = lfpTs(ds1Ind);
% ds2Times = lfpTs(ds2Ind);
% cols = {'Coral', 'Amethyst'};
% %% plot lfp stack
% 
% ds1IndToUse = 68:71;
% ds2IndToUse = 10;
% % timeWin = [floor(lfpTs(ds1Ind(ds1IndToUse))) ceil(lfpTs(ds1Ind(ds1IndToUse)))]; 
% timeWin = [153.5 154.5];
% lfpIndWin = [match(timeWin(1), lfpTs') match(timeWin(2), lfpTs')];
% chan2plot = 1:4:size(lfp,1);%chDG-10:chDG+10;
% 
% % plotLFPstack(lfp(30:80, ds1Ind(4)-1250:ds1Ind(4)+1250),2500,'SpacingFactor',.1, 'ScalebarVoltage', 5e-3)
% % lfp_mV = lfp .* 1e3;
% 
% % ptp_all = max(lfp_mV, [], 2) - min(lfp_mV, [], 2); % peak2peak
% % max_ptp = max(ptp_all);
% % spacing = .25;
% % for i=1:length(chan2plot)
% %     plot(lfpTs(lfpIndWin(1):lfpIndWin(2)), lfp_mV(chan2plot(i),lfpIndWin(1):lfpIndWin(2))+(i-1)*max_ptp*spacing, 'k-',...
% %         'LineWidth',1)
% %     if i == match(chDG, chan2plot')
% %         offset_for_marker = (i-1)*max_ptp*spacing;
% %         
% %     end
% % %     pause
% % end
% % set(gca, 'XColor', 'none')
% % yticks((0:length(chan2plot)-1)*max_ptp*spacing)
% % yticklabels(length(chan2plot):-1:1)
% % ylabel('Channel')
% % axis tight
% 
% figure, clf, 
% subplot(4,4,[1,9]), cla, hold on
% plot(nan, nan, 'v', 'MarkerEdgeColor','k',...
%     'MarkerFaceColor', rgb(cols{1}), 'MarkerSize', 10)
% plot(nan, nan, 'v','MarkerEdgeColor','k',...
%     'MarkerFaceColor', rgb(cols{2}), 'MarkerSize', 10)
% legend({'DS1', 'DS2'}, 'box', 'off')
% legend autoupdate off
% % offset = plotLFPstack(lfpTs(lfpIndWin(1):lfpIndWin(2)), lfp(chan2plot,lfpIndWin(1):lfpIndWin(2)),'SpacingFactor', .3);
% offset = plotLFPstack(lfpTs(lfpIndWin(1):lfpIndWin(2)), lfp(chan2plot,lfpIndWin(1):lfpIndWin(2)),'ScaleBarVoltage', 1e-3, 'SpacingFactor', .3);
% offset_for_markers = (match(chDG, chan2plot')-1)*offset;
% 
% plot(ds2Times(ds2IndToUse), lfp(chDG, ds2Ind(ds2IndToUse))+offset_for_markers, 'v','MarkerEdgeColor','k',...
%     'MarkerFaceColor', rgb(cols{2}), 'MarkerSize', 10)
% plot(ds1Times(ds1IndToUse), lfp(chDG, ds1Ind(ds1IndToUse))+offset_for_markers, 'v', 'MarkerEdgeColor','k',...
%     'MarkerFaceColor', rgb(cols{1}), 'MarkerSize', 10)
% 
% set(gca, ...
%     'XColor', 'none', ...        % hide x-axis line and ticks
%     'TickDir', 'out', ...        % ticks pointing outward
%     'Box', 'off', ...            % remove top/right box lines
%     'FontSize', 10)
% axis tight
% yticks((0:4:96-1)*offset)
% yticklabels(96:-4:1)
% 
% % figure, cla, hold on 
% % scaling = 0.0005;
% %     for chI = 1:size(lfp,1)
% %         x = lfp(chI,lfpIndWin(1):lfpIndWin(2));
% %         x = x / scaling; %scale for amplitude
% %         
% %         %if spline is used, find electrode where sink/source is present
% %         [~,k] = min(abs(el_pos(chI) - zs));
% %         %plot(x + k,'Color',[0.7 0.7 0.7]);
% %         plot(lfpTs(lfpIndWin(1):lfpIndWin(2)), x + k,'Color','k');
% %     end
% %% loop through sessions for day collecting ds1 and 2, take the peaks squeeze(:,126,:) for each, concatenate, then plot together
% % i did it by hand instead of writing the code unfortunately
% cd(cellStruct.rat(2).cond(2).day(1).dataLoc)
% CSD_ds1_day = [];
% CSD_ds2_day = [];
% for b=1:9
%     cd([cellStruct.rat(2).cond(2).day(1).session(b).name '\' ...
%                         cellStruct.rat(2).cond(2).day(1).session(b).name(7:end) '_imec0'])
%     load('ds_alt_method_corrected_shank0_v2.mat')
%     CSD_ds1_day = cat(3,CSD_ds1_day, CSD_ds1);
%     CSD_ds2_day = cat(3,CSD_ds2_day, CSD_ds2);
%     cd(cellStruct.rat(2).cond(2).day(1).dataLoc)
% end
% ds1Pks = squeeze(CSD_ds1_day(:,126,:));
% ds2Pks = squeeze(CSD_ds2_day(:,126,:));
% all_ds_day = [ds1Pks ds2Pks];
% 
% subplot(4,4,[2,3,10,11]), cla
% % mins = min(resultsCSD(1:100,:));
% % [~,sortInd] = sort(mins);
% % sort(resultsCSD)
% % imagesc(resultsCSD)
% imagesc(fliplr(all_ds_day))
% caxis([-3e4 3e4])
% colormap jet
% clbr = colorbar;
% clbr.Position = [0.705    0.50   0.0100    0.20];
% clbr.Ticks = [-2e4 2e4];
% clbr.TickLabels = {'Sink', 'Source'};
% ylabel(clbr, '')
% title('All DS Peak-time CSDs From One Day')
% ylabel('Depth along probe (CSD space)')
% xlabel('DS #')
% xline(size(ds2Pks,2),'--','LineWidth',1)
% yticks('')
% 
% subplot(4,4,[4,12]), hold on
% % [~,minInd] = min(all_ds_day);
% % edges = 0.5:1:200.5;
% % histMinInd = histc(minInd, edges);
% % plot(histMinInd, edges+.5,'k','LineWidth',1.5);
% % % histogram(minInd,edges,'orientation','horizontal')
% % axis ij tight
% % xlabel('Count')
% % title('Histogram of Sinks')
% % yticks('')
% 
% % subplot(144)
% plot(mean(ds1Pks,2),1:200,'Color',rgb(cols{1}), 'Linewidth', 2, 'DisplayName', 'DS1')
% plot(mean(ds2Pks,2),1:200,'Color',rgb(cols{2}), 'Linewidth', 2, 'DisplayName', 'DS2')
% title('Mean DS Peak Time CSD')
% xlabel('CSD')
% xlim([-3e4 3e4])
% axis ij
% yticks('')
% legend box off
% title('Mean DS Peak-time CSD')
% 
% %% plot average ds csd and waveform 
% xaxis = -.05:1/2500:.05;
% cd('D:\NeuropixelsData')
% load('ds_metrics_for_stats.mat')
% 
% figure, clf
% subplot(4,4,[1,5]), cla
% imagesc(xaxis,1:200,mean(CSD_ds1_day,3))
% colormap jet
% title('Mean DS1 CSD')
% caxis([-2e4 2e4])
% ylabel('Depth along probe (CSD space)')
% % yticks('')
% xlabel('Time from DS1 Peak (s)')
% xticks([-.05 -.025 0 0.025 .05])
% yline([40 50 60 70],'--',{' ','OML','MML','IML'},'LabelVerticalAlignment','top', 'Color',[.5 .5 .5])
% yline([150 160 170 180],'--',{'IML','MML','OML', ' '},'LabelVerticalAlignment','bottom', 'Color',[.5 .5 .5])
% yline(70, '--', {'GCL'},'LabelVerticalAlignment','bottom', 'Color',[.5 .5 .5])
% yline(150, '--', {'GCL'},'LabelVerticalAlignment','top', 'Color',[.5 .5 .5])
% 
% subplot(4,4,[9]), cla
% % get data
% pullDataInds = strcmp(table_for_stats.Condition, 'Social') & strcmp(table_for_stats.Rat, 'Rat451'); 
% ds1Wave = table_for_stats.("DS1Waveform")(pullDataInds,:); 
% error_fill_plot(xaxis,mean(ds1Wave),semfunct(ds1Wave),cols{1});
% error_fill_plot(xaxis,mean(ds1Waveforms)*1e3,sem(ds1Waveforms)*1e3,cols{1});
% % ylabel('LFP Amplitude (z-score)');
% ylabel('Voltage (mV)');
% title(['Mean DS1 LFP Waveform'])
% xlabel('Time from DS1 Peak (s)')
% xticks([-.05 -.025 0 0.025 .05])
% % ylim([-1 5])
% 
% subplot(4,4,[10]), cla
% ds2Wave = table_for_stats.("DS2Waveform")(pullDataInds,:); 
% % error_fill_plot(xaxis,mean(ds2Wave),sem(ds2Wave),cols{2});
% error_fill_plot(xaxis,mean(ds2Waveforms)*1e3,sem(ds2Waveforms)*1e3,cols{2});
% % ylabel('LFP Amplitude (z-score)');
% ylabel('Voltage (mV)');
% title(['Mean DS2 LFP Waveform'])
% xlabel('Time from DS2 Peak (s)')
% xticks([-.05 -.025 0 0.025 .05])
% % ylim([-1 5])
% 
% 
% subplot(4,4,[2,6]), cla
% imagesc(xaxis,1:200,mean(CSD_ds2_day,3))
% colormap jet
% title('Mean DS2 CSD')
% caxis([-2e4 2e4])
% yticks('')
% xticks([-.05 -.025 0 0.025 .05])
% yline([40 50 60 70],'--',{' ','OML','MML','IML'},'LabelVerticalAlignment','top', 'Color',[.5 .5 .5])
% yline([150 160 170 180],'--',{'IML','MML','OML', ' '},'LabelVerticalAlignment','bottom', 'Color',[.5 .5 .5])
% yline(70, '--', {'GCL'},'LabelVerticalAlignment','bottom', 'Color',[.5 .5 .5])
% yline(150, '--', {'GCL'},'LabelVerticalAlignment','top', 'Color',[.5 .5 .5])
% xlabel('Time from DS2 Peak (s)')
%% revision figure
cd('D:\NeuropixelsData\Rat503\7_19_25\catgt_sleep1_g0\sleep1_g0_imec0')
load('ds_alt_method_corrected_shank_auto3_SDthresh4.mat')

% BE CAREFUL WITH CLUSTER IDENTITY, MAKE SURE ORIGINAL CLUSTER IDS MATCH BECAUSE "1"/"2" MAY FLIP ACROSS FUNCTION CALLS
[pc12, labels] = dentateSpikeClustering(resultsCSD); % do automated clustering of dentate spikes 
xaxis = -.05:1/2500:.05;

% get average cluster csd
avgClust1 = mean(ds_cluster(1).CSD,3);
avgClust2 = mean(ds_cluster(2).CSD,3);

% get isopotential (reversal) channels
iso1 = match(0,avgClust1(1:100,126));
iso2 = match(0,avgClust2(1:100,126));

% figure, clf
% plot cluster 1 average CSD
subplot(4,4,[11,15]), cla
imagesc(xaxis,1:200,avgClust1)
colormap jet
title('Mean Cluster 1 CSD')
caxis([-2e4 2e4])
% ylabel({'Depth index'; '(ventral \leftrightarrow dorsal)'});
yticks('')
ylabel('')
xlabel('Time from DS Peak (s)')
xticks([-.05 -.025 0 0.025 .05])
yline(iso1,'--', 'Reversal')
% yline([40 50 60 70],'--',{' ','OML','MML','IML'},'LabelVerticalAlignment','top', 'Color',[.5 .5 .5])
% yline([150 160 170 180],'--',{'IML','MML','OML', ' '},'LabelVerticalAlignment','bottom', 'Color',[.5 .5 .5])
% yline(70, '--', {'GCL'},'LabelVerticalAlignment','bottom', 'Color',[.5 .5 .5])
% yline(150, '--', {'GCL'},'LabelVerticalAlignment','top', 'Color',[.5 .5 .5])

% plot cluster 2 average CSD
subplot(4,4,[12,16]), cla
imagesc(xaxis,1:200,avgClust2)
colormap jet
title('Mean Cluster 2 CSD')
caxis([-2e4 2e4])
% ylabel({'Depth index'; '(ventral \leftrightarrow dorsal)'});
yticks('')
ylabel('')
xlabel('Time from DS Peak (s)')
xticks([-.05 -.025 0 0.025 .05])
yline(iso2,'--', 'Reversal')
clbr = colorbar;
clbr.Position = [0.91    0.2    0.0100    0.20];
clbr.Ticks = [-1.5e4 1.5e4];
clbr.TickLabels = {'Sink', 'Source'};

SetFigureDefaults()
savefig(gcf,'ds_type_classification')
saveas(gcf,'ds_type_classification','png')
saveas(gcf,'ds_type_classification','epsc')
%% s4 - plot depth profiles and average waveforms (optional)
cd('D:\NeuropixelsData\Rat503\7_19_25\catgt_sleep1_g0\sleep1_g0_imec0')
load('ds_alt_method_corrected_shank_auto3_SDthresh4.mat')
load('dsAutoClass.mat')
load('LFP_all_corrected_7_19_25_catgt_sleep1_g0.mat')
lfp = shank3(1:2:end,:);
clear shank0 shank3
cols = {'Coral', 'Amethyst'};

% find good ds visually
% eegplot(lfp, 'srate', 2500, 'winlength', 3, 'spacing', 0.001 );

% chan2plot = 1:4:size(lfp,1);%chDG-10:chDG+10;
chan2plot = 1:2:chDG;%chDG-10:chDG+10;

x = lfpTs(1):3:lfpTs(end);
figure
% for i=1:length(x)-1
timeWin = [306 309] %timeWin = [x(i), x(i+1)]; % timeWin = [86 89];
lfpIndWin = [match(timeWin(1), lfpTs') match(timeWin(2), lfpTs')];
ds1IndToUse = find(ds1Cluster.inds > lfpIndWin(1) & ds1Cluster.inds < lfpIndWin(2));
ds2IndToUse = find(ds2Cluster.inds > lfpIndWin(1) & ds2Cluster.inds < lfpIndWin(2)); 

% chan2plot = 1:4:size(lfp,1);%chDG-10:chDG+10;
chan2plot = 1:2:chDG;%chDG-10:chDG+10;

% figure, clf, 
% subplot(4,4,[1,9]), cla, 
% subplot(4,4,[1,9])
subplot(4,4,[1 2 9 10]); cla
hold on
plot(nan, nan, 'v', 'MarkerEdgeColor','k',...
    'MarkerFaceColor', rgb(cols{1}), 'MarkerSize', 10)
plot(nan, nan, 'v','MarkerEdgeColor','k',...
    'MarkerFaceColor', rgb(cols{2}), 'MarkerSize', 10)
legend({'DS1', 'DS2'}, 'box', 'off')
legend autoupdate off
% offset = plotLFPstack(lfpTs(lfpIndWin(1):lfpIndWin(2)), lfp(chan2plot,lfpIndWin(1):lfpIndWin(2)),'SpacingFactor', .3);
offset = plotLFPstack(lfpTs(lfpIndWin(1):lfpIndWin(2)), lfp(chan2plot,lfpIndWin(1):lfpIndWin(2)),'ScaleBarVoltage', 1e-3, 'SpacingFactor', .4);
% offset_for_markers = (match(chDG, chan2plot')-1)*offset;
offset_for_markers = 12*offset; % select which channel to plot markers on
axis tight
plot(lfpTs(ds2Cluster.inds(ds2IndToUse)), lfp(chDG, ds2Cluster.inds(ds2IndToUse))+offset_for_markers, 'v','MarkerEdgeColor','k',...
    'MarkerFaceColor', rgb(cols{2}), 'MarkerSize', 10)
plot(lfpTs(ds1Cluster.inds(ds1IndToUse)), lfp(chDG, ds1Cluster.inds(ds1IndToUse))+offset_for_markers, 'v', 'MarkerEdgeColor','k',...
    'MarkerFaceColor', rgb(cols{1}), 'MarkerSize', 10)

set(gca, ...
    'XColor', 'none', ...        % hide x-axis line and ticks
    'TickDir', 'out', ...        % ticks pointing outward
    'Box', 'off', ...            % remove top/right box lines
    'FontSize', 10)
title(num2str(timeWin))
% pause
% end
% axis tight
% yticks((0:4:96-1)*offset)
% yticklabels(96:-4:1)

halfwin = 250;
xaxis = -halfwin*(1/2500):1/2500:halfwin*(1/2500);
% ds1Waveforms = nan(length(ds1Cluster.inds), (halfwin*2)+1);
ds1Waveforms = nan(length(chan2plot), (halfwin*2)+1, length(ds1Cluster.inds));
for i=1:length(ds1Cluster.inds)
    if ds1Cluster.inds(i)-halfwin < 1 | ds1Cluster.inds(i)+halfwin > length(lfp)
        continue
    else
%         ds1Waveforms(i,:) = lfp(chDG,ds1Cluster.inds(i)-halfwin:ds1Cluster.inds(i)+halfwin);
        ds1Waveforms(:,:,i) = lfp(chan2plot,ds1Cluster.inds(i)-halfwin:ds1Cluster.inds(i)+halfwin);
    end
end

ds2Waveforms = nan(length(chan2plot), (halfwin*2)+1, length(ds2Cluster.inds));
for i=1:length(ds2Cluster.inds)
    if ds2Cluster.inds(i)-halfwin < 1 | ds2Cluster.inds(i)+halfwin > length(lfp)
        continue
    else
%         ds2Waveforms(i,:) = lfp(chDG,ds2Cluster.inds(i)-halfwin:ds2Cluster.inds(i)+halfwin);
        ds2Waveforms(:,:,i) = lfp(chan2plot,ds2Cluster.inds(i)-halfwin:ds2Cluster.inds(i)+halfwin);
    end
end

avgDs1Lfp = mean(ds1Waveforms,3);
avgDs2Lfp = mean(ds2Waveforms,3);
semDs1Lfp = semfunct(ds1Waveforms,3);
semDs2Lfp = semfunct(ds2Waveforms,3);

subplot(4,4,15), cla
error_fill_plot(xaxis,avgDs1Lfp(match(chDG, chan2plot')-1,:)*1e3, semDs1Lfp(match(chDG, chan2plot')-1,:)*1e3,cols{1});
ylabel('Voltage (mV)');
title(['Mean DS1 LFP Waveform'])
xlabel('Time from Peak (s)')
ylim([-1 2.5])

subplot(4,4,16), cla
error_fill_plot(xaxis,avgDs2Lfp(match(chDG, chan2plot')-1,:)*1e3, semDs2Lfp(match(chDG, chan2plot')-1,:)*1e3,cols{2});
ylabel('Voltage (mV)');
title(['Mean DS2 LFP Waveform'])
xlabel('Time from Peak (s)')
ylim([-1 2.5])


subplot(4,4,[3,7,11]), cla
plotLFPstack(xaxis,avgDs1Lfp,'SpacingFactor', 0.2, 'ScalebarTime', 0.05);
axis tight
title('Mean DS1 LFP Depth Profile')
set(gca, ...
    'XColor', 'none', ...        % hide x-axis line and ticks
    'YColor','none', ...
    'TickDir', 'out', ...        % ticks pointing outward
    'Box', 'off', ...            % remove top/right box lines
    'FontSize', 10)

subplot(4,4,[4,8,12]), cla
plotLFPstack(xaxis,avgDs2Lfp,'SpacingFactor', 0.2, 'ScalebarTime', 0.05);
axis tight
title('Mean DS2 LFP Depth Profile')
set(gca, ...
    'XColor', 'none', ...        % hide x-axis line and ticks
    'YColor','none', ...
    'TickDir', 'out', ...        % ticks pointing outward
    'Box', 'off', ...            % remove top/right box lines
    'FontSize', 10)


% %% overlay heatmap and lfps -WIP 
% 
% R = size(avgDs1Lfp,1);
% C = size(avgDs1Lfp,2);
% 
% figure; clf,
% imagesc(avgDs1Lfp);   % your heatmap
% colormap redblue
% caxis([-1e-3 1e-3])
% hold on;
% 
% for r = 1:R
%     line_raw = avgDs1Lfp(r,:);
% 
%     % Normalize to [0,1]
%     line_norm = (line_raw - min(line_raw)) ./ (max(line_raw) - min(line_raw));
% 
%     % Shift into row r
%     line_shifted = line_norm + (R - r);
% 
%     % Plot
%     plot(1:C, line_shifted, 'k', 'LineWidth', 1.2);
% end
% 
% hold off;
% axis tight;
% 
% % Example matrix
% A = rand(10,50);   % 10 rows, 50 columns
% 
% figure, cla
% imagesc(avgDs1Lfp);        % Heatmap
% colormap(parula);
% hold on;
% 
% [numRows, numCols] = size(avgDs1Lfp);
% 
% % For each row, plot a line scaled + shifted to sit on top of the heatmap row
% for r = 1:numRows
%     y = r * ones(1, numCols);   % baseline at row index
%     plot(1:numCols, avgDs1Lfp + .5*(avgDs1Lfp(r,:) - mean(avgDs1Lfp(r,:))), 'k', 'LineWidth', 1.2);
% end
% 
% hold off;
% 
% axis tight;
% set(gca,'YDir','normal');   % Make row 1 at bottom
% 
% A = avgDs1Lfp;   % 25x1001
% 
% figure; clf
% imagesc(A);
% colormap(parula);
% hold on;
% 
% [numRows, numCols] = size(A);
% 
% for r = 1:numRows
%     row = A(r,:);
% 
%     % Normalize each row to [0, 1]
%     rowNorm = (row - min(row)) / (max(row) - min(row) + eps);
% 
%     % Scale to fit nicely inside the row band
%     y = r - 0.4 + 0.8 * rowNorm;
% 
%     plot(1:numCols, y, 'k', 'LineWidth', 1.2);
% end
% 
% set(gca,'YDir','normal');   % Ensure row 1 is at bottom
% axis tight;

