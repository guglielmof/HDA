%If i randomly pick two utterances, what is the average correlation?

measure = 'NDCG_cut_3';
metric = 'markovian-forward-mean';
B = 20000;

base_path = '../../data/downsampled_measures';

mpath = sprintf("%s/%s/%s/", base_path, metric, measure);  

data = readtable(sprintf("%s/1/0.csv",mpath), 'Format','%d%s%s%s%s%f%s%s');
data(:, {'alpha', 'roots', 'leaves'}) = [];

convs = unique(data{:, 'conv'});

ref_run_order = unique(data{:, 'run'});


conv2utts = containers.Map();
for cn=1:length(convs)
    conv2utts(convs{cn}) = unique(data{strcmp(data{:,'conv'},convs(cn)), 'utt'});
end


different = zeros(B, 1);
conversation = zeros(B, 1);

for b=1:B
    sampled_conv_1 = datasample(convs, 1, 'Replace',false);
    sampled_conv_2 = datasample(convs, 1, 'Replace',false);
    
    
    sampled_u1 = datasample(conv2utts(char(sampled_conv_1)), 2, 'Replace', false);
    sampled_u3 = sampled_u1{2};
    sampled_u1 = sampled_u1{1};
    sampled_u2 = datasample(conv2utts(char(sampled_conv_2)), 1);
    
 
    while strcmp(sampled_conv_1,sampled_conv_2) && strcmp(sampled_u1, sampled_u2)
    	sampled_u2 = datasample(conv2utts(char(sampled_conv_2)), 1);
    end
    
    
    %take the scores for u1
    d1 = data(strcmp(data{:,'conv'}, sampled_conv_1) & strcmp(data{:,'utt'}, sampled_u1), {'run', 'score'}); 
    d1.Properties.RowNames = d1{:, 'run'};
    d1 = d1{ref_run_order, 'score'};
    
    %take the scores for u2
    d2 = data(strcmp(data{:,'conv'}, sampled_conv_2) & strcmp(data{:,'utt'}, sampled_u2), {'run', 'score'});
    d2.Properties.RowNames = d2{:, 'run'};
    d2 = d2{ref_run_order, 'score'};

    %take the scores for u3
    d3 = data(strcmp(data{:,'conv'}, sampled_conv_1) & strcmp(data{:,'utt'}, sampled_u3), {'run', 'score'});
    d3.Properties.RowNames = d3{:, 'run'};
    d3 = d3{ref_run_order, 'score'};

    
    
    
    different(b)  = corr(d1, d2, 'type', 'Kendall');
    conversation(b)  = corr(d1, d3, 'type', 'Kendall');
end

[h,p] = ttest2(different, conversation);
disp(p);


ds1 = fitdist(different, 'kernel');
ds2 = fitdist(conversation, 'kernel');
x = 0:0.01:1;

hold on;
y = pdf(ds1, x);
plot(x,y,'LineWidth',2);


y = pdf(ds2, x);
plot(x,y,'LineWidth',2);


legend(["different", "conversation"]);



