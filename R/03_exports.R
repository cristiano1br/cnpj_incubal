# R/03_exports.R
# Salva amostras aleatórias de até 5 linhas de df_completo e df_socios

library(dplyr)
library(readr)

if (!exists("df_completo") || !exists("df_socios")) {
  stop("df_completo ou df_socios não encontrados no ambiente. Carregue-os antes de rodar este script.")
}

n_completo <- min(5, nrow(df_completo))
n_socios   <- min(5, nrow(df_socios))

# Amostras aleatórias
set.seed( sample(1:10000, 1) )
df_completo_sample <- df_completo |> slice_sample(n = n_completo)
df_socios_sample   <- df_socios   |> slice_sample(n = n_socios)

# Garante diretório tidy exista
dir.create("data/data_tidy", showWarnings = FALSE, recursive = TRUE)

# Salvando amostras
write_csv(df_completo_sample, "data/data_tidy/df_completo_sample.csv")
write_csv(df_socios_sample,   "data/data_tidy/df_socios_sample.csv")

# Salvando dados completos
write_csv(df_completo, "data/data_tidy/df_completo.csv")
write_csv(df_socios,   "data/data_tidy/df_socios.csv")

cat("\nAmostras (5 linhas) salvas em data/data_tidy/\n")
print(df_completo_sample)
print(df_socios_sample)

cat("\n--- Dados completos exportados ---\n")
cat("df_completo:", nrow(df_completo), "linhas →", "data/data_tidy/df_completo.csv\n")
cat("df_socios:", nrow(df_socios), "linhas →", "data/data_tidy/df_socios.csv\n")
