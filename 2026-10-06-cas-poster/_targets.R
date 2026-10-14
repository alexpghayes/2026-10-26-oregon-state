library(targets)
library(crew)

tar_option_set(
  controller = crew_controller_local(workers = 2),
  packages = c(
    "broom",
    "car",
    "dplyr",
    "fastadi",
    "fastRG",
    "forcats",
    "ggplot2",
    "ggraph",
    "glue",
    "here",
    "ids",
    "igraph",
    "irlba",
    "ivreg",
    "Matrix",
    "purrr",
    "readr",
    "rlang",
    "scales",
    "stringr",
    "tibble",
    "tidyr",
    "tidygraph"
  )
)

tar_source()

list(
  tar_target(
    concentration_figure,
    make_concentration_figure(),
    format = "file"
  ),

  tar_target(
    blockmodel_figure,
    make_blockmodel_figure(),
    format = "file"
  ),

  tar_target(
    anxiety_edge_path,
    here("data", "li2023", "edgelist.csv"),
    format = "file"
  ),

  tar_target(
    anxiety_node_path,
    here("data", "li2023", "node_data.csv"),
    format = "file"
  ),

  tar_target(
    anxiety_graph,
    construct_anxiety_graph(anxiety_node_path, anxiety_edge_path)
  ),

  tar_target(
    anxiety_estimates,
    get_anxiety_estimates(anxiety_graph)
  ),

  tar_target(
    anxiety_figures,
    plot_anxiety_estimates(anxiety_estimates),
    format = "file"
  )
)
