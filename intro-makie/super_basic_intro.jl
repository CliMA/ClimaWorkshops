using GLMakie

randoms = [rand(10, 10) for i = 1:10]

fig = Figure()
slider = Slider(fig[2, 1], range=1:length(randoms), startvalue=1)
n = slider.value

ax = Axis(fig[1, 1], aspect=1)

rn = @lift randoms[$n]
heatmap!(ax, rn)
display(fig)

# Exercise:
#
# 1. Add axis labels (https://makie.juliaplots.org/stable/examples/layoutables/axis/)
# 2. Add a title that's updated by the slider Hint: create a title with `@lift`:
# 3. Add dynamically updating `colorrange` in `heatmap!`.
# 4. Change the aspect ratio of the plot
# 5. Add a colorbar
# 6. Add a title to the colorbar that update dynamically
#
# title = @lift string("Random ", $n) # like string("Random ", 1), string("Random ", 2)
# colorrange = @lift (0, 1 + 0.1 * $n)
# Colorbar(fig[1, 2], hm, label=title)
