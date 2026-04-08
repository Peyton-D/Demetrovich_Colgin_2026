function getCircularTimemaps(tbl, degreeSpan, saveOrNot)
% purpose: get circular 1-d ratemaps for 2 begin sessions using pcolor. 
% essentially, this code draws two circles (one bigger and one smaller) then
% colors the the space between the same radial points on the two circles
% according to the time per bin. it also plots the stimulus location as an angle 
% 
% Inputs:
%       tbl - output of "stimulus_zone_time_stats.m"
%       saveOrNot - whether to save images (1) or not (0)
% Outputs:
%   .png and .epsc files of ratemaps from only cells of CellTypeToPlot
% 
% PG Demetrovich
% Colgin Lab 8/2025
%% initialize
conditions = {'Empty', 'Social' 'SocialOdor' 'NonSocialOdor' 'FoxOdor' 'NovelRoom'};
conditionNames = {'Empty', 'Social' 'Social Odor' 'Nonsocial Odor' 'Fox Odor' 'Novel Room'};
sessions = {'A' 'B'};
cols = {[0.0 0.45 0.70] [0.85 0.37 0.01] [0.93 0.69 0.13] [0.0 0.62 0.45] [0.80 0.47 0.74] [0.8203 0.7031 0.5469]};
mapLength = size(tbl.TimeMaps{1},2);
radii = [.75;1]; % radii of two circles to plot color between
theta = linspace(-pi,pi,mapLength); %  position bins in radians 
X = radii*cos(theta); % x coordinates for both circles
Y = radii*sin(theta); % y coordinates for both circles
%% plot
figTitle = ['avg_timemaps_per_cond'];
figure('Name', figTitle , 'color', [1 1 1]);
theme(gcf, 'light');
pltCntr = 1;
for c=1:numel(unique(tbl.Condition))
    uName = [conditionNames{c}];
    for b=1:length(sessions)
        pullDataInds = strcmp(tbl.Condition, conditions{c}) & strcmp(tbl.Session, sessions{b});
        data_tbl = tbl(pullDataInds,:);
        avgTmMap = zeros(1,mapLength);
        for i=1:height(data_tbl)
            avgTmMap = data_tbl.TimeMaps{i} + avgTmMap;
        end
        avgTmMap = avgTmMap / height(data_tbl);
        C = avgTmMap;

        subplot(3,4,pltCntr), hold on 
        if c == 6 & b == 2
        else
            % plot stimulus zone
            X_pf_start = [0;.75]*cos(deg2rad(225+degreeSpan+180)); % have to add 180 degrees because of -pi:pi instead of 0:2pi
            Y_pf_start = [0;.75]*sin(deg2rad(225+degreeSpan+180));
            plot(X_pf_start, Y_pf_start, '--','Color', cols{c}, 'LineWidth',2);
            X_pf_end = [0;.75]*cos(deg2rad(225-degreeSpan+180)); % have to add 180 degrees because of -pi:pi instead of 0:2pi
            Y_pf_end = [0;.75]*sin(deg2rad(225-degreeSpan+180));
            plot(X_pf_end, Y_pf_end, '--', 'Color', cols{c}, 'LineWidth',2);
            
            % plot reward zone
            X_pf_start = [0;.75]*cos(deg2rad(90+degreeSpan+180)); % have to add 180 degrees because of -pi:pi instead of 0:2pi
            Y_pf_start = [0;.75]*sin(deg2rad(90+degreeSpan+180));
            plot(X_pf_start, Y_pf_start, 'k--', 'LineWidth',2);
            X_pf_end = [0;.75]*cos(deg2rad(90-degreeSpan+180)); % have to add 180 degrees because of -pi:pi instead of 0:2pi
            Y_pf_end = [0;.75]*sin(deg2rad(90-degreeSpan+180));
            plot(X_pf_end, Y_pf_end, 'k--', 'LineWidth',2);
        end

        if c == 1 & b == 1 
            lines = findobj(gca, 'Type', 'line');
            legend(lines(1:2:end),{'Reward Zone' ,'Stimulus Zone'})
            legend autoupdate off
            legend box off
        end

        p = pcolor(X,Y,[C;C]);
        p.EdgeColor =  'none';
        shading flat
        axis equal tight ij
        ax = gca;
        axis(ax, 'off')
        caxis([0 100])
        colormap hot
       
        if b ==1
            ylabel(ax,uName,'Rotation', 90, 'Interpreter', 'none', 'FontWeight','bold');
            ax.YLabel.Visible = 'on';
        end
        
        title(sessions{b});
        pltCntr = pltCntr + 1; 
    end

    if c == numel(unique(tbl.Condition))
        clbr = colorbar;
        clbr.Location = 'South';
        clbr.Position = [0.3448    0.075    0.1400    0.0206];
        clbr.Ticks = [0 50 100];
        ylabel(clbr, 'Time In Bin (s)')
    end
end

if saveOrNot == 1
            saveas(gcf, [figTitle], 'png')  %save png of this fig in day folder
            saveas(gcf, [figTitle], 'epsc')  %save eps of this fig in day folder
end

end % function