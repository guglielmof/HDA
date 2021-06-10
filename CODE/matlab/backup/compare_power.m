function [] = compare_power(TAG, measure, B)

    common_parameters;
    
    save_path = "../../data/analysis/";
    data = readtable(sprintf("../../data/%s.csv", measure));
    data(:, 'Var1') = [];
    data(:, 'utt') = [];

    data = grpstats(data, {'conv', 'alpha', 'run'}, 'mean', 'varnames', {'conv', 'alpha', 'run', 'GroupCount', 'score'});
    data(:, 'GroupCount') = [];


    alphas = unique(data{:, 'alpha'});
    convs = unique(data{:, 'conv'});
    nconvs = 2:3:length(convs);
    alphas = alphas(end:end);
    %nconvs = nconvs(end-2:end);


    keep = cell(length(alphas)*length(nconvs)*B, 6);
    

    for an=1:length(alphas)
        for cn=1:length(nconvs)

            fprintf("computing %d ANOVAs using recursive %s (alpha=%.1f) for %d sampled conversations\n", B, measure, alphas(an), nconvs(cn))

            comps = {}; %mc tables
            for b=1:B
                %compute anova by sampling some conversations
                sampled_convs = datasample(convs, nconvs(cn));

                filtered_data = data((ismember(data{:,'conv'}, sampled_convs) & ...
                                     (data{:,'alpha'}==alphas(an))), :);
                                 
                
                N = height(filtered_data);
                [~, tbl, sts] = EXPERIMENT.analysis.anova.(TAG)(...
                filtered_data{:,'score'}, ...
                filtered_data{:,'conv'}, ...
                filtered_data{:, 'run'}); 

                [c,m,h,gnms] = multcompare(sts,  'ctype', 'hsd', 'dimension', 2, 'display', 'off');
                soa = compute_SOA(N, tbl, {'Topics', 'Systems'});
                ssd_p = sum(c(:, 6)<EXPERIMENT.analysis.alpha);

                keep((an-1)*(length(nconvs)*B)+(cn-1)*B+b, :) = {alphas(an), nconvs(cn), b, ssd_p, soa.omega2p.Systems, soa.omega2p.Topics};

            end
        end


    end
    

    fprintf("Data processed: saving figures and data.\n")

    
    keep = cell2table(keep, 'VariableNames', {'alpha', 'nconvs', 'b', 'ssd_pairs', 'effect_size_system', 'effect_size_topic'});
    %writetable(keep,sprintf("%sssd_table_%s_%d.csv", save_path, measure, B));

    aggregate_keep = grpstats(keep(:, {'alpha', 'nconvs', 'ssd_pairs', 'effect_size_system', 'effect_size_topic'}), {'alpha', 'nconvs'}, ...
            {'mean',...
            @(x) confidenceIntervalDelta(x, EXPERIMENT.analysis.alpha)},...
            'varnames', {'alpha', 'nconvs', 'count', 'ssd_pairs', 'sp_ci', 'effect_size_system', 'ess_ci', 'effect_size_topic', 'est_ci'});
     
    disp(aggregate_keep);
    %{   
    print_figure_from_table(aggregate_keep, 'nconvs', 'alpha', 'ssd_pairs',...
        'xlabel', '$\alpha$',...
        'ylabel', 'ssd pairs',...
        'savepath', sprintf('%sssd_pairs_%s_%d.pdf', save_path, measure, B));

    print_figure_from_table(aggregate_keep, 'nconvs', 'alpha', 'effect_size_system',...
        'xlabel', '$\alpha$',...
        'ylabel', 'effect size($\omega^2$)',...
        'savepath', sprintf('%seffect_size_system_%s_%d.pdf', save_path, measure, B));
    
    print_figure_from_table(aggregate_keep, 'nconvs', 'alpha', 'effect_size_topic',...
        'xlabel', '$\alpha$',...
        'ylabel', 'effect size($\omega^2$)',...
        'savepath', sprintf('%seffect_size_conversation_%s_%d.pdf', save_path, measure, B));
    %}    
end