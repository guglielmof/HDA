function [] = plot_measure(measure, v_cons, manual)
    %v_cons: run (compare systems) or conv (conversations)
    common_parameters;
    
    save_path = "../../data/analysis/";
 
    %data = readtable(sprintf("../../data/%s.csv", measure), 'Format','%d%s%s%s%f%f');
    data = import_and_aggregate(measure);
    symbols = {'x', '+', 'd', 'o', '*'};
    
    alphas  = [1., 0.7, 0.5, 0.3, 0.0];

    
    if (manual)
        mruns = readtable("../../data/manual_runs.csv", 'delimiter', " ");
        mdata = data(ismember(data{:,'run'}, mruns{:, 1}), :);
        md1 = grpstats(mdata(:, {'run', 'alpha', 'score'}), {'run', 'alpha'}, 'mean');
        md1 = grpstats(md1(:, {'run', 'mean_score'}), 'run', 'std');
        
        nmdata = data(~ismember(data{:,'run'}, mruns{:, 1}), :);
        md2 = grpstats(nmdata(:, {'run', 'alpha', 'score'}), {'run', 'alpha'}, 'mean');
        md2 = grpstats(md2(:, {'run', 'mean_score'}), 'run', 'std');
        disp(quantile(md1{:, 'std_mean_score'}, 4));
        fprintf("%.3f %.3f\n", mean(md1{:, 'std_mean_score'}), median(md1{:, 'std_mean_score'}));
        disp(quantile(md2{:, 'std_mean_score'}, 4));
        fprintf("%.3f %.3f\n", mean(md2{:, 'std_mean_score'}), median(md2{:, 'std_mean_score'}));
    end

    
        
    currentFigure = figure('Visible', 'on');
    hold on;
    for an=1:length(alphas)
        a = alphas(an);
        filtered_data = data(data{:, 'alpha'}==a, :);
        agg_data = grpstats(filtered_data(:, {v_cons, 'score'}), v_cons);
        if an==1
            [~, sidx] = sort(agg_data{:, 'mean_score'});
            order = agg_data{sidx, v_cons};
        end
        c = repmat([0,0,1], length(order), 1);
          
        if (manual)
            [~,idx] = ismember(mruns{:, 1}, order);
            c(idx, :) = repmat([1, 0, 0], height(mruns), 1);
        end
        scatter(1:length(order), agg_data{order,'mean_score'},...
            [],c, symbols{an});
        %scatter(1:length(order), agg_data{order,'mean_score'}, symbols{an});
    end
    
    
   	legend(string(alphas), 'Location', 'NorthWest');
    
    if contains(measure, 'NDCG_cut_5')
        mlabel = "nDCG@5";
    elseif contains(measure, 'NDCG_cut_3')
        mlabel = "nDCG@3";
    elseif contains(measure, 'P_cut_1')
        mlabel = "P@1";
    elseif contains(measure, 'P_cut_3')
        mlabel = "P@3";
    end
    
    ylabel(sprintf("recursive %s", mlabel),'fontsize', 24, 'interpreter','latex');
    
    if strcmp(v_cons, 'run')
        xl = sprintf("CAsT systems (sorted on %s)", mlabel);
    elseif strcmp(v_cons, 'conv')
        xl = sprintf("CAsT conversations (sorted on %s)", mlabel);
        xticks(1:length(order));
        xticklabels(order);
    end
    
    xlabel(xl,'fontsize', 24, 'interpreter','latex');
    ax = gca;
    ax.FontSize = 24; 
    
    currentFigure.PaperPositionMode = 'auto';
    currentFigure.PaperUnits = 'centimeters';
    currentFigure.PaperSize = [42 22];
    currentFigure.PaperPosition = [1 1 40 20];
    
   
    print(currentFigure, '-dpdf', sprintf('%srecursive_%s_scores_%s_bin.pdf', save_path, measure, v_cons));

    close(currentFigure);
       
end 