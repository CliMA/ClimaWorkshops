# # Intro to two-dimensional plotting with Makie
#
# This tutorial introduces two-dimensional static and animated visualization
# with GLMakie.jl, using data from a freely-decaying barotropic turbulence simulation.
#
# We'll 
#
# 1. Create a simple figure with one axis
# 2. Create a figure with layout
# 3. Update a plot live while a simulation runs
# 4. Record an animation while a simulation runs
# 5. Use `Slider` to explore data in a static plot in post
# 6. Use `Observable` to animate data in post with a fancy `colorrange`
#
# If you're using a notebook or you forgot to write `julia --project`,
# these lines will help...

using Pkg
Pkg.activate(".")
Pkg.instantiate()

# Now we import all the packages we're planning to use: Makie with the OpenGL backend,
# Oceananigans, the function `mean`, and `Printf` for pretty printing.

using GLMakie
using Oceananigans
using Oceananigans.Simulations: reset!
using Statistics: mean
using Printf

# # The setup: freely-decaying barotropic turbulence on the beta plane
#
# All of the following examples use the setup below, which simulates
# barotropic turbulence on the beta-plane in a meridionally-bounded domain.

## Set up a simulation with random velocity initial conditions
grid = RectilinearGrid(size=(128, 128), extent=(2π, 2π), halo=(3, 3), topology=(Periodic, Bounded, Flat))
model = NonhydrostaticModel(; grid, advection=WENO5(), coriolis=BetaPlane(f₀=1, β=20))
ϵ(x, y, z) = 2rand() - 1
set!(model, u=ϵ, v=ϵ)
simulation = Simulation(model, Δt=0.02, stop_iteration=2000)

# ## Diagnostics: vorticity, speed, mean momentum, and enstrophy
#
# We build some diagnostics so we have data to plot:

## Vorticity
u, v, w = model.velocities
ζ = compute!(Field(∂x(v) - ∂y(u)))
xζ, yζ, zζ = nodes(ζ)

## Speed
s_op = @at (Center, Center, Center) sqrt(u^2 + v^2)
s = compute!(Field(s_op))
xs, ys, zs = nodes(s)

## Zonal-averaged enstrophy and momentum
Z = Field(Average(ζ^2, dims=1))
U = Field(Average(u, dims=1))
compute!(Z)
compute!(U)

# Tiny note about Oceananigans syntax: the objects `ζ`, `s`, `Z`, and `U` are
# Oceananigans `Field`s. We extract data from these objects with the function
# `interior`, which you'll find peppered throughout the code below.
# `interior` `view` into the data underlying a `Field`. For example,

typeof(interior(ζ, :, :, 1))

# returns a two-dimensional ``(x, y)`` view into the vorticity at index "1"
# in the vertical (the only index in this problem).

# # Demo
#
# ## Create a simple figure with one axis
#
# Here we plot the initial condition in a `Figure` with one `Axis`:

## Create the figure:
fig = Figure(resolution=(800, 600))

## Create the axis, specifying axis labels, title, and aspect ratio
ax = Axis(fig[1, 1], xlabel="x", ylabel="y", title="Vorticity", aspect=1)

## Create a filled contour plot of vorticity with 5 levels
contourf!(ax, xζ, yζ, interior(ζ, :, :, 1), levels=5)

## Save the plot
save("barotropic_turbulence_vorticity.png", fig)
## ![]("barotropic_turbulence_vorticity.png")
# <img src="barotropic_turbulence_vorticity.png" alt="Barotropic turbulence vorticity" width="400"/>

display(fig)

# ## Create a figure with layout
fig = Figure(resolution=(1200, 1200))

ax_ζ = Axis(fig[1, 1], xlabel="x", ylabel="y", title="Vorticity", aspect=1)
ax_s = Axis(fig[2, 1], xlabel="x", ylabel="y", title="Speed", aspect=1)
ax_Z = Axis(fig[1, 2], xlabel="Zonally-averaged enstrophy", ylabel="y")
ax_U = Axis(fig[2, 2], xlabel="Zonally-averaged zontal momentum", ylabel="y")

lbl = Label(fig[0, :], "Barotropic turbulence at t = 0")

hm_ζ = heatmap!(ax_ζ, xζ, yζ, interior(ζ, :, :, 1), colormap=:redblue)
hm_s = heatmap!(ax_s, xs, ys, interior(s, :, :, 1))
ln_Z = lines!(ax_Z, interior(Z, 1, :, 1), yζ)
ln_U = lines!(ax_U, interior(U, 1, :, 1), ys)

