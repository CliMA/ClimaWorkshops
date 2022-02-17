# Best practices and workflow for computational scientists in CliMA

### What is reproducibile code?

> "But it works on my machine!"

Code is reproducible if someone is able to easily re-run it and get the same results.

Why might code not be reproducible:
- software or packages are not installed
- software uses different versions
- different configurations (environment variables, optimization flags)
- differences between platforms: operating systems (Windows, Linux, MacOS), architecture (x86, ARM, GPUs)

Some of these are unavoidable (e.g. going from working locally on a Mac to the Linux cluster), but we can do our best to minimize these
- we're not aiming for "bit-for-bit" reproducibility

### How can we make our code reproducible?

We need to supply both the code, and the "environment" used to run the code, and we need to keep track of it as we run experiments.


## 1. Keeping track with `git`

But first, let us give an overview of what is `git` and the best practices when using it.

* [Introduction to version control with `git`](intro-to-git.md)

> ### Exercise 1.1
> Create a new directory and initialize a git repository

## 2. Specifying environments

### Julia Pkg.jl

The Julia environment is tracked with two files:

- `Project.toml`: contains "user-editable" information:
    - dependencies you use directly (e.g. loaded by `using` or `import`)
    - dependency version constraints (optional)
    - package metadata (optional: only if the project is also a package)
- `Manifest.toml`: contains the "derived" information necessary to recreate the environment exactly
    - all the recursive dependencies (i.e. the dependencies, their dependencies, etc.)
    - the exact version used (version number / branch name + git sha hash)

**To be able to reproduce your code, you need to check in both files to git**

You can recreate this on another machine by doing:
```julia
using Pkg
Pkg.instantiate()
```
or at the REPL:
```
]instantiate
```
- if you have the Manifest.toml, this will create an environment with the exact versions used
- if you don't have the Manifest.toml, this will resolve it (see below)

> ### Exercise 2.1
> Copy the Project.toml from ClimaCore.jl/examples and instantiate it.
> Add and commit both Project.toml and Manifest.toml to the repository.

