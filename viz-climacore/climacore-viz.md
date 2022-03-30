# Basic visualizations in ClimaCore.jl

## 1. Setting up a reproducible environment

As, we have done in the [Best practices and workflow for computational scientists in CliMA](intro-best-practices/best-practices.md) workshop, we will start a reproducible environment.

> #### Exercise 1.1
> If you haven't done this already, `git clone` the [ClimaWorkshops](https://github.com/CliMA/ClimaWorkshops) repo, create a working branch for this workshop, and move to the `viz-climacore` directory.

> #### Exercise 1.2
> Start Julia and instantiate the project in the current working directory, `viz-climacore`.
> Add and commit both `Project.toml` and `Manifest.toml` files to the repository.

## 2. Julia Plots visualizations with `ClimaCorePlots`

`ClimaCorePlots` extends many functionalities of the Julia [Plots.jl](https://docs.juliaplots.org/stable/) package. Check its documentation to know how to define plot properties, attributes and embellishments.

Start Julia and open the [climacore-plots notebook](climacore-plots.ipynb) notebook in the current working directory

> #### Exercise 2.1
> julia> using IJulia

> julia> notebook()

## 3. `ClimaCoreMakie`

Here we are going to give an introduction on some basic support for [Makie.jl](https://makie.juliaplots.org/stable/) plotting available in ClimaCore.jl at the moment. A Makie.jl specific workshop is upcoming.
> #### Exercise 3.1
> Open the [climacore-makie](climacore-makie.ipynb) notebook in the current working directory.

## 4. `ClimaCoreVTK`

`ClimaCoreVTK` allows to produce output files that can be loaded in [Paraview](https://www.paraview.org/) or [VisIt](https://visit-dav.github.io/visit-website/index.html). For this workshop, we will use Paraview.

- To output ODE solve compatible fields (i.e., collect `sol` fields in a Field array), we will use examples from the suite of examples available in ClimaCore.jl.

    * The function we use to print `.vtu` and `.pvd` output files is `writepvd`. The `.vtu` file format is an XML-based file format, which is used for unstructured meshes.

> #### Exercise 4.1
> Run the [shallow_water.jl](shallow_water.jl) example with the `barotropic_instability` test case argument (either as a command line argument or from the Julia REPL).

> #### Exercise 4.2
> Open the output files in Paraview

> #### Exercise 4.3
> Use again the `writepvd` function from the example, but this time specify the output `basis` as `:lagrange` and notice the difference in the output, when reloaded in Paraview.

- For time series data (vtu/pvd files):

    * A ParaView Data (PVD) `.pvd` File Format ParaView’s native data file format (PVD) supports any type of data set that can be loaded or created in ParaView (polygonal, uniform rectilinear, nonuniform rectilinear, curvilinear, or unstructured), including spatially partitioned, multi-block, and time series data. This file format is XML-based.

- To view a navigation/scroll bar for the time series: View > Animation View

- To view a high-order visualization mesh, in the `Properties` pane: `Miscellaneous` > `Nonlinear Subdivision Level` (can search in Properties search bar).

### 4.1 Vector fields

- Filters > Common > Glyph (usually referred to as a "quiver plot" in other packages).

### 4.2 Basic calculations

- Filters > Common > Calculator:

> #### Exercise 4.3
> 4.3.1) Load the shallow-water barotropic instability scalar field output (e.g., load vorticity output and compute `ω`^2)
> 4.3.2) Load any shallow-water test case velocity vector field output (e.g., load velocity, inspect the components and magnitude and compute `vel_X * iHat + vel_Y * jHat + vel_Z * k_Hat`)

### 4.3 Stream tracers

- To be able to follow particle/point data trajectories, we can use: Filters > Common > StreamTracers (needs to set up a seed from which the trajectories are traced).

### 4.5 Hybrid 3D sphere
For an example of an extruded 3D sphere, run the [`deformation_flow.jl`](deformation_flow.jl) file and load the output in Paraview.

### 4.6 Hybrid 3D Cartesian domain
For an example of an hybrid 3D Cartesian domain, run the [`bubble_3d_invariant_rhotheta.jl`](bubble_3d_invariant_rhotheta.jl) file and load the output in Paraview.

> #### Exercise 4.4
> Slice the domain and inspect the field.
### 4.6 Scripting

It is possible to do [Python scripting](https://www.paraview.org/Wiki/ParaView/Python_Scripting) directly in Paraview.

### 4.7 Connecting to remote hosts

File > Connect > Fetch Servers



