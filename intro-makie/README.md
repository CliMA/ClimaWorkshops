# Intro to 2D and 3D plotting in Makie

This is an introduction to

* Basic `GLMakie.jl` syntax: `Figure`, `Axis`, layouts, `heatmap`, `contour`, `lines`, `scatter`
* `Observable`, `Slider`, and `record` for animating data
* `Axis3` and `surface` for 3D plotting

## Material

This tutorial consists of three scripts / notebooks:

* `super_basic_intro.jl` / `super_basic_intro.ipynb` (`Figure`, `Axis`, `heatmap`, and `Slider` for interactivity)
* `barotropic_turbulence.jl` / `barotropic_turbulence.ipynb` (Animating two-dimensional data on the fly and in post-processing)
* `free_convection.jl` / `free_convection.ipynb` (Animating three-dimensional data with `Axis3` and `surface`)

The tutorials can be run as scripts by navigating to `/intro-makie/`,
writing `julia --project` in a terminal, and then

```julia
julia> include("super_basic_intro.jl")
```

for example. To run the notebooks through `Julia`, launch `julia --project` and then type

```julia
julia> using IJulia; notebook()
```

## External resources

* [`Makie.jl` documentation](https://makie.juliaplots.org/stable/)
    - [`Axis`](https://makie.juliaplots.org/stable/examples/layoutables/axis/)
    - [`Slider`](https://makie.juliaplots.org/stable/examples/layoutables/slider/)
    - [`Axis3`](https://makie.juliaplots.org/stable/examples/layoutables/axis3/)
