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
plt.rcParams["font.family"] = "serif"

# load the data
df = pd.read_csv("data/processed/tile_load_analysis.csv")

fig, ax1 = plt.subplots(figsize=(10, 5))
fig.patch.set_alpha(0)
ax1.patch.set_alpha(0)

x = np.arange(len(df["tile_count"]))
bar_width = 0.35

# plotting load time on left axis Y
bars1 = ax1.bar(
    x - bar_width / 2,
    df["load_time_ms"],
    bar_width,
    label="Load Time (ms)",
    color="#d9d9d9",
    edgecolor="black",
    linewidth=0.8,
)

# second Y-axis for Memory
ax2 = ax1.twinx()
bars2 = ax2.bar(
    x + bar_width / 2,
    df["memory_mb"],
    bar_width,
    label="Memory (MB)",
    color="#808080",
    edgecolor="black",
    linewidth=0.8,
)

ax1.set_xlabel("Number of Tiles", fontsize=11, color="#606060")
ax1.set_ylabel("Load Time [ms]", fontsize=11, color="#606060")
ax2.set_ylabel("Memory [MB]", fontsize=11, color="#606060")

ax1.set_xticks(x)
ax1.set_xticklabels(df["tile_count"])

ax1.grid(True, alpha=0.25, linewidth=0.5, color="gray", axis="y", linestyle=":")
ax1.set_axisbelow(True)

for ax in [ax1, ax2]:
    for spine in ax.spines.values():
        spine.set_linewidth(0.8)
        spine.set_color("#888888")
    ax.tick_params(width=0.8, color="#888888", labelsize=10)

lines1, labels1 = ax1.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax1.legend(
    lines1 + lines2, labels1 + labels2, frameon=False, fontsize=10, loc="upper left"
)

plt.tight_layout()

plt.savefig("data/plots/tile_load_analysis.pgf", transparent=True)
