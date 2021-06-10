function []=test_macro_alpha(TAG, measure, B, varargin)

    common_parameters;
    varargs = process_varargin(varargin);
    
    data = import_and_aggregate(measure);
    

    convs = unique(data{:, 'conv'});
    nconvs = 2:3:(length(convs)-1);
    
    [ref_tbl, ref_soa, ref_mc] = compute_anova(TAG, data);
    
    sampled_mc = cell(B, length(nconvs));
    sampled_soa = cell(B, length(nconvs));
    
    for b=1:B
    
        for cn=1:length(nconvs)
            
            %sampling conversations
            selected_convs = datasample(convs, nconvs(cn),....
                'replace', (isKey(varargs, 'replace')&&varargs('replace')));
            
            [~, soa, mc] = compute_anova(TAG, data, 'conversations', selected_convs);
            
            sampled_mc{b, cn} = mc;
            sampled_soa{b, cn} = soa;

        end
        
    end
    
    fprintf("REF\n");
    fprintf("%d\t%.3f\t%.3f\n", sum(ref_mc{:,6}<EXPERIMENT.analysis.alpha),...
        ref_soa.omega2p.Systems, ref_soa.omega2p.Topics);

    for cn=1:length(nconvs)
        
        %multcompares
        mcs = sampled_mc(:,cn);
        
        %ssd pairs for different multcompairs
        ssds = cellfun(@(x) sum(x{:,6}<0.05), mcs);
        
        omega2systems = cellfun(@(x) x.omega2p.Systems, sampled_soa(:, cn));
        omega2topics = cellfun(@(x) x.omega2p.Topics, sampled_soa(:, cn));

        %compare multipole comparisons
        cmc = comp_multcompare(ref_mc,  mcs, EXPERIMENT.analysis.alpha);
        
        result = [ssds, omega2systems, omega2topics, cmc(:, [2, 6, 7])];
        fprintf("%d ", nconvs(cn));
        fprintf("%.3f$\\pm$%.3f ", reshape([mean(result); confidenceIntervalDelta(result, 0.05)], 1, []))
        fprintf("\n");
    end

end