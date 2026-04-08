%% 1) Figure-level horizontal highlight bars above an axes
% ax          = axes handle (e.g., gca or handle from nexttile)
% xranges     = Nx2 matrix of x ranges in data units, e.g. [0.01 0.02; 0.05 0.06]
% yOffset     = vertical offset above axes in normalized units (default 0.01)
% barHeight   = height of the bar in normalized units (default 0.02)
% color       = RGB color or Nx3 array
function h = add_highlight_above_axes(ax, xranges, yOffset, barHeight, color)
if nargin<3 || isempty(yOffset), yOffset = 0.01; end
if nargin<4 || isempty(barHeight), barHeight = 0.02; end
if nargin<5 || isempty(color), color = [1 0.8 0.8]; end

ax = handle(ax);
origUnits = get(ax, 'Units');
set(ax, 'Units', 'normalized');
axpos = get(ax, 'Position');                 % [left bottom width height] in normalized fig units
set(ax, 'Units', origUnits);

xlim_ax = get(ax, 'XLim');
% ensure xranges is Nx2
xranges = reshape(xranges, [], 2);

h = gobjects(size(xranges,1),1);
fig = ancestor(ax,'figure');
for k = 1:size(xranges,1)
    xr = xranges(k,:);
    % clamp within xlim
    xr(1) = max(xr(1), xlim_ax(1));
    xr(2) = min(xr(2), xlim_ax(2));
    if xr(2) <= xr(1), continue; end
    % normalized x within the axes box
    nx1 = axpos(1) + axpos(3) * ( (xr(1) - xlim_ax(1)) / (xlim_ax(2)-xlim_ax(1)) );
    nx2 = axpos(1) + axpos(3) * ( (xr(2) - xlim_ax(1)) / (xlim_ax(2)-xlim_ax(1)) );
    ny  = axpos(2) + axpos(4) + yOffset;        % start above axes
    nwidth  = nx2 - nx1;
    nheight = barHeight;
    % use annotation rectangle in normalized figure units
    pos = [nx1, ny, nwidth, nheight];
    if size(color,1) > 1
        c = color(k,:);
    else
        c = color;
    end
    h(k) = annotation(fig, 'rectangle', pos, 'Color', 'none', ...
                      'FaceColor', c, 'FaceAlpha', 0.75, 'LineStyle', 'none');
end
end