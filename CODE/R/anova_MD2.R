data = read.csv("../../data/NDCG_cut_5.csv")
data$conv = as.factor(data$conv)
data$alpha = as.factor(data$alpha)
#data[data$X] <- NULL
data = aggregate(data[, 6], list(data$conv, data$run, data$alpha), mean)
colnames(data) <- c("conv", "run", "alpha", "score")

res.aov2 <- aov(score ~  alpha/conv + run, data = data)
summary(res.aov2)
mc = TukeyHSD(res.aov2, "run")

print(sum(mc$run[, 4]<0.05))


if (FALSE){
alphas = unique(data$alpha)
data$uttid = apply(data, 1, function(x)paste(x[3],  x[4], sep="_"))
data$conv = as.factor(data$conv)
data$utt = as.factor(data$utt)

for (a in alphas){
  
  filtered_data=data[data$alpha==a, ]
  
  res.aov2 <- aov(score ~ uttid + run, data = filtered_data)
  #print(summary(res.aov2))
  #res.aov2 <- aov(score ~ conv/utt + run, data = filtered_data)
  #print(summary(res.aov2))
  
  
  #res.aov2 <- aov(score ~ conv/utt + run+ run*conv, data = filtered_data)
  #print(summary(res.aov2))
  
  
  mc = TukeyHSD(res.aov2, "run")
  print(sum(mc$run[, 4]<0.05))
  
}
}
