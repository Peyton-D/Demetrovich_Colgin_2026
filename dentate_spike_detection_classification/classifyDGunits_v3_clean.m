function classifyDGunits_v3_clean(cellStruct)
% Purpose: classify DG units recorded from Neuropixels probes as dentate or not based on channel distance to DS2 reversal
% Requires saved output of:
%           - getDS_CSD_per_shank_v4.m (Dentate spikes and CSDs)
%           - getDS2_reversal.m (DS2 reversals)
% Inputs:
%   cellStruct
% Outputs:
%   none - updates cellStruct with cell classification info
% PG Demetrovich, Colgin Lab, 5/2026
cd('D:\NeuropixelsData')
s = 1; % session to pull spikes and lfp from
%% Step 0: Data wrangling
for r = 1:length(cellStruct.rat)
    fprintf('%s\n', cellStruct.rat(r).name)
    for c=1:length(cellStruct.rat(r).cond)
        for d=1:length(cellStruct.rat(r).cond(c).day)
            fprintf('\t%s Day %d\n', cellStruct.rat(r).cond(c).name, d)
            fprintf('\t\t%s\n', cellStruct.rat(r).cond(c).day(d).name)
            cd(cellStruct.rat(r).cond(c).day(d).dataLoc)
            
            % get DS2 reversal channels 
            if iscell(cellStruct.rat(r).cond(c).day(d).reversalFn)
                for i=1:length(cellStruct.rat(r).cond(c).day(d).reversalFn)
                    load(cellStruct.rat(r).cond(c).day(d).reversalFn{i});
                end
            else
                load(cellStruct.rat(r).cond(c).day(d).reversalFn);
            end
            
            % get cells 
            if r==2 & c==1 & d==2
                load("new_ks2.5Cells_quickNormRm_fixSync.mat");
            else
                load("new_ks4Cells_quickNormRm_fixSync.mat");
            end
            
            % get dentate spikes and CSDs 
            cd('catgt_sleep1_g0\sleep1_g0_imec0')
            if iscell(cellStruct.rat(r).cond(c).day(d).dsFn)
                for i=1:length(cellStruct.rat(r).cond(c).day(d).dsFn)
                    if i == 1
                        try
                            ds.shankA = load(cellStruct.rat(r).cond(c).day(d).dsFn{i});
                        catch
                            ds.shankA =load('ds_alt_method_corrected_shank0_SDthresh3_5.mat');
                        end
                    elseif i==2
                        ds.shankB = load(cellStruct.rat(r).cond(c).day(d).dsFn{i});
                    end
                end
            else
                ds.shankA = load(cellStruct.rat(r).cond(c).day(d).dsFn);
            end
            fprintf('\t\tLoaded Dentate spikes\n')
            
            % get shank numbers 
            try
                shanks = unique([cellStruct.rat(r).cond(c).day(d).session(1).uID(:).shankNum]);
            catch
                fprintf('\t\tUnit info not found. Adding info to struct...\n')
                meta = SGLX_readMeta_new.ReadMeta('sleep1_g0_tcat.imec0.ap.bin', pwd);
                pattern = '\d+(?=\))'; % Pattern (\d+(?=\))): \d+ matches one or more digits, and (?=\)) ensures the match is immediately followed by a closing parenthesis ).
                matches = regexp(meta.snsChanMap(10:end), pattern, 'match'); % Extract matches
                graphOrder = str2double(matches); % Convert matches to numeric array
                [~,sortInd] = sort(graphOrder);
                pattern = '\d+(?=\;)'; % extract channel numbers
                matches = regexp(meta.snsChanMap(10:end), pattern, 'match');
                chanNums = str2double(matches);
                chanMap = [chanNums' graphOrder'];
                for b=1:length(uID)%9%4
                    for u=1:length(uID{1,b})
                        cellStruct.rat(r).cond(c).day(d).session(b).uID(u).clusterID = uID{1,b}(u);
                        idx = superClusterInfo.cluster_id == uID{1,b}(u);
                        cellStruct.rat(r).cond(c).day(d).session(b).uID(u).channelNum_Acq = table2array(superClusterInfo(idx,'ch'));
                        cellStruct.rat(r).cond(c).day(d).session(b).uID(u).channelNum_User = chanMap(match(cellStruct.rat(r).cond(c).day(d).session(b).uID(u).channelNum_Acq,chanMap(:,1)),2);
                        if r==2 & c==1 & d==2
                            cellStruct.rat(r).cond(c).day(d).session(b).uID(u).shankNum = table2array(superClusterInfo(idx,'sh'));
                        else
                            cellStruct.rat(r).cond(c).day(d).session(b).uID(u).shankNum = table2array(superClusterInfo(idx,'sh')) - 1;
                        end
                    end
                end
                shanks = unique([cellStruct.rat(r).cond(c).day(d).session(1).uID(:).shankNum]);
            end

             % set up plots for checking accurate classification later
             figure 
                if numel(cellStruct.rat(r).cond(c).day(d).shankNums) == 1
                    subplot(121), hold on
                    imagesc(mean(ds.shankA.CSD_ds2,3))
                     plot(nan, 'b--','LineWidth',1.5);
                     plot(nan, 'r--','LineWidth',1.5);
                     legend({'Dentate', 'Undetermined'})
                     legend autoupdate off
                     axis ij tight
                    title(['shank' num2str(shanks(1))]), caxis([-1.5e4 1.5e4]), colormap jet
                elseif numel(cellStruct.rat(r).cond(c).day(d).shankNums) == 2
                    subplot(121), hold on
                    imagesc(mean(ds.shankA.CSD_ds2,3))
                     plot(nan, 'b--','LineWidth',1.5);
                     plot(nan, 'r--','LineWidth',1.5);
                     legend({'Dentate', 'Undetermined'})
                     legend autoupdate off
                     axis ij tight
                    title(['shank' num2str(shanks(1))]), caxis([-1.5e4 1.5e4]), colormap jet
                    subplot(122)
                    imagesc(mean(ds.shankB.CSD_ds2,3)), caxis([-1.5e4 1.5e4]), colormap jet
                    title(['shank' num2str(shanks(2))])
                end

            cd ..
            cd ..
