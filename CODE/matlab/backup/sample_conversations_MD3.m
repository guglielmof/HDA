function [] = sample_conversations_MD3(TAG, measure, B)

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
    %nconvs = [1];
    %alphas = alphas(end-2:end);
    %nconvs = nconvs(end-2:end);
    disp(nconvs);


    keep = cell(length(nconvs), 7);

    
    
    fprintf("computing ANOVA using recursive %s for all conversations\n", measure)


    filtered_data = data(:, :);

    [~, tbl, sts] = EXPERIMENT.analysis.anova.(TAG)(...
     filtered_data{:,'score'}, ...
     filtered_data{:,'alpha'}, ...
     filtered_data{:,'conv'}, ...
     filtered_data{:, 'run'}); 

    [c,m,h,gnms] = multcompare(sts,  'ctype', 'hsd', 'dimension', 3, 'display', 'off');
    ref_mc = mc2table(c, gnms);




    for cn=1:length(nconvs)

        fprintf("computing %d ANOVAs using recursive %s for %d sampled conversations\n", B, measure, nconvs(cn))

        comps = {}; %mc tables
        for b=1:B
            %compute anova by sampling some conversations
            sampled_convs = datasample(convs, nconvs(cn), 'replace', false);

            filtered_data = data(ismember(data{:,'conv'}, sampled_convs), :);



            [~, tbl, sts] = EXPERIMENT.analysis.anova.(TAG)(...
             filtered_data{:,'score'}, ...
             filtered_data{:,'alpha'}, ...
             filtered_data{:,'conv'}, ...
             filtered_data{:, 'run'}); 

            [c,m,h,gnms] = multcompare(sts,  'ctype', 'hsd', 'dimension', 3, 'display', 'off');
            comps{end+1} = mc2table(c, gnms);


        end
        fprintf("ANOVAs computed. Comparing the multiple comparisons.\n")

        cmc = comp_multcompare(ref_mc, comps, EXPERIMENT.analysis.alpha);
        disp(cmc(:, 1:5))
        fprintf("Comparison done.\n")

        ciwpaa = confidenceIntervalDelta(cmc(:, 6), EXPERIMENT.analysis.alpha);
        ciwppa = confidenceIntervalDelta(cmc(:, 7), EXPERIMENT.analysis.alpha);
        ciwad  = confidenceIntervalDelta(cmc(:, 2), EXPERIMENT.analysis.alpha);
        keep(cn, :) = { nconvs(cn), mean(cmc(:, 6)), ciwpaa, mean(cmc(:, 7)), ciwppa, mean(cmc(:,7)), ciwad};

    end
    disp(keep);
end