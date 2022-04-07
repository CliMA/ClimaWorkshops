# Intro to 2D and 3D plotting in Makie

This is an introduction to

* Basic `GLMakie.jl` syntax: `Figure`, `Axis`, layouts, `heatmap`, `contour`, `lines`, `scatter`
* `Observable`, `Slider`, and record for animating data
* `Axis3` and `surface` for 3D plotting

## Material

This tutorial consists of three scripts / notebooks:

* `super_basic_intro.jl` / `super_basic_intro.ipynb`
    - `Figure`, `Axis`, `heatmap`, and `Slider` for interactivity
* `barotropic_turbulence.jl` / `barotropic_turbulence.ipynb`
    - Animating two-dimensional data on the fly and in post-processing
* `free_convection.jl` / `free_convection.ipynb`
    - Animating three-dimensional data with `Axis3` and `surface`

## External resources

* [`Makie.jl` documentation](https://makie.juliaplots.org/stable/)

Run the tutorials with

```bash
$ julia --project
```

and then

```julia
julia> include("barotropic_turbulence.jl")
```

for example.
