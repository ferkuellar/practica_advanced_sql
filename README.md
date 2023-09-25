# Proyecto de Analítica de Interacción con IVR (Respuesta de Voz Interactiva)

## Objetivo del Proyecto

El objetivo principal del proyecto es desarrollar un modelo de datos robusto y eficiente que permita analizar y comprender las interacciones del cliente a través del sistema IVR (Respuesta de Voz Interactiva).

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

### Tabla de Resumen (`ivr_summary`)

A partir de la tabla detallada, se genera una tabla de resumen que recopila indicadores clave de rendimiento (KPIs) y otros datos relevantes por llamada.

### Funciones de Limpieza

Para manejar valores nulos y otros problemas de calidad de datos, se implementan funciones de limpieza, como `clean_integer`.

### Indicadores de Comportamiento del Cliente

Se introducen campos como `repeated_phone_24H` y `cause_recall_phone_24H` para rastrear el comportamiento del cliente, lo que es crucial para futuras estrategias de atención al cliente.

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

# Documentación de la Función `clean_integer`

## Descripción General

La función `clean_integer` es una función SQL personalizada diseñada para manejar valores enteros que pueden ser nulos. En caso de recibir un valor `NULL`, la función devuelve un valor predeterminado de `-999999`.

## Definición de la Función

La función se define de la siguiente manera en SQL:

```sql
CREATE OR REPLACE FUNCTION keepcoding.clean_integer(input_value INT64) 
RETURNS INT64 
AS (
  IF(input_value IS NULL, -999999, input_value)
);
```

# Documentación de la Función `clean_integer`

## Descripción General

La función `clean_integer` es una función SQL personalizada diseñada para tratar valores enteros que pueden ser nulos. Si se recibe un valor `NULL`, la función devuelve un valor predeterminado de `-999999`.

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
