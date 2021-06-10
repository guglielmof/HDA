function [] = compute_anova_MD2(TAG, measure)

    common_parameters;

    data = readtable(sprintf("../data/%s.csv", measure));
    new_col = cell(height(data), 1);
    for i=1:height(data)
        new_col{i} = [num2str(data{i,'conv'}), '_', num2str(data{i, 'utt'})];
    end
    
    data(:, 'qid') = new_col;


    alphas = unique(data{:, 'alpha'});
    
    ssd_pairs = zeros(length(alphas), 1);
    sys_effect = zeros(length(alphas), 1);
    
    comps = {};
    
    for an=1:length(alphas)
        alpha = alphas(an);
        fprintf("computing ANOVA using recursive %s (alpha=%f)\n", measure, alpha)
        filtered_data = data(data{:, 'alpha'}==alpha, :);
        
        N = height(filtered_data);
        
        

        [~, tbl, sts] = EXPERIMENT.analysis.anova.(TAG)(...
            filtered_data{:,'score'}, ...
            filtered_data{:,'conv'}, ...
            filtered_data{:,'utt'}, ...
            filtered_data{:, 'run'});
    
        disp(tbl);
        soa = compute_SOA(N, tbl, {'Topics', 'Utterances', 'Systems'});
        disp(soa.omega2p);
        
        %[c,m,h,gnms] = multcompare(sts,  'ctype', 'hsd', 'dimension', 2, 'display', 'off');
        %comps{end+1} = mc2table(c, gnms);
        %ssd_p = sum(c(:, 6)<EXPERIMENT.analysis.alpha);
        %fprintf("ssd pairs: %d\n\n", ssd_p);
        
        sys_effect(an) = soa.omega2p.Systems;
        %ssd_pairs(an) = ssd_p;

    end
    disp(ssd_pairs);
    cmc = comp_multcompare(comps{end}, comps, EXPERIMENT.analysis.alpha);
    disp(cmc);
    %line(alphas, ssd_pairs);
    %line(alphas, sys_effect);
end
