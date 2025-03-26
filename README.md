# Taller de manuscritos en Quarto

**Viernes de Bioinformatica 28/marzo/2025**

### Temas:

1.  ¿Qué es Quarto?
2.  ¿Qué es un artículo de Quarto?

-   ¿Cual es la utilidad de este tipo de documentos para la reproducibilidad de la ciencia?
-   Tutorial de cómo hacer un documento de Quarto

3.  ¿Cómo escribir un manuscrito en Quarto?

-   ¿Cómo utilizar el template de quarto manuscripts?

-   Tutorial de las funcionalidades

    -   Insertar figuras de documentos externos y cómo referenciarlas
    -   Citas bibliográficas
    -   Publicación de página en github

------------------------------------------------------------------------

## Requisitos

Para la realización del taller he preparado código de muestra sobre el set de datos de Palmer Penguins. Para seguir los tutoriales asegurate de tener lo siguiente:

-   `quarto` version \> 1.6 (yo tengo 1.6.32). Las instrucciones para instalarlo las puedes encontrar en el siguiente [link](https://quarto.org/docs/get-started/)

-   Paquetes de R (corre el siguiente código para revisar si los tienes e instalarlos en caso de que no los tengas)

```         
# Lista de paquetes
required_packages <- c(
  "tidyverse", "palmerpenguins", "tidymodels", "kableExtra", 
  "rnaturalearth", "rnaturalearthdata", "patchwork", 
  "ggrepel", "GGally", "gt"
)

# Identificar paquetes que no estan instalados
missing_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]

# Instalar paquetes faltantes
if (length(missing_packages) > 0) {
  install.packages(missing_packages)
}

# Cargar paquetes
invisible(lapply(required_packages, library, character.only = TRUE))
```

-   Una cuenta de github

------------------------------------------------------------------------

## Ligas para más información:

-   [Tutorial de artículos html en Quarto](https://quarto.org/docs/output-formats/html-basics.html)

-   [Tutorial Quarto Manuscripts de Posit](https://quarto.org/docs/manuscripts/authoring/rstudio.html)
