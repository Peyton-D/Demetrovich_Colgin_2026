%% script to generate figures 6-9 & S4 from paper
% PROVIDED FOR CODE TRANSPARENCY. WILL NOT RUN WITHOUT DATA STORED LOCALLY IN LOCATIONS DENOTED IN CELLSTRUCT!
keep cellStruct
projDir = 'D:/NeuropixelsData/';
cd(projDir)

%% get automated clustering for each day
for r=1:length(cellStruct.rat)
    fprintf('%s\n', cellStruct.rat(r).name)
    for c=1:length(cellStruct.rat(r).cond)
        for d=1:length(cellStruct.rat(r).cond(c).day)
            if (r==3 & c==5 & d==1) | (r==1 & c==4 & d==1) % bad noise/unusable DS on these days
                continue
            end
            fprintf('\t%s Day %d\n', cellStruct.rat(r).cond(c).name, d)
            cd(cellStruct.rat(r).cond(c).day(d).dataLoc);
            fprintf('\t\t%s\n', cellStruct.rat(r).cond(c).day(d).name)
            shankNums = cellStruct.rat(r).cond(c).day(d).shankNums;
            if numel(shankNums) > 1
                shankToUse = cellStruct.rat(r).cond(c).day(d).ds_shankInd;
            else
                shankToUse = 1;
            end
            
            for s = [2 4]
                try
                    cd([cellStruct.rat(r).cond(c).day(d).session(s).name '\' ...
                        cellStruct.rat(r).cond(c).day(d).session(s).name(7:end) '_imec0']) % one day does not have sleep 5  
                catch
                    continue;
                end
                prefix = 'LFP_all_corrected';
                files = dir([prefix, '*', '.mat']);
                if length(files) == 1
                    filename = files(1).name; % Get the first matching file
                    lfp = load(filename, 'lfpTs'); % Load the .mat file
                    disp(['Loaded file: ', filename]);
                elseif length(files) > 1 % if more than one file named 'LFP_all_corrected', load the most recent
                    dates = datetime.empty;
                    for f=1:length(files)
                        %                         dates{f} = files(f).date(1:11);
                        dates(f) = datetime(files(f).date(1:11), 'InputFormat', 'dd-MMM-yyyy');
                    end
                    [~, idx] = max(dates);
                    filename = files(idx).name;
                    lfp = load(filename, 'lfpTs');
                    %                     filename = uigetfile('*.mat');
                    %                     Lfp = load(filename);
                    disp(['Loaded file: ', filename]);
                else
                    disp('No matching files found.');
                end
                
                prefix = 'ds_alt_method_corrected_shank_auto';
                files = dir([prefix, '*', '.mat']);
                if length(files) == 1
                    filename = files(1).name; % Get the first matching file
                    load(filename); % Load the .mat file
                    disp(['Loaded file: ', filename]);
                elseif length(files) > 1 % if more than one file named 'LFP_all_corrected', load the most recent
                    dates = datetime.empty;
                    for f=1:length(files)
                        %                         dates{f} = files(f).date(1:11);
                        dates(f) = datetime(files(f).date(1:11), 'InputFormat', 'dd-MMM-yyyy');
                    end
                    [~, idx] = max(dates);
                    filename = files(idx).name;
                    load(filename)
                    %                     filename = uigetfile('*.mat');
                    %                     Lfp = load(filename);
                    disp(['Loaded file: ', filename]);

                else
                    disp('No matching files found.');
                end

               [ds1Cluster, ds2Cluster] = assignClusterType_v2(ds_cluster);
               save dsAutoClass.mat ds1Cluster ds2Cluster
               cd(cellStruct.rat(r).cond(c).day(d).dataLoc);
            end
        end
    end
end

%% using automated clustering of ds type
rmBinSz = 6;
ds1Ratemaps = cell(6,4); % condition by begin
ds1Rms = [];
ds2Ratemaps = cell(6,4);
ds2Rms = [];
ratID = {};
condID = {};
sessID = {};
dayID = [];
dsTypes = {'DS1', 'DS2'};
types = {};
zoneTypes = {'Stimulus', 'Reward', 'Neither'};
zones = {};
dsRates = [];
dsRates_noTheta = [];
dsRatemaps = cell(6,4);
dsRms = [];
dsRms_noTheta = [];
dsCounts_auto = [];
dsCounts_manual = [];
dsCounts_auto_noTheta = [];
dsCounts_manual_noTheta = [];
durs = [];
cd(projDir)

for r=1:length(cellStruct.rat) 
    fprintf('%s\n', cellStruct.rat(r).name)
    for c=1:length(cellStruct.rat(r).cond)
        for d=1:length(cellStruct.rat(r).cond(c).day)
            if (r==3 & c==5 & d==1) | (r==1 & c==4 & d==1) % bad noise/unusable DS on these days
                continue
            end

            fprintf('\t%s Day %d\n', cellStruct.rat(r).cond(c).name, d)
            cd(cellStruct.rat(r).cond(c).day(d).dataLoc);
            fprintf('\t\t%s\n', cellStruct.rat(r).cond(c).day(d).name)
            shankNums = cellStruct.rat(r).cond(c).day(d).shankNums;
            if numel(shankNums) > 1
                shankToUse = cellStruct.rat(r).cond(c).day(d).ds_shankInd;
            else
                shankToUse = 1;
            end

            for b = [2 4]
                try
                    cd([cellStruct.rat(r).cond(c).day(d).session(b).name '\' ...
                        cellStruct.rat(r).cond(c).day(d).session(b).name(7:end) '_imec0']) % one day does not have sleep 5  
                catch
                    continue;
                end
                
                % zone positions are different on these days
                if r==1 | (r==2 & d==2) | (r==2 & c==6 & b==2)
                    stimLoc = 180;
                    rewardLoc = 90;
                elseif r==2 & c==6 & b==4
                    stimLoc = 225;
                    rewardLoc = 180;
                elseif r==3 & c==6 & b==4
                    stimLoc = 300;
                    rewardLoc = 90;
                elseif r==4 & c==6 & b==4
                    stimLoc = 45;
                    rewardLoc = 270;
                elseif r==5 & c==6 & b==4
                    stimLoc = 135;
                    rewardLoc = 270;
                else
                    stimLoc = 225;
                    rewardLoc = 90;
                end

                stimLocs = round((stimLoc-45)/rmBinSz):round((stimLoc+45)/rmBinSz); % 90 degree region in bins around stimulus cage
                stimLocs(stimLocs == 0) = []; 
                rewardLocs = round((rewardLoc-45)/rmBinSz):round((rewardLoc+45)/rmBinSz); % 90 degree region around reward loction
                neitherLocs = setdiff(1:360/rmBinSz, [stimLocs rewardLocs]); % any bins not part of stimLocs or rewardLocs

                fprintf('\t\t\t%s\n', cellStruct.rat(r).cond(c).day(d).session(b).name)

                prefix = 'ds_alt_method_corrected_shank_auto';
                files = dir([prefix, '*', '.mat']);
                if length(files) == 1
                    filename = files(1).name; % Get the first matching file
                    load(filename); % Load the .mat file
                    disp(['Loaded file: ', filename]);
                elseif length(files) > 1 % if more than one file named 'LFP_all_corrected', load the most recent
                    dates = datetime.empty;
                    for f=1:length(files)
                        %                         dates{f} = files(f).date(1:11);
                        dates(f) = datetime(files(f).date(1:11), 'InputFormat', 'dd-MMM-yyyy');
                    end
                    [~, idx] = max(dates);
                    filename = files(idx).name;
                    load(filename)
                    %                     filename = uigetfile('*.mat');
                    %                     Lfp = load(filename);
                    disp(['Loaded file: ', filename]);

                else
                    disp('No matching files found.');
                end

                prefix = 'LFP_all_corrected';
                files = dir([prefix, '*', '.mat']);
                if length(files) == 1
                    filename = files(1).name; % Get the first matching file
                    Lfp = load(filename, 'lfpTs'); % Load the .mat file
                    disp(['Loaded file: ', filename]);
                elseif length(files) > 1 % if more than one file named 'LFP_all_corrected', load the most recent
                    dates = datetime.empty;
                    for f=1:length(files)
                        %                         dates{f} = files(f).date(1:11);
                        dates(f) = datetime(files(f).date(1:11), 'InputFormat', 'dd-MMM-yyyy');
                    end
                    [~, idx] = max(dates);
                    filename = files(idx).name;
                    Lfp = load(filename,'lfpTs');
                    %                     filename = uigetfile('*.mat');
                    %                     Lfp = load(filename);
                    disp(['Loaded file: ', filename]);

                else
                    disp('No matching files found.');
                end

                lfpTs = Lfp.lfpTs;
                
                % original classification method - "manual"
