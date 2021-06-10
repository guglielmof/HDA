function [] = compute_correlation(measure, varargin)
    common_parameters;
    varargs = process_varargin(varargin);
    if ~isKey(varargs, 'corr')
        varargs('corr') = 'kendall';
    end
    
    base_path = '../../data/downsampled_measures';
    
    m_original_path = sprintf("%s/%s/1/0.csv", base_path, measure);
    m_path = sprintf("%s/%s/%s/1/0.csv", base_path, varargs('metric'), measure);
    
    data_original = readtable(m_original_path, 'Format','%d%s%s%s%f');
    data_original = aggregate_data(data_original);
    conv_order = data_original.Properties.RowNames;
    
    if ~isKey(varargs, 'alpha') || varargs('alpha')
       
        data_new = read_alpha(m_path);
        alphas = unique(data_new{:, 'alpha'});
        correlation = zeros(length(alphas),1);
        for an=1:length(alphas)
            alpha = alphas(an);
            data_alpha = data_new(data_new{:,'alpha'}==alpha, :);
            data_alpha = aggregate_data(data_alpha);
            correlation(an) = corr(data_original{conv_order, 'score'},...
                data_alpha{conv_order, 'score'},...
                'type', varargs('corr'));
        end
    else
        data_new = read_simple(m_path);
        data_new = aggregate_data(data_new);
        [correlation, p] = corr(data_original{conv_order, 'score'},...
             data_new{conv_order, 'score'},...
             'type', varargs('corr'));
    end
    
    disp(correlation);
    disp(p);
end

function data = read_alpha(mpath)
    data = readtable(mpath, 'Format','%d%s%s%s%f%f%s%s');
end

function data = read_simple(mpath)
    data = readtable(mpath, 'Format','%d%s%s%s%s%f%s%s');
end

function fd = aggregate_data(data)
    fd = data;
    if ismember('alpha', data.Properties.VariableNames)
        fd(:, {'alpha'}) = [];
    end
    if ismember('roots', data.Properties.VariableNames)
        fd(:, {'Var1', 'utt', 'roots', 'leaves'}) = [];
    else
        fd(:, {'Var1', 'utt'}) = [];
    end
    
    

    %aggregate data per conversatio
    fd = grpstats(fd, {'conv', 'run'}, 'mean', ...
        'varnames', {'conv', 'run', 'GroupCount', 'score'});
    fd(:, {'GroupCount', 'conv'}) = [];
    
    fd = grpstats(fd,  {'run'}, 'mean', ...
        'varnames', {'run', 'GroupCount', 'score'});
    
    
    fd.Properties.RowNames = fd{:, 'run'};
    fd(:, {'run', 'GroupCount'}) = [];


end     
