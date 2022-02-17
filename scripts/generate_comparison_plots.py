import os
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.lines as mlines
import matplotlib as mpl
from matplotlib.ticker import AutoMinorLocator

# Define global parameters for further usage
data = pd.DataFrame(columns=["step", "value", "structure", "extraction", "encoding", "run"])
run_count = 1
lockwood = "Lockwood and Si."
skolik = "Skolik et al."
gs = "GS"
gsp = "GSP"
ls = "LS"
c_enc = "Continuous (C)"
sc_enc = "Scaled and Continuous (SC)"
sd_enc = "Scaled and Directional (SD)"
colors = {c_enc: "#D81B60",
          sc_enc: "#1E88E5",
          sd_enc: "#FFC107"
          }


def read_csv_data(file_path):
    """
    Get all files in the given path, check them for a ".csv" as file ending and use the function for adding them to the
    global data frame -> load all the data
    """

    [add_csv_data_to_data_frame(os.path.join(file_path, file)) for file in os.listdir(file_path) if ".csv" in file]


def add_csv_data_to_data_frame(file_path):
    """
    Get a csv data file and add the data to the global data frame with checking for some meta information.
    """

    global run_count
    global data

    plain_data = pd.read_csv(file_path)

    plain_data["step"] = plain_data["step"].mul(100)

    # Get the structure of the data.
    if "lockwood" in file_path:
        structure = lockwood
    else:
        structure = skolik

    plain_data["structure"] = structure

    # Get the extraction of the data.
    if ".gs." in file_path:
        extraction = gs
    elif ".ls." in file_path:
        extraction = ls
    else:
        extraction = gsp

    plain_data["extraction"] = extraction

    # Get the encoding of the data.
    if ".c_enc" in file_path:
        encoding = c_enc
    elif ".sc_enc" in file_path:
        encoding = sc_enc
    else:
        encoding = sd_enc

    plain_data["encoding"] = encoding

    # Get the current run count, incremented for every data file.
    plain_data["run"] = run_count
    run_count += 1

    # dataframe.append() is deprecated now, pandas.concat() is the recommended new method
    # add modified data to frame
    data = pd.concat([data, plain_data])


def plot_data():
    """
    Use the data frame and plot all the data in one figure with six different subplots: 2 different structures and 3
    different extraction methods.
    """

    figure, axes = plt.subplots(2, 3)
    # Count the rows and columns for adding the correct subplot at the right position.
    row_count = 0
    column_count = 0

    for structure in [lockwood, skolik]:
        for extraction in [gs, gsp, ls]:
            # Get the correct subplot.
            ax = axes[row_count][column_count]
            plot_data_for_structure_and_extraction(structure, extraction, ax)
            column_count += 1

            # Add the column title.
            if row_count == 0:
                ax.set_title(extraction, fontsize=14)

            # Add the row title.
            if column_count == 3:
                # Use the right side of the plot for the row title.
                ax_right = ax.twinx()
                ax_right.set_ylabel(structure, fontsize=14)

        row_count += 1
        column_count = 0

    # Prepare the legend for the different encoding values.
    legend_lines = []
    for color_value in colors.values():
        line = mlines.Line2D([], [], color=color_value)
        legend_lines.append(line)
    figure.legend(legend_lines, list(colors.keys()), loc="upper center", ncol=3, title="Encoding")

    figure.supxlabel("Steps")
    figure.supylabel("Validation Return")
    plt.show()


def plot_data_for_structure_and_extraction(structure, extraction, ax):
    """
    Plot the data for one given structure and extraction: The plot contains five different runs and a summary of those
    five runs per encoding.
    """

    # Filter for the given structure and extraction.
    structure_extraction_data = data.loc[(data["structure"] == structure) & (data["extraction"] == extraction)]
    # Calculate the mean of every run for all three encoding types.
    mean_data = pd.pivot_table(structure_extraction_data.reset_index(), index="step", columns=["encoding"],
                               values="value")

    for encoding in [c_enc, sc_enc, sd_enc]:
        # Plot the five runs.
        encoding_data = extract_encoding_data(structure_extraction_data, encoding)
        ax.plot(encoding_data, color=colors[encoding], alpha=0.1)

        if not mean_data.empty:
            ax.plot(mean_data[encoding], color=colors[encoding])

        # Modify the labels on the x-axis to K for thousands.
        ax.xaxis.set_major_formatter(mpl.ticker.FuncFormatter(
            lambda step, position: "{:}K".format(int(round(step/1000)))))

        # Modify the grid: Gray background, white lines.
        ax.grid(which="major", color="#FFFFFF", linewidth=1.0)
        ax.grid(which="minor", color="#FFFFFF", linewidth=0.5)
        ax.minorticks_on()
        ax.xaxis.set_minor_locator(AutoMinorLocator(2))
        ax.yaxis.set_minor_locator(AutoMinorLocator(2))
        ax.set_facecolor("#EBEBEB")


def extract_encoding_data(extraction_data, encoding):
    """
    Extract the data for one specific encoding type and prepare it for further processing.
    """

    encoding_data = extraction_data.loc[(extraction_data["encoding"] == encoding)]
    encoding_data = pd.pivot_table(encoding_data.reset_index(), index="step", columns=["run"], values="value")
    return encoding_data


if __name__ == '__main__':
    read_csv_data("../data")
    plot_data()
