function offset = plotLFPstack(t, LFP, varargin)
% plotLFPstack  Plot stacked LFP traces with adaptive spacing and a scale bar.
%
%   plotLFPstack(LFP, fs) plots the channels in LFP (channels x timepoints) in VOLTS
%   stacked vertically with spacing based on the largest peak-to-peak amplitude.
%
%   plotLFPstack(..., 'SpacingFactor', val) sets the spacing multiplier
%   (default = 1.5).
%
%   plotLFPstack(..., 'ScalebarTime', val) sets the horizontal scale bar length
%   in seconds (default = 0.5).
%
%   plotLFPstack(..., 'ScalebarVoltage', val) sets the vertical scale bar height
%   in volts (default = 100e-6).
%
% Example:
%   fs = 1000;
%   LFP = 100e-6 * randn(8, 2000);
%   plotLFPstack(LFP, fs, 'SpacingFactor', 2, 'ScalebarVoltage', 50e-6);

% --- Parse inputs ---
p = inputParser;
addParameter(p, 'SpacingFactor', 1.5, @isnumeric);
addParameter(p, 'ScalebarTime', 0.1, @isnumeric);
addParameter(p, 'ScalebarVoltage', 1e-3, @isnumeric);
parse(p, varargin{:});

spacing_factor = p.Results.SpacingFactor;
scalebar_time = p.Results.ScalebarTime;
scalebar_voltage = p.Results.ScalebarVoltage;

% --- Time vector ---
nChannels = size(LFP, 1);
% nTimepoints = size(LFP, 2);
% t = (0:nTimepoints-1) / fs;

% --- Determine adaptive offset ---
ptp_all = max(LFP, [], 2) - min(LFP, [], 2);
max_ptp = max(ptp_all);
offset = spacing_factor * max_ptp; % volts

% --- Plot ---
% colors = lines(nChannels);
% figure, 
hold on
% subplot(4,4,[1,9]), hold on
% for ch = 1:nChannels
%     plot(t, LFP(ch,:) + (ch-1)*offset, '-k')
% end
for ch = 1:nChannels
    plot(t, LFP(ch,:) + (nChannels - ch) * offset, '-k')
end
% --- Beautify axes ---
xlabel('Time (s)')
ylabel('Channels')
yticks((0:nChannels-1)*offset)
yticklabels(nChannels:-1:1)
% set(gca, 'YDir', 'reverse') % optional: channel 1 at top
box off

% --- Add scale bar ---
% x_start = t(end) - scalebar_time - 0.1; % position near right
x_start = t(end) - scalebar_time; % position near right
y_start = -offset;%/2; % position below first trace

% Horizontal bar (time)
plot([x_start, x_start + scalebar_time], [y_start, y_start], 'k', 'LineWidth', 2)
text(x_start + scalebar_time/2, y_start - scalebar_voltage/5, ...
    sprintf('%.0f ms', scalebar_time*1000), ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')

% Vertical bar (voltage)
plot([x_start, x_start], [y_start, y_start + scalebar_voltage], 'k', 'LineWidth', 2)
text(x_start - scalebar_time/10, y_start + scalebar_voltage/2, ...
    sprintf('%.0f mV', scalebar_voltage*1e3), ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle')

% title('Stacked LFP traces with adaptive spacing and scale bar')

end
