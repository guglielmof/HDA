function []=print_figure_from_table(tbl, f1, f2, f3, varargin)

    assert(mod(length(varargin), 2)==0);
    params = containers.Map();    
    for i=1:2:length(varargin)
        params(varargin{i}) = varargin{i+1};
    end
   
    currentFigure = figure('Visible', 'off');
    
    hold on;
    
    ax = gca;
    ax.FontSize = 16; 

    uf1 = unique(tbl{:, f1});

    labels = {};
    for k=1:length(uf1)
        labels{end+1} = string(uf1(k));
        rowIdcs = tbl{:, f1}==uf1(k); 
        plot(tbl{rowIdcs, f2}, tbl{rowIdcs, f3});
    end
    legend(labels,'fontsize', 24, 'interpreter','latex', 'location', 'northoutside', 'orientation', 'horizontal');

    if isKey(params, 'xlabel')
        xlabel(params('xlabel'),'fontsize', 24, 'interpreter','latex');
    end
    if isKey(params, 'ylabel')
        ylabel(params('ylabel'), 'fontsize', 24, 'interpreter','latex');
    end
    
    currentFigure.PaperPositionMode = 'auto';
    currentFigure.PaperUnits = 'centimeters';
    currentFigure.PaperSize = [42 22];
    currentFigure.PaperPosition = [1 1 40 20];
    if isKey(params, 'savepath')
        print(currentFigure, '-dpdf', params('savepath'));
    end
    
    close(currentFigure);
   
end