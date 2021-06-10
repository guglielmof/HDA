function [] = conv_sampling(measure, B, varargin)

    common_parameters;
    varargs = process_varargin(varargin);
    
    %divide into different alphas
    base_path = '../../data/downsampled_measures';
    if ~isKey(varargs, 'metric') || strcmp(varargs('metric'), 'original')
        mpath = sprintf("%s/%s/", base_path, measure);
        data = readtable(sprintf("%s/1/0.csv",mpath), 'Format','%d%s%s%s%f');
        data = filter_data(data);
    else
        mpath = sprintf("%s/%s/%s/", base_path, varargs('metric'), measure);   
        data = readtable(sprintf("%s/1/0.csv",mpath), 'Format','%d%s%s%s%d%f%s%s');
        alpha = unique(data{:, 'alpha'});
        data = filter_data_alpha(data, alpha(1));
    end
    
    [~, ~, ref_mc] = compute_anova('MD1', data);
    
    convs = unique(data{:, 'conv'});
    convn = [2, 5, 8, 11, 14, 17];
    mcs = cell(length(convn), B);
    for cn=1:length(convn)
        for b=1:B
            sampled_convs = datasample(convs, convn(cn), 'Replace',false);
            filtered_data = data(ismember(data{:, 'conv'}, sampled_convs), :);
            [~, ~, mc] = compute_anova('MD1', filtered_data);
            mcs{cn, b} = mc;
        end
    end
    
    
    for cn=1:length(convn)
        cmc = comp_multcompare(ref_mc, mcs(cn, :), EXPERIMENT.analysis.alpha);
        comp_scores = (cmc(:, 1)+cmc(:, 3))./sum(cmc(:, 1:5), 2);
        fprintf("&\t$%.3f\\pm %.3f$\t", mean(comp_scores), confidenceIntervalDelta(comp_scores, EXPERIMENT.analysis.alpha));
    end
    
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