xlims!(ax_U, -0.1, 0.1)
xlims!(ax_Z, 0.0, 10.0)

save("barotropic_turbulence_vorticity_speed.png", fig)
display(fig)

# ## Update a plot live while a simulation runs
function update!(sim)
    ## Update the label text to the current time
    lbl.text[] = @sprintf("Barotropic turbulence at t = %.2f", time(sim))

    ## Update the vorticity and speed heatmaps. Note that the vorticity and speed
    ## are the "third" argument to `heatmap!` above
    hm_ζ.input_args[3][] = interior(compute!(ζ), :, :, 1)
    hm_s.input_args[3][] = interior(compute!(s), :, :, 1)

    ## Update the enstrophy and momentum
    compute!(Z); compute!(U)
    ln_Z.input_args[1][] = interior(Z, 1, :, 1)
    ln_U.input_args[1][] = interior(U, 1, :, 1)
    return nothing
end

simulation.callbacks[:plot] = Callback(update!, IterationInterval(10))
run!(simulation)

# ## Record an animation
pop!(simulation.callbacks, :plot)
reset!(simulation) # back to time=0, iteration=0
set!(model, u=ϵ, v=ϵ)

record(fig, "barotropic_turbulence_online.mp4", 1:100, framerate=24) do frame
    [time_step!(simulation) for i = 1:10]
    update!(simulation)
end

# ## Use a slider to explore data
reset!(simulation) # back to time=0, iteration=0
set!(model, u=ϵ, v=ϵ)
simulation.stop_iteration = 1000
simulation.output_writers[:fields] = JLD2OutputWriter(model, (; ζ, s, Z, U),
                                                      schedule = IterationInterval(10),
                                                      prefix = "barotropic_turbulence",
                                                      force = true)

run!(simulation)

filename = "barotropic_turbulence.jld2"
ζ_ts = FieldTimeSeries(filename, "ζ")
s_ts = FieldTimeSeries(filename, "s")
Z_ts = FieldTimeSeries(filename, "Z")
U_ts = FieldTimeSeries(filename, "U")

Nt = length(ζ_ts.times)

fig = Figure(resolution=(1200, 1200))

ax_ζ = Axis(fig[1, 1], xlabel="x", ylabel="y", aspect=1)
ax_s = Axis(fig[2, 1], xlabel="x", ylabel="y", aspect=1)
ax_Z = Axis(fig[1, 2], xlabel="Zonally-averaged enstrophy", ylabel="y")
ax_U = Axis(fig[2, 2], xlabel="Zonally-averaged zontal momentum", ylabel="y")

slider = Slider(fig[3, :], range=1:Nt, startvalue=1)
n = slider.value
#n = Observable(1) # This works too if we don't need a slider

ζn = @lift interior(ζ_ts[$n], :, :, 1)
sn = @lift interior(s_ts[$n], :, :, 1)
Zn = @lift interior(Z_ts[$n], 1, :, 1)
Un = @lift interior(U_ts[$n], 1, :, 1)

smax = maximum(abs, interior(s_ts))

# Dynamic colorange
Navg = 30
ζlims = @lift begin
    if $n > Nt - Navg
        ζmax = maximum(abs, ζ_ts[$n])
        ζlim = ζmax / 2
    else
        ζmax = mean(maximum(abs, ζ_ts[nn]) for nn in $n:$n+Navg-1)
        ζlim = ζmax / 2
    end
    (-ζlim, ζlim)
end

hm_ζ = heatmap!(ax_ζ, xζ, yζ, ζn, colormap=:redblue, colorrange=ζlims)
hm_s = heatmap!(ax_s, xs, ys, sn, colorrange=(0, smax/2))

lines!(ax_Z, Zn, yζ)
lines!(ax_U, Un, ys)

xlims!(ax_U, -0.15, 0.15)

## TODO: make this pretty
## Colorbar(fig[2, 0], hm_s, label="Speed", flipaxis=false)
## Colorbar(fig[1, 0], hm_ζ, label="Vorticity", flipaxis=false)

title = @lift "Barotropic turbulence at t = " * string(ζ_ts.times[$n])
lbl = Label(fig[0, :], title)

display(fig)

# ## Create an animation in post-process
record(fig, "barotropic_turbulence_offline.mp4", 1:100, framerate=24) do nn
    n[] = nn
    Zmax = maximum(Z_ts[nn])
    xlims!(ax_Z, -Zmax/10, 2Zmax)
end
