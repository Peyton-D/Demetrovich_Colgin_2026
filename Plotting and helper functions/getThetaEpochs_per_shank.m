function getThetaEpochs_per_shank(shank_override, coords, bandStart, bandStop)
%% purpose: to detect periods of high theta using channel with maximal theta
% shank_overrride = shank to use, overrides automatic shank detection
% bandStart = 5; % in hz
% bandStop = 10; % in hz
minDur = (1 / ((bandStart + bandStop)/2)) * 3; % 3 times average cycle length

sessionList = {'catgt_sleep1_g0', 'catgt_begin1_g0', 'catgt_sleep2_g0', 'catgt_begin2_g0',...
    'catgt_sleep3_g0', 'catgt_begin3_g0', 'catgt_sleep4_g0', 'catgt_begin4_g0', 'catgt_sleep5_g0'};

dayDir = pwd;
fprintf('\t\t%s\n', dayDir);
cd([dayDir '\catgt_sleep1_g0\sleep1_g0_imec0'])
cd ..
cd ..
for sh=shank_override
    fprintf('\t\t\tShank %d\n',sh);
    for b=[2,4,6,8]%1:9
        fprintf('\t\t\t\tSession %d\n',b);
        cd([dayDir '\' sessionList{b} '\' sessionList{b}(7:end) '_imec0'])
        %% Load LFP
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
        srate = 2500;
        newDataArray = Lfp.(['shank' num2str(sh)])(1:2:end,:);
        %% find good theta channel
        if b==2
            % get longest running bout (presumed epoch of high, sustained theta)
            [runTimes, runInds, ~] = find_run_bouts(coords{b/2}, 5, 2);
            [~, maxRunInds] = max(diff(runInds,1,2));
            maxRunTimes = runTimes(maxRunInds,:); 
            eegStart = match(maxRunTimes(1),Lfp.lfpTs);
            eegStop = match(maxRunTimes(2),Lfp.lfpTs);

            % for each channel, get the average theta power for the run bout
            thetaPow = zeros(size(newDataArray,1),1);
            for i=1:size(newDataArray,1)
                eeg = newDataArray(i,eegStart:eegStop);
                thetaTFR = get_wavelet_power(eeg', srate, [bandStart bandStop], 6, 0, 0);
                thetaPow(i) = mean(mean(thetaTFR));
            end
            [~,thetaChan] = max(thetaPow);
%             eegplot(newDataArray, 'srate', srate, 'winlength', 3, 'spacing', 0.001 );
%             prompt = '                  Which channel has the highest amplitude theta waves?  Channel:';
%             chTheta = input(prompt);
        end
        %% Theta detection
        fprintf('\t\t\t\tDetecting theta...\n');
%         [remEdgeInds, nremEdgeInds] = find_rem_and_nrem_bouts(thetaLFP', srate, 1);

        % filter hilbert method
        thetaLFP = newDataArray(thetaChan, :);
        filtThetaLFP = filter_lfp_timeseries(thetaLFP, srate, bandStart, bandStop);
        thetaInds = find_lfp_events_in_filtered_ts(filtThetaLFP, 2500, 2, 1, minDur);
        save thetaIndices.mat thetaInds thetaChan
    end % session
end % shank
end