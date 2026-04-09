function getDS_CSD_per_shank_v4(shank_override, thresh)
%% purpose: to detect dentate spikes and get surrounding CSD for each shank 
% shank_overrride = shank to use, overrides automatic shank detection
% thresh = standard deviation threshold for ds detection

sessionList = {'catgt_sleep1_g0', 'catgt_begin1_g0', 'catgt_sleep2_g0', 'catgt_begin2_g0',...
    'catgt_sleep3_g0', 'catgt_begin3_g0', 'catgt_sleep4_g0', 'catgt_begin4_g0', 'catgt_sleep5_g0'};
% for r=4%1:length(dsMegaStruct.rat)%di=1:numel(dfolders)
% fprintf('%s\n', ratDir(end-5:end));
% cd(ratDir)
%     for c=6%:length(dsMegaStruct.rat(r).cond)
%         fprintf('\t%s\n', dsMegaStruct.rat(r).cond(c).name);
% for d=1:length(dayList)
%     dayDir = [ratDir '\' dayList{d}];
    dayDir = pwd; 
    fprintf('\t\t%s\n', dayDir);
    cd([dayDir '\catgt_sleep1_g0\sleep1_g0_imec0'])
%     if nargin < 1
%         try
%             warning('error', 'MATLAB:load:variableNotFound');
%             shankInfo = load('LFP_all_corrected.mat', 'shankNums');
%         catch
%             %                 load('LFP_all_corrected.mat', 'meta');
%             binName = ['sleep1_g0_tcat.imec0.lf.bin']; % for circ track
%             %                 binName = [dsMegaStruct.rat(r).cond(c).day(d).session(1).name '_g0_tcat.imec0.lf.bin']; % for olf_hab
%             meta = SGLX_readMeta.ReadMeta(binName, pwd);
%             shank_extractor_pattern  = '(?<=\()\d+(?=\:)';
%             matches = regexp(meta.snsGeomMap(18:end), shank_extractor_pattern, 'match');
%             shankInfo.shankNums = unique(str2double(matches));
%         end
%         thresh = 3.5; % default
%     end
%     warning('on', 'MATLAB:load:variableNotFound');
%     if nargin < 2
%         shankInfo.shankNums = shank_override;
%         thresh = 3.5; % default
%     end
    cd ..
    cd ..
    for sh=shank_override
        fprintf('\t\t\tShank %d\n',sh);
        badChan = [];
        for b=1:9%length(dsMegaStruct.rat(r).cond(c).day(d).session)
            fprintf('\t\t\t\tSession %d\n',b);
            cd([dayDir '\' sessionList{b} '\' sessionList{b}(7:end) '_imec0'])
            %% Load LFP
            %                     if r == 4 & c ==1 &  b == 1  % lfp upside down for this recording only for some reason
            %                         Lfp = load('LFP_all_corrected_flip.mat');
            %                     else
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
            %                         Lfp = load('LFP_all_corrected.mat');
            %                     end
%             thresh = 3.5; % 3.5 was used for all original ds detections
            srate = 2500;
            newDataArray = Lfp.(['shank' num2str(sh)])(1:2:end,:);

            %                 if exist('shank2', 'var')
            %                     newDataArray = shank2(1:2:end,:);
            %                     clear shank1 shank2
            %                 end
            %% Find Dentate channels
            if b==1
                %
                eegplot(newDataArray, 'srate', srate, 'winlength', 3, 'spacing', 0.001 );
                prompt = '              Remove bad channel(s)?';
                badChan = input(prompt);
                if ~isempty(badChan)
                    newDataArray(badChan,:) = [];
                    close
                    eegplot(newDataArray, 'srate', srate, 'winlength', 3, 'spacing', 0.001 );
                end
                %         plot(newDataArray(191,1:1000))
%                 if any(r ==[3,4,5,6])
                    prompt = '                  Extract Hippocampal Channels?  1 for Yes, 0 for No:';
                    getHippChan = input(prompt);
                    chHipp = [1 size(newDataArray,1)];
                    if getHippChan == 1
                        prompt = '                  Which channels are hippocampal?  Channels:';
                        chHipp = input(prompt);
                        close
                        newDataArray = newDataArray(chHipp(1):chHipp(2),:);
                        eegplot(newDataArray, 'srate', srate, 'winlength', 3, 'spacing', 0.001 );
                    end
                    prompt = '                  Which channel has the highest amplitude dentate spike?  Channel:';
                    chDG = input(prompt);
                    %                             if strcmpi(getHippChan, 'Y')
                    %                                 chDG = chDG - chHipp(1);
                    %                             end

%                 end

                prompt = '              Do notch filtering? 1 for YES, 0 for NO:';
                doNotch = input(prompt);
                if doNotch == 1
%                     notch = designfilt('bandstopiir','FilterOrder',2, ...
%                         'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
%                         'DesignMethod','butter','SampleRate',srate);
                    notch60 = designfilt('bandstopiir', ...
                            'FilterOrder', 6, ...
                            'HalfPowerFrequency1', 59, ...
                            'HalfPowerFrequency2', 61, ...
                            'DesignMethod', 'butter', ...
                            'SampleRate', 2500);
                end
            end
            %                     close
            if ~isempty(badChan) & (b > 1)
                newDataArray(badChan,:) = [];
            end
            if b > 1 & getHippChan == 1
                newDataArray = newDataArray(chHipp(1):chHipp(2),:);
            end
            %%
            if doNotch == 1
%                 newDataArray = filter(notch, newDataArray);
                for i=1:size(newDataArray,1)
                    newDataArray(i,:) = filtfilt(notch60, newDataArray(i,:));
                end
            end
            %% DS detection (method adapted from Farrell, Hwaun, Dudok, & Soltesz 2024)
            fprintf('\t\t\t\tDetecting Dentate spikes...\n');
            zDgChan = zscore(newDataArray(chDG,:));
            filtDgChan = filter_lfp_timeseries(zDgChan, srate, 5, 100);
            [peaks,locs] = findpeaks(filtDgChan);
            stdev = std(filtDgChan);
            threshPeaks = peaks > (stdev .* thresh);
            %                 dsPeaks = peaks(threshPeaks);
            dsPeaks = filtDgChan(locs(threshPeaks));
            dsInd = locs(threshPeaks);

            %% CSD params
            h = 40e-6; %inter-electrode distance meters
            ex_cond = 0.3; %external conductivity S/m
            top_cond = 0.3; %S/m
            diam = 0.5e-3; %mm
            gauss_sigma = 0.05e-3; %mm
            filter_range = 5*gauss_sigma; % numeric filter must be finite in extent
            dt = 0.4; %sampling time ms (for 2k); % was 0.5 for 2k sample hz, changed to 0.4 for 2.5k sample hz - PD
            scale_plot = 1; %focus
            max_plot = 0;
            CSDres = 200; %CSD resolution (fixed)
            methodSpline = 1; %CSD method
            el_pos = 0.02:.02:(.02*size(newDataArray,1));
            % el_pos = 0.1:.04:1.06; % should be 0.04?
            % el_pos = 0.1:.04:.46; % should be 0.04? % MAKE SURE LENGTH MATCHES THE NUMBER OF CHANNELS USED FOR CSD
            el_pos = el_pos*1e-3; %mm

            %% run initial CSD
            resultsCSD = [];
            fprintf('\t\t\t\t\tGetting CSDs...\n');
            for i = 1:length(dsInd)
                s = dsInd(i);
                eeg = newDataArray(:,s-10:s+10); % make sure matches el_pos
                %                         eeg = shank0(:,s-10:s+10); % make sure matches el_pos
                % compute spline iCSD:
                Fcs = F_cubic_spline(el_pos,diam,ex_cond,top_cond);
                [zs,CSD_cs] = make_cubic_splines(el_pos,eeg,Fcs);
                if gauss_sigma~=0 %filter iCSD
                    [~,CSD_cs]=gaussian_filtering(zs,CSD_cs,gauss_sigma,filter_range);
                end
                CSD = CSD_cs;

                CSDp = CSD(:,10+1);

                resultsCSD(:,i) = CSDp;
            end
            %% get daily sinks
            if b == 1
                figure
                subplot(1,4,1:2)
                imagesc(resultsCSD)
                caxis([-1e4 1e4])
                colormap redblue
                clbr = colorbar;
                clbr.Position = [0.495    0.4    0.0100    0.20];
                clbr.Ticks = [-1e4 1e4];
                clbr.TickLabels = {'Sink', 'Source'};
                ylabel(clbr, 'CSD')
                title('All Detected DSs from one 10 min Session')
                ylabel('Depth along probe (CSD space)')
                xlabel('DS #')
                 
                subplot(1,4,3)
                [~,minInd] = min(resultsCSD);
                edges = 0.5:1:200.5;
                histMinInd = histc(minInd, edges);
                plot(histMinInd, edges+.5,'b');
                axis ij tight
                xlabel('Count')
                title('Histogram of Sinks')
                yticks('')

                subplot(144)
                plot(mean(resultsCSD,2),1:200, 'k', 'Linewidth', 2)
                title('Mean DS Peak Time CSD')
                xlabel('CSD')
                axis ij
                yticks('')

                prompt = '                      Use superior or inferior sinks? 1 for superior, 2 for inferior: ';
                bladeChoice = input(prompt);
                prompt = '                      Sink 1: ';
                sinks(1) = input(prompt);
                prompt = '                      Sink 2: ';
                sinks(2) = input(prompt);
                %                         prompt = 'Sink 3: ';
                %                         sinks(3) = input(prompt);
                %                         prompt = 'Sink 4: ';
                %                         sinks(4) = input(prompt);
                if any( diff(sinks) < 1)
                    error('Sinks must be increasing values!')
                end
            end
            %% DS type classification - sink method
            fprintf('\t\t\t\tClassifying DS types...\n');
            ds1Ind = [];
            ds1Num = [];
            ds2Ind = [];
            ds2Num = [];
            for i=1:length(dsInd)
                if bladeChoice == 1 % use sup/dorsal blade sinks
                    tmpCSD = resultsCSD(1:100,i); % only use upper half of DG CSD
%                     tmpCSD = resultsCSD(:,i); % only use upper half of DG CSD
                    [~,ind] = min(tmpCSD);
                    [~,sinkInd] = min(abs([ind(1) - sinks(1), ind(1) - sinks(2)]));
                    if sinkInd == 1
                        %         ds2Ind = [ds2Ind dsInd(i)];
                        ds1Ind = [ds1Ind dsInd(i)];
                        ds1Num = [ds1Num i];
                    else
                        %         ds1Ind = [ds1Ind dsInd(i)];
                        ds2Ind = [ds2Ind dsInd(i)];
                        ds2Num = [ds2Num i];
                    end
                elseif bladeChoice == 2 % use inferior blade sinks
                    tmpCSD = resultsCSD(101:200,i); % only use lower half of DG CSD
%                     tmpCSD = resultsCSD(:,i); % only use lower half of DG CSD
                    [~,ind] = min(tmpCSD);
                    ind = ind +100;
                    [~,sinkInd] = min(abs([ind(1) - sinks(2), ind(1) - sinks(1)]));
                    if sinkInd == 1
                        %         ds2Ind = [ds2Ind dsInd(i)];
                        ds1Ind = [ds1Ind dsInd(i)];
                        ds1Num = [ds1Num i];
                    else
                        %         ds1Ind = [ds1Ind dsInd(i)];
                        ds2Ind = [ds2Ind dsInd(i)];
                        ds2Num = [ds2Num i];
                    end
                end
            end
            
            
            winLen = .05; %sec
            
            [pc12, labels] = dentateSpikeClustering(resultsCSD); % do automated clustering of dentate spikes 
            ds_cluster = struct; 
            
            clustCnt = 1;
            for c=unique(labels)'
                ei = labels == c; % cluster mask
                if ~any(ei), continue; end
                ds_cluster_inds = dsInd(ei); % cluster indices
                ds_cluster(clustCnt).inds = ds_cluster_inds;
                ds_cluster(clustCnt).num = c; % cluster name
                for i=1:length(ds_cluster_inds)
                    s = ds_cluster_inds(i);
                    try
                        eeg = newDataArray(:,s-(winLen*srate):s+(winLen*srate));
                    catch
                        continue
                    end
                    Fcs = F_cubic_spline(el_pos,diam,ex_cond,top_cond);
                    [zs,CSD_cs] = make_cubic_splines(el_pos,eeg,Fcs);
                    if gauss_sigma~=0 %filter iCSD
                        [~,CSD_cs]=gaussian_filtering(zs,CSD_cs,gauss_sigma,filter_range);
                    end
                    ds_cluster(clustCnt).CSD(:,:,i) = CSD_cs;   
                end
                clustCnt = clustCnt+1;
            end
            
            if b == 1
                figure
                pltCnt = 1;
                for p=1:size(ds_cluster,2)
                    subplot(1,size(ds_cluster,2),pltCnt)
                    imagesc(mean(ds_cluster(p).CSD,3))
                    colormap jet
                    title(['Cluster ' num2str(ds_cluster(p).num)])
                    caxis([-1.5e4 1.5e4])
                    pltCnt = pltCnt+1;
                end
                sgtitle(['Automated classification, session ' num2str(b) ' Shank ' num2str(sh)])
                keyboard
            end

            fprintf('\t\t\t\tGetting DS1 CSDs...\n');
            CSD_ds1 = zeros(200,(winLen*srate*2)+1,length(ds1Ind));
            for i = 1:length(ds1Ind)
                s = ds1Ind(i);
                try
                    eeg = newDataArray(:,s-(winLen*srate):s+(winLen*srate));
                    %                             eeg = shank0(:,s-(winLen*srate):s+(winLen*srate));
                catch
                    continue
                end
                % compute spline iCSD:
                Fcs = F_cubic_spline(el_pos,diam,ex_cond,top_cond);
                [zs,CSD_cs] = make_cubic_splines(el_pos,eeg,Fcs);
                if gauss_sigma~=0 %filter iCSD
                    [~,CSD_cs]=gaussian_filtering(zs,CSD_cs,gauss_sigma,filter_range);
                end
                CSD_ds1(:,:,i) = CSD_cs;
            end

            fprintf('\t\t\t\tGetting DS2 CSDs...\n');
            CSD_ds2 = zeros(200,(winLen*srate*2)+1,length(ds2Ind));
            for i = 1:length(ds2Ind)
                s = ds2Ind(i);
                try
                    eeg = newDataArray(:,s-(winLen*srate):s+(winLen*srate));
                    %                             eeg = shank0(:,s-(winLen*srate):s+(winLen*srate));
                catch
                    continue
                end
                % compute spline iCSD:
                Fcs = F_cubic_spline(el_pos,diam,ex_cond,top_cond);
                [zs,CSD_cs] = make_cubic_splines(el_pos,eeg,Fcs);
                if gauss_sigma~=0 %filter iCSD
                    [~,CSD_cs]=gaussian_filtering(zs,CSD_cs,gauss_sigma,filter_range);
                end
                CSD_ds2(:,:,i) = CSD_cs;
            end

            if b==1
                figure
                subplot(121)
                imagesc(mean(CSD_ds1,3))
                colormap jet
                title('DS1')
                caxis([-1e4 1e4])
                subplot(122)
                imagesc(mean(CSD_ds2,3))
                colormap jet
                title('DS2')
                caxis([-1.5e4 1.5e4])
                sgtitle(['Manual classification, session ' num2str(b) ' Shank ' num2str(sh)])
                keyboard
            end

            filename = ['ds_alt_method_corrected_shank_auto' num2str(sh) '_SDthresh' num2str(thresh) '.mat'];
            save(filename, 'dsPeaks', 'dsInd', 'resultsCSD', 'ds1Ind', 'ds2Ind', 'CSD_ds1', 'CSD_ds2',...
                'sinks', 'ds1Num', 'ds2Num', 'chDG', 'chHipp', 'el_pos', 'zs', 'bladeChoice', 'doNotch', 'thresh', 'ds_cluster', 'pc12', 'labels');

%             switch sh
%                 case 0
%                     save ds_alt_method_corrected_shank0_v5.mat dsPeaks dsInd resultsCSD ds1Ind ds2Ind CSD_ds1 CSD_ds2 sinks ds1Num ds2Num chDG el_pos zs bladeChoice doNotch thresh
%                 case 1
%                     save ds_alt_method_corrected_shank1_v5.mat dsPeaks dsInd resultsCSD ds1Ind ds2Ind CSD_ds1 CSD_ds2 sinks ds1Num ds2Num chDG el_pos zs bladeChoice doNotch thresh
%                 case 2
%                     save ds_alt_method_corrected_shank2_v5.mat dsPeaks dsInd resultsCSD ds1Ind ds2Ind CSD_ds1 CSD_ds2 sinks ds1Num ds2Num chDG el_pos zs bladeChoice doNotch thresh
%                 case 3
%                     save ds_alt_method_corrected_shank3_v5.mat dsPeaks dsInd resultsCSD ds1Ind ds2Ind CSD_ds1 CSD_ds2 sinks ds1Num ds2Num chDG el_pos zs bladeChoice doNotch thresh
%             end
        end % session
    end % shank
% end % day
%     end %condition
% end %rat
end