%                 ds1Times = lfpTs(ds1Ind);
%                 ds2Times = lfpTs(ds2Ind);

                %% remove dentate spikes that occurred during theta
                load('thetaIndices.mat')
                load('dsAutoClass.mat')
                ds1Ind_no_theta = ds1Ind; 
                for j=1:size(thetaInds,1)
                    mask = ds1Ind_no_theta >= thetaInds(j,1) & ds1Ind_no_theta <= thetaInds(j,3);
                    ds1Ind_no_theta(mask) = [];
                end

                ds2Ind_no_theta = ds2Ind; 
                for j=1:size(thetaInds,1)
                    mask = ds2Ind_no_theta >= thetaInds(j,1) & ds2Ind_no_theta <= thetaInds(j,3);
                    ds2Ind_no_theta(mask) = [];
                end
                
                
                %% accumulate data
                for ds = 1:2
                    switch ds
                        case 1
                            dsTimes = lfpTs(ds1Cluster.inds);
                            [dsMap,~, ~, ~] = get_ratemap_circtrack(dsTimes, ...
                                cellStruct.rat(r).cond(c).day(d).session(b).coords_2d, cellStruct.rat(r).cond(c).day(d).session(b).coords_1d, rmBinSz, -1, 0);
                            
                            % remove ds that occurred during theta epochs
                            ds1Cluster_no_theta = ds1Cluster.inds; 
                            for j=1:size(thetaInds,1)
                                mask = ds1Cluster_no_theta >= thetaInds(j,1) & ds1Cluster_no_theta <= thetaInds(j,3);
                                ds1Cluster_no_theta(mask) = [];
                            end

                            dsTimes_noTheta = lfpTs(ds1Cluster_no_theta);
                            [dsMap_noTheta,~, ~, ~] = get_ratemap_circtrack(dsTimes_noTheta, ...
                                cellStruct.rat(r).cond(c).day(d).session(b).coords_2d, cellStruct.rat(r).cond(c).day(d).session(b).coords_1d, rmBinSz, -1, 0);

                        case 2
                            dsTimes = lfpTs(ds2Cluster.inds);
                            [dsMap,~, ~, ~] = get_ratemap_circtrack(dsTimes, ...
                                cellStruct.rat(r).cond(c).day(d).session(b).coords_2d, cellStruct.rat(r).cond(c).day(d).session(b).coords_1d, rmBinSz, -1, 0);

                             % remove ds that occurred during theta epochs
                            ds2Cluster_no_theta = ds2Cluster.inds; 
                            for j=1:size(thetaInds,1)
                                mask = ds2Cluster_no_theta >= thetaInds(j,1) & ds2Cluster_no_theta <= thetaInds(j,3);
                                ds2Cluster_no_theta(mask) = [];
                            end

                            dsTimes_noTheta = lfpTs(ds2Cluster_no_theta);
                            [dsMap_noTheta,~, ~, ~] = get_ratemap_circtrack(dsTimes_noTheta, ...
                                cellStruct.rat(r).cond(c).day(d).session(b).coords_2d, cellStruct.rat(r).cond(c).day(d).session(b).coords_1d, rmBinSz, -1, 0);
                    end

                    smDsMap = smooth_circtrack_ratemap(dsMap, rmBinSz);
%                     dsRatemaps{c,b/2} = [dsRatemaps{c,b/2}; smDsMap];

                    smDsMap_noTheta = smooth_circtrack_ratemap(dsMap_noTheta, rmBinSz);
%                     dsRatemaps_noTheta{c,b/2} = [dsRatemaps{c,b/2}; smDsMap];
                    
                    for z = 1:3
                        switch z
                            case 1 % stim zone
                                dsRates = [dsRates; mean(smDsMap(stimLocs))];
                                dsRates_noTheta = [dsRates_noTheta; mean(smDsMap_noTheta(stimLocs))];

                                dsCounts_auto = [dsCounts_auto; numel(dsTimes)];
                                dsCounts_auto_noTheta = [dsCounts_auto_noTheta; numel(dsTimes_noTheta)];

                                if ds==1
                                   dsCounts_manual = [dsCounts_manual; numel(ds1Ind)];
                                   dsCounts_manual_noTheta = [dsCounts_manual_noTheta; numel(ds1Ind_no_theta)];
                                else
                                   dsCounts_manual = [dsCounts_manual; numel(ds2Ind)];
                                   dsCounts_manual_noTheta = [dsCounts_manual_noTheta; numel(ds2Ind_no_theta)];
                                end

                                zones = [zones; zoneTypes{z}];
                                types = [types; dsTypes{ds}];
                                ratID = [ratID; cellStruct.rat(r).name];
                                condID = [condID; cellStruct.rat(r).cond(c).name];
                                sessID = [sessID; cellStruct.rat(r).cond(c).day(d).session(b).name(7:12)];
                                dayID = [dayID; d];
                                dsRms = [dsRms; smDsMap];
                                dsRms_noTheta = [dsRms_noTheta; smDsMap_noTheta];
                                durs = [durs; lfpTs(end) - lfpTs(1)];
                                
                            case 2 % reward zone
                                dsRates = [dsRates; mean(smDsMap(rewardLocs))];
                                dsRates_noTheta = [dsRates_noTheta; mean(smDsMap_noTheta(rewardLocs))];

                                dsCounts_auto = [dsCounts_auto; numel(dsTimes)];
                                dsCounts_auto_noTheta = [dsCounts_auto_noTheta; numel(dsTimes_noTheta)];

                                if ds==1
                                   dsCounts_manual = [dsCounts_manual; numel(ds1Ind)];
                                   dsCounts_manual_noTheta = [dsCounts_manual_noTheta; numel(ds1Ind_no_theta)];
                                else
                                   dsCounts_manual = [dsCounts_manual; numel(ds2Ind)];
                                   dsCounts_manual_noTheta = [dsCounts_manual_noTheta; numel(ds2Ind_no_theta)];
                                end
                                
                                zones = [zones; zoneTypes{z}];
                                types = [types; dsTypes{ds}];
                                ratID = [ratID; cellStruct.rat(r).name];
                                condID = [condID; cellStruct.rat(r).cond(c).name];
                                sessID = [sessID; cellStruct.rat(r).cond(c).day(d).session(b).name(7:12)];
                                dayID = [dayID; d];
                                dsRms = [dsRms; smDsMap];
                                dsRms_noTheta = [dsRms_noTheta; smDsMap_noTheta];
                                durs = [durs; lfpTs(end) - lfpTs(1)];

                            case 3 % neither zone
                                dsRates = [dsRates; mean(smDsMap(neitherLocs))];
                                dsRates_noTheta = [dsRates_noTheta; mean(smDsMap_noTheta(neitherLocs))];

                                dsCounts_auto = [dsCounts_auto; numel(dsTimes)];
                                dsCounts_auto_noTheta = [dsCounts_auto_noTheta; numel(dsTimes_noTheta)];

                                if ds==1
                                   dsCounts_manual = [dsCounts_manual; numel(ds1Ind)];
                                   dsCounts_manual_noTheta = [dsCounts_manual_noTheta; numel(ds1Ind_no_theta)];
                                else
                                   dsCounts_manual = [dsCounts_manual; numel(ds2Ind)];
                                   dsCounts_manual_noTheta = [dsCounts_manual_noTheta; numel(ds2Ind_no_theta)];
                                end
                                
                               
                                zones = [zones; zoneTypes{z}];
                                types = [types; dsTypes{ds}];
                                ratID = [ratID; cellStruct.rat(r).name];
                                condID = [condID; cellStruct.rat(r).cond(c).name];
                                sessID = [sessID; cellStruct.rat(r).cond(c).day(d).session(b).name(7:12)];
                                dayID = [dayID; d];
                                dsRms = [dsRms; smDsMap];
                                dsRms_noTheta = [dsRms_noTheta; smDsMap_noTheta];
                                durs = [durs; lfpTs(end) - lfpTs(1)];
                        end
                    end
                end
               
                cd(cellStruct.rat(r).cond(c).day(d).dataLoc);
                clear ds_cluster ds1Cluster ds2Cluster
            end% session
        end % day
    end % cond
end % rat

