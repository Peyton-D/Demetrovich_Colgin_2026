function stim_explore_time(cellStruct)
% Purpose: to extract the time spent by rats on the track in each condition
% and session, plot the average exploration maps and individual data
% points, and run stats
% - note: the saving functions have been commented out. uncomment them if
%   you would like to save tables, figure, stats, etc.
%
% Inputs: 
%   cellStruct - data structure containing the cells from all recordings 
%
% Outputs:
%   Fig. 1 - average exploration time maps (Fig. 5A from paper)
%   Fig. 2 - dotplot of stimulus exploration times (Fig. 5B from paper)
%
% Peyton Demetrovich
% Colgin Lab 4/8/26

%% initialize
cols = {[0.0 0.45 0.70] [0.85 0.37 0.01] [0.93 0.69 0.13] [0.0 0.62 0.45] [0.80 0.47 0.74] [0.8203 0.7031 0.5469]};
sessionNames = {'A' 'B'};
stimTime = [];
stimTimeA = [];
stimTimeB = [];
rewardTime = [];
rewardTimeA = [];
rewardTimeB = [];
ratID = {};
condID = {};
dayID = [];
stimID = [];
rewardID = [];
sessionID = {}; 
% rewardZone = 90; % center degree
binSize = 6; % degrees
degreeSpan = 45; 
useWindow = 1; 
% timeWindow = [1 3600]; % indices, 30 fps
timeWindow = [1 18000]; % indices, 30 fps
timePerBin = {}; % condition by session 

%% get data
for r=1:length(cellStruct.rat)
    for c=1:length(cellStruct.rat(r).cond)
        if c > length(cellStruct.rat(r).cond)
            continue
        end
        for d=1:length(cellStruct.rat(r).cond(c).day)
            for s=[2 4]
                % zones were in different locations on these days
                if r == 1 | (r == 2 & d == 2) | (r==2 & c==6 & s==2)
                    stimZone = 180;
                    rewardZone = 90;
                elseif r == 2 & c == 6 & s==4
                    stimZone = 225;
                    rewardZone = 180;
                elseif r == 3 & c == 6 & s==4
                    stimZone = 300;
                    rewardZone = 90;
                elseif r == 4 & c == 6 & s==4
                    stimZone = 45;
                    rewardZone = 270;
                elseif r == 5 & c == 6 & s==4
                    stimZone = 135;
                    rewardZone = 270;
                else
                    stimZone = 225; % center degree
                    rewardZone = 90;
                end

                stimZoneBounds = [stimZone-degreeSpan stimZone+degreeSpan];
                rewardZoneBounds = [rewardZone-degreeSpan rewardZone+degreeSpan];

                % convert degrees to bins
                stimZoneInds = round(stimZoneBounds/binSize);
                rewardZoneInds = round(rewardZoneBounds/binSize);
                % wrap around to prevent zero indices
                stimZoneInds(stimZoneInds == 0) = 1;
                rewardZoneInds(rewardZoneInds == 0) = 1;

                ratID = [ratID; cellStruct.rat(r).name];
                condID = [condID; cellStruct.rat(r).cond(c).name];
                dayID = [dayID; d];
                sessionID = [sessionID; sessionNames{s/2}];
                stimID = [stimID; stimZone];
                rewardID = [rewardID; rewardZone];

                if useWindow == 1
                    tpb = getTimePerBin(cellStruct.rat(r).cond(c).day(d).session(s).coords_1d(timeWindow(1):timeWindow(2),:), ...
                        cellStruct.rat(r).cond(c).day(d).session(s).coords_2d(timeWindow(1):timeWindow(2),:), 6 );
                    tmpTime = sum( tpb( stimZoneInds(1):stimZoneInds(2) ) );
                else

                    tmpTime = sum(cellStruct.rat(r).cond(c).day(d).session(s).coords_1d(:,2) >= stimZone-degreeSpan & ...
                        cellStruct.rat(r).cond(c).day(d).session(s).coords_1d(:,2) <= stimZone+degreeSpan) / 30;
                end

                stimTime = [stimTime; tmpTime];

                if s== 2
                    stimTimeA = [stimTimeA; tmpTime];
                elseif s==4
                    stimTimeB = [stimTimeB; tmpTime];
                end

                if useWindow == 1
                    tmpTime = sum( tpb( rewardZoneInds(1):rewardZoneInds(2) ) );
                else
                    tmpTime = sum(cellStruct.rat(r).cond(c).day(d).session(s).coords_1d(:,2) >= rewardZone-degreeSpan & ...
                        cellStruct.rat(r).cond(c).day(d).session(s).coords_1d(:,2) <= rewardZone+degreeSpan) / 30;
                end

                rewardTime = [rewardTime; tmpTime];

                if s== 2
                    rewardTimeA = [rewardTimeA; tmpTime];
                elseif s==4
                    rewardTimeB = [rewardTimeB; tmpTime];
                end

                if useWindow == 1
                    timePerBin = [timePerBin; tpb];
                end
            end
        end
    end
end

table_for_stats = table(ratID, condID, dayID, sessionID, stimID, rewardID, timePerBin, stimTime, 'VariableNames', {'Rat', 'Condition', 'Day', 'Session' 'StimLoc', 'RewardLoc', 'TimeMaps' ,'StimTime',});
getCircularTimemaps(table_for_stats, 45, 0);

%% plot dotlines
conditions = {'Empty', 'Social', 'SocialOdor', 'NonSocialOdor', 'FoxOdor', 'NovelRoom'};
conditionNames = {'Empty', 'Social', 'Social Odor', 'Nonsocial Odor', 'Fox Odor', 'Novel Room'};

