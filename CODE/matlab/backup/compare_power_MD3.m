function [] = compare_power_MD3(TAG, measure, B)

    common_parameters;
    
    save_path = "../../data/analysis/";
    data = readtable(sprintf("../../data/%s.csv", measure));
    data(:, 'Var1') = [];
    data(:, 'utt') = [];

    data = grpstats(data, {'conv', 'alpha', 'run'}, 'mean', 'varnames', {'conv', 'alpha', 'run', 'GroupCount', 'score'});
    data(:, 'GroupCount') = [];


    alphas = unique(data{:, 'alpha'});
    convs = unique(data{:, 'conv'});
    nconvs = 2:3:(length(convs)-1);
    %alphas = alphas(end-2:end);
    %nconvs = nconvs(end:end);


    keep = cell(length(nconvs)*B, 5);
    


    for cn=1:length(nconvs)

        fprintf("computing %d ANOVAs using recursive %s for %d sampled conversations\n", B, measure, nconvs(cn))

        comps = {}; %mc tables
        for b=1:B
            %compute anova by sampling some conversations
            sampled_convs = datasample(convs, nconvs(cn), 'replace', false);
            %sampled_convs = convs;
            filtered_data = data(ismember(data{:,'conv'}, sampled_convs), :);


            N = height(filtered_data);
            [~, tbl, sts] = EXPERIMENT.analysis.anova.(TAG)(...
            filtered_data{:,'score'}, ...
            filtered_data{:,'alpha'}, ...
            filtered_data{:,'conv'}, ...
            filtered_data{:, 'run'}); 

            [c,m,h,gnms] = multcompare(sts,  'ctype', 'hsd', 'dimension', 3, 'display', 'off');
            soa = compute_SOA(N, tbl, {'Alphas', 'Topics', 'Systems'});
            ssd_p = sum(c(:, 6)<EXPERIMENT.analysis.alpha);

            keep((cn-1)*B+b, :) = {nconvs(cn), b, ssd_p, soa.omega2p.Systems, soa.omega2p.Topics};

        end


    end
    fprintf("Data processed: saving figures and data.\n")

    
    keep = cell2table(keep, 'VariableNames', {'nconvs', 'b', 'ssd_pairs', 'effect_size_system', 'effect_size_topic'});

    aggregate_keep = grpstats(keep(:, {'nconvs', 'ssd_pairs', 'effect_size_system', 'effect_size_topic'}), {'nconvs'}, ...
            {'mean',...
            @(x) confidenceIntervalDelta(x, EXPERIMENT.analysis.alpha)},...
            'varnames', {'nconvs', 'count', 'ssd_pairs', 'sp_ci', 'effect_size_system', 'ess_ci', 'effect_size_topic', 'est_ci'});
     
    disp(aggregate_keep);
end