%% create table
cd('D:\NeuropixelsData\revision')
tbl = table(ratID, condID, dayID, sessID, durs, zones, types, dsRates, dsRates_noTheta,...
    dsCounts_auto, dsCounts_auto_noTheta, dsCounts_manual, dsCounts_manual_noTheta, dsRms, dsRms_noTheta,...
    'VariableNames', {'Rat' 'Condition' 'Day' 'Session' 'SessDurations' 'ZoneType' 'DSType' 'DSRates'...
    'DSRates_noTheta' 'DSCounts_auto' 'DSCounts_auto_noTheta' 'DSCounts_manual' 'DSCounts_manual_noTheta' 'DSRatemaps' 'DSRatemaps_noTheta'} );

% remove noisy nonsocial odor day
pullDataInds = strcmp(tbl.Rat, 'Rat452') & strcmp(tbl.Condition, 'NonSocialOdor'); 
tbl(pullDataInds,:) = []; 

% remove noisy fox odor day
pullDataInds = strcmp(tbl.Rat, 'Rat501') & strcmp(tbl.Condition, 'FoxOdor'); 
tbl(pullDataInds,:) = []; 

% remove noisy day
pullDataInds = strcmp(tbl.Rat, 'Rat501') & strcmp(tbl.Condition, 'NovelRoom'); 
tbl(pullDataInds,:) = []; 

% remove noisy day
pullDataInds = strcmp(tbl.Rat, 'Rat503') & strcmp(tbl.Condition, 'Empty') & tbl.Day == 1 ; 
tbl(pullDataInds,:) = []; 

% remove noisy  day
pullDataInds = strcmp(tbl.Rat, 'Rat503') & strcmp(tbl.Condition, 'Social') & tbl.Day == 1; 
tbl(pullDataInds,:) = []; 

% remove noisy  day
pullDataInds = strcmp(tbl.Rat, 'Rat503') & strcmp(tbl.Condition, 'NonSocialOdor') & tbl.Day == 1; 
tbl(pullDataInds,:) = []; 

% remove noisy day
pullDataInds = strcmp(tbl.Rat, 'Rat503') & strcmp(tbl.Condition, 'NovelRoom'); 
tbl(pullDataInds,:) = []; 

% save('fullDSTable.mat', 'tbl')

% remove zone metrics
tbl = tbl(1:3:end,:); 

%% scatter lines
conditions = {'Empty' 'Social' 'SocialOdor' 'NonSocialOdor' 'FoxOdor' 'NovelRoom'};
conditionNames = {'Empty' 'Social' 'Social Odor' 'Nonsocial Odor' 'Fox Odor' 'Novel Room'};
metric = {'DS1' 'DS2'};
sessionNames = {'begin1', 'begin2'};
colsSpec = [
0.0, 0.45, 0.70;  % Blue
0.85, 0.37, 0.01; % Orange
0.93, 0.69, 0.13; % Yellow
0.0, 0.62, 0.45;  % Teal
0.80, 0.47, 0.74; % Purple
rgb('Tan')
];
figure; clf;
for p=1:length(metric)
        subplot(2,2,2+p),cla, hold on
        patch([nan,nan],[nan,nan], rgb('Grey'), 'DisplayName', 'Session A' )
        patch([nan,nan],[nan,nan], colsSpec(1,:), 'DisplayName', 'Session B' )
        legend
        legend autoupdate off
    for i = 1:6 % condition
        xPosForLines = [];
        condLines =[];
        for j = 1:length(sessionNames) % session

            % get data 
            pullDataInds = strcmp(tbl.Condition, conditions{i}) & strcmp(tbl.Session, sessionNames{j}) & strcmp(tbl.DSType, metric{p}) ; 
            data = tbl.DSCounts_auto_noTheta(pullDataInds,:) ./ tbl.SessDurations(pullDataInds,:); 
            
            % compute horizontal offset:
            if j==1
                xPos = i - .25;  
                scatter(repmat(xPos, numel(data),1), data, 20, [.5 .5 .5], 'filled')
            else
                xPos = i + .25;
                scatter(repmat(xPos, numel(data),1), data, 20, colsSpec(i,:), 'filled')
            end
            condLines = [condLines data];
            xPosForLines = [xPosForLines repmat(xPos, numel(data),1)];
        end
        plot(xPosForLines',condLines', ':k')
    end
    
    % Tidy up axes
    xticks(1:6);
    xticklabels(conditionNames);
    xlabel('Condition');
    switch p
        case 1
            ylabel('DS1 Rate (Hz)');
        case 2
             ylabel('DS2 Rate (Hz)');
    end
    ylim([0 .4])
end

%% session by condition by ds type Poisson glmm
tbl.Rat = categorical(tbl.Rat);
tbl.Condition = categorical(tbl.Condition);
tbl.Condition = reordercats(tbl.Condition, {'Empty' 'Social' 'SocialOdor' 'NonSocialOdor' 'FoxOdor' 'NovelRoom'});
tbl.Day = categorical(tbl.Day);
tbl.DSType = categorical(tbl.DSType);
tbl.Session = categorical(tbl.Session);

% fit full model
glme = fitglme(tbl, ...
        'DSCounts_auto_noTheta ~ Session*Condition*DSType + (1|Rat) + (1|Rat:Day)', ...
        'Distribution','Poisson','Link','log','DummyVarCoding','effects', ...
        'Offset',log(tbl.SessDurations));

anv = anova(glme)
% save(['DSCounts_auto_noTheta_glm_anova' date '.mat'], 'glme', 'anv')
% writetable(dataset2table(anv), 'DSCounts_auto_noTheta_glm_anova.csv')

% get intercept (grand mean + ci )
rowIdx = strcmp(glme.CoefficientNames, '(Intercept)');
beta0  = glme.Coefficients.Estimate(rowIdx);  % grand mean
se0    = glme.Coefficients.SE(rowIdx);
alpha = 0.05;
tval  = tinv(1 - alpha/2, glme.DFE);
ci = [beta0 - tval*se0, beta0 + tval*se0];
fprintf('Grand mean: %.4f [%.4f, %.4f]\n', beta0, ci(1), ci(2));

% isolate DS type models
for ds = 1:length(metric)
    pullDataInds = tbl.DSType == metric{ds};
    tbl_temp = tbl(pullDataInds,:);
    glme_temp = fitglme(tbl_temp, ...
        'DSCounts_auto_noTheta ~ Session*Condition + (1|Rat) + (1|Rat:Day)', ...
        'Distribution','Poisson','Link','log','DummyVarCoding','effects', ...
        'Offset',log(tbl_temp.SessDurations));
    anv_temp = anova(glme_temp)
