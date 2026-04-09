lfp_list  = cell(6,1);
lfp_times = cell(6,1);
ds1_list = cell(6,1);
ds2_list = cell(6,1);

for r=4%1:length(cellStruct.rat)
    fprintf('%s\n', cellStruct.rat(r).name)
    for c=1:length(cellStruct.rat(r).cond)
        for d=1%:length(cellStruct.rat(r).cond(c).day)
            fprintf('\t%s Day %d\n', cellStruct.rat(r).cond(c).name, d)
            cd(cellStruct.rat(r).cond(c).day(d).dataLoc);
            fprintf('\t\t%s\n', cellStruct.rat(r).cond(c).day(d).name)
            shankNums = cellStruct.rat(r).cond(c).day(d).shankNums;
            if numel(shankNums) > 1
                shankToUse = cellStruct.rat(r).cond(c).day(d).ds_shankInd;
            else
                shankToUse = 1;
            end
            for b = 4%1:9
                try
                    cd([cellStruct.rat(r).cond(c).day(d).session(b).name '\' ...
                        cellStruct.rat(r).cond(c).day(d).session(b).name(7:end) '_imec0']) % one day does not have sleep 5  
                catch
                    continue;
                end

                fprintf('\t\t\t%s\n', cellStruct.rat(r).cond(c).day(d).session(b).name)

                if size(cellStruct.rat(r).cond(c).day(d).dsFn,1) == 1 & ~iscell(cellStruct.rat(r).cond(c).day(d).dsFn)
                    load(cellStruct.rat(r).cond(c).day(d).dsFn);
                elseif size(cellStruct.rat(r).cond(c).day(d).dsFn,1) == 1 & iscell(cellStruct.rat(r).cond(c).day(d).dsFn)
                    load(cellStruct.rat(r).cond(c).day(d).dsFn{1});
                elseif size(cellStruct.rat(r).cond(c).day(d).dsFn,1) > 1
                    load(cellStruct.rat(r).cond(c).day(d).dsFn{shankToUse,1});
                else
                    continue
                end

                prefix = 'LFP_all_corrected';
                files = dir([prefix, '*', '.mat']);
                if length(files) == 1
                    filename = files(1).name; % Get the first matching file
                    Lfp = load(filename); % Load the .mat file
                    disp(['Loaded file: ', filename]);
                elseif length(files) > 1 % if more than one file named 'LFP_all_corrected', load the most recent
                    dates = datetime.empty;
                    for f=1:length(files)
                        %                         dates{f} = files(f).date(1:11);
                        dates(f) = datetime(files(f).date(1:11), 'InputFormat', 'dd-MMM-yyyy');
                    end
                    [~, idx] = max(dates);
                    filename = files(idx).name;
                    Lfp = load(filename);
                    %                     filename = uigetfile('*.mat');
                    %                     Lfp = load(filename);
                    disp(['Loaded file: ', filename]);

                else
                    disp('No matching files found.');
                end

                lfpTs = Lfp.lfpTs;
                lfpTs_2 = lfpTs - lfpTs(1);
                ds1Times = lfpTs(ds1Ind);
%                 [stimRate, stimCoords, rewardRate, rewardCoords, neitherRate, neitherCoords] = getZoneEventRate(ds1Times,...
%                     cellStruct.rat(r).cond(c).day(d).session(b).coords_1d, 225, 90, 90);
                ds2Times = lfpTs(ds2Ind); 
%                 [stimRate, stimCoords, rewardRate, rewardCoords, neitherRate, neitherCoords] = getZoneEventRate(ds2Times,...
%                     cellStruct.rat(r).cond(c).day(d).session(b).coords_1d, 225, 90, 90);
                newDataArray = Lfp.(['shank' num2str(shankNums(shankToUse))])(1:2:end,:);
                clear Lfp
%                 lfp_list{c} = zscore(newDataArray(chDG,:));
                lfp_list{c} = newDataArray(chDG,:);
                lfp_times{c} = lfpTs;
                ds1_list{c} = ds1Times;
                ds2_list{c} = ds2Times;
                clear newDataArray
                cd(cellStruct.rat(r).cond(c).day(d).dataLoc);
            end% session
        end % day
    end % cond
