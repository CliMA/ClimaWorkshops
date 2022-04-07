# # Super basic intro to `Slider` and interactivity
#
# All we need for this tutorial besides

using Pkg; Pkg.activate("."); Pkg.instantiate()

# is

using GLMakie

# Next we'll generate a "series" of random data,

random_series = [rand(10, 10) for i = 1:10]

# Our objective is to create an interactive visualization for exploring
# `random_series`. So we create a figure with a `Slider`:

fig = Figure()
slider = Slider(fig[2, 1], range=1:length(random_series), startvalue=1)

# note that we've placed the `Slider` at `fig[2, 1]`, which is the
# second row and first column in the `Figure`'s layout.
# The slider has a "`value`",

n = slider.value

# which is something called an "`Observable`". An `Observable` wraps a value;
# in this case an `Integer`:

n.val

# The `Observable` can be updated by referencing it:

n[] = 2

# Next we create an `Axis` in which we'll plot the data

ax = Axis(fig[1, 1])

# Finally, we create another `Observable` which is linked to `n`.
# There are a few ways to do this and it can sometime require trial and error
# to get right. Here we use the macro `@lift`:

rn = @lift random_series[$n]

# and "interpolate" the `Observable` `n` into the expression by writing `$n`.
# This creates another `Observable` that "listens" to the value of `$n`. So

rn.val

# but

n[] = 1
rn.val

# changes the data. `Observable` can be passed to `Makie`'s plotting functions,

heatmap!(ax, rn)

# moving the slider updates the data!

fig

# # Exercises
#
# Completing these exercises might help reinforce the lessons of this tutorial:
#
# 1. Add axis labels (https://makie.juliaplots.org/stable/examples/layoutables/axis/)
# 2. Add a title that's updated by the slider Hint: create a title with `@lift`:
# 3. Add dynamically updating `colorrange` in `heatmap!`.
# 4. Change the aspect ratio of the plot
# 5. Add a colorbar
# 6. Add a title to the colorbar that update dynamically
#
# The "answers" to the exercises are provided in the updated script `even_better_super_basic_intro.jl`.

fig