Specifying dependencies:
- `]add PackageName` / `Pkg.add("PackageName"`): this will add the most recent registered version
- `]add PackageName @version` / `Pkg.add(name="PackageName", version="version")`: use a specific version
- `]add PackageName #branchname` / `Pkg.add(name="PackageName", rev="branchname")`: this will use the current version on a specific branch (or commit sha1)
- `]dev localpath` / `Pkg.develop(path="localpath")`: use the version of a package at a specific path
- `]dev PackageName` / `Pkg.develop("PackageName")`
  - check out the most recent version to `~/.julia/dev/PackageName` (only if it doesn't already exist)
  - use this version of the package

Other useful Pkg operations:
- `]resolve` / `Pkg.resolve()`: creates or updates the Manifest if it isn't in sync with the Project.toml or its dependencies
  - e.g. if you've `dev`-ed ClimaCore.jl, and you added a new dependency, say NetCDF.jl, to ClimaCore.jl, then you need to go back to your experiment project and `resolve` it so that  the top project adds NetCDF.jl to the Manifest.toml
  - this is called by `instantiate` if no Manifest.toml exists.
- `]up` / `Pkg.update()`: update dependencies to their latest versions (subject to compatiblity contraints)
  - This will modify the Manifest.toml


> ### Exercise 2.2
> Try using different ways to specify a dependency (e.g. `ClimaCore`), and look at how the Project.toml and Manifest.toml changes (e.g. use `git diff`)
> - What happens when you update (`]up`/`Pkg.update()`)?
> - Which of these are reproducible?


## Python

Analog reproducible environments in Python can be obtained via [Conda](https://docs.conda.io/projects/conda/en/latest/index.html). For example
```
conda env export > environment.yml
```
will give you an exact snapshot of the packages installed, which can be stored in version control. It can be reproduced with
```
conda env create -f environment.yml
```

Unlike Julia, Conda environments are _not_ reproducible across platforms (e.g. MacOS => Linux). And they can also export only the direct dependencies:
```
conda env --from-history export > environment.yml
```
but it may resolve differently. See [Conda: manage environments: sharing an environment](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#sharing-an-environment) for more information.

[pipenv](https://pipenv.pypa.io) (another Python environment manager) has `pipfile` and `pipfile.lock`: roughly analogous to `Project.toml` and `Manifest.toml`, but again the `pipfile.lock` is tied to a specific platform.

## Containers

![](https://i.imgur.com/3eTKEZp.jpg)

Containers are another way to create an isolated environment that can be easily shared. These include:
- Docker: widely used, but not supported on Caltech's cluster
- Singularity (now Apptainer): supported on HPC systems.


# 3. Creating an experiment

> ### Exercise 3.1
> Copy `ClimaCore.jl/examples/sphere/solidbody.jl` into your local directory.
> Run it

Now there are some extra files.

We usually don't want to store the output in the repository, so we can tell git to ignore them. There are a couple of ways we can specify this:

- `.gitignore`: this is specific to this repository, and is checked into the repository
  - output or temporary files that are specific to this experiment
- `~/.config/git/ignore`: this is specific to your machine
  - temporary files used by editors (emacs, vim)
  - `.DS_Store` files on Mac
- `.git/info/exclude`: specific to this repository _and_ your machine (not checked into git)
    - occasionally useful

Files are specified according to patterns, e.g.
```
*.nc # ignore all files with a .nc extension
!test.nc # except test.nc
```
See [Git manual: gitignore](https://git-scm.com/docs/gitignore) for more information

> ### Exercise 3.2
> Set up your `.gitignore` (and `~/.config/git/ignore` if necessary)

# 4. Move to the cluster

## 4.1. Create a new repository on github

- Go to github.com, and click + in the top right hand corner
- follow instructions to connect and push your current repository

## 4.2 SSH to cluster

- ssh to cluster
- clone repository to cluster

For a nice integration of SSH with VSCode, one can use the `VSCode Remote - SSH` extension that allows you to connect to a host such as Caltech's cluster (landing on the login node) and edit files remotely.

> #### Note:
> Do NOT compile or run code directly on the login node. If you want to compile and run quick experiments for debugging purposes, you can request interactive nodes by running
```bash
srun --pty -t hh:mm:ss -n tasks -N nodes /bin/bash -l
```

# 5. Running your job on the cluster

First we need to load Julia. For this we use the cluster module system:
```
module load julia/1.7.1
```
This modifies a some environment variables so that calling `julia` will use the specific instance of Julia installed on the cluster.

Other useful commands:
- `module list` see what modules are loaded
- `module unload XXX` remove a module
- `module purge` remove all modules
- `module show XXX`: see what loading a module will do
- `module avail`: list all available modules

> ### Exercise 5.1
> What modules do you currently have loaded?
> What happens if you try to load multiple julia versions?
> Load `julia/1.7.1` and instantiate your project.


We're currently on the login node: we don't want to run our job here! We need to schedule it to run on a worker node.

The Caltech HPC cluster uses the Slurm scheduler. Create a file called `run.sh`
```
#!/bin/bash

#SBATCH --time=00:10:00

julia --project XXX.jl
```

Now call
```
sbatch run.sh
```

> #### Highlight

> Our very own Simon Byrne and Haako Ludvig came up with a nice [VSCode integration](https://gist.github.com/haakon-e/e444972b99a5cd885ef6b29c86cb388e) for which the VSCode backend (and all plugins you might have installed) run directly on a dedicated compute node on Caltech's cluster so that people are refrained from using the login node for heavy project compilations or runs. This setup was also endorsed by Caltech, om their [HPC facility documentation](https://www.hpc.caltech.edu/documentation/software-and-modules/vscode).

Now we are ready to submit a job to the scheduler.


A sbatch script is an ordinary shell script, with some optional `#SBATCH`: this is just an alternative way to specify command line options to `sbatch`: see the [`sbatch` man page](https://slurm.schedmd.com/sbatch.html).


Some useful ones:
- `--reservation=clima`: this will use the CliMA reserved node (okay for short or interactive work, please don't abuse it for long-running jobs)
- `--gres=gpu:1`: request a GPU
- `--dependency`: for setting job dependencies (i.e. a job that shouldn't start until another job is finished)
- `--ntasks` / `-n`: number of tasks (MPI ranks)
- `--nodes` / `-N`: how many nodes to spread the tasks over.
- `--cpus-per-task` / `-c`: how many cores per task (useful for using multithreading)
- `--mem` / `--mem-per-cpu`: memory per node or cpu core

Note that `sbatch` scripts will inherit the environment variables you ran it with (so any loaded modules will be available).


> ### Exercise 5.2
> Run your job using `sbatch`

We can check its status:
```
squeue --me
```
(if it's empty, the job has finished)

If you want to keep refreshing, you can use `watch`
```
watch squeue --me
```

To cancel a job
```
scancel jobid
```

You can see any output at `slurm-jobid.out`.


Some useful tips:
- If you want to be pedantic, you can add `git diff --exit-code HEAD`. This will return an error if there are any uncommitted changes to your repository.
- `git log --pretty=oneline -n 1` will print the most recent commmit.


> ### Exercise 5.3
> Is this sbatch script reproducible?
> What modifications should be made so that someone else in the group could run it?
> What information is useful to log to the output?

# 6. Optional arguments and array jobs

There are a couple of ways to pass options to Julia scripts

- command line arguments
  - accessible in Julia via the `ARGS` object (a vector of strings)
  - only available when running scripts
  - [ArgParse.jl](https://carlobaldassi.github.io/ArgParse.jl/stable/) can be used for parsing options

 - environment variables
   - accessible in Julia via the `ENV` object (a dictionary-like object)
   - a single system-wide namespace: need to ensure names don't conflict with other programs

 - configuration file
   - this will be used by the new ClimaParameters.jl

> ### Exercise 6.1
> Add command line arguments to your script to specify a value for some option value, e.g.:
> - number of elements
> - number of quadrature points
> - dt

We can schedule multiple jobs to run this on the cluster. The easiest/best way to do this is via array jobs: these are specified via `--array=<indices>` option: `<indices>` can either be a range (e.g. `1-5`) or comma-separated list (`0,3,5`) of integers.

This will schedule a job for each element of the range, and the index of the job is accessible via the `SLURM_ARRAY_TASK_ID` environment variable.

Note that indices have to be integers: you can get other values by making use of bash arrays (note that bash arrays are 0-indexed)
```
#!/bin/bash

#SBATCH --time=00:10:00
#SBATCH --array=0-4

values=(
    "this"
    "creates"
    "a"
    "bash"
    "array"
)

echo ${values[SLURM_ARRAY_TASK_ID]}
```
> ### Exercise 6.2
> Do a sweep over different values of the parameter you added using a Slurm array.
> Note that you may need to adjust how you handle output to avoid it being overwritten.

# 7. Discussion

- What are some good ideas for managing output of experiments? One way to avoid output being overwirtten is to concatenate parameters as strings in the output folder name so that each experiment will create a unique output folder, and this should facilitate experiments book-keeping.
- What information should be logged?
    - `git log --pretty=oneline -n 1` will print the current commit
    - `julia --project -e 'using Pkg; Pkg.status(mode=PKGMODE_MANIFEST)'` will print all the packages and versions
- What would help improve the workflow?
    - `git diff --exit-code HEAD` will exit with an error if there are any uncommitted changes to the repository
- What would make it easier to share?
    - `README.md` file?

