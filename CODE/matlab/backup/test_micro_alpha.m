function []=test_micro_alpha(TAG, measure, B, varargin)

    common_parameters;

    varargs = process_varargin(varargin);
    
    data = import_and_aggregate(measure);
    
    alphas = unique(data{:, 'alpha'});
    convs = unique(data{:, 'conv'});
    %nconvs = 2:length(convs);
    %nconvs = [1];
    nconvs = 2:3:(length(convs)-1);
    %nconvs = 14:3:(length(convs)-1);
    %alphas = alphas(end-1:end);
    
    sampled_mc = cell(B, length(nconvs), length(alphas));
    sampled_soa = cell(B, length(nconvs), length(alphas));
    
    ref_soas = cell(length(alphas), 1);
    ref_mcs = cell(length(alphas), 1);
    
    for an=1:length(alphas)
        [~, ref_soa, ref_mc] = compute_anova(TAG, data, 'alphas', [alphas(an)]);
        ref_soas{an} = ref_soa;
        ref_mcs{an} = ref_mc;
    end
    
    for b=1:B
    
        for cn=1:length(nconvs)
            
            %sampling conversations
            selected_convs = datasample(convs, nconvs(cn),....
                'replace', (isKey(varargs, 'replace')&&varargs('replace')));
            
            for an=1:length(alphas)
            
                [tbl, soa, mc] = compute_anova(TAG, data, 'conversations', selected_convs, 'alphas', [alphas(an)]);

                sampled_mc{b, cn, an} = mc;
                sampled_soa{b, cn, an} = soa;
            end

        end
        
    end
    
    aggregated_results = cell(length(alphas)*(length(nconvs)+1), 8);

    for an=1:length(alphas)
        fprintf("REF %.1f\n", alphas(an));
        ref_mc = ref_mcs{an};
        ref_soa = ref_soas{an};
        ssd_ref =  sum(ref_mc{:,6}<EXPERIMENT.analysis.alpha);
        fprintf("%d\t%.3f\t%.3f\n", ssd_ref,...
            ref_soa.omega2p.Systems, ref_soa.omega2p.Topics);
        
        aggregated_results(length(alphas)*length(nconvs)+an, :) = {alphas(an), length(convs),...
            ssd_ref, 0, ...
            ref_soa.omega2p.Systems, 0, ...
            ref_soa.omega2p.Topics, 0};

        for cn=1:length(nconvs)
            %multcompares
            mcs = sampled_mc(:,cn, an);

            %ssd pairs for different multcompairs
            ssds = cellfun(@(x) sum(x{:,6}<0.05), mcs);

            omega2systems = cellfun(@(x) x.omega2p.Systems, sampled_soa(:, cn, an));
            omega2topics = cellfun(@(x) x.omega2p.Topics, sampled_soa(:, cn, an));

            %compare multipole comparisons
            cmc = comp_multcompare(ref_mc,  mcs, EXPERIMENT.analysis.alpha);

            result = [ssds, omega2systems, omega2topics, cmc(:, [2, 6, 7])];
            
            means = mean(result);
            cis   = confidenceIntervalDelta(result, 0.05);

            fprintf("%d ", nconvs(cn));
            fprintf("%.3f$\\pm$%.3f ", reshape([means;cis] , 1, []))
            fprintf("\n");
            aggregated_results((an-1)*length(nconvs)+cn, :) = {alphas(an), nconvs(cn), means(1), cis(1), means(2), cis(2), means(3), cis(3)};
        end
    end
    
    aggregated_results = cell2table(aggregated_results, 'VariableNames', {'alpha', 'nconvs', 'ssd', 'ssdci', 'sys_effect', 'seci', 'conv_effect', 'ceci'});

    
    save_path = "../../data/analysis/";
    print_figure_from_table(aggregated_results, 'nconvs', 'alpha', 'ssd',...
        'xlabel', '$\alpha$',...
        'ylabel', 'ssd pairs of systems',...
        'savepath', sprintf('%sssd_%s_%d.pdf', save_path, measure, B));
        
    print_figure_from_table(aggregated_results, 'nconvs', 'alpha', 'sys_effect',...
        'xlabel', '$\alpha$',...
        'ylabel', 'system effect size ($\omega^2$)',...
        'savepath', sprintf('%ssys_effect_%s_%d.pdf', save_path, measure, B));
    
        
    print_figure_from_table(aggregated_results, 'nconvs', 'alpha', 'conv_effect',...
        'xlabel', '$\alpha$',...
        'ylabel', 'conversations effect size ($\omega^2$)',...
        'savepath', sprintf('%sconv_effect_%s_%d.pdf', save_path, measure, B));
    
end