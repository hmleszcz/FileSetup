## R_Demo_Simulation_Inference_MCMC_Estimate_Mean.R
##########################################################################
##.  TEST TO SEE IF THIS COMMITTED... why didn't this work? 

##INSTRUCTOR: Christopher Fariss
## COURSE NAME: Programming and Simulation Methods for Computational Social Science (2W)
## University of Essex Summer School 2024
##
## Date: 2024-07-22
##
## Please e-mail me if you find any errors or have and suggestions (either email is fine)
## e-mail: cjf0006@gmail.com
## e-mail: cjfariss@umich.edu
##
##########################################################################
##
## Goal: Improve the estimation of uncertainty associated with one or more model parameters by fully approximating the posterior distribution of every parameter contained within a model.
##
##########################################################################
## Introduction to tutorial:
##
## For this R tutorial we will write a program that implements the Metropolis-Hastings sampling algorithm.
##
## The Metropolis–Hastings algorithm is a Markov chain Monte Carlo (MCMC) method for obtaining a sequence of random samples from a probability distribution.
##
## The parameter for the mean will be selected based on the likelihood function that links the parameter to the data contained in the x variable.
##
## A key feature of this simulation method is the dependence of each estimate of the parameter(s) on only the most recent estimate of the prior.
## 
## Select a starting value for the parameter. The first estimate of the simulation will be based on this starting value. 
##
## Repeat the simulation several thousand times.
##
## To review Markov chains with an intuitive program challenge, go here: https://github.com/CJFariss/R-Program-Challenges/blob/main/R-Program-Challenges/R_Challenge_simulation_weather_forecast.R
##
## There is a nice explain-er here too: https://nicercode.github.io/guides/mcmc/
##
##########################################################################

## load library
library(MASS) # load library with truehist function

set.seed(940)
## set x values
#x <- 1:5
x <- rnorm(1000, mean=pi, sd=1)

## print the mean to the console screen
mean(x)
truehist(x)

## Prior distribution
## we take the log of the density because we are going to combine it with the value of the loglikelihood later on
log_prior <- function(mu){
    value <- dunif(x=mu, -100, 100, log=T)
    return(value)
}

## loglikelihood Function
log_likelihood <- function(mu,data){
    value <- sum(log(dnorm(x=data, mean=mu, sd=1)))
    return(value)
}


## plot the likelihood profile for different estimates of the mean parameter mu
values <- seq(0, 6, by=.05)
out <- c()
for(i in 1:length(values)){
    out[i] <- log_likelihood(mu=values[i], data=x)
}

## Graph the likelihood profile
plot (values, out , type="l", xlab = "mean", ylab = "Log Likelihood", main="Likelihood profile of the mean", lwd=2, col="orange")


## number of simulations
samples <- 4000

## proposal width
proposal_width <- .2

## start values for the parameter estimate of the mean 
## (NOTE: I have selected a really poor value to start with because it is really far away from the truth which is 3 or 3.141593...
estimate <- -20

loglik <- log_likelihood(mu=estimate[1], data=x) + log_prior(mu=estimate[1])
loglik

## monitor the number of times the algorithm accepts the new estimate
accept_new_estiamte <- 1

## monitor the decision criterion
comp <- 0

## MCMC simulation
## iterate to take samples 
for(i in 2:samples){
    
    ## propose new values and calculate LL
    estimate[i] <- rnorm(1, mean=estimate[i-1], sd = proposal_width)
    loglik[i] <- log_likelihood(mu=estimate[i], data=x) + log_prior(estimate[i])
    
    current_ll <- loglik[i]
    last_ll <- loglik[i-1]
    
    ## calculate decision criterion
    comp[i] <- exp(current_ll - last_ll) - runif(1, 0, 1)
    
    ## decide whether to accept or not
    if (comp[i] >= 0) {
        accept_new_estiamte[i] <- 1
        ## estimate[i] <- estimate[i] ## redundant but this is what is occurring
        ## loglik[i] <- loglik[i] ## redundant but this is what is occurring
    } else {
        accept_new_estiamte[i] <- 0
        estimate[i] <- estimate[i-1]
        loglik[i] <- loglik[i-1]
    }
}

## number of acceptances?
table(accept_new_estiamte)

## summarize the acceptance criteria metric
summary(comp)

## graph the full chain
plot(estimate, type="l")

## graph the chain after disregarding a burn-in period
plot(estimate[2001:4000], type="l")

##
truehist(estimate[2001:4000], col="grey")


## point estimate of our mean estimate
mean(estimate[2001:4000])

## standard deviation of our mean estimate
sd(estimate[2001:4000])


## compare the MCMC estimation of the mean and sd to the empirical mean and se of the mean
mean_se <- function(x){sd(x)/sqrt(length(x))}

mean(x)
mean_se(x)


