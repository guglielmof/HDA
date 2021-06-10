function [] = plot_measure_root(measure, v_cons, manual)
    %v_cons: run (compare systems) or conv (conversations)
    common_parameters;
    
    save_path = "../../data/analysis/";
 
    original_data = readtable(sprintf("../../data/%s.csv", measure), 'Format','%d%s%s%s%f%f');
    
    fid = fopen('../../data/conv_roots.csv');
    c2roots = containers.Map();
    tline = fgetl(fid);
    stline = split(tline, ",");
    c2roots(stline{1}) = stline(2:end);
    while ischar(tline)
        stline = split(tline, ",");
        c2roots(stline{1}) = stline(2:end);
        tline = fgetl(fid);
    end

    
    convs = c2roots.keys();
    fdata = original_data;
    for cn=1:length(convs)
        c = convs{cn};
        fdata = fdata((~strcmp(fdata{:, 'conv'}, c) | ismember(fdata{:, 'utt'}, c2roots(c))), :);
    end
    data = fdata;
    data(:, {'Var1', 'utt'}) = [];
    data = grpstats(data, {'conv', 'alpha', 'run'}, 'mean', ...
        'varnames', {'conv', 'alpha', 'run', 'GroupCount', 'score'});
    data(:, 'GroupCount') = [];
    
    %data = import_and_aggregate(measure);
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
    end
    
    
   	legend(string(alphas), 'Location', 'NorthWest');
    if strcmp(measure, 'NDCG_cut_5')
        ylabel("recursive nDCG@5",'fontsize', 24, 'interpreter','latex');
    elseif strcmp(measure, 'NDCG_cut_3')
        ylabel("recursive nDCG@3",'fontsize', 24, 'interpreter','latex');
    elseif strcmp(measure, 'P_cut_1')
        ylabel("recursive P@1",'fontsize', 24, 'interpreter','latex');
    elseif strcmp(measure, 'P_cut_3')
        ylabel("recursive P@3",'fontsize', 24, 'interpreter','latex');
    end
    
    if strcmp(v_cons, 'run')
        xl = "CAsT systems (sorted on nDCG)";
    elseif strcmp(v_cons, 'conv')
        xl = "CAsT conversations (sorted on nDCG)";
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
    
   
    print(currentFigure, '-dpdf', sprintf('%srecursive_%s_scores_%s_root_bin.pdf', save_path, measure, v_cons));

    close(currentFigure);
    
end 