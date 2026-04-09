function plotLfpEventSnippet_no_norm(lfp_list, lfp_time_list, lfp_labels, event_label, event_time_list, window_duration, colors, pltInd)
% Parameters
% Fs = 1000; % Sampling rate
% window_duration = 5; % seconds
step_size = 0.1; % seconds
num_lfps = length(lfp_list); % Number of LFP signals

% Initialize storage
snippets = cell(num_lfps, 1);
time_snippets = cell(num_lfps, 1);
event_snippets = cell(num_lfps, 1);
event_values = cell(num_lfps, 1);
snippet_max_list = zeros(num_lfps, 1); % for optional scale bar

for i = 1:num_lfps
    lfp = lfp_list{i};
    lfp_time = lfp_time_list{i};
    event_times = event_time_list{i};
    
    % Sliding window
    start_times = lfp_time(1):step_size:(lfp_time(end) - window_duration);
    event_counts = zeros(size(start_times));

    for j = 1:length(start_times)
        t_start = start_times(j);
        t_end = t_start + window_duration;
        event_counts(j) = sum(event_times >= t_start & event_times < t_end);
    end

    % Find max event window
    [~, max_idx] = max(event_counts);
    best_start = start_times(max_idx);
    best_end = best_start + window_duration;

    % Extract snippet
    idx = find(lfp_time >= best_start & lfp_time < best_end);
    snippet = lfp(idx);
    time_snip = lfp_time(idx);

    % Store original snippet and time aligned to 0–5s
    snippets{i} = snippet;
    time_snippets{i} = time_snip - time_snip(1);

    % Event markers
    ev_times = event_times(event_times >= best_start & event_times < best_end);
    ev_vals = interp1(lfp_time, lfp, ev_times);
    event_snippets{i} = ev_times - best_start;
    event_values{i} = ev_vals;

    % Store max amplitude for optional scale bar
    snippet_max_list(i) = max(abs(snippet));
end

% Plot all snippets stacked with preserved voltage scale
% figure;
subplot(2,2,pltInd)
hold on;
% colors = lines(num_lfps);
offset_step = max(snippet_max_list) * 2; % spacing based on largest amplitude
for i = 1:num_lfps
    offset = (i - 1) * offset_step;
    plot(time_snippets{i}, snippets{i} + offset, 'Color', colors(i,:));
    scatter(event_snippets{i}, event_values{i} + offset, 10, colors(i,:), 'filled', 'Marker', 'o');

    % Add label
    text(0.1, offset + max(snippets{i}) + 0.2 * offset_step, lfp_labels{i}, ...
        'Color', colors(i,:), 'FontSize', 10, 'FontWeight', 'bold');
end

% Add scale bar (e.g., 1 mV)
bar_y2 = 0.003; % V
bar_x2 = window_duration + 0.05 ;
bar_y1 = -.002;
plot([bar_x2 bar_x2], [bar_y1 bar_y2], 'k', 'LineWidth', 2);
text(bar_x2 + 0.015, bar_y1 + (bar_y2 -bar_y1)/2, [num2str((bar_y2 - bar_y1)*1000) ' mV'], ...
    'FontSize', 10, 'HorizontalAlignment', 'left');
if window_duration == 5
    bar_x1 = bar_x2 - 0.5;
elseif window_duration == 2
    bar_x1 = bar_x2 - 0.25;
end
plot([bar_x1 bar_x2], [bar_y1 bar_y1], 'k', 'LineWidth', 2);
text(bar_x1 + (bar_x2-bar_x1)/2, bar_y1 - .002, [num2str((bar_x2 - bar_x1)) ' s'], ...
    'FontSize', 10, 'HorizontalAlignment', 'center');

xlabel('Time (s)');
ylabel('Voltage (mV, stacked)');
title(['Max ' event_label ' LFP Snippets']);
set(gca, 'ytick', []);
xlim([0 window_duration + 0.3]);
ylim([-.005 max(get(gca, 'YLim'))+ .0015])
box on;
hold off;

end