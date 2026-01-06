import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

mpl.use("pgf")
mpl.rcParams.update(
    {
        "text.usetex": True,
        "pgf.texsystem": "pdflatex",
        "font.family": "serif",
        "pgf.rcfonts": False,
    }
)
plt.rcParams["axes.linewidth"] = 0.8
plt.rcParams["grid.linewidth"] = 0.5
plt.rcParams["grid.alpha"] = 0.3

df = pd.read_csv("data/processed/download_time.csv")

# get unique values
radii = sorted(df["radius_km"].unique())
tile_sizes = sorted(df["tile_size_mb"].unique())

# prepare data for stacked bars
x = np.arange(len(radii))
bar_width = 0.2

# create figure
fig, ax = plt.subplots(figsize=(10, 5))
fig.patch.set_alpha(0)
ax.patch.set_alpha(0)

# colors for different tile sizes
colors = ["#d9d9d9", "#b0b0b0", "#808080", "#4d4d4d"]

# stack bars
bottom = np.zeros(len(radii))
for i, tile_size in enumerate(tile_sizes):
    times = [
        df[(df["radius_km"] == r) & (df["tile_size_mb"] == tile_size)]["time"].values[0]
        / 60
        for r in radii
    ]
    ax.bar(
        x + i * bar_width,
        times,
        bar_width,
        label=f"{tile_size} MB",
        color=colors[i],
        edgecolor="black",
        linewidth=0.8,
    )
    bottom += times

# labels and styling
ax.set_xlabel("Radius [km]", fontsize=11, color="#606060")
ax.set_ylabel("Time [min]", fontsize=11, color="#606060")

# x-axis
ax.set_xticks(x + 0.3)
ax.set_xticklabels([int(r) for r in radii])

# grid
ax.grid(True, alpha=0.25, linewidth=0.5, color="gray", axis="y", linestyle=":")
ax.set_axisbelow(True)

# legend
ax.legend(frameon=False, fontsize=10, loc="upper left")

# spines
for spine in ax.spines.values():
    spine.set_linewidth(0.8)
    spine.set_color("#888888")

# ticks
ax.tick_params(width=0.8, color="#888888", labelsize=10)

plt.tight_layout()

plt.savefig("data/plots/download_time_stacked.pgf", transparent=True)
