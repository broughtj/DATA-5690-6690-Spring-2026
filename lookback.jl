"""
    LookbackOption <: ExoticOption

Abstract type for lookback options whose payoff depends on the extremum
of the underlying asset price over the life of the option.

See also: [`FixedStrikeLookbackCall`](@ref), [`FixedStrikeLookbackPut`](@ref),
          [`FloatingStrikeLookbackCall`](@ref), [`FloatingStrikeLookbackPut`](@ref)
"""
abstract type LookbackOption <: ExoticOption end


# ──────────────────────────────────────────────────────────────────────────────
# Fixed-strike lookback options
# ──────────────────────────────────────────────────────────────────────────────

"""
    FixedStrikeLookbackCall(strike, expiry, fixings)

European fixed-strike lookback call option.

The payoff at maturity is `max(0, max(S_t1, …, S_tN) - K)` where the maximum
is taken over a discrete set of observation (fixing) dates.

# Fields
- `strike::AbstractFloat`: Strike price K
- `expiry::AbstractFloat`: Time to expiration in years
- `fixings::Int`:          Number of equally-spaced fixing dates

# Examples
```julia
# 1-year lookback call, strike 100, observed at 52 weekly fixings
opt = FixedStrikeLookbackCall(100.0, 1.0, 52)
```

See also: [`FixedStrikeLookbackPut`](@ref), [`payoff`](@ref)
"""
struct FixedStrikeLookbackCall <: LookbackOption
    strike::AbstractFloat
    expiry::AbstractFloat
    fixings::Int
end

Base.broadcastable(x::FixedStrikeLookbackCall) = Ref(x)

"""
    payoff(option::FixedStrikeLookbackCall, path::AbstractVector)

Compute the payoff `max(0, max(path) - K)` from a full simulated price path.
"""
function payoff(option::FixedStrikeLookbackCall, path::AbstractVector)
    return max(0.0, maximum(path) - option.strike)
end


"""
    FixedStrikeLookbackPut(strike, expiry, fixings)

European fixed-strike lookback put option.

The payoff at maturity is `max(0, K - min(S_t1, …, S_tN))`.

# Fields
- `strike::AbstractFloat`: Strike price K
- `expiry::AbstractFloat`: Time to expiration in years
- `fixings::Int`:          Number of equally-spaced fixing dates

# Examples
```julia
opt = FixedStrikeLookbackPut(100.0, 1.0, 52)
```
"""
struct FixedStrikeLookbackPut <: LookbackOption
    strike::AbstractFloat
    expiry::AbstractFloat
    fixings::Int
end

Base.broadcastable(x::FixedStrikeLookbackPut) = Ref(x)

"""
    payoff(option::FixedStrikeLookbackPut, path::AbstractVector)

Compute the payoff `max(0, K - min(path))`.
"""
function payoff(option::FixedStrikeLookbackPut, path::AbstractVector)
    return max(0.0, option.strike - minimum(path))
end


# ──────────────────────────────────────────────────────────────────────────────
# Floating-strike lookback options
# ──────────────────────────────────────────────────────────────────────────────

"""
    FloatingStrikeLookbackCall(expiry, fixings)

European floating-strike lookback call whose payoff is `max(0, S_T - min(S))`.

# Fields
- `expiry::AbstractFloat`: Time to expiration in years
- `fixings::Int`:          Number of equally-spaced fixing dates
"""
struct FloatingStrikeLookbackCall <: LookbackOption
    expiry::AbstractFloat
    fixings::Int
end

Base.broadcastable(x::FloatingStrikeLookbackCall) = Ref(x)

function payoff(option::FloatingStrikeLookbackCall, path::AbstractVector)
    return max(0.0, path[end] - minimum(path))
end


