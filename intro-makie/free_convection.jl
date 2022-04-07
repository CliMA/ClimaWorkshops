# # Intro to three-dimensional plotting with Makie
#
# This tutorial introduces three-dimensional animations
# with GLMakie.jl, using data from a large eddy simulation of convection.
#
# If you're using a notebook or you forgot to write `julia --project`,
# these lines will help...

using Pkg
Pkg.activate(".")
Pkg.instantiate()

# Next we import packages

using GLMakie
using Oceananigans
using Printf

# # The setup
#
# We generate 3D data of free (dry) convection to have something pretty to plot.
# The details aren't too important... suffice to say that it's stably stratified,
# heated from the bottom, and we save 3D cubes kinetic energy to plot later.

grid = RectilinearGrid(size=(64, 64, 64), extent=(256, 256, 128), halo=(3, 3, 3), topology=(Periodic, Periodic, Bounded))
boundary_conditions = (; b=FieldBoundaryConditions(bottom=FluxBoundaryCondition(1e-7)))
model = NonhydrostaticModel(; grid, boundary_conditions, advection=WENO5(), tracers=:b, buoyancy=BuoyancyTracer())
bᵢ(x, y, z) = 1e-6 * z + 1e-8 * rand()
set!(model, b=bᵢ)
simulation = Simulation(model, Δt=20.0, stop_iteration=800)

e_op = @at (Center, Center, Center) (u^2 + v^2 + w^2) / 2
e = compute!(Field(e_op))

simulation.output_writers[:ke] = JLD2OutputWriter(model, (; e),
                                                  schedule = IterationInterval(20),
                                                  prefix = "convection",
                                                  force = true)

progress(sim) = @info string("Iter: ", iteration(sim), ", time: ", prettytime(sim))
simulation.callbacks[:progress] = Callback(progress, IterationInterval(10))

run!(simulation)

# Note that it's usually advisible to save just the _slices_ that are going
# to be plotted later for 3D animations. Here I save 3D data for simplicity.

# # Visualization
#
# We first define a function that'll help us extract slices on the
# outside of a cube of data:

function datacube(field)
    Nx, Ny, Nz = size(field)
    return (east   = interior(field,  1, :, :),
            west   = interior(field, Nx, :, :),
            south  = interior(field, :,  1, :),
            north  = interior(field, :, Ny, :),
            bottom = interior(field, :, :,  1),
            top    = interior(field, :, :, Nz))
end

# We use the `datacube` util to create "coordinate fields":

x = set!(CenterField(grid), (x, y, z) -> x)
y = set!(CenterField(grid), (x, y, z) -> y)
z = set!(CenterField(grid), (x, y, z) -> z)

xcube = datacube(x)
ycube = datacube(y)
zcube = datacube(z)

# This is the important part: we nudge the coordinates a little bit
# to close gaps between surfaces. Nudging coordinates is often
# handy in 3D to overcome visualization artifacts or enforce visibility of
# stacked objects.

nudge = 0.005 * grid.Lx
xcube.west   .+= nudge
ycube.south  .+= nudge
zcube.top    .+= nudge
xcube.east   .-= nudge
ycube.north  .-= nudge
zcube.bottom .-= nudge

# Next, we create a `Figure` with `Axis3` for 3D visualization,

fig = Figure(resolution=(800, 600))
ax = Axis3(fig[1, 1], xlabel="x (m)", ylabel="y (m)", zlabel="z (m)")

# and a `Slider` to control the time index,

slider = Slider(fig[2, 1], range=1:Nt, startvalue=1)
n = slider.value

# Now we're ready to load data and create `Observable`s,

et = FieldTimeSeries("convection.jld2", "e")
Nt = length(et.times)
Nx, Ny, Nz = size(grid)

eⁿ_east   = @lift interior(et[$n],  1,  :,  :)
eⁿ_west   = @lift interior(et[$n], Nx,  :,  :)
eⁿ_south  = @lift interior(et[$n],  :,  1,  :)
eⁿ_north  = @lift interior(et[$n],  :, Ny,  :)
eⁿ_top    = @lift interior(et[$n],  :,  :,  1)
eⁿ_bottom = @lift interior(et[$n],  :,  :, Nz)

eⁿ = (east  = eⁿ_east,  west   = eⁿ_west,
      south = eⁿ_south, north  = eⁿ_north,
      top   = eⁿ_top,   bottom = eⁿ_bottom)

# and plot everything
      
for side in sides
    x = getproperty(xcube, side)
    y = getproperty(ycube, side)
    z = getproperty(zcube, side)
    pl = surface!(ax, x, y, z, color=eⁿ[side])
end

display(fig)

# We can then either play with the `Slider`, or compile the frames into
# an animation,

record(fig, "free_convection.mp4", 1:Nt, framerate=24) do nn
    n[] = nn
end

