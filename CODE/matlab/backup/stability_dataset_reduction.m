function []=stability_dataset_reduction(TAG, measure)

    common_parameters;

    
    save_path = "../../data/analysis/";
    data = readtable(sprintf("%saggregated_%s.csv", save_path, measure));
    
    reps = unique(data{:, 'rep'});
    probs = unique(data{:, 'p'});
    alphas = unique(data{:, 'alpha'});
    
    ssd_pairs = cell(length(alphas)*length(probs)*length(reps), 4);

    for idx =1:length(alphas)*length(probs)*length(reps)
        an = int64(idivide(int64(idx-1), int64(length(probs)*length(reps)))+1);
        pn = int64(mod(idivide(int64(idx-1), int64(length(reps))), length(probs))+1);
        rn = mod(idx-1, length(reps))+1;
        
        
        a = alphas(an);
        p = probs(pn);
        r = reps(rn);

        
        filtered_data = data(((data{:,'alpha'}==a )& ...
                             (data{:,'p'}==p )& ...
                             (data{:,'rep'}==r )) ...
                             ,:);

        [~, ~, sts] = EXPERIMENT.analysis.anova.(TAG)(...
         filtered_data{:,'score'}, ...
         filtered_data{:,'conv'}, ...
         filtered_data{:, 'run'}); 

        [c,~,~,~] = multcompare(sts,  'ctype', 'hsd', 'dimension', 2, 'display', 'off');
        ssd_p = sum(c(:, 6)<EXPERIMENT.analysis.alpha);

        ssd_pairs(idx, :) = {a, p, r, ssd_p};
        
    end

    
    ssd_pairs = cell2table(ssd_pairs, "VariableNames", {'alpha', 'p', 'rep', 'ssd_pairs'});
    
    result = grpstats(ssd_pairs(:, {'alpha', 'p', 'ssd_pairs'}), {'alpha', 'p'}, ...
        {'mean',...
        @(x) confidenceIntervalDelta(x, EXPERIMENT.analysis.alpha)},...
        'varnames', {'alpha','p', 'GroupCount', 'ssd_pairs', 'ci'});
    
     
        
    print_figure_from_table(table, 'alpha', 'p', 'ssd_pairs',...
        'xlabel', 'proportion of pool',...
        'ylabel', 'ssd pairs',...
        'savepath', sprintf('%sdownsample_ssd_pairs_%s_%d.pdf', save_path, measure, B));

end

