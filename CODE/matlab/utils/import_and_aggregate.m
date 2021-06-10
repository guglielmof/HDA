function data = import_and_aggregate(measure)

    %import measure
    data = readtable(sprintf("../../data/%s.csv", measure), 'Format','%d%s%s%s%f%f%s%s');
    data(:, {'Var1', 'utt', 'roots', 'leaves'}) = [];

    %aggregate data per conversation
    data = grpstats(data, {'conv', 'alpha', 'run'}, 'mean', ...
        'varnames', {'conv', 'alpha', 'run', 'GroupCount', 'score'});
    data(:, 'GroupCount') = [];
end