library(Rvcg)
library(dplyr)

read_ply = function(file_path){
  ply_data = vcgPlyRead(file_path)
  data = as.data.frame(t(ply_data$vb[1:3,]))
  names(data) = c("x", "y", "z")
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
                  "z1", "z2", "z3", "z4",
                  "xz", "sqrt_xnz", "sqrt_x2nz2"
    ),
    coef = model_summary$coefficients[,1],
    se = model_summary$coefficients[,2]
  )
  rownames(coef_matrix) = NULL
  
  return(list(
    coefficients = coef_matrix,
    rsq = r2,
    fitted_data = data
  ))
  
}

data = read_ply("data/TN/TNNavicularBoneSurfaces/L230959LTNNavicularBone.ply")
fit_data(data)
