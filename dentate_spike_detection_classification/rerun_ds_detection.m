% rerun all ds detections 
function rerun_ds_detection(cellStruct, thresh)
% Purpose: loop through all recordings included in cellStruct, detecting dentate spikes, getting dentate spike CSDs, 
% and identifying epochs of high theta
%
% Inputs: 
%   cellStruct - data structure containing info on all recordings
%   thresh - standard deviation threshold for dentate spike detection (should be validated by evaluate_scoring.m)       
%
% Outputs: 
%   none (files saved to corresponding recording folder)
%
% Peyton D
% Colgin Lab 2026
%% initialize
projDir = 'D:/NeuropixelsData/';
cd(projDir)
%%
for r=1:length(cellStruct.rat) 
    fprintf('%s\n', cellStruct.rat(r).name)
    for c=1:length(cellStruct.rat(r).cond)
        for d=1:length(cellStruct.rat(r).cond(c).day)
            fprintf('\t%s Day %d\n', cellStruct.rat(r).cond(c).name, d)
            cd(cellStruct.rat(r).cond(c).day(d).dataLoc);
            fprintf('\t\t%s\n', cellStruct.rat(r).cond(c).day(d).name)
            shankNums = cellStruct.rat(r).cond(c).day(d).shankNums;
            if numel(shankNums) > 1
                shankToUse = cellStruct.rat(r).cond(c).day(d).ds_shankInd;
            else
                shankToUse = 1;
            end
            % detect dentate spikes and get CSDs
            getDS_CSD_per_shank_v4(shankNums(shankToUse), thresh)
            
            % get epochs of high theta
            coords{1} = cellStruct.rat(r).cond(c).day(d).session(2).coords_2d; 
            coords{2} = cellStruct.rat(r).cond(c).day(d).session(4).coords_2d; 
            coords{3} = cellStruct.rat(r).cond(c).day(d).session(6).coords_2d; 
            coords{4} = cellStruct.rat(r).cond(c).day(d).session(8).coords_2d; 
            getThetaEpochs_per_shank(shankNums(shankToUse), coords, 5, 10)
        end % day
    end % cond
end % rat