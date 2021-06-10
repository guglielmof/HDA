function [] = compute_anova(TAG, measure)

    common_parameters;

    data = readtable(sprintf("../../data/%s.csv", measure));
    data(:, 'Var1') = [];
    data(:, 'utt') = [];

    data = grpstats(data, {'conv', 'alpha', 'run'}, 'mean', 'varnames', {'conv', 'alpha', 'run', 'GroupCount', 'score'});
    data(:, 'GroupCount') = [];
    
    alphas = unique(data{:, 'alpha'});
    
    ssd_pairs = zeros(length(alphas), 1);
    sys_effect_system = zeros(length(alphas), 1);
    sys_effect_topic = zeros(length(alphas), 1);
    
    comps = {};
    
    for an=1:length(alphas)
        alpha = alphas(an);
        fprintf("computing ANOVA using recursive %s (alpha=%f)\n", measure, alpha)
        filtered_data = data(data{:, 'alpha'}==alpha, :);
        
        N = height(filtered_data);
        
        

        [~, tbl, sts] = EXPERIMENT.analysis.anova.(TAG)(...
            filtered_data{:,'score'}, ...
            filtered_data{:,'conv'}, ...
            filtered_data{:, 'run'});
    
        disp(tbl);
        soa = compute_SOA(N, tbl, {'Topics', 'Systems'});
        disp(soa.omega2p);
        
        [c,m,h,gnms] = multcompare(sts,  'ctype', 'hsd', 'dimension', 2, 'display', 'off');
        comps{end+1} = mc2table(c, gnms);
        ssd_p = sum(c(:, 6)<EXPERIMENT.analysis.alpha);
        fprintf("ssd pairs: %d\n\n", ssd_p);
        
        sys_effect_system(an) = soa.omega2p.Systems;
        sys_effect_topic(an) = soa.omega2p.Topics;

        ssd_pairs(an) = ssd_p;

    end
    fprintf("%.1f & ", alphas);
    fprintf("\n");
    fprintf("%d & ", ssd_pairs);
    fprintf("\n");
    fprintf("%.3f & ", sys_effect_system);
    fprintf("\n");
    fprintf("%.3f & ", sys_effect_topic);
    fprintf("\n");


    cmc = comp_multcompare(comps{end}, comps, EXPERIMENT.analysis.alpha);
    disp(cmc);
    %line(alphas, ssd_pairs);
    %line(alphas, sys_effect);
end
