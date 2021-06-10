function [] = compute_agreement(measure)
    common_parameters;
    
    %divide into different alphas
    base_path = '../../data/downsampled_measures';

    mpath_o = sprintf("%s/%s", base_path, measure);        
    
    
    %compute the true anova
    data = readtable(sprintf("%s/1/0.csv",mpath_o), 'Format','%d%s%s%s%f');
    data = filter_data(data);
    
    [~, ~, ref_mc] = compute_anova('MD1', data);
    
        mpath_mbm = sprintf("%s/markovian-forward-mean/%s", base_path, measure);        
    
    
    mpath_mbm = sprintf("%s/markovian-backward-mean/%s", base_path, measure);        

    data = readtable(sprintf("%s/1/0.csv",mpath_mbm), 'Format','%d%s%d%d%f%f%s%s');
    data = filter_data_alpha(data);
    
    [~, ~, mbm_mc] = compute_anova('MD1', data);
    
    
    mpath_mfm = sprintf("%s/markovian-forward-mean/%s", base_path, measure);        
    
    
    %compute the true anova
    data = readtable(sprintf("%s/1/0.csv",mpath_mfm), 'Format','%d%s%d%d%f%f%s%s');
    data = filter_data_alpha(data);
    
    [~, ~, mfm_mc] = compute_anova('MD1', data);
    
    cmc = comp_multcompare(ref_mc, {mbm_mc, mfm_mc}, EXPERIMENT.analysis.alpha);
    disp(cmc(:, 1:5));
    
    
    
    
    cmc = comp_multcompare(mbm_mc, {mfm_mc}, EXPERIMENT.analysis.alpha);
    disp(cmc(:, 1:5));
end

function fd = filter_data(data)
    fd = data;
    fd(:, {'Var1', 'utt'}) = [];

    %aggregate data per conversation
    fd = grpstats(fd, {'conv', 'run'}, 'mean', ...
        'varnames', {'conv', 'run', 'GroupCount', 'score'});
    fd(:, 'GroupCount') = [];
end 

function fd = filter_data_alpha(data)
    fd = data;
    fd(:, {'Var1', 'utt', 'roots', 'leaves', 'alpha'}) = [];

    %aggregate data per conversation
    fd = grpstats(fd, {'conv', 'run'}, 'mean', ...
        'varnames', {'conv', 'run', 'GroupCount', 'score'});
    fd(:, 'GroupCount') = [];
end 