figure, theme(gcf,'light'), clf, subplot(2,1,2), hold on 
patch(nan, nan, [.5 .5 .5], 'DisplayName', 'Session A');
patch(nan, nan, cols{1}, 'DisplayName', 'Session B');
legend('AutoUpdate','off')
pltCntr = 1;
for c=1:6
    xs = [];
    ys = [];
    for s=1:2
        % get condition and session data
        pullData = strcmp(table_for_stats.Condition, conditions{c}) & strcmp(table_for_stats.Session, sessionNames{s});
        tmpTbl = table_for_stats(pullData,:);
        tmpY = tmpTbl.StimTime;
        tmpX = ones(size(tmpY))*pltCntr;
        
        % plot points
        if s==1
            scatter(tmpX,tmpY, 40, [.5 .5 .5], 'filled')
        else
            scatter(tmpX,tmpY, 40, cols{c}, 'filled')
        end
        
        % collect points for lines
        xs = [xs tmpX];
        ys = [ys tmpY];
        pltCntr = pltCntr+1;
    end
        
    % connect session A and B points
    for i = 1:length(tmpY)
        plot([xs(i,1) xs(i,2)], [ys(i,1) ys(i,2)], ':', 'LineWidth', 0.7, 'Color',[0 0 0 0.3])
    end
end
ylabel('Stimulus Zone Time (s)');
xticks([1.5 3.5 5.5 7.5 9.5 11.5])
xticklabels(conditionNames)
ylim([0 600])
xlim([0 13])
%% GLMM
table_for_stats.Rat = categorical(table_for_stats.Rat);
table_for_stats.Condition = categorical(table_for_stats.Condition);
table_for_stats.Condition = reordercats(table_for_stats.Condition, {'Empty', 'Social', 'SocialOdor', 'NonSocialOdor', 'FoxOdor', 'NovelRoom'});
table_for_stats.Day = categorical(table_for_stats.Day);
table_for_stats.Session = categorical(table_for_stats.Session);
table_for_stats.Session = reordercats(table_for_stats.Session, {'A', 'B'});

% fit model
glme = fitglme(table_for_stats, ...
    'StimTime ~ Condition*Session  + (1|Rat) + (1|Rat:Day)', 'Verbose', 1, 'DummyVarCoding', 'effects');

% test for main and interaction effects
anv = anova(glme)
% save(['stim_time_exploration_glme_' date '.mat'], 'table_for_stats', 'glme', 'anv')

% get estimated marginal means
% Define categories
conditions = unique(table_for_stats.Condition);
sessions = unique(table_for_stats.Session);

% % Create grid of all combinations
[C, S] = ndgrid(conditions, sessions);

% Create dummy values for Rat and Day
n = numel(conditions);
dummyRat = repmat("DummyRat", n, 2);
dummyDay = repmat("DummyDay", n, 2);

% Build table
newTbl = table(C(:), S(:), categorical(dummyRat(:)), categorical(dummyDay(:)), ...
    'VariableNames', {'Condition', 'Session', 'Rat', 'Day'});


[~, yCI] = predict(glme, newTbl, 'Conditional', false);

pltCnt = 1;
for c=[1,7,2,8,3,9,4,10,5,11,6,12]
    colInd = mod(c,6);
    if colInd == 0
        colInd = 6;
    end
    if c < 7 
        plot([pltCnt,pltCnt],[yCI(c,1), yCI(c,2)], 'Color', [.5 .5 .5], 'LineWidth', 2)
    else
        plot([pltCnt,pltCnt],[yCI(c,1), yCI(c,2)], 'Color', cols{colInd}, 'LineWidth', 2)
    end
    pltCnt = pltCnt + 1;
end

%% post-hoc tests two fixed factors
xpos = [1,2; 3,4; 5,6; 7,8; 9,10; 11,12];
pcs = {'Empty' 'A'  'Empty' 'B'; % planned comparisons
       'Social' 'A' 'Social' 'B';
       'SocialOdor' 'A' 'SocialOdor' 'B';
       'NonSocialOdor' 'A' 'NonSocialOdor' 'B';
       'FoxOdor' 'A' 'FoxOdor' 'B';
       'NovelRoom' 'A' 'NovelRoom' 'B'};
statCell = {'Comparison','contrast','F', 'df1', 'df2', 'p', 'p_BF'};

for i=1:size(pcs,1)
    statCell{i+1,1} = [pcs{i,1} ':' pcs{i,2} ' vs '  pcs{i,3} ':' pcs{i,4}];
    v1 = generateEffectVectorFromModel(glme,'Condition' , 'Session', pcs{i,1}, pcs{i,2});
    v2 = generateEffectVectorFromModel(glme,'Condition' , 'Session', pcs{i,3}, pcs{i,4});
    L = v2-v1;
    [statCell{i+1,6},statCell{i+1,3},statCell{i+1,4},statCell{i+1,5}] = coefTest(glme, L); 
    statCell{i+1,2} = L; 
    statCell{i+1,7} = min(1, statCell{i+1,6}*size(pcs,1)); % bonferroni correction
    if statCell{i+1,7} < .05
        sigstar({xpos(i,:)}, statCell{i+1,7})
    end
end
disp(statCell)
% writecell(statCell, ['stim_time_exploration_stats_' date '.csv']);
SetFigureDefaults()
% saveas(gcf, ['stim_time_exploration_' date], 'epsc')
% saveas(gcf, ['stim_time_exploration_' date], 'png')

end