%     save(['DSCounts_auto_noTheta_' metric{ds} '_glm_anova' date '.mat'], 'glme_temp', 'anv_temp')
%     writetable(dataset2table(anv), ['DSCounts_auto_noTheta_' metric{ds} '_glm_anova.csv'])

    % get marginal means
    % Example: grid of Condition × DSType
    [condGrid, sessGrid] = ndgrid(categories(tbl.Condition), ...
        categories(tbl.Session));

    % dummy Rat and Day from your dataset
    exampleRat = tbl.Rat(1);
    exampleDay = tbl.Day(1);

    % Build prediction table
    predTbl = table(categorical(condGrid(:)), categorical(sessGrid(:)), ...
        repmat(exampleRat, numel(condGrid), 1), ...
        repmat(exampleDay, numel(condGrid), 1), ...
        'VariableNames', {'Condition', 'Session', 'Rat', 'Day'});

    % Predict
    [meanVals, meanCI] = predict(glme_temp, predTbl, 'Conditional', false);
    predTbl.Mean = meanVals;
    predTbl.CI_Lower = meanCI(:,1);
    predTbl.CI_Upper = meanCI(:,2);
    disp(predTbl)

    xpos = [.75 1.25 1.75 2.25 2.75 3.25 3.75 4.25 4.75 5.25 5.75 6.25];
    pltOrder = [1 7 2 8 3 9 4 10 5 11 6 12];
    half = height(predTbl)/2;

    subplot(2,2,2+ds),hold on
    for i=pltOrder
        if mod(pltOrder(i),6) == 0
            if pltOrder(i) < 7
                plot([xpos(i),xpos(i)], [predTbl.CI_Lower(pltOrder(i)), predTbl.CI_Upper(pltOrder(i))], 'Color', [.5 .5 .5], 'LineWidth', 2)
            else
                plot([xpos(i),xpos(i)], [predTbl.CI_Lower(pltOrder(i)), predTbl.CI_Upper(pltOrder(i))], 'Color', colsSpec(6,:), 'LineWidth', 2)
            end
        else
            if pltOrder(i) < 7
                plot([xpos(i),xpos(i)], [predTbl.CI_Lower(pltOrder(i)), predTbl.CI_Upper(pltOrder(i))], 'Color', [.5 .5 .5], 'LineWidth', 2)
            else
                plot([xpos(i),xpos(i)], [predTbl.CI_Lower(pltOrder(i)), predTbl.CI_Upper(pltOrder(i))], 'Color', colsSpec(mod(pltOrder(i),6),:), 'LineWidth', 2)
            end
        end
    end

    ylabel([metric{ds} ' Rate (Hz)'])

    % if full interaction term is significant, perform planned comparisons
    if anv_temp.pValue(end) < 0.05
        xpos= [.75, 1.25;
            1.75, 2.25;
            2.75, 3.25;
            3.75, 4.25;
            4.75, 5.25;
            5.75, 6.25;];
        pcs = {'Empty' 'begin1' 'Empty' 'begin2';
            'Social' 'begin1' 'Social' 'begin2';
            'SocialOdor' 'begin1' 'SocialOdor' 'begin2';
            'NonSocialOdor' 'begin1' 'NonSocialOdor' 'begin2';
            'FoxOdor' 'begin1' 'FoxOdor' 'begin2';
            'NovelRoom' 'begin1' 'NovelRoom' 'begin2';
            };
        statCell = {'Comparison','contrast', 'F', 'df1', 'df2', 'p', 'p_BF'};

        for i=1:size(pcs,1)
            statCell{i+1,1} = [pcs{i,1} ':' pcs{i,2} ' vs '  pcs{i,3} ':' pcs{i,4}];
            %     L = makeContrast_auto(glme, pcs{i,1}, pcs{i,2}, pcs{i,3}, pcs{i,4});
            %             L = makeContrast_two_way(glme, 'Condition', 'DSType', pcs{i,1}, pcs{i,2}, pcs{i,3}, pcs{i,4});
            v1 = generateEffectVectorFromModel(glme_temp,'Condition' , 'Session', pcs{i,1}, pcs{i,2});
            v2 = generateEffectVectorFromModel(glme_temp,'Condition' , 'Session', pcs{i,3}, pcs{i,4});
            L = v2-v1;
            [statCell{i+1,6},statCell{i+1,3},statCell{i+1,4},statCell{i+1,5}] = coefTest(glme_temp, L);
            statCell{i+1,2} = L;
            statCell{i+1,7} = min(1, statCell{i+1,6}*size(pcs,1)); % bonferroni correction
            if statCell{i+1,7} < .05
                sigstar({xpos(i,:)}, statCell{i+1,7})
            end
        end
%         writecell(statCell, ['DSCounts_auto_noTheta_' metric{ds} '_comparisons' date '.csv'])
        %     disp(statCell)
    end
end

%% test for interaction between ethological odors (social and fox)
clear tbl
load('fullDSTable.mat')

% remove zone metrics
tbl = tbl(1:3:end,:); 

% only (?) way to assess magnitude of difference
pullDataInds = strcmp(tbl.DSType, 'DS1') & (strcmp(tbl.Condition, 'SocialOdor') | strcmp(tbl.Condition, 'FoxOdor'));

% pullDataInds = tbl.DSType == 'DS1' & (tbl.Condition == 'SocialOdor' | tbl.Condition == 'FoxOdor');

tbl_temp = tbl(pullDataInds,:);

tbl_temp.Rat = categorical(tbl_temp.Rat);
tbl_temp.Condition = categorical(tbl_temp.Condition);
% tbl_temp.Condition = removecats(tbl_temp.Condition);
tbl_temp.Day = categorical(tbl_temp.Day);
tbl_temp.DSType = categorical(tbl_temp.DSType);
tbl_temp.Session = categorical(tbl_temp.Session);
glme_temp = fitglme(tbl_temp, ...
    'DSCounts_auto_noTheta ~ Condition*Session + (1|Rat) + (1|Rat:Day)', ...
    'Distribution','Poisson','Link','log','DummyVarCoding','effects', ...
    'Offset',log(tbl_temp.SessDurations));
anv_temp = anova(glme_temp)
% save(['DSCounts_auto_noTheta_SOvsFO_DS1_glm_anova' date '.mat'], 'glme_temp', 'anv_temp')

%% plot average ds ratemaps
clear tbl
load('fullDSTable.mat')

% remove zone metrics
tbl = tbl(1:3:end,:); 

cntlColSpec = 'Grey'; 
colsSpec = [
0.0, 0.45, 0.70;  % Blue
0.85, 0.37, 0.01; % Orange
0.93, 0.69, 0.13; % Yellow
0.0, 0.62, 0.45;  % Teal
0.80, 0.47, 0.74; % Purple
rgb('Tan');
];
metric = {'DS1' 'DS2'};
conditions = {'Empty' 'Social' 'SocialOdor','NonSocialOdor', 'FoxOdor', 'NovelRoom'};
sessions = {'begin1', 'begin2'};

% these are the most common values for non-novel room days. rat 1 and day 2s of rat 2 are different
stimLoc = 225;
rewardLoc = 90;

for ds=1:2
    figure, clf
    for c=1:6
        subplot(2,3,c), hold on
        if c==1
            patch([nan,nan],[nan,nan], rgb(cntlColSpec), 'DisplayName', 'Session A' )
            patch([nan,nan],[nan,nan],  colsSpec(c,:), 'DisplayName', 'Session B' )
            xline((stimLoc-45)/rmBinSz, '--', 'color', colsSpec(c,:),'LineWidth', 2, 'DisplayName', 'Stimulus Zone')
            xline((rewardLoc-45)/rmBinSz, 'k--','LineWidth', 2, 'DisplayName', 'Reward Zone')
            legend autoupdate off
        else
            if c ~= 6
                xline((stimLoc-45)/rmBinSz, '--', 'color', colsSpec(c,:),'LineWidth', 2, 'DisplayName', 'Stimulus Zone');
                xline((rewardLoc-45)/rmBinSz, 'k--','LineWidth', 2, 'DisplayName', 'Reward Zone');
            end
        end

        if c ~= 6
            xline((stimLoc+45)/rmBinSz, '--', 'color',  colsSpec(c,:),'LineWidth', 2);
            xline((rewardLoc+45)/rmBinSz, 'k--','LineWidth', 2);
        end
    
        pullData = strcmp(tbl.Session, sessions{1}) & strcmp(tbl.Condition, conditions{c}) ...
            & strcmp(tbl.DSType, metric{ds});
        rms = tbl.DSRatemaps_noTheta(pullData,:);
        [~,err1] = error_fill_plot(1:size(rms,2), mean(rms), sem(rms),  cntlColSpec);
    
        pullData = strcmp(tbl.Session, sessions{2}) & strcmp(tbl.Condition, conditions{c}) ...
             & strcmp(tbl.DSType, metric{ds});
        rms = tbl.DSRatemaps_noTheta(pullData,:);
        [~,err2] = error_fill_plot2(1:size(rms,2), mean(rms), sem(rms),  colsSpec(c,:)); 
        xlabel('Position (bins)')
        ylabel([metric{ds} ' Rate (Hz)'])
        title(conditions{c})
        ylim([0 1])
        xlim([1 60])
    end
    sgtitle([metric{ds} ' Ratemaps, Sessions A & B'])
end
%%
clear tbl
load('fullDSTable.mat')

% remove DS2 
pullDataInds = strcmp(tbl.DSType, 'DS2'); 
tbl(pullDataInds,:) = [];

%% visualize groups
figure, clf
for j = 1:length(zoneTypes) % zone
    for i = 1:length(conditions)
        xPosForLines = [];
        condLines =[];
        for s=1:2 % session
            % get data
            pullDataInds = strcmp(string(tbl.Condition), conditions{i}) & strcmp(string(tbl.ZoneType), zoneTypes{j}) &...
                strcmp(string(tbl.Session), sessionNames{s}) & strcmp(string(tbl.DSType), 'DS1');
            tbl_temp = tbl(pullDataInds,:);
            data = tbl_temp.DSRates_noTheta;
            % compute horizontal offset:
            if s==1
                xPos = i - .25;
            else
                xPos = i + .25;
            end
            subplot(2,2,j), hold on
            if s==1
                scatter(repmat(xPos, numel(data),1), data, 20, [.5 .5 .5], 'filled', 'DisplayName', 'Session A')
            else
                scatter(repmat(xPos, numel(data),1), data, 20, colsSpec(i,:), 'filled', 'DisplayName', 'Session B')
                legend autoupdate off
                legend location southwest
            end
            condLines = [condLines data];
            xPosForLines = [xPosForLines repmat(xPos, numel(data),1)];
        end
        plot(xPosForLines',condLines', ':k')
    end
    % Tidy up axes
    xticks(1:length(conditions));
    xticklabels(conditionNames);
    ylabel('DS1 Rate (Hz)');
    title([zoneTypes{j} ' Zone'])
