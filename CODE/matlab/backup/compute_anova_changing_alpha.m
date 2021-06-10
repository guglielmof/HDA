function []=compute_anova_changing_alpha(measure)

    common_parameters;
    
    data = import_and_aggregate(measure);
    
    alphas = unique(data{:, 'alpha'});
    

    
    ssd_p = zeros(length(alphas), 1);

            
    for an=1:length(alphas)

        [~, ~, mc] = compute_anova('MD1', data, 'alphas', [alphas(an)]);

        ssd_p(an) = sum(mc{:, 6}<0.05);
    end
    
    
    currentFigure = figure('Visible', 'off');
    
    hold on;
    
    ax = gca;
    ax.FontSize = 24; 
    ax.YGrid = 'on';
    
    b = bar(ssd_p);
    text((1:length(alphas))-0.4, ssd_p+30, int2str(ssd_p), 'fontsize', 24);
    
    b.FaceColor = 'flat';

    if ~contains(measure, 'only_roots')
        b.CData(alphas==1.,:) = [.8 .2 .1];
    end
    xticks(1:length(alphas));
    xticklabels(alphas);
    xlabel("$\alpha$",'fontsize', 24, "Interpreter", "latex");
    ylabel("ssd pairs", 'fontsize', 24);
    
    
    currentFigure.PaperPositionMode = 'auto';
    currentFigure.PaperUnits = 'centimeters';
    currentFigure.PaperSize = [42 22];
    currentFigure.PaperPosition = [1 1 40 20];

    print(currentFigure, '-dpng', sprintf("../../data/ANOVA-MD1-ssd_pairs-%s.png", measure));

    close(currentFigure);
    
    
    [~, ~, mc] = compute_anova('MD2', data);

    disp(sum(mc{:, 6}<0.05));
    
    
end