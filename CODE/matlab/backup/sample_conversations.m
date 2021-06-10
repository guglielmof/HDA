function [] = sample_conversations(TAG, measure, B)

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
    %alphas = alphas(end:end);
    %nconvs = nconvs(end-2:end);


    keep = cell(length(alphas)*length(nconvs), 6);

    for an=1:length(alphas)
        %compute anova using all the conversations
        fprintf("computing ANOVA using recursive %s (alpha=%.1f) for all conversations\n", measure, alphas(an))


        filtered_data = data(data{:,'alpha'}==alphas(an), :);

        [~, tbl, sts] = EXPERIMENT.analysis.anova.(TAG)(...
         filtered_data{:,'score'}, ...
         filtered_data{:,'conv'}, ...
         filtered_data{:, 'run'}); 

        [c,m,h,gnms] = multcompare(sts,  'ctype', 'hsd', 'dimension', 2, 'display', 'off');
        ref_mc = mc2table(c, gnms);
        writetable(ref_mc,sprintf("%smc_%s_%.1f.csv", save_path, measure, alphas(an)));

        


        for cn=1:length(nconvs)

            fprintf("computing %d ANOVAs using recursive %s (alpha=%.1f) for %d sampled conversations\n", B, measure, alphas(an), nconvs(cn))

            comps = {}; %mc tables
            for b=1:B
                %compute anova by sampling some conversations
                sampled_convs = datasample(convs, nconvs(cn));

                filtered_data = data((ismember(data{:,'conv'}, sampled_convs) & ...
                                     (data{:,'alpha'}==alphas(an))), :);

                [~, tbl, sts] = EXPERIMENT.analysis.anova.(TAG)(...
                filtered_data{:,'score'}, ...
                filtered_data{:,'conv'}, ...
                filtered_data{:, 'run'}); 

                [c,m,h,gnms] = multcompare(sts,  'ctype', 'hsd', 'dimension', 2, 'display', 'off');
                comps{end+1} = mc2table(c, gnms);


            end
            fprintf("ANOVAs computed. Comparing the multiple comparisons.\n")

            cmc = comp_multcompare(ref_mc, comps, EXPERIMENT.analysis.alpha);
            disp(cmc(:, 1:5))
            fprintf("Comparison done.\n")

            pd = fitdist(cmc(:, 6),'Normal');
            ci = paramci(pd,'Alpha',EXPERIMENT.analysis.alpha);
            ciwpaa = (ci(2, 1) - ci(1, 1))/2;
            
            pd = fitdist(cmc(:, 7),'Normal');
            ci = paramci(pd,'Alpha',EXPERIMENT.analysis.alpha);
            ciwppa = (ci(2, 1) - ci(1, 1))/2;
            
            keep((an-1)*length(nconvs)+cn, :) = {alphas(an), nconvs(cn), mean(cmc(:, 6)), ciwpaa, mean(cmc(:, 7)), ciwppa};

        end


    end
    disp(keep);
    %{
    fprintf("Data processed: saving figures and data.\n")

    
    keep = cell2table(keep, 'VariableNames', {'alpha', 'nconvs', 'PAA', 'PAA_ci_width', 'PPA', 'PPA_ci_width'});
    writetable(keep,sprintf("%smultiple_comparisons_%s_%d.csv", save_path, measure, B));
    

    
    print_figure_from_table(aggregate_keep, 'nconvs', 'alpha', 'PAA',...
        'xlabel', '$\alpha$',...
        'ylabel', 'PAA',...
        'savepath', sprintf('%sPAA_agreement_%s_%d.pdf', save_path, measure, B));
    
    
    print_figure_from_table(aggregate_keep, 'nconvs', 'alpha', 'PPA',...
        'xlabel', '$\alpha$',...
        'ylabel', 'PPA',...
        'savepath', sprintf('%sPPA_agreement_%s_%d.pdf', save_path, measure, B));
    %}
    
end