end

%% condition by session by zone type GLMM
tbl.Rat = categorical(tbl.Rat);
tbl.Condition = categorical(tbl.Condition);
tbl.Condition = reordercats(tbl.Condition, {'Empty' 'Social' 'SocialOdor' 'NonSocialOdor' 'FoxOdor' 'NovelRoom'});
tbl.Day = categorical(tbl.Day);
tbl.DSType = categorical(tbl.DSType);
tbl.ZoneType = categorical(tbl.ZoneType);
tbl.ZoneType = reordercats(tbl.ZoneType, {'Stimulus' 'Reward' 'Neither'}); 
tbl.Session = categorical(tbl.Session);

glme = fitglme(tbl,'DSRates_noTheta ~ Session * Condition  * ZoneType + (1|Rat) + (1|Rat:Day)',  'DummyVarCoding', 'effects');
anv = anova(glme)
% save(['DS1_zoneRates_no_theta_glme_anova' date '.mat'], 'glme', 'anv')

% isolate zone
for z = 1:length(zoneTypes)
    fprintf('%s Zone\n', zoneTypes{z})
    pullDataInds = tbl.ZoneType == zoneTypes{z};
    tbl_temp = tbl(pullDataInds,:);
    glme_temp = fitglme(tbl_temp,'DSRates_noTheta ~ Session * Condition  + (1|Rat) + (1|Rat:Day)',  'DummyVarCoding', 'effects');
    anv_temp = anova(glme_temp)
%     save(['DS1_' zoneTypes{z} '_Rates_noTheta__glm_anova' date '.mat'], 'glme_temp', 'anv_temp')

    % get marginal means
    % Example: grid of Condition × DSType
    [condGrid, sessGrid] = ndgrid(categories(tbl.Condition), ...
        categories(tbl.Session));
    
    % dummy Rat and Day from your dataset
    exampleRat = tbl.Rat(1);
    exampleDay = tbl.Day(1);
    
    % Build prediction table
    predTbl = table(categorical(condGrid(:)), categorical(sessGrid(:)), ...
        repmat(exampleRat, numel(condGrid), 1), ...
        repmat(exampleDay, numel(condGrid), 1), ...
        'VariableNames', {'Condition', 'Session', 'Rat', 'Day'});
    
    % Predict
    [meanVals, meanCI] = predict(glme_temp, predTbl, 'Conditional', false);
    predTbl.Mean = meanVals;
    predTbl.CI_Lower = meanCI(:,1);
    predTbl.CI_Upper = meanCI(:,2);
    disp(predTbl)
    
    xpos = [.75 1.25 1.75 2.25 2.75 3.25 3.75 4.25 4.75 5.25 5.75 6.25];
    pltOrder = [1 7 2 8 3 9 4 10 5 11 6 12];
    half = height(predTbl)/2;
    
    subplot(2,2,z), hold on
    for i=pltOrder
        if mod(pltOrder(i),6) == 0
            if pltOrder(i) < 7
                plot([xpos(i),xpos(i)], [predTbl.CI_Lower(pltOrder(i)), predTbl.CI_Upper(pltOrder(i))], 'Color', [.5 .5 .5], 'LineWidth', 2)
            else
                plot([xpos(i),xpos(i)], [predTbl.CI_Lower(pltOrder(i)), predTbl.CI_Upper(pltOrder(i))], 'Color', colsSpec(6,:), 'LineWidth', 2)
            end
        else
            if pltOrder(i) < 7
                plot([xpos(i),xpos(i)], [predTbl.CI_Lower(pltOrder(i)), predTbl.CI_Upper(pltOrder(i))], 'Color', [.5 .5 .5], 'LineWidth', 2)
            else
                plot([xpos(i),xpos(i)], [predTbl.CI_Lower(pltOrder(i)), predTbl.CI_Upper(pltOrder(i))], 'Color', colsSpec(mod(pltOrder(i),6),:), 'LineWidth', 2)
            end
        end
    end
    
     if anv_temp.pValue(end) < 0.05
         xpos= [.75, 1.25;
               1.75, 2.25;
               2.75, 3.25;
               3.75, 4.25;
               4.75, 5.25;
               5.75, 6.25;];
        
         pcs = {'Empty' 'begin1' 'Empty' 'begin2';
               'Social' 'begin1' 'Social' 'begin2';
               'SocialOdor' 'begin1' 'SocialOdor' 'begin2';
               'NonSocialOdor' 'begin1' 'NonSocialOdor' 'begin2';
               'FoxOdor' 'begin1' 'FoxOdor' 'begin2';
               'NovelRoom' 'begin1' 'NovelRoom' 'begin2';};
    
        statCell = {'Comparison','contrast', 'F', 'df1', 'df2', 'p', 'p_BF'};
        
        for i=1:size(pcs,1)
            statCell{i+1,1} = [pcs{i,1} ':' pcs{i,2} ' vs '  pcs{i,3} ':' pcs{i,4}];
            v1 = generateEffectVectorFromModel(glme_temp,'Condition' , 'Session', pcs{i,1}, pcs{i,2});
            v2 = generateEffectVectorFromModel(glme_temp,'Condition' , 'Session', pcs{i,3}, pcs{i,4});
            L = v2-v1;
            [statCell{i+1,6},statCell{i+1,3},statCell{i+1,4},statCell{i+1,5}] = coefTest(glme_temp, L); 
            statCell{i+1,2} = L; 
            statCell{i+1,7} = min(1, statCell{i+1,6}*size(pcs,1)); % bonferroni correction
            if statCell{i+1,7} < .05
                sigstar({xpos(i,:)}, statCell{i+1,7})
            end
        end
%         writecell(statCell, ['DS1_' zoneTypes{z} '_Rates_noTheta_comparisons' date '.csv'])
%         disp(statCell)
     end
end
%% construct PETHs
keep cellStruct
bin_size = 0.01; %bin_size = 0.01;
fullWindow = [-0.1, 0.1]; % fullWindow = [-0.1, 0.1]; % peri-event window in seconds
baseWindow = [-0.1, -0.06]; % baseWindow = [-0.1, -0.05]; % peri-event window in seconds
roiWindow = [-0.02, 0.02]; % roiWindow = [-0.025, 0.025]; % peri-event window in seconds
edges = fullWindow(1):bin_size:fullWindow(2);
bin_centers = edges(1:end-1) + bin_size/2;
[~, zero_idx] = min(abs(bin_centers));

ratID = {};
condID = {};
sessID = {};
dayID = [];
peths = {};
frMods = {};
dsTypes = {'DS1' 'DS2'};
types = {}; 

