# Proyecto de Analítica de Interacción con IVR (Respuesta de Voz Interactiva)

[Querys IVR para creacion de tablas Intermediate, Details, Summary](https://console.cloud.google.com/bigquery?sq=658206446308:b4997ad7d40b446fbe59743d23fa348a)

## Objetivo del Proyecto

El objetivo principal del proyecto es desarrollar un modelo de datos robusto y eficiente que permita analizar y comprender las interacciones del cliente a través del sistema IVR (Respuesta de Voz Interactiva).

## Índice

1. [Objetivo del Proyecto](#objetivo-del-proyecto)
2. [Estructura de Datos](#estructura-de-datos)
   - [ivr_calls](#ivr_calls)
   - [ivr_modules](#ivr_modules)
   - [ivr_steps](#ivr_steps)
3. [Proceso de Modelado de Datos](#proceso-de-modelado-de-datos)
   - [Creación de Tablas](#creación-de-tablas)
   - [Tabla Detallada (`ivr_detail`)](#tabla-detallada-ivr_detail)
4. [Creación de la Tabla ivr_detail en SQL](#creación-de-la-tabla-ivr_detail-en-sql)
   - [Objetivo](#objetivo-1)
   - [Código SQL](#código-sql)
   - [Explicación de Campos](#explicación-de-campos)
5. [Creación de la Tabla ivr_intermediate en SQL](#creación-de-la-tabla-ivr_intermediate-en-sql)
   - [Objetivo](#objetivo-2)
   - [Código SQL](#código-sql-1)
   - [Explicación de Campos](#explicación-de-campos-1)
6. [Tabla de Resumen (`ivr_summary`)](#tabla-de-resumen-ivr_summary)
   - [Funciones de Limpieza](#funciones-de-limpieza)
   - [Indicadores de Comportamiento del Cliente](#indicadores-de-comportamiento-del-cliente)
7. [Documentación de la Función `clean_integer`](#documentación-de-la-función-clean_integer)
8. [Descripción de Campos en Tablas del Proyecto IVR](#descripción-de-campos-en-tablas-del-proyecto-ivr)
9. [Campos de Fecha Calculados](#campos-de-fecha-calculados)
   - [Detalles del Formato](#detalles-del-formato)
   - [Cómo se Calculan](#cómo-se-calculan)

## Estructura de Datos

Se parte de tres fuentes de datos principales:

### ivr_calls

Esta tabla contiene la información básica de cada llamada, como el identificador único de la llamada (`ivr_id`), el número de teléfono del cliente, el resultado de la llamada y otros detalles relevantes.

### ivr_modules

Aquí se registran los diferentes módulos o secciones del IVR por los que pasa una llamada. Cada entrada en esta tabla se relaciona con una entrada en `ivr_calls` mediante el campo `ivr_id`.

### ivr_steps

Esta tabla recoge los diferentes pasos o acciones que realiza un usuario dentro de un módulo específico del IVR. Se relaciona con la tabla `ivr_modules` utilizando los campos `ivr_id` y `module_sequence`.

## Proceso de Modelado de Datos

### Creación de Tablas

Se crean las tablas `ivr_calls`, `ivr_modules` y `ivr_steps` en el dataset `keepcoding` de BigQuery, asegurando que las relaciones entre ellas estén bien definidas mediante claves foráneas.

### Tabla Detallada (`ivr_detail`)

Una tabla detallada se crea mediante una consulta JOIN que une las tablas `ivr_calls`, `ivr_modules` y `ivr_steps` en los campos relevantes.

# Creación de la Tabla ivr_detail en SQL

## Objetivo

El objetivo de este script es crear una tabla detallada (`ivr_detail`) que combine información de las tablas `ivr_calls`, `ivr_modules`, y `ivr_steps`. Esta tabla servirá como una fuente única de verdad para análisis posteriores.

## Código SQL

```sql
CREATE TABLE keepcoding.ivr_detail AS
SELECT 
  c.ivr_id AS calls_ivr_id,
  c.phone_number AS calls_phone_number,
  c.ivr_result AS calls_ivr_result,
  c.vdn_label AS calls_vdn_label,
  c.start_date AS calls_start_date,
  CAST(FORMAT_TIMESTAMP('%Y%m%d', TIMESTAMP(c.start_date)) AS INT64) AS calls_start_date_id,
  c.end_date AS calls_end_date,
  CAST(FORMAT_TIMESTAMP('%Y%m%d', TIMESTAMP(c.end_date)) AS INT64) AS calls_end_date_id,
  c.total_duration AS calls_total_duration,
  c.customer_segment AS calls_customer_segment,
  c.ivr_language AS calls_ivr_language,
  c.steps_module AS calls_steps_module,
  c.module_aggregation AS calls_module_aggregation,
  m.module_sequece,
  m.module_name,
  m.module_duration,
  m.module_result,
  s.step_sequence,
  s.step_name,
  s.step_result,
  s.step_description_error,
  s.document_type,
  s.document_identification,
  s.customer_phone,
  s.billing_account_id
FROM keepcoding.ivr_calls c
JOIN keepcoding.ivr_modules m ON c.ivr_id = m.ivr_id
JOIN keepcoding.ivr_steps s ON m.ivr_id = s.ivr_id AND m.module_sequece = s.module_sequece;
```

### Explicación de Campos

- `calls_ivr_id`: Identificador único para cada llamada, se obtiene de la tabla `ivr_calls`.
- `calls_phone_number`: Número de teléfono del cliente que hizo la llamada, proviene de `ivr_calls`.
- `calls_ivr_result`: Resultado final de la llamada, también se toma de `ivr_calls`.
- `calls_vdn_label`: Etiqueta VDN de la llamada, proviene de `ivr_calls`.
- `calls_start_date`: Fecha y hora en que comenzó la llamada.
- `calls_start_date_id`: Identificador de fecha calculado para `calls_start_date` en formato yyyymmdd.
- `calls_end_date`: Fecha y hora en que terminó la llamada.
- `calls_end_date_id`: Identificador de fecha calculado para `calls_end_date` en formato yyyymmdd.
- `calls_total_duration`: Duración total de la llamada en segundos.
- `calls_customer_segment`: Segmento del cliente al que pertenece la llamada.
- `calls_ivr_language`: Idioma seleccionado en el IVR durante la llamada.
- `calls_steps_module`: Número de módulos por los que pasó la llamada.
- `calls_module_aggregation`: Agregación de módulos por los que pasó la llamada.
- `module_sequece`: Secuencia del módulo dentro de la llamada.
- `module_name`: Nombre del módulo.
- `module_duration`: Duración del módulo en segundos.
- `module_result`: Resultado del módulo.
- `step_sequence`: Secuencia del paso dentro del módulo.
- `step_name`: Nombre del paso dentro del módulo.
- `step_result`: Resultado del paso.
- `step_description_error`: Descripción de cualquier error ocurrido durante el paso.
- `document_type`: Tipo de documento del cliente, si se identifica.
- `document_identification`: Identificación del documento del cliente, si se identifica.
- `customer_phone`: Número de teléfono del cliente, si se identifica.
- `billing_account_id`: ID de la cuenta de facturación del cliente, si se identifica.

# Creación de la Tabla ivr_intermediate en SQL

## Objetivo

El objetivo de este script es crear una tabla intermedia (`ivr_intermediate`) que extraiga información relevante de la tabla `ivr_detail`. En particular, se calculan dos indicadores clave: `repeated_phone_24H` y `cause_recall_phone_24H`.

## Código SQL

```sql
CREATE TABLE keepcoding.ivr_intermediate AS
SELECT 
  calls_ivr_id,
  calls_phone_number,
  CASE 
    WHEN TIMESTAMP_DIFF(calls_start_date, LAG(calls_start_date) OVER (PARTITION BY calls_phone_number ORDER BY calls_start_date), HOUR) <= 24 THEN 1
    ELSE 0
  END AS repeated_phone_24H,
  CASE 
    WHEN TIMESTAMP_DIFF(LEAD(calls_start_date) OVER (PARTITION BY calls_phone_number ORDER BY calls_start_date), calls_start_date, HOUR) <= 24 THEN 1
    ELSE 0
  END AS cause_recall_phone_24H
FROM keepcoding.ivr_detail;
```

## Explicación de Campos

- **calls_ivr_id**: Identificador único de la llamada, heredado de `ivr_detail`.
- **calls_phone_number**: Número de teléfono del cliente que hizo la llamada, heredado de `ivr_detail`.
- **repeated_phone_24H**: Indicador que toma el valor 1 si el mismo número de teléfono ha realizado otra llamada en las 24 horas anteriores, y 0 en caso contrario.
- **cause_recall_phone_24H**: Indicador que toma el valor 1 si el mismo número de teléfono realiza otra llamada en las 24 horas posteriores, y 0 en caso contrario.

### Indicadores de Comportamiento del Cliente

Se introducen campos como `repeated_phone_24H` y `cause_recall_phone_24H` para rastrear el comportamiento del cliente, lo que es crucial para futuras estrategias de atención al cliente.

### Funciones de Limpieza

Para manejar valores nulos y otros problemas de calidad de datos, se implementan funciones de limpieza, como `clean_integer`.

# Función `clean_integer`

## Descripción General

La función `clean_integer` es una función SQL personalizada diseñada para tratar valores enteros que pueden ser nulos. Si se recibe un valor `NULL`, la función devuelve un valor predeterminado de `-999999`.

## Objetivo

Crear una función llamada `clean_integer` en el dataset `keepcoding` que se encargue de limpiar valores enteros, devolviendo un valor por defecto en caso de que el valor entrante sea NULL.

## Código SQL

```sql
CREATE OR REPLACE FUNCTION keepcoding.clean_integer(input_value INT64) 
RETURNS INT64 
AS (
  IF(input_value IS NULL, -999999, input_value)
);
```

## Parámetros

| Parámetro     | Tipo  | Descripción                                                |
|---------------|-------|------------------------------------------------------------|
| `input_value` | INT64 | Valor entero que se desea limpiar. Puede ser nulo.         |

## Valor de Retorno

- **Tipo**: INT64
- **Descripción**: Devuelve el mismo valor entero si `input_value` no es nulo. Si `input_value` es nulo, devuelve `-999999`.

## Ejemplos de Uso

```sql
SELECT keepcoding.clean_integer(NULL);  -- Devolverá -999999
SELECT keepcoding.clean_integer(5);     -- Devolverá 5
```

## Casos de Uso

- **Limpieza de Datos**: Útil para limpiar datos antes de realizar análisis, especialmente cuando se trabajan con grandes sets de datos donde los valores nulos pueden ser problemáticos.

- **Normalización**: Facilita la normalización de los datos al asignar un valor predeterminado a los registros nulos, lo que permite realizar análisis más consistentes.

## Precauciones

- Asegúrese de entender el impacto de reemplazar los valores nulos con `-999999` en su análisis específico.

## Descripción de Campos en Tablas del Proyecto IVR

| Campo                   | Descripción                                                                                       |
|-------------------------|---------------------------------------------------------------------------------------------------|
| `ivr_id`                | Identificador único de cada llamada en el sistema IVR.                                            |
| `phone_number`          | Número de teléfono del cliente que hizo la llamada.                                                |
| `ivr_result`            | Resultado de la llamada (ej. exitosa, fallida, etc.).                                              |
| `vdn_label`             | Etiqueta que indica el tipo de atención requerida (ej. Soporte Técnico, Atención al Cliente).       |
| `start_date`            | Fecha y hora en que comenzó la llamada.                                                            |
| `end_date`              | Fecha y hora en que terminó la llamada.                                                            |
| `total_duration`        | Duración total de la llamada en segundos.                                                          |
| `customer_segment`      | Segmento al que pertenece el cliente (ej. Premium, Regular).                                       |
| `ivr_language`          | Idioma en el que se realiza la interacción en el IVR.                                              |
| `steps_module`          | Número de módulos por los que pasa la llamada.                                                     |
| `module_aggregation`    | Lista de módulos por los que pasa la llamada.                                                      |
| `document_type`         | Tipo de documento utilizado para identificar al cliente en ciertos pasos (ej. DNI, Pasaporte).      |
| `document_identification`| Número del documento utilizado para identificar al cliente.                                        |
| `customer_phone`        | Número de teléfono del cliente, si es identificado en algún paso.                                   |
| `billing_account_id`    | Identificador de la cuenta de facturación del cliente.                                             |
| `masiva_lg`             | Flag que indica si la llamada pasó por el módulo de avería masiva (1 para sí, 0 para no).          |
| `info_by_phone_lg`      | Flag que indica si se identificó al cliente por su número de teléfono (1 para sí, 0 para no).       |
| `info_by_dni_lg`        | Flag que indica si se identificó al cliente por su DNI (1 para sí, 0 para no).                     |
| `repeated_phone_24H`    | Flag que indica si el número realizó una llamada en las últimas 24 horas (1 para sí, 0 para no).    |
| `cause_recall_phone_24H`| Flag que indica si el número realizará una llamada en las próximas 24 horas (1 para sí, 0 para no). |

## Campos de Fecha Calculados: `calls_start_date_id` y `calls_end_date_id`

Estos dos campos son especialmente útiles para realizar análisis temporales y se generan a partir de las fechas `calls_start_date` y `calls_end_date` respectivamente.

### Detalles del Formato

- **Formato**: Estos campos son de tipo entero y almacenan la fecha en formato `yyyymmdd`. 
  - Por ejemplo, el 1 de enero de 2023 se almacenaría como `20230101`.

### Cómo se Calculan

Se calculan utilizando la función `FORMAT_TIMESTAMP` en la consulta SQL, donde la fecha original se transforma a una cadena en el formato `yyyymmdd`, y posteriormente se convierte a un entero.

```sql
CAST(FORMAT_TIMESTAMP('%Y%m%d', TIMESTAMP(calls_start_date)) AS INT64) AS calls_start_date_id,
CAST(FORMAT_TIMESTAMP('%Y%m%d', TIMESTAMP(calls_end_date)) AS INT64) AS calls_end_date_id
```

# Documentación de la Tabla `ivr_summary`

## Introducción

La tabla `ivr_summary` es una tabla de resumen que consolida la información más relevante de las interacciones de los clientes a través del sistema IVR (Respuesta de Voz Interactiva). Esta tabla se deriva de la tabla `ivr_detail` y se centra en proporcionar un registro único por llamada con indicadores clave para el análisis y la toma de decisiones.

## Objetivo

El objetivo de este script es crear una tabla de resumen (`ivr_summary`) que sintetiza la información más relevante de las llamadas y las interacciones del cliente en el IVR. Esta tabla se basa en los datos ya compilados en las tablas `ivr_detail` e `ivr_intermediate`.

## Estructura de la Tabla

A continuación se describen los campos que componen la tabla `ivr_summary`:

| Campo                    | Descripción                                                                                               |
|--------------------------|-----------------------------------------------------------------------------------------------------------|
| `ivr_id`                 | Identificador único de la llamada, heredado de `ivr_detail`.                                               |
| `phone_number`           | Número de teléfono desde el cual se realizó la llamada.                                                     |
| `ivr_result`             | Resultado final de la llamada (ej. exitosa, fallida, etc.).                                                 |
| `vdn_aggregation`        | Categorización del tipo de atención requerida basada en `vdn_label`.                                        |
| `start_date`             | Fecha y hora de inicio de la llamada.                                                                      |
| `end_date`               | Fecha y hora de finalización de la llamada.                                                                |
| `total_duration`         | Duración total de la llamada en segundos.                                                                  |
| `customer_segment`       | Segmento del cliente (ej. Premium, Regular, etc.).                                                          |
| `ivr_language`           | Idioma del IVR utilizado en la llamada.                                                                    |
| `steps_module`           | Número total de módulos por los que pasó la llamada.                                                        |
| `module_aggregation`     | Lista de módulos por los que pasó la llamada.                                                               |
| `document_type`          | Tipo de documento utilizado para identificación del cliente en ciertos pasos.                               |
| `document_identification`| Número de identificación del documento del cliente.                                                         |
| `customer_phone`         | Número de teléfono del cliente, si se pudo identificar en algún paso.                                       |
| `billing_account_id`     | ID de la cuenta de facturación del cliente.                                                                 |
| `masiva_lg`              | Flag para indicar si la llamada pasó por el módulo 'AVERIA_MASIVA' (1 para sí, 0 para no).                  |
| `info_by_phone_lg`       | Flag para indicar si el cliente fue identificado por teléfono (1 para sí, 0 para no).                        |
| `info_by_dni_lg`         | Flag para indicar si el cliente fue identificado por DNI (1 para sí, 0 para no).                            |
| `repeated_phone_24H`     | Flag para indicar si ese número realizó una llamada en las últimas 24 horas (1 para sí, 0 para no).          |
| `cause_recall_phone_24H` | Flag para indicar si ese número realizará una llamada en las próximas 24 horas (1 para sí, 0 para no).       |

## Utilidades de la Tabla

- **Análisis de Comportamiento del Cliente**: Los indicadores como `repeated_phone_24H` y `cause_recall_phone_24H` son esenciales para entender las interacciones repetitivas y planificar estrategias de retención.
  
- **Segmentación del Cliente**: Campos como `customer_segment` y `ivr_language` son vitales para realizar una segmentación más precisa de la base de clientes.

# Creación de la Tabla `ivr_summary` en SQL

## Código SQL

```sql
CREATE TABLE keepcoding.ivr_summary AS
SELECT 
  d.calls_ivr_id AS ivr_id,
  d.calls_phone_number AS phone_number,
  d.calls_ivr_result AS ivr_result,
  CASE 
    WHEN STARTS_WITH(d.calls_vdn_label, 'ATC') THEN 'FRONT',
    WHEN STARTS_WITH(d.calls_vdn_label, 'TECH') THEN 'TECH',
    WHEN d.calls_vdn_label = 'ABSORPTION' THEN 'ABSORPTION',
    ELSE 'RESTO'
  END AS vdn_aggregation,
  MIN(d.calls_start_date) AS start_date,
  MAX(d.calls_end_date) AS end_date,
  TIMESTAMP_DIFF(MAX(d.calls_end_date), MIN(d.calls_start_date), SECOND) AS total_duration,
  d.calls_customer_segment AS customer_segment,
  d.calls_ivr_language AS ivr_language,
  COUNT(DISTINCT d.calls_steps_module) AS steps_module,
  STRING_AGG(DISTINCT d.calls_module_aggregation, ', ') AS module_aggregation,
  MAX(d.document_type) AS document_type,
  MAX(d.document_identification) AS document_identification,
  MAX(d.customer_phone) AS customer_phone,
  MAX(d.billing_account_id) AS billing_account_id,
  MAX(CASE WHEN d.module_name = 'AVERIA_MASIVA' THEN 1 ELSE 0 END) AS masiva_lg,
  MAX(CASE WHEN d.step_name = 'CUSTOMERINFOBYPHONE.TX' AND d.step_description_error IS NULL THEN 1 ELSE 0 END) AS info_by_phone_lg,
  MAX(CASE WHEN d.step_name = 'CUSTOMERINFOBYDNI.TX' AND d.step_description_error IS NULL THEN 1 ELSE 0 END) AS info_by_dni_lg,
  MAX(i.repeated_phone_24H) AS repeated_phone_24H,
  MAX(i.cause_recall_phone_24H) AS cause_recall_phone_24H
FROM 
  keepcoding.ivr_detail d
JOIN 
  keepcoding.ivr_intermediate i 
ON 
  d.calls_ivr_id = i.calls_ivr_id,
  d.calls_phone_number = i.calls_phone_number
GROUP BY 
  d.calls_ivr_id,
  d.calls_phone_number,
  d.calls_ivr_result,
  d.calls_vdn_label,
  d.calls_customer_segment,
  d.calls_ivr_language;
```
