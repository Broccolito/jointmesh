# JointMesh

**JointMesh** is an R Shiny application designed for visualizing and analyzing joint surfaces. The application allows users to upload 3D mesh files, perform various analyses, and visualize the results in an interactive web interface.

## Features

- **3D Mesh Visualization**: Load and visualize 3D mesh files of joint structures.
- **Statistical Analysis**: Perform various statistical analyses on the joint mesh data.
- **Interactive Plots**: Use interactive plots powered by `plotly` for in-depth exploration of data.
- **Export Functionality**: Export analysis results and visualizations for further use.

## Installation

### Prerequisites

Ensure that you have R installed on your system. You can download it from [CRAN](https://cran.r-project.org/).

### Install Required Packages

The application relies on several R packages. To install all the required packages, run the following script provided in `setup.R`:

```r
# Install required packages
source("setup.R")
```

This script installs all the necessary R packages required to run the JointMesh application, such as `shiny`, `plotly`, `rgl`, and `DT`. It is also fine if you skip this step, but the packages will be installed the first time the application is launched.

### Clone the Repository

To get started, clone the repository from GitHub:

```bash
git clone https://github.com/Broccolito/jointmesh.git
cd jointmesh
```

### Running the Application

After cloning the repository and installing the required packages, you can run the application using the following command in R:

```r
# Set the working directory to the location of app.R
setwd("path/to/jointmesh")

# Run the Shiny application
shiny::runApp("app.R")
```

This will start the Shiny app, which can be accessed through your web browser at the default address `http://127.0.0.1:xxxx` (port number varies).

## Usage

### Uploading Mesh Files

1. **Select a Directory**: Users can select the directory containing the mesh files. The application will automatically list the `.ply` files available.
2. **View Mesh**: The selected mesh will be displayed in an interactive 3D viewer.

### Performing Analysis

1. **Statistical Analysis**: Once a mesh is loaded, users can perform various statistical tests (e.g., Chi-square test) to analyze the mesh data.
2. **Export Results**: The results of the analysis can be exported as a CSV file using the "Export as CSV" button available in the DataTable view.

### Visualization

- **3D Plots**: The application provides options to visualize the original and predicted meshes, overlaying them to compare and contrast different features.
- **Customization**: Users can customize the appearance of the 3D plots, such as changing the number of rows displayed or switching between scientific notation.

### Example Workflow

1. Start the Shiny app using the instructions above.
2. Select a directory containing your 3D mesh files.
3. Load a mesh file and visualize it in the 3D viewer.
4. Perform any required statistical analysis on the mesh data.
5. Export the results for further analysis or publication.

## File Structure

- `app.R`: The main Shiny application file. Contains the UI and server logic.
- `jointmesh.R`: Contains core functions and analysis methods used by the Shiny app.
- `setup.R`: Script to install all required packages.

## License

JointMesh is licensed under the MIT License. See `LICENSE` for more information.

## Contact

For questions or issues, please open an issue on GitHub or contact the maintainer at wanjun.gu@ucsf.edu

