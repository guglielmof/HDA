%If i randomly pick two utterances, what is the average correlation?

measure = 'NDCG_cut_3';
B = 10000;

base_path = '../../data/downsampled_measures';

mpath = sprintf("%s/%s/", base_path, measure);  

data = readtable(sprintf("%s/1/0.csv",mpath), 'Format','%d%s%s%s%f');

convs = unique(data{:, 'conv'});

ref_run_order = unique(data{:, 'run'});

triples = readtable("../../data/triples.csv", 'Format', '%s%s%s%s', 'ReadRowNames',true);
tree = zeros(height(triples), 1);
for i=1:height(triples)
    [sampled_conv_3, sampled_u4, sampled_u5] = triples{i, :}{:};   
    d4 = data(strcmp(data{:,'conv'}, sampled_conv_3) & strcmp(data{:,'utt'}, sampled_u4), {'run', 'score'});
    d4.Properties.RowNames = d4{:, 'run'};
    d4 = d4{ref_run_order, 'score'};
    
    d5 = data(strcmp(data{:,'conv'}, sampled_conv_3) & strcmp(data{:,'utt'}, sampled_u5), {'run', 'score'});
    d5.Properties.RowNames = d5{:, 'run'};
    d5 = d5{ref_run_order, 'score'};
    
    tree(i) = corr(d4, d5, 'type', 'Kendall');
 
end


conv2utts = containers.Map();
lengths = [];
for cn=1:length(convs)
    utts = unique(data{strcmp(data{:,'conv'},convs(cn)), 'utt'});
    conv2utts(convs{cn}) = utts;
    lengths(end + 1) = length(utts);
end
disp(mean(lengths));

conversation = [];

for cn=1:length(convs)
    conv = convs(cn);
    utts = conv2utts(convs{cn});
    for un1=1:(length(utts)-1)
        utt1 = utts(un1);
        for un2=(un1+1):length(utts)
            utt2 = utts(un2);
            
            %if height(triples(strcmp(triples{:,'conv'}, conv) & ...
            %        strcmp(triples{:,'u1'}, utt1) &...
            %        strcmp(triples{:,'u2'}, utt2), :))==0 && ...
            %    height(triples(strcmp(triples{:,'conv'}, conv) & ...
            %        strcmp(triples{:,'u1'}, utt2) &...
            %       strcmp(triples{:,'u2'}, utt1), :))==0
            if true
                d4 = data(strcmp(data{:,'conv'}, conv) & strcmp(data{:,'utt'}, utt1), {'run', 'score'});
                d4.Properties.RowNames = d4{:, 'run'};
                d4 = d4{ref_run_order, 'score'};


                d5 = data(strcmp(data{:,'conv'}, conv) & strcmp(data{:,'utt'}, utt2), {'run', 'score'});
                d5.Properties.RowNames = d5{:, 'run'};
                d5 = d5{ref_run_order, 'score'};

                conversation(end+1, 1) = corr(d4, d5, 'type', 'Kendall');
            end
        end
    end
end



different = [];

for cn1=1:(length(convs)-1)
    utts1 = conv2utts(convs{cn1});
    c1 = convs(cn1);
    for cn2=(cn1+1):length(convs)
        utts2 = conv2utts(convs{cn2});
        c2 = convs(cn2);
        for un1=1:length(utts1)
            u1 = utts1(un1);
            for un2=1:length(utts2)
                u2 = utts2(un2);
                d4 = data(strcmp(data{:,'conv'}, c1) & strcmp(data{:,'utt'}, u1), {'run', 'score'});
                d4.Properties.RowNames = d4{:, 'run'};
                d4 = d4{ref_run_order, 'score'};


                d5 = data(strcmp(data{:,'conv'}, c2) & strcmp(data{:,'utt'}, u2), {'run', 'score'});
                d5.Properties.RowNames = d5{:, 'run'};
                d5 = d5{ref_run_order, 'score'};

                different(end+1, 1) = corr(d4, d5, 'type', 'Kendall');
                
            end
        end
    end
end

disp(mean(different(~isnan(different), 1)));
disp(mean(conversation(~isnan(conversation), 1)));
disp(mean(tree(~isnan(tree), 1)));

[~,p] = kstest2(different, conversation);
disp(p);

[~,p] = kstest2(different, tree);
disp(p);


[~,p] = kstest2(tree, conversation);
disp(p);

ds1 = fitdist(different, 'kernel');
ds2 = fitdist(conversation, 'kernel');
ds3 = fitdist(tree, 'kernel');
x = 0:0.01:1;


fid = fopen('../../data/correlations.txt' , 'wt');
fprintf(fid, [repmat('%f,', 1, length(x)) '\n'], x);


hold on;
y = pdf(ds1, x);
fprintf(fid, [repmat('%f,', 1, length(x)) '\n'], y);
plot(x,y,'LineWidth',2);


y = pdf(ds2, x);
plot(x,y,'LineWidth',2);
fprintf(fid, [repmat('%f,', 1, length(x)) '\n'], y);


y = pdf(ds3, x);
plot(x,y,'LineWidth',2);
fprintf(fid, [repmat('%f,', 1, length(x)) '\n'], y);


fclose(fid);

legend(["different", "conversation", "tree"]);



