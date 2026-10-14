make_blockmodel_figure <- function() {
  palette <- c(
    "#84994F",
    "#FFE797",
    "#FCB53B",
    "#A72703"
  )

  k <- 4

  B <- matrix(0.075, k, k)
  diag(B) <- 0.8

  set.seed(26)

  theta <- runif(100, min = 1, max = 2)

  model <- dcsbm(
    theta = theta,
    B = B,
    expected_density = 0.15,
    sort_nodes = TRUE,
    poisson_edges = FALSE,
    allow_self_loops = FALSE
  )

  tbl_graph <- sample_tidygraph(model) |>
    mutate(
      block = model$z,
      block_int = as.integer(block),
      fill = palette[block_int],
      popularity = centrality_degree()
    ) |>
    filter(popularity > 2)

  ggraph(tbl_graph, layout = 'fr') +
    geom_edge_link2(
      aes(colour = node.fill),
      alpha = 0.4
    ) +
    geom_node_point(
      aes(size = popularity, color = fill)
    ) +
    geom_node_point(
      aes(size = popularity),
      stroke = 1,
      shape = 21,
      color = "white"
    ) +
    scale_edge_color_identity(guide = "none") +
    scale_color_identity(guide = "none") +
    theme_void() +
    theme(
      legend.position = "none"
    )

  blockmodel_path <- here("figures", "blockmodel.png")

  ggsave(
    blockmodel_path,
    height = 5,
    width = 5,
    dpi = 500,
    create.dir = TRUE
  )

  blockmodel_path
}
