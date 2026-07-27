

library(basedosdados)
library(readr)


# Carrega o arquivo gerado pelo script de importação
cnpj_empresas <- read_csv("data/data_tidy/cnpj_empresas.csv", show_col_types = FALSE)

# Extrai os 8 primeiros dígitos do CNPJ
meus_cnpjs <- cnpj_empresas |>
  transmute(cnpj_basico = str_sub(str_remove_all(CNPJ, "[^0-9]"), 1, 8)) |>
  pull(cnpj_basico)

print(meus_cnpjs)

# 1. Configurar ID do Projeto
set_billing_id("our-lacing-503720-v2")

# 2. Lista de CNPJs básicos (8 dígitos) 
cnpjs_string <- paste0("'", meus_cnpjs, "'", collapse = ", ")


# 3. Construir a query combinando Estabelecimentos e Empresas
# Filtramos pela data mais recente (period_end) para garantir dados atuais
query <- paste0("
SELECT
  est.cnpj,
  est.nome_fantasia,
  emp.razao_social,
  emp.capital_social,
  est.situacao_cadastral,
  est.logradouro,
  est.numero,
  est.bairro,
  est.sigla_uf,
  est.id_municipio
FROM `basedosdados.br_me_cnpj.estabelecimentos` AS est
INNER JOIN `basedosdados.br_me_cnpj.empresas` AS emp
  ON est.cnpj_basico = emp.cnpj_basico AND est.data = emp.data
WHERE est.cnpj_basico IN (", cnpjs_string, ")
  AND est.data = '2026-01-11'  -- Filtro de partição (Estabelecimentos)
  AND emp.data = '2026-01-11'  -- Filtro de partição (Empresas)
")

# 4. Executar e visualizar
df_completo <- read_sql(query)
print(df_completo)




# 3. Query com Estabelecimentos, Empresas e Sócios
# Note que usamos LEFT JOIN para sócios, para não excluir empresas que porventura 
# não tenham sócios registrados na base.
query <- paste0("
SELECT
  est.cnpj,
  emp.razao_social,
  est.nome_fantasia,
  soc.nome AS nome_socio,
  soc.tipo AS tipo_socio,
  soc.qualificacao AS qualificacao_socio,
  emp.capital_social,
  est.sigla_uf
FROM `basedosdados.br_me_cnpj.estabelecimentos` AS est
INNER JOIN `basedosdados.br_me_cnpj.empresas` AS emp
  ON est.cnpj_basico = emp.cnpj_basico AND est.data = emp.data
LEFT JOIN `basedosdados.br_me_cnpj.socios` AS soc
  ON est.cnpj_basico = soc.cnpj_basico AND est.data = soc.data
WHERE est.cnpj_basico IN (", cnpjs_string, ")
  AND est.data = '2026-01-11'  -- Filtro de partição para todas as tabelas
  AND emp.data = '2026-01-11'
  AND soc.data = '2026-01-11'
")

# 4. Execução
df_socios <- read_sql(query)
print(df_socios)

