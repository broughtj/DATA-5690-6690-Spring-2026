using Plots
using StatsBase

S = 41.0
r = 0.08
v = 0.30
q = 0.0
T = 1.0
N = 252
h = T / N
K = 40.0

u = exp((r - q)*h + v*sqrt(h))
d = exp((r - q)*h - v*sqrt(h))
pu = (exp((r - q)*h) - d) / (u - d)

M = 5_000 
spot = zeros(252)
call  = zeros(M)

payoff(spot, strike) = max(spot - strike, 0.0)

function naive_mc(spot, M, N)
    for j in 1:M
        spot = zeros(N)
        spot[1] = S
        for t in 2:N
            if rand() >= pu
                spot[t] = spot[t-1] * u
            else
                spot[t] = spot[t-1] * d
            end
            
        end
        call[j] = payoff(spot[end], K)
    end

    return call_prc = exp(-r*T) * mean(call)
end