%% Step 1: Classify cells
            for u=1:length(cellStruct.rat(r).cond(c).day(d).session(s).uID)
                % set cell type to unknown for recordings without DG profile
                if r==4 & ismember(cellStruct.rat(r).cond(c).day(d).name, {'5_9_25' '5_12_25' '5_13_25'}) & ...
                        cellStruct.rat(r).cond(c).day(d).session(1).uID(u).shankNum == 3 % this shank did not have DG on these days
                    for i=1:length(cellStruct.rat(r).cond(c).day(d).session)
                        cellStruct.rat(r).cond(c).day(d).session(i).uID(u).cellType = 'undetermined';
                    end
                    continue
                end
                
                % find the distance to the closest DS2 reversal (either blade)
                switch cellStruct.rat(r).cond(c).day(d).session(1).uID(u).shankNum
                    case 0
                        tmpDist = min(abs([cellStruct.rat(r).cond(c).day(d).session(1).uID(u).channelNum_User - ds2ReversalShank0.supUserChan,...
                            cellStruct.rat(r).cond(c).day(d).session(1).uID(u).channelNum_User - ds2ReversalShank0.infUserChan]));
                    case 1
                        tmpDist = min(abs([cellStruct.rat(r).cond(c).day(d).session(1).uID(u).channelNum_User - ds2ReversalShank1.supUserChan,...
                            cellStruct.rat(r).cond(c).day(d).session(1).uID(u).channelNum_User - ds2ReversalShank1.infUserChan]));
                    case 2
                        tmpDist = min(abs([cellStruct.rat(r).cond(c).day(d).session(1).uID(u).channelNum_User - ds2ReversalShank2.supUserChan,...
                            cellStruct.rat(r).cond(c).day(d).session(1).uID(u).channelNum_User - ds2ReversalShank2.infUserChan]));
                    case 3
                        tmpDist = min(abs([cellStruct.rat(r).cond(c).day(d).session(1).uID(u).channelNum_User - ds2ReversalShank3.supUserChan,...
                            cellStruct.rat(r).cond(c).day(d).session(1).uID(u).channelNum_User - ds2ReversalShank3.infUserChan]));
                end
                cellStruct.rat(r).cond(c).day(d).session(1).uID(u).distToRev = (tmpDist/2)*15; % 15 um electrode pitch every two electrodes due to channel numbering scheme 

                % classify cell types
                if (tmpDist/2)*15 <= 150 
                    for i=1:length(cellStruct.rat(r).cond(c).day(d).session)
                        cellStruct.rat(r).cond(c).day(d).session(i).uID(u).cellType = 'dentate';
                    end
                else
                    for i=1:length(cellStruct.rat(r).cond(c).day(d).session)
                        cellStruct.rat(r).cond(c).day(d).session(i).uID(u).cellType = 'undetermined';
                    end
                end
                
                % visually check accurate classification
                if cellStruct.rat(r).cond(c).day(d).session(1).uID(u).shankNum < 2
                    subplot(121)
                        if ismember(cellStruct.rat(r).cond(c).day(d).session(i).uID(u).cellType, {'dentate'})
                            yline(cellStruct.rat(r).cond(c).day(d).session(1).uID(u).channelNum_CSD, 'b--', 'LineWidth', 1.5)
                        elseif ismember(cellStruct.rat(r).cond(c).day(d).session(i).uID(u).cellType, {'undetermined'})
                            yline(cellStruct.rat(r).cond(c).day(d).session(1).uID(u).channelNum_CSD, 'r--', 'LineWidth', 1.5)
                        end
                else
                     subplot(122)
                        if ismember(cellStruct.rat(r).cond(c).day(d).session(i).uID(u).cellType, {'dentate'})
                            yline(cellStruct.rat(r).cond(c).day(d).session(1).uID(u).channelNum_CSD, 'b--', 'LineWidth', 1.5)
                        elseif ismember(cellStruct.rat(r).cond(c).day(d).session(i).uID(u).cellType, {'undetermined'})
                            yline(cellStruct.rat(r).cond(c).day(d).session(1).uID(u).channelNum_CSD, 'r--', 'LineWidth', 1.5)
                        end
                end
 %% Step 2: get unit CSD channel number 
                % have to transform original channel number (in user order) into CSD space
                channelNum_User = cellStruct.rat(r).cond(c).day(d).session(1).uID(u).channelNum_User; 
                if numel(shanks) == 1 & ~ismember(cellStruct.rat(r).cond(c).day(d).name, {'5_9_25' '5_12_25' '5_13_25'}) % no DG cells on shank 3 for these days
                    tmp = 384 - channelNum_User + 1; % correct for flipping shanks upside down to get dorsoventral axis
                elseif numel(shanks) == 2 | ismember(cellStruct.rat(r).cond(c).day(d).name, {'5_9_25' '5_12_25' '5_13_25'})
                    tmp = 192 - channelNum_User + 1; % correct for flipping upside down
                end
                if (cellStruct.rat(r).cond(c).day(d).session(1).uID(u).shankNum == 2 ...
                        || cellStruct.rat(r).cond(c).day(d).session(1).uID(u).shankNum == 3) & numel(shanks) == 2
                    tmp = tmp + 192; % correct for channels being split across two shanks
                end
                tmp = floor(tmp/2); % correct for getting every other channel 
                
                % for a given corrected channel, find the closest channel in CSD space
                if numel(shanks) ==1
                    [~,channelNum_CSD] = min( abs( ds.shankA.el_pos(tmp) - ds.shankA.zs ) );
                elseif numel(shanks) == 2
                    switch cellStruct.rat(r).cond(c).day(d).session(1).uID(u).shankNum
                        case {0 1}
                            [~,channelNum_CSD] = min( abs( ds.shankA.el_pos(tmp) - ds.shankA.zs ) );
                        case {3 2}
                            try
                                [~,channelNum_CSD] = min( abs( ds.shankB.el_pos(tmp) - ds.shankA.zs ) ); % should be ds.shankB.zs ??
                            catch
                                keyboard
                            end
                    end
                end
                cellStruct.rat(r).cond(c).day(d).session(1).uID(u).channelNum_CSD = channelNum_CSD;
            end % unit
            pause
            close all
            cellStruct.rat(r).cond(c).day(d).dgU = ismember({cellStruct.rat(r).cond(c).day(d).session(1).uID(:).cellType}, 'dentate');
            cellStruct.rat(r).cond(c).day(d).unknownU = ismember({cellStruct.rat(r).cond(c).day(d).session(1).uID(:).cellType}, 'undetermined');
        clear ds2ReversalShank0 ds2ReversalShank1 ds2ReversalShank2 ds2ReversalShank3 ds
        end % day
    end % cond
end % rat 
