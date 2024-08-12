read_ply = function(file_path, filename = "0.ply"){
  ply_data = vcgPlyRead(file_path)
  data = as.data.frame(t(ply_data$vb[1:3,]))
  names(data) = c("x", "y", "z")
  filename = basename(gsub(pattern = ".ply", replacement = "", filename))
  data = list(filename = filename,
              data = data)
  return(data)
}

normalize = function(v){
  qmin = quantile(v, 0.05, na.rm = TRUE)
  qmax = quantile(v, 0.95, na.rm = TRUE)
  v_normalized = (v - qmin) / (qmax - qmin)
  v_normalized = v_normalized + 1
  return(v_normalized)
}

align = function(data, normalize = TRUE){
  
  min_x_point = data %>% filter(x == min(x))
  max_x_point = data %>% filter(x == max(x))
  
  delta_z = max_x_point$z - min_x_point$z
  delta_x = max_x_point$x - min_x_point$x
  theta = atan(delta_z / delta_x)
  
  rotation_matrix_y = matrix(c(cos(theta), 0, sin(theta),
                               0, 1, 0,
                               -sin(theta), 0, cos(theta)), 
                             nrow = 3, byrow = TRUE)
  
  coords = as.matrix(data[, c("x", "y", "z")])
  rotated_coords = coords %*% t(rotation_matrix_y)
  
  data$x = rotated_coords[, 1]
  data$y = rotated_coords[, 2]
  data$z = rotated_coords[, 3]
  
  if(normalize){
    data = data %>%
      mutate(x = normalize(x)) %>%
      mutate(y = normalize(y)) %>%
      mutate(z = normalize(z))
  }
  
  return(data)
}

fit_data = function(data){
  filename = data$filename
  data = data$data
  data = align(data, normalize = TRUE)
  
  model = lm(data = data, 
             formula = z ~ poly(x,4) + poly(y, 4) +
               I(x*y) + I(sqrt(x + y)) + 
               I(sqrt(x^2 + y^2))
  )
  
  data[["predicted_z"]] = predict(model, select(data, x, y))
  
  model_summary = summary(model)
  r2 = model_summary$adj.r.squared
  coef_matrix = data.frame(
    coef_name = c("intercept", 
                  "x1", "x2", "x3", "x4",
                  "y1", "y2", "y3", "y4",
                  "xy", "sqrt_xny", "sqrt_x2ny2"
    ),
    coef = model_summary$coefficients[,1],
    se = model_summary$coefficients[,2],
    p_value = model_summary$coefficients[,4]
  )
  rownames(coef_matrix) = NULL
  
  return(list(
    filename = filename,
    coefficients = coef_matrix,
    rsq = r2,
    fitted_data = data
  ))
  
}

fit_data_batch = function(file_dir){
  files = list.files(path = file_dir, pattern = ".ply")
  filenames = gsub(pattern = ".ply", replacement = "", files)
  files = as.list(file.path(file_dir, files))
  
  fitted_data_batch = map(files, function(x){
    data = read_ply(x)
    fitted_model = fit_data(data)
    coefs = as.data.frame(t(c(fitted_model$rsq, fitted_model$coefficients$coef)))
    names(coefs) = c("rsq", fitted_model$coefficients$coef_name)
    return(coefs)
  }) %>%
    reduce(rbind.data.frame)
  
  fitted_data_batch = fitted_data_batch %>%
    mutate(filename = filenames) %>%
    select(filename, everything())
  
  return(fitted_data_batch)
}

visualize_data = function(fitted_model){
  fitted_data = fitted_model$fitted_data
  figure_title = paste(fitted_model$filename, "Fitted to JointMesh")
  plt = plot_ly() %>%
    add_trace(
      x = fitted_data$x, 
      y = fitted_data$y, 
      z = fitted_data$z, 
      type = "mesh3d", 
      name = "Original Mesh",
      opacity = 0.5,
      color = I("blue"),
      showlegend = TRUE
    ) %>%
    add_trace(
      x = fitted_data$x, 
      y = fitted_data$y, 
      z = fitted_data$predicted_z, 
      type = "mesh3d", 
      name = "Fitted Mesh",
      opacity = 0.5,
      color = I("red"),
      showlegend = TRUE
    ) %>%
    layout(
      title = figure_title,
      scene = list(
        xaxis = list(title = "X"),
        yaxis = list(title = "Y"),
        zaxis = list(title = "Z")
      ),
      legend = list(title = list(text = ''))
    )
  
  return(plt)
}