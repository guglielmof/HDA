function [] = sample_utts(TAG, measure, B)

    common_parameters;
    
    save_path = "../data/analysis/";
 
    data = readtable(sprintf("../data/sampled_utts_%s.csv", measure));



    tmp = [num2cell(data{:, 'conv'}.');...
           num2cell(data{:, 'sampleid'}.')];
                  
    data(:, 'new_conv_id') = split(strip(sprintf('%d_%d ',tmp{:})));
    
    tmp = [num2cell(data{:, 'conv'}.');...
           num2cell(data{:, 'sampleid'}.');...
           num2cell(data{:, 'utt'}.')];

    data(:, 'qid') = split(strip(sprintf('%d_%d_%d ',tmp{:})));         



    alphas = unique(data{:, 'alpha'});
    convs = unique(data{:, 'conv'});
    new_conv_ids = unique(data{:, 'new_conv_id'});
    nconvs = length(convs);
    
    keep = cell(length(alphas), 5);

    
    for an=1:length(alphas)
        %compute anova using only the original set of conversations
        filtered_data = data(data{:, 'alpha'}==alphas(an) & data{:, 'sampleid'}==0, :);

        
        [~, tbl, sts] = EXPERIMENT.analysis.anova.(TAG)(...
         filtered_data{:,'score'}, ...
         filtered_data{:,'qid'}, ...
         filtered_data{:, 'run'}); 

        [c,m,h,gnms] = multcompare(sts,  'ctype', 'hsd', 'dimension', 2, 'display', 'off');
        ref_mc = mc2table(c, gnms);
        
        
        %compute anova using all the conversations
        %fprintf("computing ANOVA using recursive %s (alpha=%.1f) for all conversations\n", measure, alphas(an))
        
        comps = {};
        for b=1:B
            %compute anova by sampling some conversations
            sampled_convs = datasample(new_conv_ids, nconvs);

            filtered_data = data((ismember(data{:,'new_conv_id'}, sampled_convs) & ...
                                 data{:,'alpha'}==alphas(an)), :);

            [~, tbl, sts] = EXPERIMENT.analysis.anova.(TAG)(...
             filtered_data{:,'score'}, ...
             filtered_data{:,'qid'}, ...
             filtered_data{:, 'run'}); 

            [c,m,h,gnms] = multcompare(sts,  'ctype', 'hsd', 'dimension', 2, 'display', 'off');
            comps{end+1} = mc2table(c, gnms);

        end
        fprintf("ANOVAs computed. Comparing the multiple comparisons.\n")

        cmc = comp_multcompare(ref_mc, comps, EXPERIMENT.analysis.alpha);

        fprintf("Comparison done.\n")

        pd = fitdist(cmc(:, 6),'Normal');
        ci = paramci(pd,'Alpha',EXPERIMENT.analysis.alpha);
        ciwpaa = (ci(2, 1) - ci(1, 1))/2;

        pd = fitdist(cmc(:, 7),'Normal');
        ci = paramci(pd,'Alpha',EXPERIMENT.analysis.alpha);
        ciwppa = (ci(2, 1) - ci(1, 1))/2;

        keep(an, :) = {alphas(an),  mean(cmc(:, 6)), ciwpaa, mean(cmc(:, 7)), ciwppa};


    end
    fprintf("Data processed: saving figures and data.\n")

    
    keep = cell2table(keep, 'VariableNames', {'alpha','PAA', 'PAA_ci_width', 'PPA', 'PPA_ci_width'});
    disp(keep);
end