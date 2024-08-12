library(Rvcg)
library(dplyr)
library(purrr)
library(plotly)
source("jointmesh.R")

data = read_ply("data/TN/TNNavicularBoneSurfaces/L230959LTNNavicularBone.ply")
fitted_model = fit_data(data)
# fitted_model

plt = visualize_data(fitted_model)
# plt

fitted_data_batch = fit_data_batch(file_dir = "data/TN/TNNavicularBoneSurfaces/")
# fitted_data_batch