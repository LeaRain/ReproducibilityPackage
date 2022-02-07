import os
import pandas as pd
import matplotlib.pyplot as plt

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
    files = os.listdir(file_path)

    for file in files:
        add_csv_data_to_data_frame(os.path.join(file_path, file))


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
    for structure in [lockwood, skolik]:
        for extraction in [gs, gsp, ls]:
            plot_data_for_structure_and_extraction(structure, extraction)


def plot_data_for_structure_and_extraction(structure, extraction):
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
        plt.plot(encoding_data, color=colors[encoding], alpha=0.1)
        if not mean_data.empty:
            plt.plot(mean_data[encoding], color=colors[encoding])

    plt.show()


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
