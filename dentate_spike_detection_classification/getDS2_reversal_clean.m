function getDS2_reversal_clean(ratDir,dayList)
% purpose: to get the CSD channel of the Dentate spike type 2 sink-source reversal
% ratDir = 'D:\NeuropixelsData\Rat501';
% dayList = {'2_23_25'};
cd(ratDir)

%% move directory to recording file
for d=1:length(dayList)
    fprintf('\t%s\n', dayList{d});
    cd(dayList{d})
    cd(['catgt_sleep1_g0\sleep1_g0_imec0'])
%% get shank numbers for recording 
    try
        warning('error', 'MATLAB:load:variableNotFound');
        LfpInfo = load('LFP_all_corrected.mat', 'shankNums', 'meta');
    catch
        prefix = 'LFP_all_corrected';
        files = dir([prefix, '*', '.mat']);
        if ~isempty(files)
            filename = files(1).name;
            lfpObj = matfile(filename);
            varNames = who(lfpObj);
            numerals = cellfun(@(x) str2double(regexp(x, '\d+', 'match')), varNames, 'UniformOutput', false);
            LfpInfo.shankNums = [numerals{:}];
        else
            error('Shanks undetermined! Check configuration and use override')
        end
    end
    warning('on', 'MATLAB:load:variableNotFound');
%% for each shank, get DS2 sink/source reversal channels
    for sh = LfpInfo.shankNums
        fprintf('\t\tShank %d\n', sh);
        filename = uigetfile('*.mat');
        ds = load(filename);

        if isempty(ds.CSD_ds2)
            keyboard
        end
        
        % get mean peak-time DS2 CSD profile
        ds2_avg_csd = mean(ds.CSD_ds2,3);
        ds2_avg_csd_peak = ds2_avg_csd(:,126);

        % plot CSDs
        figure
        subplot(121)
        imagesc(mean(ds.CSD_ds2,3))
        colormap jet
        subplot(122)
        plot(ds2_avg_csd_peak,1:200)
        axis ij

        % get DS2 sinks and sources
        [sourceVals,sourceInds] = findpeaks(ds2_avg_csd_peak,'MinPeakDistance',20);
        [~,tmpInds] = maxk(sourceVals,2);
        tmpInds = sort(tmpInds);
        sourceInds = sourceInds(tmpInds);
        [sinkVals,sinkInds] = findpeaks(-ds2_avg_csd_peak,'MinPeakDistance',20);
        [~,tmpInds] = mink(-sinkVals,2);
        tmpInds = sort(tmpInds);
        sinkInds = sinkInds(tmpInds);

        hold on
        % plot sinks and sources
        plot(ds2_avg_csd_peak(sinkInds(1)),sinkInds(1),'b*')
        plot(ds2_avg_csd_peak(sourceInds(1)),sourceInds(1),'r*')

        % get reversal points for superior and inferior blades
        [~, tmp_idx_sup] =min(abs(ds2_avg_csd_peak(sinkInds(1):sourceInds(1))));
        [~, tmp_idx_inf] =min(abs(ds2_avg_csd_peak(sourceInds(2):sinkInds(2))));

        ds2_reversal_chan_sup = tmp_idx_sup + sinkInds(1) - 1;
        ds2_reversal_chan_inf = tmp_idx_inf + sourceInds(2) - 1;
        
        % plot reversal poitns
        plot(ds2_avg_csd_peak(ds2_reversal_chan_sup),ds2_reversal_chan_sup, 'g*')
        plot(ds2_avg_csd_peak(ds2_reversal_chan_inf),ds2_reversal_chan_inf, 'g*')
        plot(ds2_avg_csd_peak(sinkInds(2)),sinkInds(2),'b*')
        plot(ds2_avg_csd_peak(sourceInds(2)),sourceInds(2),'r*')
        xline(0,'--')
        legend ds2 ds2Sink ds2Source ds2Reversal
        sgtitle([strrep(dayList{d},'_','-') ' shank ' num2str(sh)])

        % check if reversals are sensible and manually override reversal channels if automated detection failed
        prompt = '          Override automated reversal detection? 1 for Yes, 0 for No: ';
        doOverride = input(prompt);
        if doOverride
            prompt = '          Superior blade reversal CSD channel: ';
            ds2_reversal_chan_sup = input(prompt);
            prompt = '          Inferior blade reversal CSD channel: ';
            ds2_reversal_chan_inf = input(prompt);
        end
        close

        switch sh
            case 0
                ds2ReversalShank0.supCSDChan = ds2_reversal_chan_sup;
                ds2ReversalShank0.infCSDChan = ds2_reversal_chan_inf;
            case 1
                ds2ReversalShank1.supCSDChan = ds2_reversal_chan_sup;
                ds2ReversalShank1.infCSDChan = ds2_reversal_chan_inf;
            case 2
                ds2ReversalShank2.supCSDChan = ds2_reversal_chan_sup;
                ds2ReversalShank2.infCSDChan = ds2_reversal_chan_inf;
            case 3
                ds2ReversalShank3.supCSDChan = ds2_reversal_chan_sup;
                ds2ReversalShank3.infCSDChan = ds2_reversal_chan_inf;
        end