"""
    FloatingStrikeLookbackPut(expiry, fixings)

European floating-strike lookback put whose payoff is `max(0, max(S) - S_T)`.

# Fields
- `expiry::AbstractFloat`: Time to expiration in years
- `fixings::Int`:          Number of equally-spaced fixing dates
"""
struct FloatingStrikeLookbackPut <: LookbackOption
    expiry::AbstractFloat
    fixings::Int
end

Base.broadcastable(x::FloatingStrikeLookbackPut) = Ref(x)

function payoff(option::FloatingStrikeLookbackPut, path::AbstractVector)
    return max(0.0, maximum(path) - path[end])
end


# ──────────────────────────────────────────────────────────────────────────────
# Analytical pricing – Continuous fixed-strike lookback call  (Eq. 4.53)
# ──────────────────────────────────────────────────────────────────────────────

"""
    price(option::FixedStrikeLookbackCall, ::BlackScholes, data::MarketData)

Analytical price for a **continuously monitored** fixed-strike lookback call
under the Black-Scholes model (equation 4.53 in Clewlow & Strickland).

    C = G + S e^{-δT} N(x + σ√T) - K e^{-rT} N(x)
        - (S/B) [ e^{-rT} (E/S)^B  N(x + (1-B)σ√T)
                 - e^{-δT} N(x + σ√T) ]

where M is the current known maximum, and the remaining variables are
defined in terms of (S, K, T, r, δ, σ, M).

This formula is exact for continuous monitoring; it slightly overestimates
the value of a discretely-monitored lookback because the continuous maximum
is always ≥ the discrete maximum.

# Examples
```julia
data = MarketData(100.0, 0.06, 0.2, 0.03)
opt  = FixedStrikeLookbackCall(100.0, 1.0, 52)
price(opt, BlackScholes(), data)
```
"""
function price(option::FixedStrikeLookbackCall, ::BlackScholes, data::MarketData)
    K = option.strike
    T = option.expiry
    S = data.spot
    r = data.rate
    σ = data.vol
    δ = data.div

    M = S                       # no fixings have occurred yet → current max = S
    _lookback_call_continuous(S, K, T, r, δ, σ, M)
end

"""
    _lookback_call_continuous(S, K, T, r, δ, σ, M)

Internal: Continuous fixed-strike lookback call formula (eq. 4.53).
M is the current known maximum of the asset price.
"""
function _lookback_call_continuous(S, K, T, r, δ, σ, M)
    # Determine E and G based on whether the current max exceeds the strike
    if K >= M
        E = K
        G = 0.0
    else
        E = M
        G = exp(-r * T) * (M - K)
    end

    B = 2(r - δ) / σ^2

    x = (log(S / E) + (r - δ - 0.5 * σ^2) * T) / (σ * sqrt(T))

    term1 = S * exp(-δ * T) * norm_cdf(x + σ * sqrt(T))
    term2 = K * exp(-r * T) * norm_cdf(x)
    term3 = (S / B) * (
        exp(-r * T) * (E / S)^B * norm_cdf(x + (1 - B) * σ * sqrt(T)) -
        exp(-δ * T) * norm_cdf(x + σ * sqrt(T))
    )

    return G + term1 - term2 - term3
end


# ──────────────────────────────────────────────────────────────────────────────
# Lookback delta (via the continuous formula) for control-variate hedging
# ──────────────────────────────────────────────────────────────────────────────

"""
    _lookback_delta(S, K, T, t, r, δ, σ, M)

Black-Scholes delta of the continuously-monitored fixed-strike lookback call
computed by central finite difference on the analytical formula.

Used internally by the control-variate Monte Carlo pricer.
"""
function _lookback_delta(S, K, T, t, r, δ, σ, M)
    τ = T - t
    τ <= 0.0 && return 0.0
    dS = 0.001 * S
    cup = _lookback_call_continuous(S + dS, K, τ, r, δ, σ, max(M, S + dS))
    cdn = _lookback_call_continuous(S - dS, K, τ, r, δ, σ, max(M, S - dS))
    return (cup - cdn) / (2 * dS)
end


