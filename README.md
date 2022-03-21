# ClimaWorkshops
A repository that contains material for hands-on workshops and tutorials in CliMA.

Topics include:

1. Introduction to some software engineering and design principles, best practices (including git version control), engineering and computational scientist's workflow (parameters logging, experiments book-keeping, etc), with a focus on reproducible environments in Julia. The material for this workshop can be found in [`intro-best-practices`](intro-best-practices/best-practices.md).

2. Introduction to [ClimaCore.jl](https://github.com/CliMA/ClimaCore.jl)'s API objects (`Domain`, `Mesh`, `Topology`, `Space`, `Field`), points, vectors, their conversions, and use in `Operator`s. The material for this workshop can be found in [`intro-climacore`](intro-climacore/climacore-api.ipynb).

3. Introduction to some basic visualizations supported in [ClimaCore.jl](https://github.com/CliMA/ClimaCore.jl). This workshop builds up on some material from the [previous workshop](intro-climacore/climacore-api.ipynb) and show how we can achieve some basic visualizations in ClimaCore.jl. This is not intended to show production-type visualizations, but mainly to show how to visualize ClimaCore.jl `Field`s using packages such as [ClimaCorePlots](https://github.com/CliMA/ClimaCore.jl/tree/main/lib/ClimaCorePlots), [ClimaCoreVTK](https://github.com/CliMA/ClimaCore.jl/tree/main/lib/ClimaCoreVTK) and [ClimaCoreMakie](https://github.com/CliMA/ClimaCore.jl/tree/main/lib/ClimaCoreMakie).
