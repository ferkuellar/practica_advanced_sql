# Análisis de Datos de IVR para Call Center

## Resumen

Este repositorio contiene scripts de SQL y conjuntos de datos para analizar sistemas de Respuesta de Voz Interactiva (IVR) en un entorno de call center. El objetivo es entender las interacciones de los clientes y optimizar el flujo de IVR.

## Índice
1. [Modelo de Datos](#modelo-de-datos)
   - [ivr_calls](#ivr_calls)
   - [ivr_modules](#ivr_modules)
   - [ivr_steps](#ivr_steps)
2. [Características](#características)
3. [Tabla ivr_detail](#tabla-ivr_detail)
   - [Origen de Datos](#origen-de-datos)
   - [Relaciones](#relaciones)
   - [Campos en ivr_detail](#campos-en-ivr_detail)
   - [Campos Calculados en ivr_detail](#campos-calculados-en-ivr_detail)
4. [Tabla ivr_summary](#tabla-ivr_summary)
   - [Propósito](#propósito)
   - [Características](#características)
   - [Relación con ivr_detail](#relación-con-ivr_detail)
   - [Campos en ivr_summary](#campos-en-ivr_summary)
5. [Función clean_integer](#función-clean_integer)
   - [Descripción](#descripción)
   - [Uso](#uso)
   - [Implementación en BigQuery](#implementación-en-bigquery)
6. [Requisitos](#requisitos)
7. [Uso](#uso)
8. [Contribuidores](#contribuidores)
9. [Licencia](#licencia)


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

### Campos en ivr_summary

La tabla `ivr_summary` contiene los siguientes campos:

| Campo                    | Origen       | Descripción                                                                                                           |
|--------------------------|--------------|-----------------------------------------------------------------------------------------------------------------------|
| ivr_id                   | ivr_detail   | Identificador único de la llamada                                                                                     |
| phone_number             | ivr_detail   | Número de teléfono del cliente                                                                                        |
| ivr_result               | ivr_detail   | Resultado general de la llamada                                                                                       |
| vdn_aggregation          | ivr_detail   | Generalización del campo `vdn_label` (FRONT para ATC, TECH para TECH, ABSORPTION para ABSORPTION, RESTO para otros)   |
| start_date               | ivr_detail   | Fecha y hora de inicio de la llamada                                                                                  |
| end_date                 | ivr_detail   | Fecha y hora de finalización de la llamada                                                                            |
| total_duration           | ivr_detail   | Duración total de la llamada en segundos                                                                              |
| customer_segment         | ivr_detail   | Segmento al que pertenece el cliente                                                                                  |
| ivr_language             | ivr_detail   | Idioma seleccionado en la IVR                                                                                         |
| steps_module             | ivr_detail   | Número de módulos por los que pasa la llamada                                                                         |
| module_aggregation       | ivr_detail   | Lista de módulos por los que pasa la llamada                                                                          |
| document_type            | ivr_detail   | Tipo de documento del cliente, si está disponible                                                                     |
| document_identification  | ivr_detail   | Identificación del documento del cliente, si está disponible                                                           |
| customer_phone           | ivr_detail   | Número de teléfono del cliente, si está disponible                                                                    |
| billing_account_id       | ivr_detail   | ID de la cuenta de facturación del cliente, si está disponible                                                        |
| masiva_lg                | ivr_detail   | Flag que indica si la llamada pasó por el módulo 'AVERIA_MASIVA' (1 para sí, 0 para no)                               |
| info_by_phone_lg         | ivr_detail   | Flag que indica si el cliente fue identificado por su número de teléfono (1 para sí, 0 para no)                        |
| info_by_dni_lg           | ivr_detail   | Flag que indica si el cliente fue identificado por su DNI (1 para sí, 0 para no)                                      |

Cada uno de estos campos se extrae o calcula a partir de los datos en la tabla `ivr_detail`, permitiendo un análisis más sencillo y focalizado de las métricas clave de rendimiento del sistema IVR.

### Campos adicionales en ivr_summary

| Campo                 | Origen       | Descripción                                                                                                    |
|-----------------------|--------------|----------------------------------------------------------------------------------------------------------------|
| repeated_phone_24H    | ivr_detail   | Es un flag (0 o 1) que indica si ese mismo número ha realizado una llamada en las 24 horas anteriores.          |
| cause_recall_phone_24H| ivr_detail   | Es un flag (0 o 1) que indica si ese mismo número ha realizado una llamada en las 24 horas posteriores.         |


## Función clean_integer

### Descripción

La función `clean_integer` es una utilidad de limpieza de datos diseñada para manejar valores enteros `null` en las tablas de nuestra base de datos. Si la función recibe un valor `null`, devuelve -999999 como valor predeterminado. Esta convención es especialmente útil para mantener la integridad de los datos y facilitar el análisis posterior.

### Uso

La función se puede usar en consultas SQL para reemplazar valores `null` en columnas de enteros, de la siguiente manera:

```sql
SELECT clean_integer(columna_entera) FROM nombre_tabla;
```

### Implementación en BigQuery
La implementación de esta función en BigQuery podría ser algo similar a:

```sql
CREATE OR REPLACE FUNCTION dataset_name.clean_integer(input INT64) AS (
  IFNULL(input, -999999)
);
```

Para usar esta función en tus consultas dentro del mismo dataset, simplemente la llamas como `clean_integer(your_integer_column)`.

Al utilizar esta función en sus consultas, puede estar seguro de que cualquier valor null se reemplazará con el valor `-999999`, facilitando así los análisis y evitando errores potenciales relacionados con la falta de manejo de valores `null`.


## Requisitos

- Sistema de base de datos compatible con SQL
- Archivos de datos en formato CSV

## Uso

1. **Clonar Repositorio**:

    ```bash
    git clone https://github.com/tu_usuario/practica_advanced_sql
    ```

2. **Ejecutar Scripts de SQL**: Ejecuta los scripts de SQL en tu base de datos para crear las tablas y funciones.

3. **Importar Datos**: Importa los archivos `ivr_calls.csv`, `ivr_modules.csv` y `ivr_steps.csv` en las tablas correspondientes.

4. **Ejecutar Análisis**: Ejecuta las consultas SQL para generar conocimientos e informes.

## Contribuidores

- [Fernando Cuellar](https://github.com/ferkuellar)

## Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo [LICENSE.md](LICENSE.md) para más detalles.

