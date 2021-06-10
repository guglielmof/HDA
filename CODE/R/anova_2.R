data = read.csv("../../data/NDCG_cut_5-original.csv")

data$conv = as.factor(data$conv)
data$utt = as.factor(data$utt)


#data[data$X] <- NULL
data_agg = aggregate(data[, 6], list(data$conv, data$run), mean)
colnames(data_agg) <- c("conv", "run", "score")

res.aov2 <- aov(score ~  conv + run, data = data_agg)
summary(res.aov2)
mc = TukeyHSD(res.aov2, "run")

print(sum(mc$run[, 4]<0.05))


res.aov3 <- aov(score ~  conv + run + conv/utt, data = data)
summary(res.aov3)
mc = TukeyHSD(res.aov3, "run")

print(sum(mc$run[, 4]<0.05))


res.aov4 <- aov(score ~  conv + run, data = data)
summary(res.aov4)
mc = TukeyHSD(res.aov4, "run")

print(sum(mc$run[, 4]<0.05))

z = paste(data$conv, data$utt, sep="_")
data$conv_utt = z
res.aov5 <- aov(score ~  conv_utt + run, data = data)
summary(res.aov5)
mc = TukeyHSD(res.aov5, "run")
