# 1. Definir e criar as pastas da estrutura minimalista
pastas_minimalistas <- c("data", "R", "docs")

lapply(pastas_minimalistas, function(pasta) {
  dir.create(pasta, showWarnings = FALSE)
})

# 2. Criar os arquivos iniciais do projeto
arquivos_iniciais <- c(
  "R/01_import.R")
file.create(arquivos_iniciais)

# 3. Configurar o .gitignore
# Verifica se o pacote 'usethis' está instalado, se não, instala automaticamente
if (!requireNamespace("usethis", quietly = TRUE)) {
  install.packages("usethis")
}

# 4. Aplicar as regras de ignorar ao Git
# Nota: É ideal que a pasta já tenha o Git inicializado (usethis::use_git())
usethis::use_git_ignore(c(
  "data/",             # Regra de ouro: nunca commitar a pasta de dados
  ".Rhistory",         # Histórico de comandos do console
  ".RData",            # Dados salvos acidentalmente na área de trabalho
  ".DS_Store",         # Arquivos ocultos do macOS
  ".env"               # Arquivo de senhas e chaves de API
))
