# R/03_exports.R
# Salva amostras aleatórias de até 5 linhas e os dados completos de df_empresas

library(dplyr)
library(readr)

if (!exists("df_empresas")) {
  stop("df_empresas não encontrado no ambiente. Carregue-o antes de rodar este script.")
}

n_empresas <- min(5, nrow(df_empresas))

# Amostra aleatória
set.seed(sample(1:10000, 1))
df_empresas_sample <- df_empresas |> slice_sample(n = n_empresas)

# Garante diretório tidy exista
dir.create("data/data_tidy", showWarnings = FALSE, recursive = TRUE)

# Salvando amostra e dados completos
write_csv(df_empresas_sample, "data/data_tidy/df_empresas_sample.csv")
write_csv(df_empresas,        "data/data_tidy/df_empresas.csv")

cat("Amostra (5 linhas) e dados completos salvos em data/data_tidy/\n")
print(df_empresas_sample)

cat("\n--- Dados completos exportados ---\n")
cat("df_empresas:", nrow(df_empresas), "linhas →", "data/data_tidy/df_empresas.csv\n")