%% convert back from shank-specific, downsampled CSD to full LFP with user order channel numbers
        if isempty(ds2_reversal_chan_sup)
            lfpChan_sup = [];
        else
            [~,lfpChan_sup] = min( abs( ds.el_pos - ds.zs(ds2_reversal_chan_sup) ) );
            lfpChan_sup =  lfpChan_sup * 2; % correct for downsampling
            if numel(LfpInfo.shankNums) == 1
                lfpChan_sup = 384 - lfpChan_sup + 1; % correct for flipud
            elseif numel(LfpInfo.shankNums) == 2
                lfpChan_sup = 192 - lfpChan_sup + 1; % correct for flipud
            end
            if (sh == 2 || sh == 3) & numel(LfpInfo.shankNums) == 2
                lfpChan_sup = lfpChan_sup + 192; % correct for shank-splitting
            end
        end

        if isempty(ds2_reversal_chan_inf)
            lfpChan_inf = [];
        else
            [~,lfpChan_inf] = min( abs( ds.el_pos - ds.zs(ds2_reversal_chan_inf) ) );
            lfpChan_inf =  lfpChan_inf * 2; % correct for downsampling
            if numel(LfpInfo.shankNums) == 1
                lfpChan_inf = 384 - lfpChan_inf + 1; % correct for flipud
            elseif numel(LfpInfo.shankNums) == 2
                lfpChan_inf = 192 - lfpChan_inf + 1; % correct for flipud
            end
            if (sh == 2 || sh == 3) & numel(LfpInfo.shankNums) == 2
                lfpChan_inf = lfpChan_inf + 192; % correct for shank-splitting
            end
        end
%% save reversal channels
        switch sh
            case 0
                ds2ReversalShank0.supUserChan = lfpChan_sup;
                ds2ReversalShank0.infUserChan = lfpChan_inf;
                cd ..
                cd ..
                save ds2ReversalShank0.mat ds2ReversalShank0
                cd(['catgt_sleep1_g0\sleep1_g0_imec0'])
            case 1
                ds2ReversalShank1.supUserChan = lfpChan_sup;
                ds2ReversalShank1.infUserChan = lfpChan_inf;
                cd ..
                cd ..
                save ds2ReversalShank1.mat ds2ReversalShank1
                cd(['catgt_sleep1_g0\sleep1_g0_imec0'])
            case 2
                ds2ReversalShank2.supUserChan = lfpChan_sup;
                ds2ReversalShank2.infUserChan = lfpChan_inf;
                cd ..
                cd ..
                save ds2ReversalShank2.mat ds2ReversalShank2
                cd(['catgt_sleep1_g0\sleep1_g0_imec0'])
            case 3
                ds2ReversalShank3.supUserChan = lfpChan_sup;
                ds2ReversalShank3.infUserChan = lfpChan_inf;
                cd ..
                cd ..
                save ds2ReversalShank3.mat ds2ReversalShank3
                cd(['catgt_sleep1_g0\sleep1_g0_imec0'])
        end
    end

    cd ..
    cd ..
    cd ..
end
cd ..
end