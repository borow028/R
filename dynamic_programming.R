#fibonacci - recursion
fib <- function(n) {
  if (n==0L) return (0L)
  if (n==1L) return (1L)
  (fib(n-1L) + fib(n-2L))
}
fib(6L)


# Top-Down Dynamic Programming --------------------------------------------

#memoization - caching results once computed
library(memoise)
# envelop the function into memoise()
mfib <- memoise( function(n) {
  if (!is.integer(n)) stop("n must be an integer")
  if (n==0L) return (0L)
  if (n==1L) return (1L)
  (mfib(n-1L) + mfib(n-2L))
})
mfib(6L)

system.time(fib(30L))
system.time(mfib(30L))

has_cache(mfib)(6L) # Should be true
has_cache(mfib)(3L) # Should be true - part of subproblems
has_cache(mfib)(50L) # Should be false - we never computed it

#for loop approach
N <- 6L
fib_ <- array(0L, dim=N)
# R has 1-based indexing so can't define fib[0]
fib_[1] <- 1L
fib_[2] <- 1L
for(i in 3:N) {
  fib_[i] <- fib_[i-1L] + fib_[i-2L]
}
fib_[N]

#0/1 knapsack/burglar problem
#K(w,j) - capacity w, item id's j
#K(1,1) - 1 lb, item 1
#K(w − wj, j − 1) before putting item j in bag
#when you put item j you increased the value of the bag by vj, so
#K(w, j) = K(w − wj, j − 1) + vj

#recursion - naive approach
w <- c(6L,3L,4L,2L)
v <- c(30L,14L,16L,9L)
K <- function(ww,jj) {
  if (jj <= 0) return (0) # No items to be stolen: value = 0
  if (ww < w[jj]) return (K(ww,jj-1)) # Bag can't hold item jj
  value_if_dont_take_j <- K(ww,jj-1)
  value_if_take_j <- K(ww-w[jj],jj-1)+v[jj]
  (max(value_if_take_j, value_if_dont_take_j))
}
K(10L,4L)

# Create a memoised function
mK <- memoise( function(ww,jj) {
  if (!is.integer(ww) || !is.integer(jj)) stop("Must use integers!")
  if (jj <= 0L) return (0L)
  if (ww < w[jj]) return (mK(ww,jj-1L)) # mK() instead of K()
  # Call mK() instead of K() to use memoization
  value_if_dont_take_j <- mK(ww,jj-1L)
  value_if_take_j <- mK(ww-w[jj],jj-1L)+v[jj]
  (max(value_if_take_j, value_if_dont_take_j))
})
# Now run a memoised version of K
mK(10L,4L)

has_cache(mK)(10L,4L) # Should be true
#integers vs numerics - 10L is integer, 10 is floating point
has_cache(mK)(10,4) # Should be false
#use this to ensure integers
if (!is.integer(ww) || !is.integer(jj)) stop("Must use integers!")

#forget memoized version after running
mK(10L,4L) # Run the memoised version
forget(mK) # Erase the caches

#matrix of computations
W <- 10L
J <- 4L
S <- matrix(0L, nrow = W, ncol = J)
for(jj in 1:J) {
  for(ww in 1:W) {
    S[ww,jj] <- NA_integer_
    if (has_cache(mK)(ww,jj)) S[ww,jj] <- mK(ww,jj)
  }
}
S
t(S) #transpose matrix

# Bottom-Up Dynamic Programming -------------------------------------------

#loop instead of recursion - start from blank matrix
#build up table os solutions to subproblems - tabulation - table-filling

K <- matrix(0L, nrow=W, ncol=J)
# Due to 1-based index in R, need to init the first layer
K[,1] <- ifelse(1:W < w[1], 0L, v[1])
for(jj in 2:J) {
  for (ww in 1:W) {
    if (ww < w[jj]) # jj is too heavy for bag ww
      K[ww,jj] <- K[ww,jj-1]
    else {
      value_if_dont_take_j <- K[ww,jj-1]
      value_if_take_j <-
        if (ww-w[jj]==0) (v[jj]) # fix due to 1-based indexing in R
      else K[ww-w[jj],jj-1] + v[jj]
      K[ww,jj] <- max(value_if_dont_take_j, value_if_take_j)
    }
  }
}
t(K)
K[W,J]


# Comparison - Top-Down vs Bottom-Up --------------------------------------

#automated testing tools to check code
library(assertthat)
# Solve and verify a few simple cases manually
invisible( assert_that(mK(2L,2L) == 0L) ) #will bring error if wrong
invisible( assert_that(mK(3L,2L) == 14L) )
# Then use your code for production
mK(10L,4L)