# ──────────────────────────────────────────────────────────────────────────────
# Monte Carlo pricing – simple
# ──────────────────────────────────────────────────────────────────────────────

"""
    price(option::LookbackOption, engine::MonteCarlo, data::MarketData)

Price any `LookbackOption` by simple Monte Carlo simulation following
the methodology of Chapter 4 (Figures 4.2 / 4.21).

The underlying asset is simulated under GBM with `engine.steps` time steps
per path and `engine.reps` replications.  The payoff function dispatches on
the concrete option type.

# Returns
`(price, std_error)` – the discounted mean payoff and its standard error.

# Examples
```julia
data   = MarketData(100.0, 0.06, 0.2, 0.03)
opt    = FixedStrikeLookbackCall(100.0, 1.0, 52)
engine = MonteCarlo(52, 100_000)
p, se  = price(opt, engine, data)
```
"""
function price(option::LookbackOption, engine::MonteCarlo, data::MarketData)
    T = option.expiry
    S = data.spot
    r = data.rate
    σ = data.vol
    δ = data.div
    N = engine.steps
    M = engine.reps

    dt     = T / N
    nudt   = (r - δ - 0.5 * σ^2) * dt
    sigsdt = σ * sqrt(dt)

    sum_CT  = 0.0
    sum_CT2 = 0.0

    @inbounds for j in 1:M
        # Simulate one path and store prices at fixing dates
        path = Vector{Float64}(undef, N + 1)
        path[1] = S
        St = S
        for i in 1:N
            ε  = randn()
            St = St * exp(nudt + sigsdt * ε)
            path[i + 1] = St
        end

        CT = payoff(option, path)
        sum_CT  += CT
        sum_CT2 += CT * CT
    end

    call_value = (sum_CT / M) * exp(-r * T)
    SD = sqrt((sum_CT2 - sum_CT * sum_CT / M) * exp(-2 * r * T) / (M - 1))
    SE = SD / sqrt(M)

    return (price = call_value, std_error = SE)
end


# ──────────────────────────────────────────────────────────────────────────────
# Monte Carlo pricing – antithetic variance reduction  (§ 4.3 / Figure 4.5)
# ──────────────────────────────────────────────────────────────────────────────

"""
    AntitheticMonteCarlo(steps, reps)

Monte Carlo engine with antithetic variance reduction.

For each simulation, two paths are generated using `+ε` and `−ε` and their
payoffs are averaged, which ensures the sample mean of the normal draws is
exactly zero and typically halves the variance (§ 4.3).

# Fields
- `steps::Int`: Number of time steps per path
- `reps::Int`:  Number of simulation *pairs*
"""
struct AntitheticMonteCarlo
    steps::Int
    reps::Int
end

"""
    price(option::LookbackOption, engine::AntitheticMonteCarlo, data::MarketData)

Price a lookback option using antithetic Monte Carlo (Figure 4.5 pattern).

# Returns
`(price, std_error)`
"""
function price(option::LookbackOption, engine::AntitheticMonteCarlo, data::MarketData)
    T = option.expiry
    S = data.spot
    r = data.rate
    σ = data.vol
    δ = data.div
    N = engine.steps
    M = engine.reps

    dt     = T / N
    nudt   = (r - δ - 0.5 * σ^2) * dt
    sigsdt = σ * sqrt(dt)

    sum_CT  = 0.0
    sum_CT2 = 0.0

    @inbounds for j in 1:M
        path1 = Vector{Float64}(undef, N + 1)
        path2 = Vector{Float64}(undef, N + 1)
        path1[1] = S
        path2[1] = S
        St1 = S
        St2 = S

        for i in 1:N
            ε   = randn()
            St1 = St1 * exp(nudt + sigsdt * ε)
            St2 = St2 * exp(nudt + sigsdt * (-ε))
            path1[i + 1] = St1
            path2[i + 1] = St2
        end

        CT = 0.5 * (payoff(option, path1) + payoff(option, path2))
        sum_CT  += CT
        sum_CT2 += CT * CT
    end

    call_value = (sum_CT / M) * exp(-r * T)
    SD = sqrt((sum_CT2 - sum_CT * sum_CT / M) * exp(-2 * r * T) / (M - 1))
    SE = SD / sqrt(M)

    return (price = call_value, std_error = SE)
