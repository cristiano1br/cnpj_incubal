library(readr)
library(stringr)
library(dplyr)

# ------------------------------------------------------------------
# 1) Carrega o arquivo gerado pelo script de importação
# ------------------------------------------------------------------
cnpj_empresas <- read_csv("data/data_tidy/cnpj_empresas.csv", show_col_types = FALSE)

# Extrai os 8 primeiros dígitos do CNPJ (cnpj_basico)
meus_cnpjs <- cnpj_empresas |>
  transmute(cnpj_basico = str_sub(str_remove_all(CNPJ, "[^0-9]"), 1, 8)) |>
  pull(cnpj_basico) |>
  unique()

cat("CNPJs básicos (8 primeiros dígitos):\n")
print(meus_cnpjs)

# ------------------------------------------------------------------
# 2) Consulta ao Base dos Dados (BigQuery)
# ------------------------------------------------------------------
# Para usar, descomente o bloco abaixo e configure seu projeto de billing.

library(basedosdados)
set_billing_id("our-lacing-503720-v2")

data_ref <- "2026-01-11"  # data de referência das tabelas snapshot (estabelecimentos/empresas/simples)
cnpjs_string <- paste0("'", meus_cnpjs, "'", collapse = ", ")

query <- paste0("
SELECT
  -- Identificação básica
  est.cnpj,
  emp.razao_social,
  est.nome_fantasia,

  -- Sócios
  soc.nome AS nome_socio,
  soc.tipo AS tipo_socio,
  soc.qualificacao AS qualificacao_socio,

  -- Porte financeiro
  emp.capital_social,

  -- Localização
  est.sigla_uf,
  est.id_municipio,
  mun.nome AS nome_municipio,

  -- Situação cadastral: explica por que a empresa foi baixada/suspensa
  -- (ex.: encerramento voluntário x baixa de ofício por inadimplência)
  est.situacao_cadastral,
  est.data_situacao_cadastral,
  est.motivo_situacao_cadastral,

  -- CNAE: permite segmentar por setor de atuação (tech, saúde, alimentos etc.)
  est.cnae_fiscal_principal,
  est.cnae_fiscal_secundaria,

  -- Simples Nacional / MEI: indica porte e maturidade fiscal da empresa
  simp.opcao_simples,
  simp.data_opcao_simples,
  simp.data_exclusao_simples,
  simp.opcao_mei,
  simp.data_opcao_mei,
  simp.data_exclusao_mei

FROM `basedosdados.br_me_cnpj.estabelecimentos` AS est

INNER JOIN `basedosdados.br_me_cnpj.empresas` AS emp
  ON est.cnpj_basico = emp.cnpj_basico AND est.data = emp.data

LEFT JOIN `basedosdados.br_me_cnpj.socios` AS soc
  ON est.cnpj_basico = soc.cnpj_basico AND est.data = soc.data

LEFT JOIN `basedosdados.br_me_cnpj.simples` AS simp
  ON est.cnpj_basico = simp.cnpj_basico

LEFT JOIN `basedosdados.br_bd_diretorios_brasil.municipio` AS mun
  ON est.id_municipio = mun.id_municipio

WHERE est.cnpj_basico IN (", cnpjs_string, ")
  AND est.data = '", data_ref, "'
  AND emp.data = '", data_ref, "'
  AND soc.data = '", data_ref, "'
")

df_empresas <- read_sql(query)
print(df_empresas)

