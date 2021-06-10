[d1, ~] = compute_ssd_pairs_gt('NDCG_cut_3');
[d2, ~] = compute_ssd_pairs('NDCG_cut_3', 'markovian-forward-mean');
[d3, ~] = compute_ssd_pairs('NDCG_cut_3', 'markovian-backward-mean');


hold on;
%{
hist_as_line(d1);
hist_as_line(d2);
hist_as_line(d3);
%}

ds1 = fitdist(d1, 'kernel');
ds2 = fitdist(d2, 'kernel');
ds3 = fitdist(d3, 'kernel');
x = 0:0.01:1;

y = pdf(ds1, x);
plot(x_values,y,'LineWidth',2);


y = pdf(ds2, x);
plot(x_values,y,'LineWidth',2);

y = pdf(ds3, x);
plot(x_values,y,'LineWidth',2);

legend(["original", "mfm", "mbm"]);


function hist_as_line(X)
    [N,edges] = histcounts(X, 50, 'Normalization','pdf');
    edges = edges(2:end) - (edges(2)-edges(1))/2;
    plot(edges, N);
end