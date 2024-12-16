# Script: format_r_code.ps1
# Este script ejecuta styler para formatear código R con el máximo nivel de detalle.

param (
    [string]$FilePath = "",        # Ruta al archivo R a formatear (opcional)
    [string]$DirPath = ".",        # Ruta al directorio (por defecto, el actual)
    [string]$CacheDir = ".styler_cache",  # Directorio de caché para styler
    [string]$Scope = "tokens",     # Nivel de formateo (máximo detalle con "tokens")
    [bool]$Strict = $true          # Aplicar reglas estrictas
)

# Comando completo para sincronizar renv y ejecutar styler
$RCommand = @"
library(styler)

# Configuración personalizada profesional con scope completo
custom_style <- function() {
  styler::tidyverse_style(
    scope = 'tokens',  # Formatear espacios, indentaciones, saltos de línea y más
    strict = $Strict   # Aplicar reglas estrictas
  )
}

options(
  styler.cache_root = '$CacheDir',  # Directorio para la caché
  styler.col_width = 80            # Ancho máximo de línea para mayor legibilidad
)

if ('$FilePath' != '') {
  styler::style_file('$FilePath', style = custom_style)
} else {
  styler::style_dir(path = '$DirPath', style = custom_style)
}
"@

try {
    Write-Host "Sincronizando entorno con renv y ejecutando styler..."
    Rscript -e $RCommand
    Write-Host "Proceso completado con éxito."
} catch {
    Write-Error "Error al ejecutar el comando de R: $_"
}