for r=1:length(cellStruct.rat)
    fprintf('%s\n', cellStruct.rat(r).name)
    for c=1:length(cellStruct.rat(r).cond)
        for d=1:length(cellStruct.rat(r).cond(c).day)
            if (r==3 & c==5 & d==1) | (r==1 & c==4 & d==1) % bad noise/unusable DS on these days
                continue
            end
            fprintf('\t%s Day %d\n', cellStruct.rat(r).cond(c).name, d)
            cd(cellStruct.rat(r).cond(c).day(d).dataLoc);
            fprintf('\t\t%s\n', cellStruct.rat(r).cond(c).day(d).name)
            shankNums = cellStruct.rat(r).cond(c).day(d).shankNums;
            if numel(shankNums) > 1
                shankToUse = cellStruct.rat(r).cond(c).day(d).ds_shankInd;
            else
                shankToUse = 1;
            end
            
            goodU = cellStruct.rat(r).cond(c).day(d).dgPcU; 

            for s =[2,4]
                try
                    cd([cellStruct.rat(r).cond(c).day(d).session(s).name '\' ...
                        cellStruct.rat(r).cond(c).day(d).session(s).name(7:end) '_imec0']) % one day does not have sleep 5  
                catch
                    continue;
                end
                prefix = 'LFP_all_corrected';
                files = dir([prefix, '*', '.mat']);
                if length(files) == 1
                    filename = files(1).name; % Get the first matching file
                    lfp = load(filename, 'lfpTs'); % Load the .mat file
                    disp(['Loaded file: ', filename]);
                elseif length(files) > 1 % if more than one file named 'LFP_all_corrected', load the most recent
                    dates = datetime.empty;
                    for f=1:length(files)
                        %                         dates{f} = files(f).date(1:11);
                        dates(f) = datetime(files(f).date(1:11), 'InputFormat', 'dd-MMM-yyyy');
                    end
                    [~, idx] = max(dates);
                    filename = files(idx).name;
                    lfp = load(filename, 'lfpTs');
                    %                     filename = uigetfile('*.mat');
                    %                     Lfp = load(filename);
                    disp(['Loaded file: ', filename]);
                else
                    disp('No matching files found.');
                end
                
                prefix = 'ds_alt_method_corrected_shank_auto';
                files = dir([prefix, '*', '.mat']);
                if length(files) == 1
                    filename = files(1).name; % Get the first matching file
                    load(filename); % Load the .mat file
                    disp(['Loaded file: ', filename]);
                elseif length(files) > 1 % if more than one file named 'LFP_all_corrected', load the most recent
                    dates = datetime.empty;
                    for f=1:length(files)
                        %                         dates{f} = files(f).date(1:11);
                        dates(f) = datetime(files(f).date(1:11), 'InputFormat', 'dd-MMM-yyyy');
                    end
                    [~, idx] = max(dates);
                    filename = files(idx).name;
                    load(filename)
                    %                     filename = uigetfile('*.mat');
                    %                     Lfp = load(filename);
                    disp(['Loaded file: ', filename]);

                else
                    disp('No matching files found.');
                end

               load('dsAutoClass.mat')
               load('thetaIndices.mat')
               % remove ds that occurred during theta epochs
               ds1Cluster_no_theta = ds1Cluster.inds;
               for j=1:size(thetaInds,1)
                   mask = ds1Cluster_no_theta >= thetaInds(j,1) & ds1Cluster_no_theta <= thetaInds(j,3);
                   ds1Cluster_no_theta(mask) = [];
               end

               ds2Cluster_no_theta = ds2Cluster.inds;
               for j=1:size(thetaInds,1)
                   mask = ds2Cluster_no_theta >= thetaInds(j,1) & ds2Cluster_no_theta <= thetaInds(j,3);
                   ds2Cluster_no_theta(mask) = [];
               end

                for ds=1:2
                    if ds==1
                        [temp_peth, temp_frMod, ~] = compute_and_plot_peths_v2({cellStruct.rat(r).cond(c).day(d).session(s).uID(goodU).spkTms}',...
                            lfp.lfpTs(ds1Cluster_no_theta), fullWindow, baseWindow, roiWindow, bin_size);
                    else
                        [temp_peth, temp_frMod, ~] = compute_and_plot_peths_v2({cellStruct.rat(r).cond(c).day(d).session(s).uID(goodU).spkTms}',...
                            lfp.lfpTs(ds2Cluster_no_theta), fullWindow, baseWindow, roiWindow, bin_size);
                    end
                    
                    if isempty(temp_peth)
                        peths = [peths; nan];
                        frMods = [frMods; nan]; 
                    else
                        peths = [peths; temp_peth];
                        frMods = [frMods; temp_frMod]; 
                    end
                    ratID = [ratID; cellStruct.rat(r).name];
                    condID = [condID; cellStruct.rat(r).cond(c).name];
                    sessID = [sessID; cellStruct.rat(r).cond(c).day(d).session(s).name(7:12)];
                    dayID = [dayID; d];
                    types = [types; dsTypes{ds}];

                end
                cd ..
                cd ..
            end % session
            
        end % day
    end % condition
    cd ..
end % rat

cd('D:\NeuropixelsData\revision')

tbl = table(ratID, condID, dayID, sessID, types, peths, frMods, 'VariableNames', ...
    {'Rat' 'Condition' 'Day' 'Session' 'DSType' 'PETH' 'FrMod' } );

% remove noisy nonsocial odor day
pullDataInds = strcmp(tbl.Rat, 'Rat452') & strcmp(tbl.Condition, 'NonSocialOdor'); 
tbl(pullDataInds,:) = []; 

% remove noisy fox odor day
pullDataInds = strcmp(tbl.Rat, 'Rat501') & strcmp(tbl.Condition, 'FoxOdor'); 
tbl(pullDataInds,:) = []; 

% remove noisy day
pullDataInds = strcmp(tbl.Rat, 'Rat501') & strcmp(tbl.Condition, 'NovelRoom'); 
tbl(pullDataInds,:) = []; 

% remove noisy day
pullDataInds = strcmp(tbl.Rat, 'Rat503') & strcmp(tbl.Condition, 'Empty') & tbl.Day == 1 ; 
tbl(pullDataInds,:) = []; 

% remove noisy  day
pullDataInds = strcmp(tbl.Rat, 'Rat503') & strcmp(tbl.Condition, 'Social') & tbl.Day == 1; 
tbl(pullDataInds,:) = []; 

% remove noisy  day
pullDataInds = strcmp(tbl.Rat, 'Rat503') & strcmp(tbl.Condition, 'NonSocialOdor') & tbl.Day == 1; 
tbl(pullDataInds,:) = []; 

% remove noisy day
pullDataInds = strcmp(tbl.Rat, 'Rat503') & strcmp(tbl.Condition, 'NovelRoom'); 
tbl(pullDataInds,:) = []; 

% save('FullFrModTable.mat', 'tbl')
%% plot PETHs
conditions = {'Empty' 'Social' 'SocialOdor' 'NonSocialOdor' 'FoxOdor' 'NovelRoom'};
conditionNames = {'Empty' 'Social' 'Social Odor' 'Nonsocial Odor' 'Fox Odor' 'Novel Room'};
sessions = {'begin1', 'begin2'};
sessionNames = {'A', 'B'}; 
colsSpec = [
            0.0, 0.45, 0.70;  % Blue
            0.85, 0.37, 0.01; % Orange
            0.93, 0.69, 0.13; % Yellow
            0.0, 0.62, 0.45;  % Teal
            0.80, 0.47, 0.74; % Purple
            rgb('Tan');
            ];

% scaled within session
for ds = 1:2
    figure,clf
    pltCntr = 1;
    for c=1:6
        pullDataInds = strcmp(tbl.DSType, dsTypes{ds}) & strcmp(tbl.Condition, conditions{c});
        type_cond_data = tbl(pullDataInds,:);
        for s=1:2
            % get peths of interest
            pullDataInds = strcmp(type_cond_data.Session, sessions{s});
            type_cond_sess_data = type_cond_data(pullDataInds,:);
            tmp_peths = type_cond_sess_data.PETH;

            % remove nans (e.g., 0 cells for a given day)
            idx = cellfun(@(x) isnumeric(x) && any(isnan(x(:))), tmp_peths);
            tmp_peths(idx) = [];

            % concatenate
            tmp_peths = cat(1,tmp_peths{:});

            % min max scale
            tmp_peths_scale = tmp_peths ./ max(tmp_peths,[],2);

            % sort by time = 0 in A/begin1
            if s == 1
                [~,sortInds] = sort(tmp_peths(:,zero_idx),'descend');
            end

            % plot
            subplot(3,4,pltCntr)
            imagesc(bin_centers, 1:size(tmp_peths_scale,1), tmp_peths_scale(sortInds,:))
%             imagesc(bin_centers, 1:size(tmp_peths,1), tmp_peths(sortInds,:))
            xlabel(['Time from ' dsTypes{ds}  ' peak (s)'])
            if s==1
                ylabel({conditionNames{c};'Cell ID'})
            end
%             xline(baseWindow,'w--','LineWidth',2)
%             xline(roiWindow,'r--','LineWidth',2)
%             caxis([0 10])
%             colorbar
            title(sessionNames{s})
            pltCntr=pltCntr+1;
        end
    end
    sgtitle([dsTypes{ds} ' Firing Rate Modulation'])
    clbr = colorbar;
    clbr.Position = [0.91    0.11    0.0100    0.20];
    ylabel(clbr, 'Normalized Firing Rate')
end

% scaled across sessions
for ds = 1:2
    figure,clf
    pltCntr = 1;
    for c=1:6
        pullDataInds = strcmp(tbl.DSType, dsTypes{ds}) & strcmp(tbl.Condition, conditions{c});
        type_cond_data = tbl(pullDataInds,:);
        temp_pethsAB = [];
        for s=1:2
            % get peths of interest
            pullDataInds = strcmp(type_cond_data.Session, sessions{s});
            type_cond_sess_data = type_cond_data(pullDataInds,:);
            tmp_peths = type_cond_sess_data.PETH;

            % remove nans (e.g., 0 cells for a given day)
            idx = cellfun(@(x) isnumeric(x) && any(isnan(x(:))), tmp_peths);
            tmp_peths(idx) = [];

            % concatenate
            tmp_peths = cat(1,tmp_peths{:});
            temp_pethsAB = cat(2, temp_pethsAB, tmp_peths);
        end
        % min max scale
