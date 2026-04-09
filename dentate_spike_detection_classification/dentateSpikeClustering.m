function [pc12, labels] = dentateSpikeClustering(CSD)
% Inputs:
% CSD: [nCh x nEvents], channels ordered deep DG -> fissure (via sortInd)
%      If not yet ordered, do: CSD = CSD(sortInd, :);
% Optional: energy vector per event, or compute it below.
cols = 'rbgmoc'; 
[nCh, nE] = size(CSD);

% 1) Per-event normalization across depth (shape-only)
profiles = CSD; % copy
% profiles1 = CSD(sinks(1), :);
% profiles2 = CSD(sinks(2), :);
% profiles = [profiles1; profiles2];
% z-score each column (event) across channels
mu = mean(profiles, 1);
sd = std(profiles, [], 1);
% sd(sd==0) = eps;
profiles = (profiles - mu) ./ sd;

% % Optional: polarity unification (use when sessions/reference flips sign)
% % Build a coarse template (e.g., mean of top-energy events), then align signs
% Compute a crude energy per event to pick a stable template
% E = sqrt(sum(profiles.^2, 1)); 
% % [~, idxTop] = maxk(E, min(100, nE)); 
% % template = mean(profiles(:, idxTop), 2);
% % template = template / norm(template);
% % dots = template' * profiles;      % 1 x nE
% % flipIdx = dots < 0;
% % profiles(:, flipIdx) = -profiles(:, flipIdx);
% % 
% % % Optional: drop low-energy events (keeps DS contrast crisper)
% th = prctile(E, 20); 
% keep = E > th;
% profiles_thresh = profiles(:, keep);
% E = E(keep);
% fprintf('Events kept after energy filter: %d / %d\n', sum(keep), nE);

% 2) PCA on events (rows) × depth (columns)
% Transpose so rows = events
[coeff, score, latent, tsq, explained] = pca(profiles.', ...
    'Algorithm','svd', 'Centered',true);

fprintf('Explained variance: PC1=%.1f%%, PC2=%.1f%%\n', explained(1), explained(2));

pc12 = score(:,1:2);

% figure; 
% scatter(pc12(:,1), pc12(:,2), 10, 'k', 'filled'); 
% xlabel('PC1'); ylabel('PC2'); title('Event-wise PCA (z-scored across depth)'); grid on;

% 3) Choose DBSCAN epsilon from k-distance plot
k = 5; % dims=2 -> k ~ 4-6 is common
[~, D] = knnsearch(pc12, pc12, 'K', k+1); % includes self
kDist = D(:, end);
kDistSorted = sort(kDist);

% figure; plot(kDistSorted, 'LineWidth',1.5); grid on;
% xlabel('Events (sorted)'); ylabel(sprintf('%d-NN distance', k));
% title('k-distance plot (pick \epsilon near the knee)');

% Heuristic epsilon (adjust after inspecting the knee):
eps = prctile(kDist, 90); 
MinPts = round(.05 * nE);%30;%max(5, 2*k);

% labels = dbscan(pc12, eps, MinPts, 'Distance','euclidean'); % try 'cosine' if needed
% labels = clusterdata(pc12, MaxClust=3, Linkage='single', Criterion='inconsistent');
labels = kmeans(pc12, 2);
nClust = max(labels);
% fprintf('DBSCAN clusters found: %d (noise label = -1)\n', nClust);

figure; 
subplot(4,4,[1,2,5,6])
imagesc(profiles)
caxis([-3 3])
colormap jet
clbr = colorbar;
% clbr.Position = [0.49    0.625    0.0100    0.20];
% clbr.Ticks = [-3 3];
% clbr.TickLabels = {'Sink', 'Source'};
ylabel(clbr, 'CSD (z-score)')
title('PCA Input')
ylabel({'Depth index'; '(ventral \leftrightarrow dorsal)'})
xlabel('DS #')
% yticks('')

subplot(4,4,[3,7])
gscatter(pc12(:,1), pc12(:,2), labels, cols);
xlabel('PC1'); ylabel('PC2'); title('Clustering on PC1-2'); grid on;
% saveas(gcf, 'kmeans_ds_clustering', 'png')
% close
% 
% % 4) Cluster sanity checks: silhouette and depth profiles
% % validIdx = labels > 0;
% % if any(validIdx)
% %     figure; silhouette(pc12(validIdx,:), labels(validIdx));
% %     title('Silhouette (DBSCAN, clustered points only)');
% % end
% 
% Plot cluster-average depth profiles (shape)
% figure; hold on;
subplot(4,4,[4,8]), hold on
plot(nan, nan, 'Color', cols(1), 'LineWidth', 1.8,  'DisplayName', ['Cluster 1'] );
plot(nan, nan, 'Color', cols(2), 'LineWidth', 1.8,  'DisplayName', ['Cluster 2'] );
legend()
legend('AutoUpdate','off')
% cmap = lines(max(labels));
% cols = 'rcm';
colInd = 1;
for c = unique(labels)'%1:nClust
    
    ei = labels == c;
    if ~any(ei), continue; end
    m = mean(profiles(:, ei), 2);
%     m = mean(CSD(:, ei), 2);
    s = std(profiles(:, ei), [], 2) ./ sqrt(sum(ei));
%     s = std(CSD(:, ei), [], 2) ./ sqrt(sum(ei));
    % Basic error band without external functions:
    x = 1:size(profiles,1);%1:nCh;
    fill([m'-s', fliplr(m'+s')], [x, fliplr(x)], [0.5 0.5 0.5], ...
         'FaceAlpha', 0.15, 'EdgeColor','none', 'DisplayName', '' ); 
    plot(m, x, 'Color', cols(colInd), 'LineWidth', 1.8,  'DisplayName', ['Cluster ' num2str(c)] );
    colInd = colInd+1;
end
hold off; 
axis ij
ylabel({'Depth index'; '(ventral \leftrightarrow dorsal)'}); xlabel('CSD (z-score)');
title('Cluster-average CSD depth profiles');
% legend(arrayfun(@(x) sprintf('Cluster %d', x), 1:nClust, 'UniformOutput', false), 'Location','best');
grid on;

[sortLabels, sortInds] = sort(labels);
sortProfiles = profiles(:,sortInds);
subplot(4,4,[9,10,13,14])
imagesc(sortProfiles)
caxis([-3 3])
colormap jet
clbr = colorbar;
% clbr.Position = [0.49    0.625    0.0100    0.20];
% clbr.Ticks = [-3 3];
% clbr.TickLabels = {'Sink', 'Source'};
ylabel(clbr, 'CSD (z-score)')
title('CSD sorted by cluster')
ylabel({'Depth index'; '(ventral \leftrightarrow dorsal)'})
xlabel('DS #')
xline(find(diff(sortLabels)==1)+.5, '--','LineWidth',1)
% saveas(gcf, 'kmeans_clustered_CSDs', 'png')
% close
end
