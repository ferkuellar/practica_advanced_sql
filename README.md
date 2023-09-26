# Análisis de Datos de IVR para Call Center

## Resumen

Este repositorio contiene scripts de SQL y conjuntos de datos para analizar sistemas de Respuesta de Voz Interactiva (IVR) en un entorno de call center. El objetivo es entender las interacciones de los clientes y optimizar el flujo de IVR.

## Índice

- [Modelo de Datos](#modelo-de-datos)
- [Características](#características)
- [Tabla ivr_detail](#CamposCalculadosenivr_detail)
- [Campos Calculados ivr_detail](#Tabla-ivr_detail)
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

### Campos en ivr_detail

La tabla `ivr_detail` consolidará los datos de las tablas `ivr_calls`, `ivr_modules` y `ivr_steps`. A continuación se detalla cada campo de la tabla:

| Campo                    | Origen       | Descripción                                                 |
|--------------------------|--------------|-------------------------------------------------------------|
| calls_ivr_id             | ivr_calls    | Identificador único de la llamada                           |
| calls_phone_number       | ivr_calls    | Número de teléfono del cliente                              |
| calls_ivr_result         | ivr_calls    | Resultado general de la llamada                             |
| calls_vdn_label          | ivr_calls    | Etiqueta VDN asociada con la llamada                        |
| calls_start_date         | ivr_calls    | Fecha y hora de inicio de la llamada                        |
| calls_start_date_id      | ivr_calls    | Identificador de la fecha de inicio (formato yyyymmdd)      |
| calls_end_date           | ivr_calls    | Fecha y hora de finalización de la llamada                  |
| calls_end_date_id        | ivr_calls    | Identificador de la fecha de finalización (formato yyyymmdd) |
| calls_total_duration     | ivr_calls    | Duración total de la llamada en segundos                    |
| calls_customer_segment   | ivr_calls    | Segmento al que pertenece el cliente                        |
| calls_ivr_language       | ivr_calls    | Idioma seleccionado en la IVR                               |
| calls_steps_module       | ivr_calls    | Número de módulos por los que pasa la llamada               |
| calls_module_aggregation | ivr_calls    | Lista de módulos por los que pasa la llamada                |
| module_sequence          | ivr_modules  | Orden de aparición del módulo en la llamada                 |
| module_name              | ivr_modules  | Nombre del módulo                                           |
| module_duration          | ivr_modules  | Duración del módulo en segundos                             |
| module_result            | ivr_modules  | Resultado del módulo                                        |
| step_sequence            | ivr_steps    | Orden de aparición del paso en el módulo                    |
| step_name                | ivr_steps    | Nombre del paso                                             |
| step_result              | ivr_steps    | Resultado del paso                                          |
| step_description_error   | ivr_steps    | Descripción del error en el paso, si aplica                 |
| document_type            | ivr_steps    | Tipo de documento del cliente                               |
| document_identification  | ivr_steps    | Identificación del documento del cliente                    |
| customer_phone           | ivr_steps    | Número de teléfono del cliente                              |
| billing_account_id       | ivr_steps    | ID de la cuenta de facturación del cliente                  |

### Campos Calculados en ivr_detail

#### calls_start_date_id y calls_end_date_id

Estos son campos calculados que representan las fechas de inicio y finalización de las llamadas, respectivamente, en un formato específico (yyyymmdd).

| Campo              | Origen       | Descripción                                                                 |
|--------------------|--------------|-----------------------------------------------------------------------------|
| calls_start_date_id| ivr_calls    | Identificador calculado para la fecha de inicio de la llamada. Formato yyyymmdd. Ejemplo: `20230101` para el 1 de enero de 2023. |
| calls_end_date_id  | ivr_calls    | Identificador calculado para la fecha de finalización de la llamada. Formato yyyymmdd. Ejemplo: `20230101` para el 1 de enero de 2023. |

Estos campos son útiles para realizar análisis de series temporales o para unir la tabla `ivr_detail` con otras tablas que utilicen un formato de fecha similar.

## Tabla ivr_summary

La tabla `ivr_summary` es una versión resumida de la tabla `ivr_detail` y se crea para facilitar el análisis rápido y la generación de informes. Esta tabla se centra en los indicadores más importantes de cada llamada y, por tanto, contiene un solo registro por llamada.

### Propósito

El objetivo de la tabla `ivr_summary` es agilizar el análisis de KPIs (Indicadores Clave de Rendimiento) y ofrecer una vista simplificada de los datos de las llamadas. Esto es especialmente útil para stakeholders y analistas que necesitan acceder rápidamente a métricas clave sin tener que navegar a través de la gran cantidad de detalles en `ivr_detail`.

### Características

- **Un Registro por Llamada**: A diferencia de `ivr_detail`, que puede tener múltiples registros para una sola llamada en función de los distintos módulos y pasos, `ivr_summary` tiene un único registro para cada llamada.
  
- **Indicadores Clave**: Incluye campos como `ivr_id`, `phone_number`, `ivr_result`, `total_duration`, `customer_segment`, y otros que son críticos para el análisis del rendimiento del sistema IVR.

### Relación con ivr_detail

La tabla `ivr_summary` se deriva de la tabla `ivr_detail` y puede ser creada mediante consultas de agregación que resuman los campos relevantes de `ivr_detail` en un solo registro por `ivr_id`.



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

