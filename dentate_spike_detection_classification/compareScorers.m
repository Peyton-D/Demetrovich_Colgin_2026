function [results, confuse] = compareScorers(events, tolerance)
%COMPARESCORERS  Compare event times across scorers using 1-to-1 matching.
%
% events{s} = [channel, time, value]
% tolerance = max allowed time difference (seconds) for a match

if nargin < 2
    tolerance = 0.05; % default 50 ms
end

numScorers = size(events,2);
results = struct();

for s1 = 1:numScorers
    A = events{1,s1}(:,2);  % times only

    for s2 = 1:numScorers
        if s1 == s2
            % Self-comparison is not meaningful
            results(s1,s2).precision = NaN;
            results(s1,s2).recall    = NaN;
            results(s1,s2).F1        = NaN;
            results(s1,s2).timingErrors = [];
            continue
        end

        B = events{1,s2}(:,2);

        matchedA = false(size(A));   % which A events matched
        usedB    = false(size(B));   % which B events already matched
        timingErrors = [];

        % --- One-to-one matching ---
        for i = 1:length(A)
            % Compute distances to all unused B events
            diffs = abs(B - A(i));
            diffs(usedB) = inf;  % ignore already matched B events

            [d, idx] = min(diffs);

            if d < tolerance
                matchedA(i) = true;
                usedB(idx) = true;  % prevent reuse
                timingErrors(end+1) = B(idx) - A(i);
            end
        end

        TP = sum(matchedA);
        FP = sum(~matchedA);
        FN = sum(~usedB);

        precision = TP / (TP + FP + eps); % true positive / (true positive + false positive) ie ratio of hits to potential hits
        recall    = TP / (TP + FN + eps); % true positive / (true positive + false negative) ie ratio of hits to targets
        F1        = 2 * (precision * recall) / (precision + recall + eps);

        results(s1,s2).precision = precision;
        results(s1,s2).recall    = recall;
        results(s1,s2).F1        = F1;
        results(s1,s2).timingErrors = timingErrors;
    end
end


% function results = compareScorers(events, tolerance)
% 
% if nargin < 2
%     tolerance = 0.05; % 50 ms default
% end
% 
% numScorers = numel(events);
% results = struct();
% 
% for s1 = 1:numScorers
%     for s2 = 1:numScorers
%         if s1 == s2
%             continue
%         end
% 
%         A = events{s1}(:,2);   % times only
%         B = events{s2}(:,2);
% 
%         matched = false(size(A));
%         timingErrors = [];
% 
%         for i = 1:length(A)
%             [d, idx] = min(abs(B - A(i)));
%             if d < tolerance
%                 matched(i) = true;
%                 timingErrors(end+1) = B(idx) - A(i);
%             end
%         end
% 
%         precision = sum(matched) / length(A);
%         recall    = sum(matched) / length(B);
%         F1        = 2 * (precision * recall) / (precision + recall + eps);
% 
%         results(s1,s2).precision = precision;
%         results(s1,s2).recall    = recall;
%         results(s1,s2).F1        = F1;
%         results(s1,s2).timingErrors = timingErrors;
% 
%         
%     end
% end

confuse = plotOverlapMatrix(results);

function f1 = plotOverlapMatrix(results)
    numScorers = size(results,1);
    f1 = zeros(numScorers);

    for j = 1:numScorers
        for k = 1:numScorers
            if j == k
                f1(j,k) = 1;
            else
                f1(j,k) = results(j,k).F1;
            end
        end
    end

    figure;
    imagesc(f1);
    colorbar;
    axis equal tight;
    xticks(1:numScorers)
    xticklabels(events(2,:))
    yticks(1:numScorers)
    yticklabels(events(2,:))
    xlabel("Scorer")
    ylabel("Scorer")
    title("F1 Overlap Between Scorers")
end


end