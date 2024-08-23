
setwd("C:/Users/INIA/OneDrive/02_INIA_2024/23_Base de datos/01_C.spruceanum/BTB.Arb.35/Arb.35/JPG")

library(pliman)
library(tidyverse)
library(patchwork)
library(openxlsx)  # Para exportar a Excel

# Directorios de entrada y salida
input_dir <- "C:/Users/INIA/OneDrive/02_INIA_2024/23_Base de datos/01_C.spruceanum/BTB.Arb.35/Arb.35/JPG"  # Cambia a la ruta de tus imágenes
output_dir <- "C:/Users/INIA/OneDrive/02_INIA_2024/23_Base de datos/01_C.spruceanum/BTB.Arb.35/Arb.35/JPG/PNG"    # Cambia a la ruta donde guardarás las imágenes redimensionadas

# Crear el directorio de salida si no existe
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# Preparar un dataframe para almacenar los resultados
results <- data.frame()

# Procesar cada imagen
for (i in 1:25) {
  # Cargar la imagen
  img_path <- file.path(input_dir, paste0("Arb_35_", i, ".jpg"))
  img <- image_import(img_path)
  
  # Redimensionar y exportar imagen
  img_resized <- image_resize(img, rel_size = 30)
  segmented <- image_segment(img_resized, index = "R", fill_hull = TRUE)
  export_path <- file.path(output_dir, paste0("Arb_35_", i, ".png"))
  image_export(segmented, export_path)
  
  # Reimportar la imagen redimensionada
  img_resized <- image_import(export_path)
  cont <- object_contour(img_resized, index = "R", watershed = FALSE)
  
  # Medidas
  measures <- poly_measures(cont) |> round_cols()
  meas <- get_measures(measures, id = 2, area ~ 4) |> t()
  selected_measures <- meas[c("area", "perimeter", "length", "width"), , drop = FALSE]
  # Convertir a data.frame para la exportación y filtrar la fila 1
  selected_measures_df <- as.data.frame(t(selected_measures))
  resul <- selected_measures_df[rownames(selected_measures_df) == "1", , drop = FALSE]
  
  # Agregar nombre de imagen a los resultados
  resul$Image <- paste0("Arb_35_", i)
  
  # Agregar al dataframe de resultados
  results <- rbind(results, resul)
}



# Exportar los resultados a Excel
write.xlsx(results, file = "Medidas_Hoja.xlsx")
