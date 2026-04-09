function [ds1Cluster, ds2Cluster] = assignClusterType_v2(ds_cluster)

% --- Compute average CSD for each cluster ---
avgClust1 = mean(ds_cluster(1).CSD,3);
avgClust2 = mean(ds_cluster(2).CSD,3);

% --- Compute reversal depths using robust method ---
iso1 = findReversalDepth(avgClust1);
iso2 = findReversalDepth(avgClust2);

% --- Plot results ---
figure
subplot(121)
imagesc(avgClust1)
yline(iso1,'--','Reversal')
title('Cluster 1')
caxis([-1.5e4 1.5e4])
colormap jet

subplot(122)
imagesc(avgClust2)
yline(iso2,'--','Reversal')
title('Cluster 2')
caxis([-1.5e4 1.5e4])

% --- Assign DS1 vs DS2 based on reversal depth ---
if iso1 < iso2
    ds1Cluster = ds_cluster(1);
    ds2Cluster = ds_cluster(2);
    disp('Cluster 1 is DS1!')
else
    ds1Cluster = ds_cluster(2);
    ds2Cluster = ds_cluster(1);
    disp('Cluster 2 is DS1!')
end

keyboard
close
end


% ============================================================
% ===============  ROBUST REVERSAL DETECTOR  =================
% ============================================================

function iso = findReversalDepth(avgCSD)

depthRange = 1:100;
timeWindow = 120:140;   % average across time window for stability

% 1. Extract and smooth the depth profile
csdLine = mean(avgCSD(depthRange, timeWindow), 2);
csdLine = smooth(csdLine, 7);   % 7‑point smoothing

% 2. Find the main sink (largest negative deflection)
[~, sinkDepth] = min(csdLine);

% 3. Compute derivative to find strongest sink→source transition
dCSD = diff(csdLine);
% % [~, maxSlopeIdx] = max(abs(dCSD));
[~, iso] = max(abs(dCSD));

% % 4. Restrict search to region near the main sink
% searchWindow = sinkDepth + (-12:12);
% searchWindow = searchWindow(searchWindow >= 1 & searchWindow <= length(csdLine));
% 
% % 5. Within this window, find the point closest to zero
% [~, localZeroIdx] = min(abs(csdLine(searchWindow)));
% iso = searchWindow(localZeroIdx);

% % 6. Fit a line around the steepest slope to refine the zero crossing
% fitIdx = maxSlopeIdx-2 : maxSlopeIdx+2;
% fitIdx = fitIdx(fitIdx >= 1 & fitIdx <= length(csdLine));
% 
% p = polyfit(fitIdx, csdLine(fitIdx), 1);
% iso = round(-p(2)/p(1));   % zero of the fitted line
% 
% 7. Clamp to valid range
iso = max(min(iso, length(depthRange)), 1);

end
