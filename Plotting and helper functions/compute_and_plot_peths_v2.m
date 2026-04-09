function [peth, frMod, bin_centers] = compute_and_plot_peths_v2( ...
        spike_times_cell, event_times, full_window, base_window, roi_window, bin_size)

    % Build edges and bin centers
    edges = full_window(1):bin_size:full_window(2);
    bin_centers = edges(1:end-1) + bin_size/2;

    num_neurons = numel(spike_times_cell);
    num_bins = numel(edges) - 1;
    num_events = numel(event_times);

    peth = zeros(num_neurons, num_bins);

    % ---- STEP 1: Build PETH for each neuron (vectorized per neuron) ----
    for n = 1:num_neurons
        spikes = spike_times_cell{n}(:)';  
        if isempty(spikes)
            continue
        end

        aligned = spikes - event_times(:);  % event × spike matrix
        mask = aligned >= full_window(1) & aligned <= full_window(2);
        aligned_spikes = aligned(mask);

        peth(n,:) = histcounts(aligned_spikes, edges);
    end

    % Normalize to Hz
    peth = peth / (num_events * bin_size);

    % Smooth
    peth = smoothdata(peth, 2, 'gaussian', 5);

    % ---- STEP 2: Compute baseline and ROI indices once ----
    base_idx = bin_centers >= base_window(1) & bin_centers <= base_window(2);
    roi_idx  = bin_centers >= roi_window(1)  & bin_centers <= roi_window(2);

    % ---- STEP 3: Compute modulation for all neurons at once ----
    baseline_avg = mean(peth(:, base_idx), 2);
    roi_avg      = mean(peth(:, roi_idx), 2);

    frMod = roi_avg - baseline_avg;
end

% function [peth, frMod, bin_centers] = compute_and_plot_peths_v2( ...
%         spike_times_cell, event_times, full_window, base_window, roi_window, bin_size)
% 
%     % Build edges and bin centers
%     edges = full_window(1):bin_size:full_window(2);
%     bin_centers = edges(1:end-1) + bin_size/2;
% 
%     num_neurons = numel(spike_times_cell);
%     num_bins = numel(edges) - 1;
%     num_events = numel(event_times);
% 
%     peth = zeros(num_neurons, num_bins);
%     frMod = zeros(num_neurons, 1);
% 
%     % Precompute event-time matrix for vectorization
%     % Each row = event, each column = spike
%     for n = 1:num_neurons
%         spikes = spike_times_cell{n}(:)';  % row vector
%         if isempty(spikes)
%             continue
%         end
% 
%         % Vectorized alignment:
%         % aligned(i,j) = spike_j - event_i
%         aligned = spikes - event_times(:);
% 
%         % Keep only spikes within window
%         mask = aligned >= full_window(1) & aligned <= full_window(2);
% 
%         % Extract all aligned spikes in window
%         aligned_spikes = aligned(mask);
% 
%         % Vectorized histogram
%         peth(n,:) = histcounts(aligned_spikes, edges);
% 
%         % Normalize to Hz
%         peth(n,:) = peth(n,:) / (num_events * bin_size);
% 
%         % Smooth
%         peth(n,:) = smoothdata(peth(n,:), 'gaussian', 5);
% 
%         % Baseline and ROI indices
%         base_idx = bin_centers >= base_window(1) & bin_centers <= base_window(2);
%         roi_idx  = bin_centers >= roi_window(1)  & bin_centers <= roi_window(2);
% 
%         baseline_avg = mean(peth(n, base_idx));
%         roi_avg      = mean(peth(n, roi_idx));
% 
%         frMod(n) = roi_avg - baseline_avg;
%     end
% end

% function [peth, frMod] = compute_and_plot_peths_v2(spike_times_cell, event_times, full_window, base_window, roi_window, bin_size)
% 
%     edges = full_window(1):bin_size:full_window(2);
%     bin_centers = edges(1:end-1) + bin_size/2;
% 
%     num_neurons = length(spike_times_cell);
%     peth = zeros(num_neurons, length(edges)-1);
%     frMod = zeros(num_neurons, 1);
% 
%     for n = 1:num_neurons
%         spikes = spike_times_cell{n};
% 
%         % Build PETH
%         for i = 1:length(event_times)
%             aligned = spikes - event_times(i);
%             mask = aligned >= full_window(1) & aligned <= full_window(2);
%             peth(n,:) = peth(n,:) + histcounts(aligned(mask), edges);
%         end
% 
%         % Convert to Hz
%         peth(n,:) = peth(n,:) / length(event_times) / bin_size;
% 
%         % Smooth
%         peth(n,:) = smoothdata(peth(n,:), 'gaussian', 5);
% 
%         % Baseline and ROI indices
%         base_idx = bin_centers >= base_window(1) & bin_centers <= base_window(2);
%         roi_idx  = bin_centers >= roi_window(1)  & bin_centers <= roi_window(2);
% 
%         baseline_avg = mean(peth(n, base_idx));
%         roi_avg      = mean(peth(n, roi_idx));
% 
%         frMod(n) = roi_avg - baseline_avg;
%     end
% end

% function [peth, frMod] = compute_and_plot_peths_v2(spike_times_cell, event_times, full_window, base_window, roi_window, bin_size)
%     % Inputs:
%     % - spike_times_cell: cell array of spike time vectors (one per neuron)
%     % - event_times: vector of event timestamps
%     % - full_window: [start, end] full window in seconds to construct PETH
%     % - base_window: [start, end] baseline window in seconds for baseline subtraction (e.g., -200ms to -100ms)
%     % - roi_window: [start, end] time window of interest in seconds (e.g., around peak)
%     % - bin_size: bin size in seconds
%     % Outputs:
%     % - peth: peri-event time histogram of firing in Hz
%     % - frMod: firing rate modulation in Hz (baseline subtracted)
%     
%     edges = full_window(1):bin_size:full_window(2);
%     num_neurons = length(spike_times_cell);
%     peth = zeros(num_neurons, length(edges)-1);
%     frMod = zeros(num_neurons, 1);
%     for n = 1:num_neurons
%         spikes = spike_times_cell{n};
%         for i = 1:length(event_times)
%             aligned_spikes = spikes - event_times(i);
%             spikes_in_window = aligned_spikes(aligned_spikes >= full_window(1) & aligned_spikes <= full_window(2));
%             peth(n,:) = peth(n,:) + histcounts(spikes_in_window, edges);
%         end
%         peth(n,:) = peth(n,:) / length(event_times) / bin_size;
%         peth(n,:) = smoothdata(peth(n,:),'gaussian',5); 
%         baseline_avg = mean( peth(n,match(base_window(1),edges):match(base_window(2),edges)) );
%         roi_avg = mean( peth(n,match(roi_window(1),edges):match(roi_window(2),edges)) );
%         frMod(n,1) = roi_avg - baseline_avg; 
%     end
% end