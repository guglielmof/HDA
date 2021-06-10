function [tbl, soa, mc] = compute_anova(TAG, data, varargin)

    common_parameters;
    varargs = process_varargin(varargin);
    
    
    
    %filter data according to the input
    selected = boolean(ones(height(data), 1));
    if isKey(varargs, 'conversations')
        selected = selected & ismember(data{:, 'conv'}, varargs('conversations'));
    end
    if isKey(varargs, 'alphas')
        selected = selected & ismember(data{:, 'alpha'}, varargs('alphas'));
    end
    if isKey(varargs, 'runs')
        selected = selected & ismember(data{:, 'run'}, varargs('runs'));
    end

    filtered_data = data(selected, :);

    %format input for anova
    factors = containers.Map();
    factors('Topics') = filtered_data{:,'conv'};
    factors('Systems') = filtered_data{:, 'run'};
    if ismember('alpha',  filtered_data.Properties.VariableNames)
        factors('Alphas') = filtered_data{:, 'alpha'};
    end
    if ismember('utt', filtered_data.Properties.VariableNames)
        factors('Utterances') = filtered_data{:, 'utt'};
    end


    %computing ANOVA
    [~, tbl, sts] = EXPERIMENT.analysis.(TAG).anova(...
    filtered_data{:,'score'}, factors); 


        
    %computing multiple comparison and formatting it
    mc = {};
    if ~isKey(varargs, 'mc') || strcmp(varargs('mc'),'on')
        [c,m,h,gnms] = multcompare(sts,  'ctype', 'hsd',...
                                   'dimension', 2, 'display', 'off');
        mc = mc2table(c, gnms);
    end
    %computing SOA
    
    soa = compute_SOA(height(filtered_data), tbl, EXPERIMENT.analysis.(TAG).factors); 
    
end