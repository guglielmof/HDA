function [distances, ssd_pairs] = compute_ssd_pairs_gt(measure, varargin) 
    common_parameters;
    varargs = process_varargin(varargin);
    
    
    base_path = '../../data/downsampled_measures';
    

    mpath = sprintf("%s/%s/", base_path, measure);        

    
    %compute the true anova
    data = readtable(sprintf("%s/1/0.csv",mpath), 'Format','%d%s%s%s%f');
    data = filter_data(data);

    [tbl, soa, ref_mc] = compute_anova('MD1', data);

    disp(tbl);
    disp(soa.omega2p);
    distances = abs(ref_mc{ref_mc{:, 6}<EXPERIMENT.analysis.alpha, 3});

    ssd_pairs = sum(ref_mc{:, 6}<EXPERIMENT.analysis.alpha);
    disp(ssd_pairs);
end

function fd = filter_data(data)
    fd = data;
    fd(:, {'Var1', 'utt'}) = [];

    %aggregate data per conversation
    fd = grpstats(fd, {'conv', 'run'}, 'mean', ...
        'varnames', {'conv', 'run', 'GroupCount', 'score'});
    fd(:, 'GroupCount') = [];
end 

function fd = filter_data_alpha(data, alpha)
    fd = data(data{:,'alpha'}==alpha, :);
    fd(:, {'Var1', 'utt', 'roots', 'leaves', 'alpha'}) = [];

    %aggregate data per conversation
    fd = grpstats(fd, {'conv', 'run'}, 'mean', ...
        'varnames', {'conv', 'run', 'GroupCount', 'score'});
    fd(:, 'GroupCount') = [];
end 