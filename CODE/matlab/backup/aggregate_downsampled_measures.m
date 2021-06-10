function []=aggregate_downsampled_measures(measure)

    common_parameters;
    
    save_path = "../../data/analysis/";
    
    data = readtable(sprintf("../../data/%s.csv", measure));
    fprintf("dataset imported\n");
    data = grpstats(data(:, {'p', 'rep', 'conv', 'alpha', 'run','score'}),...
        {'p', 'rep', 'conv', 'alpha', 'run'}, 'mean', ...
        'varnames', { 'p', 'rep', 'conv', 'alpha', 'run', 'GroupCount', 'score'});
    
    %{
    %parpool(6);
    data = datastore(char(sprintf("../../data/%s.csv", measure)) ,'Type', 'tabulartext');
    tt = tall(data);
    %tt = tt((tt{:,'rep'}<2) & (tt{:,'p'}>0.5) & (tt{:, 'alpha'}>0.6), : );
    g = grpstats(tt(:, {'p', 'rep', 'conv', 'alpha', 'run', 'score'}), {'p', 'rep', 'conv', 'alpha', 'run'}, 'mean');
    data = gather(g);
    %}
    data(:, 'GroupCount') = [];
    
    fprintf("aggregated measure computed\n");
    
    disp(data(1:100, :));
    data.Properties.VariableNames = {'p', 'rep', 'conv', 'alpha', 'run', 'score'};
    
    
    writetable(data,sprintf("%saggregated_%s.csv", save_path, measure));
    

end