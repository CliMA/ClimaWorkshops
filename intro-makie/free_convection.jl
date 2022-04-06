# # Intro to three-dimensional plotting with Makie
#
# This tutorial introduces three-dimensional animations
# with GLMakie.jl, using data from a large eddy simulation of convection.
#
# Make sure the following packages are installed:

using GLMakie
using Oceananigans
using Statistics
using Printf

grid = RectilinearGrid(size=(64, 64, 64), extent=(256, 256, 128), halo=(3, 3, 3), topology=(Periodic, Periodic, Bounded))
boundary_conditions = (; b=FieldBoundaryConditions(bottom=FluxBoundaryCondition(1e-7)))
coriolis = FPlane(f=1e-4)
model = NonhydrostaticModel(; grid, boundary_conditions, coriolis, advection=WENO5(), tracers=:b, buoyancy=BuoyancyTracer())
bᵢ(x, y, z) = 1e-6 * z + 1e-8 * rand()
set!(model, b=bᵢ)
simulation = Simulation(model, Δt=10.0, stop_iteration=100)
run!(simulation)

# # Demo
# Extract the sides of cube of data
function datacube(field; e=1, w=size(field, 1), s=1, n=size(field, 2), b=1, t=size(field, 3))
    return (east   = interior(field, e, :, :),
            west   = interior(field, w, :, :),
            south  = interior(field, :, s, :),
            north  = interior(field, :, n, :),
            bottom = interior(field, :, :, b),
            top    = interior(field, :, :, t))
end

u, v, w = model.velocities
e_op = @at (Center, Center, Center) (u^2 + v^2 + w^2) / 2
e = compute!(Field(e_op))
ecube = datacube(e)

# Create "coordinate fields"
x = set!(CenterField(grid), (x, y, z) -> x)
y = set!(CenterField(grid), (x, y, z) -> y)
z = set!(CenterField(grid), (x, y, z) -> z)

xcube = datacube(x)
ycube = datacube(y)
zcube = datacube(z)

# Nudging closes gaps between surfaces.
nudge = 0.005 * grid.Lx
xcube.west   .+= nudge
ycube.south  .+= nudge
zcube.top    .+= nudge
xcube.east   .-= nudge
ycube.north  .-= nudge
zcube.bottom .-= nudge

fig = Figure(resolution=(800, 600))
ax = Axis3(fig[1, 1], xlabel="x (m)", ylabel="y (m)", zlabel="z (m)")

for side in (:east, :west, :south, :north, :bottom, :top)
    x = getproperty(xcube, side)
    y = getproperty(ycube, side)
    z = getproperty(zcube, side)
    pl = surface!(ax, x, y, z, color=getproperty(ecube, side))
end

display(fig)

#=
simulation.output_writers[:ke] = JLD2OutputWriter(model, (; e),
                                                  schedule = IterationInterval(100),
                                                  prefix = "convection",
                                                  force = true)

progress(sim) = @info string("Iter: ", iteration(sim), "time: ", prettytime(sim))
simulation.callbacks[:progress] = Callback(progress, IterationInterval(10))

simulation.stop_iteration += 2000
run!(simulation)
=#

fig = Figure(resolution=(800, 600))
ax = Axis3(fig[1, 1], xlabel="x (m)", ylabel="y (m)", zlabel="z (m)")

et = FieldTimeSeries("convection.jld2", "e")

eⁿ = (east   = @lift(datacube(et[$n]).east),
      west   = @lift(datacube(et[$n]).west),
      south  = @lift(datacube(et[$n]).south),
      north  = @lift(datacube(et[$n]).north),
      top    = @lift(datacube(et[$n]).top),
      bottom = @lift(datacube(et[$n]).bottom))

for side in (:east, :west, :south, :north, :bottom, :top)
    x = getproperty(xcube, side)
    y = getproperty(ycube, side)
    z = getproperty(zcube, side)
    pl = surface!(ax, x, y, z, color=getproperty(eⁿ, side))
end

display(fig)
