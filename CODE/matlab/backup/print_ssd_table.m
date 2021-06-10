function []=print_ssd_table(measure, B)


    common_parameters;
    
    save_path = "../../data/analysis/";
 
    keep = readtable(sprintf("%sssd_table_%s_%d.csv", save_path, measure, B)); %from compare_table
   
    alphas = unique(keep{:, 'alpha'});
    nconvs = unique(keep{:, 'nconvs'});
    
    aggregate_keep =  cell(length(alphas)*length(nconvs), 6);

    for an=1:length(alphas)
        for cn=1:length(nconvs)
            selected_rows = keep((keep{:,'alpha'}==alphas(an))&(keep{:,'nconvs'}==nconvs(cn)), :);
            m_ssd = mean(selected_rows{:,'ssd_pairs'});
            m_es  = mean(selected_rows{:,'effect_size_system'});
            
            pd = fitdist(selected_rows{:,'ssd_pairs'},'Normal');
            ci = paramci(pd,'Alpha',EXPERIMENT.analysis.alpha);
            cwissd = (ci(2, 1) - ci(1, 1))/2;
            
            pd = fitdist(selected_rows{:,'effect_size_system'},'Normal');
            ci = paramci(pd,'Alpha',EXPERIMENT.analysis.alpha);
            cwies = (ci(2, 1) - ci(1, 1))/2;
            
            aggregate_keep((an-1)*length(nconvs)+cn, :) = {alphas(an), nconvs(cn), m_ssd, cwissd, m_es, cwies};
        end
    end
    aggregate_keep = cell2table(aggregate_keep, 'variablenames', {'alpha', 'nconvs', 'ssd_pairs', 'ssdci', 'effect_size_system', 'esci'});

    
    selected_alphas = [1.0, 0.7, 0.5, 0.3, 0.0];
    selected_nconvs = [11, 14, 17, 20];
    
    printable = sprintf("\\begin{table}[tbh]\n");
    printable = sprintf("%s\\caption{}\n",printable);
    printable = sprintf("%s\\label{tbl:}\n",printable);
    printable = sprintf("%s\\centering\n",printable);
    printable = sprintf("%s\\begin{tabular}{l%s}\n",printable, repmat('r', length(selected_nconvs), 1));
    printable = sprintf("%s\\toprule\n",printable);                                                                                                      
    printable = sprintf("%s\\textbf{$\\alpha$}", printable);
    for c=1:length(selected_nconvs)
        printable = sprintf("%s\t&\t\\textbf{%d}", printable, selected_nconvs(c));
    end
    printable = sprintf("%s\t\\\\\n\\midrule\n", printable);
    for a=1:length(selected_alphas)
        alpha = selected_alphas(a);
        printable = sprintf("%s%.1f", printable, alpha);
        for c=1:length(selected_nconvs)
            nconvs = selected_nconvs(c);
            idx = (aggregate_keep{:,'alpha'}==alpha) & (aggregate_keep{:, 'nconvs'} == nconvs);

            printable = sprintf("%s\t&\t%.0f$\\pm$%.0f", printable, aggregate_keep{idx, 'ssd_pairs'},  aggregate_keep{idx, 'ssdci'});
        end
        printable = sprintf("%s\t\\\\\n", printable);
    end
    printable = sprintf("%s\\bottomrule\n",printable);                                                                                                      
    printable = sprintf("%s\\end{tabular}\n",printable);
    printable = sprintf("%s\\end{table}\n",printable);
    disp(printable);
    fprintf(printable);
    
end