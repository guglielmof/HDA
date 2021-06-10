function mct = mc2table(mc, ognms)
    gnames = cellfun(@(x) split(x, "="), ognms, 'uniformoutput', false);
    gnames = cellfun(@(x) x{2,:}, gnames, 'uniformoutput', false);

    [h, w] = size(mc); 
    mct = cell(h, w);
    
    for c=1:h
        mct(c,:) = {gnames{mc(c, 1)},  gnames{mc(c, 2)}, ...
            mc(c, 3), mc(c, 4), mc(c, 5), mc(c, 6)};
    end

    mct = cell2table(mct, 'VariableNames', {'system1', 'system2', 'lci', 'diff', 'uci', 'pval'});
end