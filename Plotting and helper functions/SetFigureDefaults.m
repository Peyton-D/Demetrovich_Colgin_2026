function  SetFigureDefaults()
  % put all common figure formatting code here
  set(gcf,'renderer','Painters')
  set(findall(gcf,'-property','FontSize'),'FontSize',12)
  % set(gca,'fontname','Arial')
  set(0, 'DefaultAxesFontName', 'Arial');       % Axes labels, ticks
  set(0, 'DefaultTextFontName', 'Arial');       % Text objects
  set(0, 'DefaultLegendFontName', 'Arial');     % Legends
  set(0, 'DefaultColorbarFontName', 'Arial');   % Colorbars
end