%             tmp_peths_scale = tmp_peths ./ max(tmp_peths,[],2);
        temp_pethsAB_scale = temp_pethsAB ./ max(temp_pethsAB,[],2);
        % sort by time = 0 in A/begin1
%         if s == 1
            [~,sortInds] = sort(temp_pethsAB_scale(:,zero_idx),'descend');
%         end

        % plot
        subplot(3,4,pltCntr)
%             imagesc(bin_centers, 1:size(tmp_peths_scale,1), tmp_peths_scale(sortInds,:))
        imagesc(bin_centers, 1:size(temp_pethsAB_scale,1), temp_pethsAB_scale(sortInds,1:20))
%             imagesc(bin_centers, 1:size(tmp_peths,1), tmp_peths(sortInds,:))
        xlabel(['Time from ' dsTypes{ds}  ' peak (s)'])
        if s==1
            ylabel({conditionNames{c};'Cell ID'})
        end
        xline(baseWindow,'w--','LineWidth',2)
        xline(roiWindow,'r--','LineWidth',2)
%             caxis([0 10])
            colorbar
        title('A')
        pltCntr=pltCntr+1;

         subplot(3,4,pltCntr)
%             imagesc(bin_centers, 1:size(tmp_peths_scale,1), tmp_peths_scale(sortInds,:))
        imagesc(bin_centers, 1:size(temp_pethsAB_scale,1), temp_pethsAB_scale(sortInds,21:40))
%             imagesc(bin_centers, 1:size(tmp_peths,1), tmp_peths(sortInds,:))
        xlabel(['Time from ' dsTypes{ds}  ' peak (s)'])
        if s==1
            ylabel({conditionNames{c};'Cell ID'})
        end
        xline(baseWindow,'w--','LineWidth',2)
        xline(roiWindow,'r--','LineWidth',2)
%             caxis([0 10])
            colorbar
        title('B')
        pltCntr=pltCntr+1;
    end
    sgtitle([dsTypes{ds} ' Firing Rate Modulation'])
end

% average peths
for ds = 1:2
    figure, clf
    pltCntr = 1;
    for c=1:6
        pullDataInds = strcmp(tbl.DSType, dsTypes{ds}) & strcmp(tbl.Condition, conditions{c});
        type_cond_data = tbl(pullDataInds,:);
        for s=1:2
            % get peths of interest
            pullDataInds = strcmp(type_cond_data.Session, sessions{s});
            type_cond_sess_data = type_cond_data(pullDataInds,:);
            tmp_peths = type_cond_sess_data.PETH;
    
            % remove nans (e.g., 0 cells for a given day)
            idx = cellfun(@(x) isnumeric(x) && any(isnan(x(:))), tmp_peths);
            tmp_peths(idx) = [];
    
            % concatenate
            tmp_peths = cat(1,tmp_peths{:});

            % min max scale
            tmp_peths_scale = tmp_peths ./ max(tmp_peths,[],2);
    
            % plot
            subplot(2,3,c), hold on
            if c==1
                patch([nan,nan],[nan,nan], [0.5 0.5 0.5], 'DisplayName', 'A')
                patch([nan,nan],[nan,nan], colsSpec(1,:), 'DisplayName', 'B')
                legend autoupdate off
            end
            if s == 1
                [~,err1] = error_fill_plot2(bin_centers, nanmean(tmp_peths,1), semfunct(tmp_peths,1),  [0.5 0.5 0.5]);
%                 [~,err1] = error_fill_plot2(bin_centers, nanmean(tmp_peths_scale,1), semfunct(tmp_peths_scale,1),  [0.5 0.5 0.5]);
            else
                [~,err2] = error_fill_plot2(bin_centers, nanmean(tmp_peths,1), semfunct(tmp_peths,1),  colsSpec(c,:));
%                 [~,err2] = error_fill_plot2(bin_centers, nanmean(tmp_peths_scale,1), semfunct(tmp_peths_scale,1),  colsSpec(c,:));
            end
            xlabel(['Time from ' dsTypes{ds}  ' peak (s)'])
            ylabel('Firing Rate (Hz)')
            %         xlim([-.05 .05])
        end
        title(conditionNames{c})
    end
    sgtitle([dsTypes{ds} ' Firing Rate Modulation'])
end

%% expand peth table to get per cell modulation metrics in long format
tbl.Rat = categorical(tbl.Rat);
tbl.Session = categorical(tbl.Session);
tbl.Day = categorical(tbl.Day);
tbl.Condition = categorical(tbl.Condition);
tbl.DSType = categorical(tbl.DSType); 

idx = cellfun(@(x) isnumeric(x) && any(isnan(x(:))), tbl.PETH);
tbl(idx,:) = [];

% expand table to a cell per row - NEED CELL VARIABLE FOR NESTING!
newFrMods = vertcat(tbl.FrMod{:});