end


# ──────────────────────────────────────────────────────────────────────────────
# Monte Carlo pricing – antithetic + delta control variate  (§ 4.5 / Fig 4.27)
# ──────────────────────────────────────────────────────────────────────────────

"""
    ControlVariateMonteCarlo(steps, reps)

Monte Carlo engine combining antithetic variance reduction with a
delta-based control variate derived from the continuously-monitored
fixed-strike lookback call formula (§ 4.10, Figure 4.27).

The control variate is the discretely rebalanced delta hedge:

    cv = Σ  delta_i * (S_{i+1} − S_i * erddt)

where `erddt = exp((r − δ)Δt)`.  Since the expected value of cv is zero,
subtracting `β₁ × cv` from each payoff reduces variance without introducing
bias.  `β₁ = −1` is used following the chapter's recommendation.

# Fields
- `steps::Int`: Number of time steps per path
- `reps::Int`:  Number of simulation *pairs* (antithetic)
"""
struct ControlVariateMonteCarlo
    steps::Int
    reps::Int
end

"""
    price(option::FixedStrikeLookbackCall, engine::ControlVariateMonteCarlo, data::MarketData)

Price a fixed-strike lookback call using antithetic + delta control variate
Monte Carlo (the full method of § 4.10 / Figure 4.27, simplified to delta only).

# Returns
`(price, std_error)`
"""
function price(option::FixedStrikeLookbackCall, engine::ControlVariateMonteCarlo,
               data::MarketData)
    K = option.strike
    T = option.expiry
    S = data.spot
    r = data.rate
    σ = data.vol
    δ = data.div
    N = engine.steps
    M = engine.reps

    dt     = T / N
    nudt   = (r - δ - 0.5 * σ^2) * dt
    sigsdt = σ * sqrt(dt)
    erddt  = exp((r - δ) * dt)
    beta1  = -1.0

    sum_CT  = 0.0
    sum_CT2 = 0.0

    @inbounds for j in 1:M
        # --- path 1 (+ε) and path 2 (−ε) ---
        St1 = S;  St2 = S
        maxSt1 = S;  maxSt2 = S
        cv1 = 0.0;   cv2 = 0.0

        for i in 1:N
            t_i = (i - 1) * dt

            # Delta hedge sensitivities from continuous lookback formula
            delta1 = _lookback_delta(St1, K, T, t_i, r, δ, σ, maxSt1)
            delta2 = _lookback_delta(St2, K, T, t_i, r, δ, σ, maxSt2)

            ε = randn()
            Stn1 = St1 * exp(nudt + sigsdt * ε)
            Stn2 = St2 * exp(nudt + sigsdt * (-ε))

            # Accumulate control variates (eq. 4.19 pattern)
            cv1 += delta1 * (Stn1 - St1 * erddt)
            cv2 += delta2 * (Stn2 - St2 * erddt)

            St1 = Stn1;  St2 = Stn2
            maxSt1 = max(maxSt1, St1)
            maxSt2 = max(maxSt2, St2)
        end

        pay1 = max(0.0, maxSt1 - K)
        pay2 = max(0.0, maxSt2 - K)

        CT = 0.5 * (pay1 + beta1 * cv1 + pay2 + beta1 * cv2)
        sum_CT  += CT
        sum_CT2 += CT * CT
    end

    call_value = (sum_CT / M) * exp(-r * T)
    SD = sqrt((sum_CT2 - sum_CT * sum_CT / M) * exp(-2 * r * T) / (M - 1))
    SE = SD / sqrt(M)

    return (price = call_value, std_error = SE)
end
