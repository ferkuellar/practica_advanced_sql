# Análisis de Datos de IVR para Call Center

## Resumen

Este repositorio contiene scripts de SQL y conjuntos de datos para analizar sistemas de Respuesta de Voz Interactiva (IVR) en un entorno de call center. El objetivo es entender las interacciones de los clientes y optimizar el flujo de IVR.

## Índice

- [Modelo de Datos](#modelo-de-datos)
- [Características](#características)
- [Requisitos](#requisitos)
- [Uso](#uso)
- [Contribuidores](#contribuidores)
- [Licencia](#licencia)

## Modelo de Datos

El modelo de datos consta de las siguientes tablas:

### ivr_calls

| Campo               | Descripción                                      |
|---------------------|--------------------------------------------------|
| ivr_id              | Identificador de la llamada                      |
| phone_number        | Número de teléfono del cliente                   |
| ivr_result          | Resultado de la llamada                          |
| vdn_label           | Etiqueta VDN                                     |
| start_date          | Fecha de inicio de la llamada                    |
| end_date            | Fecha de finalización de la llamada              |
| total_duration      | Duración total de la llamada                     |
| customer_segment    | Segmento del cliente                             |
| ivr_language        | Idioma de la IVR                                 |
| steps_module        | Número de módulos por los que pasa la llamada    |
| module_aggregation  | Lista de módulos por los que pasa la llamada     |

### ivr_modules

| Campo           | Descripción                                  |
|-----------------|----------------------------------------------|
| ivr_id          | Identificador de la llamada                  |
| module_sequence | Secuencia del módulo                         |
| module_name     | Nombre del módulo                            |
| module_duration | Duración del módulo                          |
| module_result   | Resultado del módulo                         |

### ivr_steps

| Campo                   | Descripción                                       |
|-------------------------|---------------------------------------------------|
| ivr_id                  | Identificador de la llamada                       |
| module_sequence         | Secuencia del módulo                              |
| step_sequence           | Secuencia del paso                                |
| step_name               | Nombre del paso                                   |
| step_result             | Resultado del paso                                |
| step_description_error  | Descripción del error en el paso                  |
| document_type           | Tipo de documento del cliente                     |
| document_identification | Identificación del documento del cliente          |
| customer_phone          | Número de teléfono del cliente                    |
| billing_account_id      | ID de la cuenta de facturación del cliente        |

## Características

- Análisis detallado de la ruta de IVR para cada llamada
- Tabla de resumen con indicadores clave de rendimiento para cada llamada
- Funciones de limpieza de datos para manejar datos faltantes o erróneos.

---

## Tabla ivr_detail

La tabla `ivr_detail` es una tabla derivada que se crea a partir de las tablas `ivr_calls`, `ivr_modules` y `ivr_steps` del dataset `keepcoding`. Esta tabla ofrece una vista unificada de las interacciones de IVR, facilitando análisis más complejos y reportes. A continuación se detalla la relación entre estas tablas:

### Origen de Datos

- **ivr_calls**: Contiene datos referentes a las llamadas realizadas en el sistema IVR.
- **ivr_modules**: Contiene datos sobre los diferentes módulos por los que pasa una llamada. Esta tabla se relaciona con `ivr_calls` a través del campo `ivr_id`.
- **ivr_steps**: Contiene datos sobre los pasos específicos que realiza un usuario dentro de un módulo. Esta tabla se relaciona con `ivr_modules` a través de los campos `ivr_id` y `module_sequence`.

### Relaciones

- `ivr_calls.ivr_id` se relaciona con `ivr_modules.ivr_id`
- `ivr_modules.ivr_id` y `ivr_modules.module_sequence` se relacionan con `ivr_steps.ivr_id` y `ivr_steps.module_sequence`, respectivamente.

### Campos en ivr_detail

Los campos en la tabla `ivr_detail` incluyen todos los campos relevantes de `ivr_calls`, `ivr_modules` y `ivr_steps`, permitiendo un análisis detallado de la experiencia del usuario en el sistema IVR.

## Requisitos

- Sistema de base de datos compatible con SQL
- Archivos de datos en formato CSV

## Uso

1. **Clonar Repositorio**:

    ```bash
    git clone https://github.com/tu_usuario/analisis_datos_ivr.git
    ```

2. **Ejecutar Scripts de SQL**: Ejecuta los scripts de SQL en tu base de datos para crear las tablas y funciones.

3. **Importar Datos**: Importa los archivos `ivr_calls.csv`, `ivr_modules.csv` y `ivr_steps.csv` en las tablas correspondientes.

4. **Ejecutar Análisis**: Ejecuta las consultas SQL para generar conocimientos e informes.

## Contribuidores

- [Fernando Cuellar](https://github.com/ferkuellar)

## Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo [LICENSE.md](LICENSE.md) para más detalles.

