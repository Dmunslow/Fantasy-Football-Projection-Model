library(rjags)


snap_data <- readRDS("./Snap Data.RDS")

anyNA(snap_data)

dat <- na.omit(snap_data)

dat$OFF_TEAM <- as.numeric(dat$OFF_TEAM)


mod_string = " model {
    for (i in 1:length(OFF_SNAPS)) {
OFF_SNAPS[i] ~ dpois(lam[i])
log(lam[i]) = int + b[1]*OFF_PASS_DVOA_4WK_MA[i] + b[2]*AVG_SPP_PACE[i] + b[3]*IMPLIED_TOTAL[i] + b[4]*OFF_HOME_IND[i] + b[5]*AVG_PASS_PCT_8WK[i]
}

int ~ dnorm(0.0, 1.0/1e6)

for (j in 1:5) {
b[j] ~ dnorm(0.0, 1.0/1.0e6)
}

} "

set.seed(102)

data_jags = as.list(dat)

params = c("int", "b")

mod = jags.model(textConnection(mod_string), data=data_jags, n.chains=3)
update(mod, 1e3)

mod_sim = coda.samples(model=mod,
                       variable.names=params,
                       n.iter=5e3)
mod_csim = as.mcmc(do.call(rbind, mod_sim))


plot(mod_csim, ask =T)

dic = dic.samples(mod, n.iter=1e3)


pmed_coef = apply(mod_csim, 2, median)

X = as.matrix(dat[,c(18,28,15,10,30)])
head(X)

llam_hat = pmed_coef["int"] + X %*% pmed_coef[c("b[1]", "b[2]", "b[3]", "b[4]", "b[5]")]

lam_hat = exp(llam_hat)

hist(lam_hat)


resid = dat$OFF_SNAPS - lam_hat

plot(resid)

plot(lam_hat, dat$OFF_SNAPS)

summary(mod_sim)


##  ============================================================================


mod2_string = " model {
for (i in 1:length(OFF_SNAPS)) {
OFF_SNAPS[i] ~ dpois(lam[i])
log(lam[i]) = a[OFF_TEAM[i]] + b[1]*OFF_PASS_DVOA_4WK_MA[i] + b[2]*AVG_SPP_PACE[i] + b[3]*IMPLIED_TOTAL[i] + b[4]*OFF_HOME_IND[i] + b[5]*AVG_PASS_PCT_8WK[i]
}

for (j in 1:max(OFF_TEAM)) {
    a[j] ~ dnorm(a0, prec_a)
}

for (j in 1:5) {
    b[j] ~ dnorm(0.0, 1.0/1.0e6)
}

a0 ~ dnorm(50.0, 1.0/1.0e6)
prec_a ~ dgamma(1/6.0, 1*10.0/6.0)
tau = sqrt( 1.0 / prec_a )

alpha = mu^2 / sig^2
beta = mu / sig^2

mu ~ dgamma(50.0, 1.0/5.0)
sig ~ dexp(10.0)

} "

set.seed(102)

data_jags = as.list(dat)

params2 = c("a", "b", "sig", "tau")

mod2 = jags.model(textConnection(mod2_string), data=data_jags, n.chains=3)
update(mod2, 1e3)


mod2_sim = coda.samples(model=mod2,
                       variable.names=params2,
                       n.iter=5e3)
mod2_csim = as.mcmc(do.call(rbind, mod2_sim))


plot(as.mcmc(mod2_csim))

dic2 = dic.samples(mod2, n.iter=1e3)
dic

pmed_coef2 = apply(mod2_csim, 2, median)

llam_hat = pmed_coef["int"] + X %*% pmed_coef[c("b[1]", "b[2]", "b[3]", "b[4]", "b[5]")]



##  ============================================================================

mod3_string = " model {
    for (i in 1:length(OFF_SNAPS)) {
OFF_SNAPS[i] ~ dpois(lam[i])
log(lam[i]) = int + b[1]*OFF_PASS_DVOA_4WK_MA[i] + b[2]*AVG_SPP_PACE[i] + b[3]*IMPLIED_TOTAL[i] + b[4]*OFF_HOME_IND[i] + b[5]*AVG_PASS_PCT_8WK[i]
}

int ~ dnorm(0.0, 1.0/1e6)

for (j in 1:5) {
b[j] ~ dnorm(0.0, 1.0/1.0e6)
}

} "

set.seed(102)

data_jags = as.list(dat)

params = c("int", "b")

mod3 = jags.model(textConnection(mod3_string), data=data_jags, n.chains=3)
update(mod, 1e3)

mod3_sim = coda.samples(model=mod3,
                       variable.names=params,
                       n.iter=5e5)
mod_csim = as.mcmc(do.call(rbind, mod_sim))




dic = dic.samples(mod3, n.iter=1e4)


pmed_coef3 = apply(mod3_csim, 2, median)

X = as.matrix(dat[,c(18,28,15,10,30)])
head(X)

llam_hat = pmed_coef["int"] + X %*% pmed_coef[c("b[1]", "b[2]", "b[3]", "b[4]", "b[5]")]

lam_hat = exp(llam_hat)

hist(lam_hat)


resid = dat$OFF_SNAPS - lam_hat

plot(resid)

plot(lam_hat, dat$OFF_SNAPS)

summary(mod3_sim)


##  ============================================================================


mod4_string = " model {
for (i in 1:length(OFF_SNAPS)) {
OFF_SNAPS[i] ~ dpois(lam[i])
log(lam[i]) = a[OFF_TEAM[i]] + b[1]*OFF_PASS_DVOA_4WK_MA[i] + b[2]*AVG_SPP_PACE[i] + b[3]*IMPLIED_TOTAL[i] + b[4]*OFF_HOME_IND[i] + b[5]*AVG_PASS_PCT_8WK[i]
}

for (j in 1:max(OFF_TEAM)) {
a[j] ~ dnorm(a0, prec_a)
}

for (j in 1:5) {
b[j] ~ dnorm(0.0, 1.0/1.0e6)
}

a0 ~ dnorm(0.0, 1.0/1.0e6)
prec_a ~ dgamma(1/2.0, 1*10.0/2.0)
tau = sqrt( 1.0 / prec_a )

alpha = mu^2 / sig^2
beta = mu / sig^2

mu ~ dgamma(2.0, 1.0/5.0)
sig ~ dexp(1.0)

} "

set.seed(102)

data_jags = as.list(dat)

params2 = c("a", "b", "sig", "tau")

mod4 = jags.model(textConnection(mod4_string), data=data_jags, n.chains=3)
update(mod2, 1e3)


mod4_sim = coda.samples(model=mod4,
                       variable.names=params2,
                       n.iter=5e5)
mod2_csim = as.mcmc(do.call(rbind, mod2_sim))


# plot(mod2_csim, ask =T)

dic4 = dic.samples(mod4, n.iter=1e4)
dic

pmed_coef4 = apply(mod4_csim, 2, median)

llam_hat = pmed_coef["int"] + X %*% pmed_coef[c("b[1]", "b[2]", "b[3]", "b[4]", "b[5]")]

