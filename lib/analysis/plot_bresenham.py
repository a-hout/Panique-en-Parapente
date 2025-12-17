import matplotlib as mpl
import matplotlib.patches as patches
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

mpl.use("pgf")
# style for latex plots
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

df = pd.read_csv("data/processed/bresenham_path_chaumont_hearc.csv")

# create tiles list
tiles = set(zip(df["x"].astype(int), df[" y"].astype(int)))

# create figure
fig, ax = plt.subplots(figsize=(8, 7))

# draw tiles
tile_size = 0.85
offset = tile_size / 2  # center offset, otherwise it will draw towards top-left

for x, y in tiles:
    if (
        (x - 1, y - 1) in tiles
        and (x, y - 1) in tiles
        and (x - 1, y) in tiles
        and (x + 1, y) in tiles
        and (x, y + 1) in tiles
        and (x - 1, y + 1) in tiles
        and (x + 1, y - 1) in tiles
        and (x + 1, y + 1) in tiles
    ):
        rect = patches.Rectangle(
            (x - offset, y - offset),
            tile_size,
            tile_size,
            linewidth=1.5,
            edgecolor="red",
            facecolor="red",
            alpha=0.3,
        )
        ax.add_patch(rect)

        # inner grid pattern (5x5 dots )
        dot_spacing = tile_size / 6
        for i in range(1, 6):
            for j in range(1, 6):
                ax.plot(
                    x - offset + i * dot_spacing,
                    y - offset + j * dot_spacing,
                    "ko",
                    markersize=1.0,
                    alpha=0.7,
                )
    else:
        # outer rectangle (border), whic is centered on (x, y)
        rect = patches.Rectangle(
            (x - offset, y - offset),
            tile_size,
            tile_size,
            linewidth=1.5,
            edgecolor="black",
            facecolor="black",
            alpha=0.3,
        )
        ax.add_patch(rect)

        # inner grid pattern (5x5 dots )
        dot_spacing = tile_size / 6
        for i in range(1, 6):
            for j in range(1, 6):
                ax.plot(
                    x - offset + i * dot_spacing,
                    y - offset + j * dot_spacing,
                    "ko",
                    markersize=1.0,
                    alpha=0.7,
                )

# set axis properties
ax.set_xlabel("Easting grid [LV95]", fontsize=12)
ax.set_ylabel("Northing grid [LV95]", fontsize=12)

# grid
ax.grid(True, alpha=0.3, linewidth=0.5, color="gray")
ax.set_axisbelow(True)

# set limits with some padding
x_coords = [t[0] for t in tiles]
y_coords = [t[1] for t in tiles]
x_min, x_max = min(x_coords) - 1, max(x_coords) + 1
y_min, y_max = min(y_coords) - 1, max(y_coords) + 1

ax.set_xlim(x_min, x_max)
ax.set_ylim(y_min, y_max)

ax.set_yticks(range(int(y_min), int(y_max) + 1))

# equal aspect ratio
ax.set_aspect("equal")

# spin styling
for spine in ax.spines.values():
    spine.set_linewidth(0.8)
    spine.set_color("#404040")

# tick parameters
ax.tick_params(width=0.8, color="#404040")

plt.tight_layout()

# save for latex
plt.savefig("data/plots/bresenham_tiles.pgf", transparent=True)
