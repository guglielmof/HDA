function [] = assess_accuracy_multialpha(measure, varargin)

    common_parameters;
    varargs = process_varargin(varargin);
    
    
    base_path = '../../data/downsampled_measures';
    
    if ~isKey(varargs, 'metric') || strcmp(varargs('metric'), 'original')
        mpath = sprintf("%s/%s/", base_path, measure);
    else
        mpath = sprintf("%s/%s/%s/", base_path, varargs('metric'), measure);        
    end
    
    
    %compute the true anova
    data_orig = readtable(sprintf("%s1/0.csv",mpath), 'Format','%d%s%d%d%f%f%s%s');
    alphas = unique(data_orig{:,'alpha'});
    
    for an=1:length(alphas)
        alpha = alphas(an);
        fprintf("%f\t", alpha);
        data = filter_data_alpha(data_orig, alpha);

        [tbl, soa, ref_mc] = compute_anova('MD1', data);


        %compute anova for the downsampled pools
        pools_cutoff = ["0.9", "0.8", "0.7", "0.6", "0.5", "0.4", "0.3", "0.2", "0.1"];
        for pcn=1:length(pools_cutoff)
            pc = pools_cutoff{pcn};
            mpcpath = sprintf("%s%s/", mpath, pc);
            fobjs = dir(mpcpath);
            fnames = {};
            for fn=1:length(fobjs)
                if ~strcmp(fobjs(fn).name, ".") && ~strcmp(fobjs(fn).name, "..")
                    fnames{end+1} = fobjs(fn).name;
                end
            end

            mcs = cell(length(fnames), 1);
            parfor fn=1:length(fnames)
                fname = fnames{fn};
                data = readtable(sprintf("%s%s",mpcpath, fname), 'Format','%d%s%d%d%f%f%s%s');
                data = filter_data_alpha(data, alpha);

                [~, ~, mc] = compute_anova('MD1', data);
                mcs{fn} = mc;
            end

            cmc = comp_multcompare(ref_mc, mcs, EXPERIMENT.analysis.alpha);

            if ~isKey(varargs, 'comparison') || strcmp(varargs('comparison'), 'F1')
                comp_scores = cmc(:, 1)./(cmc(:,1)+0.5*(cmc(:,2)+cmc(:,4)+cmc(:,5)));
            elseif strcmp(varargs('comparison'), 'accuracy')
                comp_scores = (cmc(:, 1)+cmc(:, 3))./sum(cmc(:, 1:5), 2);
            end
            fprintf("&\t$%.3f\\pm %.3f$\t", mean(comp_scores), confidenceIntervalDelta(comp_scores, EXPERIMENT.analysis.alpha));
        end
        fprintf("\n");
    
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