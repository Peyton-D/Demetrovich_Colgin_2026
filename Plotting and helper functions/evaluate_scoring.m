% this code evaluates automated and handscored dentate spike detection for different standard deviation thresholds
score_eval(1).filename = 'rat451_9_22_sleep1_shank0_filtLFP_CSD.mat';
score_eval(1).path = 'G:\Rat451\9_22_24\catgt_sleep1_g0\sleep1_g0_imec0';
score_eval(2).filename = 'rat503_7_19_sleep1_shank3_filtLFP_CSD.mat';
score_eval(2).path = 'D:\NeuropixelsData\Rat503\7_19_25\catgt_sleep1_g0\sleep1_g0_imec0';

winLen = .05; % s
srate = 2500; % hz

for f = 1:length(score_eval)
    cd(score_eval(f).path)
    load(score_eval(f).filename)

    handScore_L = readmatrix('handScore_L.csv');
    CSD_L = zeros(200,(winLen*srate*2)+1,length(handScore_L));
    for i=1:length(handScore_L)
        idx = match(handScore_L(i,2),lfpTs);
        CSD_L(:,:,i) = instantCSD(:,idx-(winLen*srate):idx+(winLen*srate));
    end

    handScore_J = readmatrix('handScore_J.csv');
    CSD_J = zeros(200,(winLen*srate*2)+1,length(handScore_J));
    for i=1:length(handScore_J)
        idx = match(handScore_J(i,2),lfpTs);
        CSD_J(:,:,i) = instantCSD(:,idx-(winLen*srate):idx+(winLen*srate));
    end
    human_events = {handScore_L handScore_J; 'L' 'J'};
    auto_times = {};

    files = dir('*SDthresh*.mat');   % find all matching files
    for k = 1:5%numel(files)
        fname = files(k).name;
        data = load(fname);
        disp(['Loaded ' fname])
    
        ds1Times = lfpTs(data.ds1Ind);
        ds2Times = lfpTs(data.ds2Ind);
        [dsTimes, sortInd] = sort([ds1Times, ds2Times]);
        dsTimes = dsTimes';
    
        auto_times{1,k} = [ones(length(dsTimes),1) dsTimes, zeros(length(dsTimes),1)+0.001];
    
        clear data
    end
    
    auto_names = {'2.5' '3.0' '3.5' '4.0' '4.5'}; % need to match order of files in files variable
    auto_events = [auto_times; auto_names];
    score_eval(f).allEvents = [human_events auto_events]; 
    [score_eval(f).results, score_eval(f).confuse] = compareScorers(score_eval(f).allEvents, 0.1);
    score_eval(f).PR = computePR([2.5 3.0 3.5 4.0 4.5], auto_events, human_events);
end
%% plotting F1 scores
avgConfuse = mean(cat(3,score_eval(1).confuse,score_eval(2).confuse),3);
figure, clf
subplot(4,4,[1,2,5,6])
imagesc(avgConfuse);
clbr = colorbar;
clbr.Label.String = {'Mean F1 Score'};
clbr.Limits = [0 1];
% clbr.Position = [0.85 0.25 0.0381 0.5];
% axis equal tight;
xticks(1:7)
xticklabels(score_eval(1).allEvents(2,:))
yticks(1:7)
yticklabels(score_eval(1).allEvents(2,:))
xlabel("Scorer/Detector")
ylabel("Scorer/Detector")
title("Dentate spike detection performance")
yline(2.5,'r-','LineWidth', 3);
xline(2.5,'r-','LineWidth', 3);

xs = [2.5 3.0 3.5 4.0 4.5];
subplot(4,4,[3,4,7,8]), cla, hold on
plot(xs,score_eval(1).confuse(3:end,1),'*-', 'Color', rgb('Coral'), 'LineWidth',2, 'DisplayName', 'Scorer L Day 1')
plot(xs,score_eval(1).confuse(3:end,2),'*-', 'Color', rgb('SkyBlue'), 'LineWidth',2, 'DisplayName', 'Scorer J Day 1' )
plot(xs,score_eval(2).confuse(3:end,1),'*--','Color', rgb('Coral'), 'LineWidth',2, 'DisplayName', 'Scorer L Day 2' )
plot(xs,score_eval(2).confuse(3:end,2),'*--','Color', rgb('SkyBlue'), 'LineWidth',2, 'DisplayName', 'ScorerJ Day 2' )
legend('autoupdate', 'off')
legend('box', 'off')

avgF1 = mean([score_eval(1).confuse(3:end,1) score_eval(2).confuse(3:end,1)...
    score_eval(1).confuse(3:end,2) score_eval(2).confuse(3:end,2)],2);
stdF1 = std([score_eval(1).confuse(3:end,1) score_eval(2).confuse(3:end,1)...
    score_eval(1).confuse(3:end,2) score_eval(2).confuse(3:end,2)],0,2);
semF1 = stdF1 / sqrt(4); 
error_fill_plot2(xs, avgF1, semF1, [0.5 0.5 0.5])
xlabel('Standard Deviation (SD) Threshold')
ylabel('F1 Score')

[~,maxInd] = max(avgF1);
yline(avgF1(maxInd), '--');
xline(xs(maxInd),'--');
ylim([0 1])
xlim([2.0 5.0])
xticks(2.5:.5:4.5);

%% plot average csds per detector 
xaxis = -.05:1/2500:.05;

subplot(4,4,[9,13])
imagesc(xaxis, 1:200, mean(CSD_L,3))
xticks([-.05 -.025 0 0.025 .05])
yticks('')
colormap(gca,'jet')
caxis([-2e4 2e4])
title({'Scorer L'})
xlabel('Time from DS Peak (s)')
ylabel('Depth along probe (CSD space)')

subplot(4,4,[10,14])
imagesc(xaxis, 1:200, mean(CSD_J,3))
xticks([-.05 -.025 0 0.025 .05])
yticks('')
colormap(gca,'jet')
caxis([-2e4 2e4])
title({'Scorer J'})
xlabel('Time from DS Peak (s)')

load('ds_alt_method_corrected_shank3_SDthresh3_5.mat')
subplot(4,4,[11,15])
CSD_1_2 = cat(3,CSD_ds1,CSD_ds2);
imagesc(xaxis, 1:200, mean(CSD_1_2,3))
xticks([-.05 -.025 0 0.025 .05])
yticks('')
colormap(gca,'jet')
caxis([-2e4 2e4])
title({'3.5 SD Detector'})
xlabel('Time from DS Peak (s)')

load('ds_alt_method_corrected_shank3_SDthresh4_0.mat')
subplot(4,4,[12,16])
CSD_1_2 = cat(3,CSD_ds1,CSD_ds2);
imagesc(xaxis, 1:200, mean(CSD_1_2,3))
xticks([-.05 -.025 0 0.025 .05])
yticks('')
colormap(gca,'jet')
caxis([-2e4 2e4])
title({'4.0 SD Detector'})
xlabel('Time from DS Peak (s)')

clbr_csd = colorbar;
clbr_csd.Label.String = {'CSD'};
clbr_csd.Limits = [-2e4 2e4];
clbr_csd.Ticks = [-1.5e4 1.5e4];
clbr_csd.Position = [.91 .175 .015 .25];
clbr_csd.TickLabels = {'Sink', 'Source'};

savefig(gcf,'ds_detection_evaluation')
saveas(gcf,'ds_detection_evaluation','png')
saveas(gcf,'ds_detection_evaluation','epsc')