end % rat
colsSpec = [
0.0, 0.45, 0.70;  % Blue
0.85, 0.37, 0.01; % Orange
0.93, 0.69, 0.13; % Yellow
0.0, 0.62, 0.45;  % Teal
0.80, 0.47, 0.74; % Purple
rgb('Tan')
];
% plotLfpEventSnippet(flipud(lfp_list), flipud(lfp_times), flipud({'Empty', 'Social', 'SocialOdor', 'NonSocialOdor', 'FoxOdor', 'NovelRoom'}'), 'DS1', flipud(ds1_list), 5, flipud(colsSpec));
% plotLfpEventSnippet_no_norm(flipud(lfp_list), flipud(lfp_times), flipud({'Empty', 'Social', 'SocialOdor', 'NonSocialOdor', 'FoxOdor', 'NovelRoom'}'), 'DS1', flipud(ds1_list), 5, flipud(colsSpec));
plotLfpEventSnippet_no_norm(flipud(lfp_list), flipud(lfp_times), flipud({'Empty', 'Social', 'SocialOdor', 'NonSocialOdor', 'FoxOdor', 'NovelRoom'}'), 'DS2', flipud(ds2_list), 5, flipud(colsSpec));
%% for revision
lfp_list  = cell(6,1);
lfp_times = cell(6,1);
ds1_list = cell(6,1);
ds2_list = cell(6,1);

for r=4%1:length(cellStruct.rat)
    fprintf('%s\n', cellStruct.rat(r).name)
    for c=1:length(cellStruct.rat(r).cond)
        for d=1%:length(cellStruct.rat(r).cond(c).day)
            fprintf('\t%s Day %d\n', cellStruct.rat(r).cond(c).name, d)
            cd(cellStruct.rat(r).cond(c).day(d).dataLoc);
            fprintf('\t\t%s\n', cellStruct.rat(r).cond(c).day(d).name)
            shankNums = cellStruct.rat(r).cond(c).day(d).shankNums;
            if numel(shankNums) > 1
                shankToUse = cellStruct.rat(r).cond(c).day(d).ds_shankInd;
            else
                shankToUse = 1;
            end

            for b = 4%1:9
                try
                    cd([cellStruct.rat(r).cond(c).day(d).session(b).name '\' ...
                        cellStruct.rat(r).cond(c).day(d).session(b).name(7:end) '_imec0']) % one day does not have sleep 5  
                catch
                    continue;
                end

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
                    Lfp = load(filename); % Load the .mat file
                    disp(['Loaded file: ', filename]);
                elseif length(files) > 1 % if more than one file named 'LFP_all_corrected', load the most recent
                    dates = datetime.empty;
                    for f=1:length(files)
                        %                         dates{f} = files(f).date(1:11);
                        dates(f) = datetime(files(f).date(1:11), 'InputFormat', 'dd-MMM-yyyy');
                    end
                    [~, idx] = max(dates);
                    filename = files(idx).name;
                    Lfp = load(filename);
                    %                     filename = uigetfile('*.mat');
                    %                     Lfp = load(filename);
                    disp(['Loaded file: ', filename]);

                else
                    disp('No matching files found.');
                end

%                [ds1Cluster, ds2Cluster] = assignClusterType(ds_cluster);
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

%                 ds1Ind_no_theta = ds1Ind; 
%                 for j=1:size(thetaInds,1)
%                     mask = ds1Ind_no_theta >= thetaInds(j,1) & ds1Ind_no_theta <= thetaInds(j,3);
%                     ds1Ind_no_theta(mask) = [];
%                 end
% 
%                 ds2Ind_no_theta = ds2Ind; 
%                 for j=1:size(thetaInds,1)
%                     mask = ds2Ind_no_theta >= thetaInds(j,1) & ds2Ind_no_theta <= thetaInds(j,3);
%                     ds2Ind_no_theta(mask) = [];
%                 end

                lfpTs = Lfp.lfpTs;
                lfpTs_2 = lfpTs - lfpTs(1);
%                 ds1Times = lfpTs(ds1Ind_no_theta);
%                 ds2Times = lfpTs(ds2Ind_no_theta); 
                ds1Times = lfpTs(ds1Cluster_no_theta);
                ds2Times = lfpTs(ds2Cluster_no_theta); 

                newDataArray = Lfp.(['shank' num2str(shankNums(shankToUse))])(1:2:end,:);
                clear Lfp
%                 lfp_list{c} = zscore(newDataArray(chDG,:));
                lfp_list{c} = newDataArray(chDG,:);
                lfp_times{c} = lfpTs;
                ds1_list{c} = ds1Times;
                ds2_list{c} = ds2Times;
                clear newDataArray
                cd(cellStruct.rat(r).cond(c).day(d).dataLoc);
            end% session
        end % day
    end % cond
end % rat

colsSpec = [
0.0, 0.45, 0.70;  % Blue
0.85, 0.37, 0.01; % Orange
0.93, 0.69, 0.13; % Yellow
0.0, 0.62, 0.45;  % Teal
0.80, 0.47, 0.74; % Purple
rgb('Tan')
];
% plotLfpEventSnippet(flipud(lfp_list), flipud(lfp_times), flipud({'Empty', 'Social', 'SocialOdor', 'NonSocialOdor', 'FoxOdor', 'NovelRoom'}'), 'DS1', flipud(ds1_list), 5, flipud(colsSpec));
% plotLfpEventSnippet_no_norm(flipud(lfp_list), flipud(lfp_times), flipud({'Empty', 'Social', 'SocialOdor', 'NonSocialOdor', 'FoxOdor', 'NovelRoom'}'), 'DS1', flipud(ds1_list), 5, flipud(colsSpec),1);
plotLfpEventSnippet_no_norm_v2(flipud(lfp_list), flipud(lfp_times), flipud({'Empty', 'Social', 'SocialOdor', 'NonSocialOdor', 'FoxOdor', 'NovelRoom'}'), 'DS1', flipud(ds1_list), 5, flipud(colsSpec),1);
axis off
% plotLfpEventSnippet_no_norm(flipud(lfp_list), flipud(lfp_times), flipud({'Empty', 'Social', 'SocialOdor', 'NonSocialOdor', 'FoxOdor', 'NovelRoom'}'), 'DS2', flipud(ds2_list), 5, flipud(colsSpec),2);
plotLfpEventSnippet_no_norm_v2(flipud(lfp_list), flipud(lfp_times), flipud({'Empty', 'Social', 'SocialOdor', 'NonSocialOdor', 'FoxOdor', 'NovelRoom'}'), 'DS2', flipud(ds2_list), 5, flipud(colsSpec),2);
axis off

