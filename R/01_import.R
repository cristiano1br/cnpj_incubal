library(readr)
library(dplyr)
library(stringr)

normalize_cnpj <- function(x) {
  x <- str_remove_all(x, "[^0-9]")
  if_else(str_length(x) == 14,
          str_c(str_sub(x, 1, 2), ".", str_sub(x, 3, 5), ".", str_sub(x, 6, 8), "/", str_sub(x, 9, 12), "-", str_sub(x, 13, 14)),
          x)
}

cnpj_incubal <- read_csv("data/data_raw/cnpj_incubal.csv", show_col_types = FALSE)

cnpj_empresas <- cnpj_incubal |>
  filter(!is.na(CNPJ), CNPJ != "NÃO POSSUI", str_trim(CNPJ) != "") |>
  transmute(
    EMPRESA = EMPRESA |> 
      str_remove_all("https?://[^ ]+|www[.][^ ]+") |> 
      str_remove("[[:space:]]*[-–—][[:space:]]*$") |> 
      str_squish(),
    CNPJ = normalize_cnpj(CNPJ)
  )

# Exporta para data/data_tidy/
write_csv(cnpj_empresas, "data/data_tidy/cnpj_empresas.csv")
