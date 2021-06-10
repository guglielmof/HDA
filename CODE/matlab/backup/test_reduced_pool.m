function []=test_reduced_pool(measure, varargin)

    common_parameters;

    data = readtable(sprintf("../../data/analysis/aggregated_downsampled_%s.csv", measure));
    
    ps = unique(data{:, 'p'});
    reps = unique(data{:, 'rep'});
    
    data_original = import_and_aggregate(measure);
    
    
    [~, ~, ref_mc_micro] = compute_anova('MD2', data_original);

    [~, ~, ref_mc_macro] = compute_anova('MD1', data_original, 'alphas', [1.0]);

    
    sampled_mc_micro = cell(length(reps), length(ps));
    sampled_mc_macro = cell(length(reps), length(ps));
    
    
    
    for pn=1:length(ps)
        p = ps(pn);

        
        for rn=1:length(reps)
            rep = reps(rn);
            filtered_data = data((data{:,'p'}==p & data{:, 'rep'}==rep), :);
            
            %compute anova using all the filtered data
            [~, ~, mc] = compute_anova('MD2', filtered_data);
            
            sampled_mc_macro{rn, pn} = mc;

            
            %compute anova using only alpha = 1.0
            [~, ~, mc] = compute_anova('MD1', filtered_data, 'alphas', [1.0]);
            sampled_mc_micro{rn, pn} = mc;
            
            
        end
        
    end
    
    
    for pn=1:length(ps)
        
        %multcompares
        mcs = sampled_mc_macro(:,pn);
        
        %ssd pairs for different multcompairs
        ssds = cellfun(@(x) sum(x{:,6}<EXPERIMENT.analysis.alpha), mcs);

        %compare multipole comparisons
        cmc = comp_multcompare(ref_mc_macro,  mcs, EXPERIMENT.analysis.alpha);
        
        result = [ssds, cmc(:, [2, 6, 7])];
        fprintf("%d ", ps(pn));
        fprintf("%.3f$\\pm$%.3f ", reshape([mean(result); confidenceIntervalDelta(result, EXPERIMENT.analysis.alpha)], 1, []))
        fprintf("\n");
        
        
                
        %multcompares
        mcs = sampled_mc_micro(:, pn);
        
        %ssd pairs for different multcompairs
        ssds = cellfun(@(x) sum(x{:,6}<EXPERIMENT.analysis.alpha), mcs);

        %compare multipole comparisons
        cmc = comp_multcompare(ref_mc_micro,  mcs, EXPERIMENT.analysis.alpha);
        
        result = [ssds, cmc(:, [2, 6, 7])];
        fprintf("%d ", ps(pn));
        fprintf("%.3f$\\pm$%.3f ", reshape([mean(result); confidenceIntervalDelta(result, EXPERIMENT.analysis.alpha)], 1, []))
        fprintf("\n");
        
    end
    
end