newID = arrayfun(@(i) repmat(tbl.Rat(i), numel(tbl.FrMod{i}), 1), ...
                 (1:height(tbl))', 'UniformOutput', false);
newRatID = vertcat(newID{:});

newID = arrayfun(@(i) repmat(tbl.Condition(i), numel(tbl.FrMod{i}), 1), ...
                 (1:height(tbl))', 'UniformOutput', false);
newCondID = vertcat(newID{:});

newID = arrayfun(@(i) repmat(tbl.Session(i), numel(tbl.FrMod{i}), 1), ...
                 (1:height(tbl))', 'UniformOutput', false);
newSessionID = vertcat(newID{:});

newID = arrayfun(@(i) repmat(tbl.Day(i), numel(tbl.FrMod{i}), 1), ...
                 (1:height(tbl))', 'UniformOutput', false);
newDayID = vertcat(newID{:});

newID = arrayfun(@(i) repmat(tbl.DSType(i), numel(tbl.FrMod{i}), 1), ...
                 (1:height(tbl))', 'UniformOutput', false);
newTypeID = vertcat(newID{:});

newID = arrayfun(@(i) repmat(numel(tbl.FrMod{i}), numel(tbl.FrMod{i}), 1), ...
                 (1:height(tbl))', 'UniformOutput', false);
newCellID = vertcat(newID{:});

tbl2 = table(newRatID, newCondID, newDayID, newSessionID, newTypeID, newFrMods, 'VariableNames', ...
    {'Rat' 'Condition' 'Day' 'Session' 'DSType' 'FrMod' } );

tbl_a = tbl2(tbl2.DSType == 'DS1' & tbl2.Session == 'begin1',:);
tbl_b = tbl2(tbl2.DSType == 'DS1' & tbl2.Session == 'begin2',:);
tbl_c = tbl2(tbl2.DSType == 'DS2' & tbl2.Session == 'begin1',:);
tbl_d = tbl2(tbl2.DSType == 'DS2' & tbl2.Session == 'begin2',:);
tbl4 = [tbl_a; tbl_b; tbl_c; tbl_d];
cellIds = (1:height(tbl_a))';
tbl4.Cell = repmat(cellIds,4,1);
%% scatter lines
conditions = {'Empty' 'Social' 'SocialOdor' 'NonSocialOdor' 'FoxOdor' 'NovelRoom'};
conditionNames = {'Empty' 'Social' 'Social Odor' 'Nonsocial Odor' 'Fox Odor' 'Novel Room'};
metric = {'DS1' 'DS2'};
sessionNames = {'begin1', 'begin2'};
colsSpec = [
0.0, 0.45, 0.70;  % Blue
0.85, 0.37, 0.01; % Orange
0.93, 0.69, 0.13; % Yellow
0.0, 0.62, 0.45;  % Teal
0.80, 0.47, 0.74; % Purple
rgb('Tan')
];
figure; clf; hold on; 
for p=1:length(metric)
    subplot(2,2,2+p),cla, hold on
    patch([nan,nan],[nan,nan], rgb('Grey'), 'DisplayName', 'Session A' )
    patch([nan,nan],[nan,nan], colsSpec(1,:), 'DisplayName', 'Session B' )
    legend
    legend autoupdate off
    for i = 1:6 % condition
        xPosForLines = [];
        condLines =[];
        for j = 1:length(sessionNames) % session

            % get data
            pullDataInds = tbl4.Condition == conditions{i} & tbl4.Session == sessionNames{j} & tbl4.DSType == metric{p} ;
            data = tbl4.FrMod(pullDataInds);

            % compute horizontal offset:
            if j==1
                xPos = i - .25;
                scatter(repmat(xPos, numel(data),1), data, 20, [.5 .5 .5], 'filled')
            else
                xPos = i + .25;
                scatter(repmat(xPos, numel(data),1), data, 20, colsSpec(i,:), 'filled')
            end
            condLines = [condLines data];
            xPosForLines = [xPosForLines repmat(xPos, numel(data),1)];
        end
        plot(xPosForLines',condLines', ':k')
%         myLabels{i} = [conditionNames{i} ' n = ' num2str(numel(data))];
    end

    % Tidy up axes
    xticks(1:6);
    xticklabels(conditionNames);
    xlabel('Condition');
    switch p
        case 1
            ylabel({'DS1 \DeltaFiring Rate'; '(peak - baseline)'});
        case 2
            ylabel({'DS2 \DeltaFiring Rate'; '(peak - baseline)'});
    end
    ylim([-20 20])
end

%% compare DS1 vs DS2 peth A only combining across conditions 
figure; subplot(2,2,1), cla; hold on, 
for p=1:length(metric)
    % get data
    pullDataInds = tbl4.Session == sessionNames{1} & tbl4.DSType == metric{p} ;

    data = tbl4.FrMod(pullDataInds);

    % compute horizontal offset:
    xPos = p;
    if p ==1
        swarmchart(repmat(xPos, numel(data),1), data, 20, rgb('Coral'), 'filled', 'DisplayName', 'DS1')
    else
        swarmchart(repmat(xPos, numel(data),1), data, 20, rgb('Amethyst'), 'filled', 'DisplayName', 'DS2')
    end
    plot(xPos, mean(data), 'xk', 'MarkerSize', 10, 'LineWidth', 2)
end
% legend()
ylabel({'\DeltaFiring Rate'; '(peak - baseline)'});
xticks([1,2])
xticklabels({'DS1', 'DS2'})
title('All conditions'' session A combined')

pullDataInds = tbl4.Session == sessionNames{1};
tbl5 = tbl4(pullDataInds,:);
glme = fitglme(tbl5,'FrMod ~ DSType + (1|Rat) + (1|Rat:Day) + (1|Rat:Cell)', 'DummyVarCoding', 'effects');
anv = anova(glme)
% save(['frMod_sessA_model_glm_anova' date '.mat'], 'glme', 'anv')
%% condition by session by DS type peth GLMM
tbl4.Rat = categorical(tbl4.Rat);
tbl4.Session = categorical(tbl4.Session);
tbl4.Day = categorical(tbl4.Day);
tbl4.Condition = categorical(tbl4.Condition);
tbl4.Condition = reordercats(tbl4.Condition, {'Empty' 'Social' 'SocialOdor' 'NonSocialOdor' 'FoxOdor' 'NovelRoom'});
tbl4.DSType = categorical(tbl4.DSType); 
tbl4.Cell = categorical(tbl4.Cell);

% fit full model
glme = fitglme(tbl4,'FrMod ~ Condition*Session*DSType + (1|Rat) + (1|Rat:Day) + (1|Rat:Cell)', 'DummyVarCoding', 'effects');
anv = anova(glme)
% save(['frMod_full_model_glm_anova' date '.mat'], 'glme', 'anv')

rowIdx = strcmp(glme.CoefficientNames, '(Intercept)');
beta0  = glme.Coefficients.Estimate(rowIdx);  % grand mean
se0    = glme.Coefficients.SE(rowIdx);

alpha = 0.05;
tval  = tinv(1 - alpha/2, glme.DFE);
ci = [beta0 - tval*se0, beta0 + tval*se0];

fprintf('Grand mean: %.4f [%.4f, %.4f]\n', beta0, ci(1), ci(2));

metric = {'DS1' 'DS2'};
% isolate DS type for reduced models
for ds = 1:length(metric)
    pullDataInds = tbl4.DSType == metric{ds};
    tbl_temp = tbl4(pullDataInds,:);
    glme_temp = fitglme(tbl_temp,'FrMod ~ Condition*Session + (1|Rat) + (1|Rat:Day) + (1|Rat:Cell)', 'DummyVarCoding', 'effects');
    anv_temp = anova(glme_temp)
%     save([metric{ds} '_isolated_frMod_glm_anova' date '.mat'], 'glme_temp', 'anv_temp')

    % get marginal means
    % Example: grid of Condition × DSType
    [condGrid, sessGrid] = ndgrid(categories(tbl_temp.Condition), ...
        categories(tbl_temp.Session));

    % dummy Rat and Day from your dataset
    exampleRat = tbl_temp.Rat(1);
    exampleDay = tbl_temp.Day(1);
    exampleCell = tbl_temp.Cell(1);

    % Build prediction table
    predTbl = table(categorical(condGrid(:)), categorical(sessGrid(:)), ...
        repmat(exampleRat, numel(condGrid), 1), ...
        repmat(exampleDay, numel(condGrid), 1), ...
        repmat(exampleCell, numel(condGrid), 1), ...
        'VariableNames', {'Condition', 'Session', 'Rat', 'Day', 'Cell'});

    % Predict
    [meanVals, meanCI] = predict(glme_temp, predTbl, 'Conditional', false);
    predTbl.Mean = meanVals;
    predTbl.CI_Lower = meanCI(:,1);
    predTbl.CI_Upper = meanCI(:,2);
    disp(predTbl)

    xpos = [.75 1.25 1.75 2.25 2.75 3.25 3.75 4.25 4.75 5.25 5.75 6.25];
    pltOrder = [1 7 2 8 3 9 4 10 5 11 6 12];
    half = height(predTbl)/2;

    subplot(2,2,2+ds),hold on
    for i=pltOrder
        if mod(pltOrder(i),6) == 0
            if pltOrder(i) < 7
                plot([xpos(i),xpos(i)], [predTbl.CI_Lower(pltOrder(i)), predTbl.CI_Upper(pltOrder(i))], 'Color', [.5 .5 .5], 'LineWidth', 2)
            else
                plot([xpos(i),xpos(i)], [predTbl.CI_Lower(pltOrder(i)), predTbl.CI_Upper(pltOrder(i))], 'Color', colsSpec(6,:), 'LineWidth', 2)
            end
        else
            if pltOrder(i) < 7
                plot([xpos(i),xpos(i)], [predTbl.CI_Lower(pltOrder(i)), predTbl.CI_Upper(pltOrder(i))], 'Color', [.5 .5 .5], 'LineWidth', 2)
            else
                plot([xpos(i),xpos(i)], [predTbl.CI_Lower(pltOrder(i)), predTbl.CI_Upper(pltOrder(i))], 'Color', colsSpec(mod(pltOrder(i),6),:), 'LineWidth', 2)
            end
        end

    end

    % if full interaction term is significant, perform planned comparisons
    if anv_temp.pValue(end) < 0.05
        xpos= [.75, 1.25;
            1.75, 2.25;
            2.75, 3.25;
            3.75, 4.25;
            4.75, 5.25;
            5.75, 6.25;];

        pcs = {'Empty' 'begin1' 'Empty' 'begin2';
            'Social' 'begin1' 'Social' 'begin2';
            'SocialOdor' 'begin1' 'SocialOdor' 'begin2';
            'NonSocialOdor' 'begin1' 'NonSocialOdor' 'begin2';
            'FoxOdor' 'begin1' 'FoxOdor' 'begin2';
            'NovelRoom' 'begin1' 'NovelRoom' 'begin2';
            };
        statCell = {'Comparison','contrast', 'F', 'df1', 'df2', 'p', 'p_BF'};

        for i=1:size(pcs,1)
            statCell{i+1,1} = [pcs{i,1} ':' pcs{i,2} ' vs '  pcs{i,3} ':' pcs{i,4}];
            v1 = generateEffectVectorFromModel(glme_temp,'Condition' , 'Session', pcs{i,1}, pcs{i,2});
            v2 = generateEffectVectorFromModel(glme_temp,'Condition' , 'Session', pcs{i,3}, pcs{i,4});
            L = v2-v1;
            [statCell{i+1,6},statCell{i+1,3},statCell{i+1,4},statCell{i+1,5}] = coefTest(glme_temp, L);
            statCell{i+1,2} = L;
            statCell{i+1,7} = min(1, statCell{i+1,6}*size(pcs,1)); % bonferroni correction
            if statCell{i+1,7} < .05
                sigstar({xpos(i,:)}, statCell{i+1,7})
            end
        end
%         writecell(statCell, [metric{ds} '_isolated_frMod_comparisons.csv'])
        %     disp(statCell)
    end
end