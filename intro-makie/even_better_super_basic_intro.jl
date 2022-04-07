using GLMakie

random_series = [rand(10, 10) for i = 1:10]

fig = Figure()
slider = Slider(fig[2, 1], range=1:length(random_series), startvalue=1)
n = slider.value

title = @lift string("Random data with index ", $n)
ax = Axis(fig[1, 1]; xlabel="x", ylabel="x", aspect=1, title)

rn = @lift random_series[$n]
colorrange = @lift (0, 1 + 0.1 * $n)
hm = heatmap!(ax, rn; colorrange)

label = @lift string("Random data number ", $n) # like string("Random ", 1), string("Random ", 2)
Colorbar(fig[1, 2], hm; label)

fig
