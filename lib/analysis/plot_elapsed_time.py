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

df = pd.read_csv("data/processed/algo_time_0.csv")

# group data by distance
distances = sorted(df["distance"].unique())
grouped_data = [df[df["distance"] == d]["elapsed_ms"].values for d in distances]

# Create figure
fig, ax = plt.subplots(figsize=(10, 5))

# boxplot
positions = [1, 5, 10, 25]
bp = ax.boxplot(
    grouped_data,
    positions=positions,
    widths=3,
    patch_artist=True,
    showmeans=True,
    meanprops=dict(
        marker="o",
        markerfacecolor="white",
        markeredgecolor="black",
        markersize=5,
        linewidth=0.8,
    ),
    boxprops=dict(facecolor="white", edgecolor="black", linewidth=1),
    whiskerprops=dict(color="black", linewidth=1),
    capprops=dict(color="black", linewidth=1),
    medianprops=dict(color="black", linewidth=1.2),
    flierprops=dict(
        marker="o",
        markerfacecolor="white",
        markeredgecolor="black",
        markersize=4,
        linewidth=0.8,
    ),
)

# line that connects to means of each distance sequentially
means = [np.mean(data) for data in grouped_data]
ax.plot(positions, means, "k-", linewidth=1, zorder=0)

ax.set_xlabel("Distances [km]", fontsize=11, color="#606060")
ax.set_ylabel("Time [ms]", fontsize=11, color="#606060")

# grid lines
ax.grid(True, alpha=0.4, linewidth=0.5, color="gray", axis="y", linestyle=":")
ax.set_axisbelow(True)

# use actual distances for x ticks
ax.set_xticks(positions)
ax.set_xticklabels(distances)
ax.set_xlim(-1, 30)  # More breathing room on left, extend right

# y axis setting
y_max = max([max(data) for data in grouped_data]) * 1.1
ax.set_ylim(0, y_max)

# spine styling - lighter gray
for spine in ax.spines.values():
    spine.set_linewidth(0.8)
    spine.set_color("#888888")

# tick parameters
ax.tick_params(width=0.8, color="#888888", labelsize=10)

plt.tight_layout()

# pgf
plt.savefig("data/plots/elapsed_time_boxplot.pgf", transparent=True)
