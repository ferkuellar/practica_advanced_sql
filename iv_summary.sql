CREATE TABLE keepcoding.ivr_summary AS

SELECT
  -- Campos directos de ivr_detail
  calls_ivr_id AS ivr_id,
  MAX(calls_phone_number) AS phone_number,
  MAX(calls_ivr_result) AS ivr_result,
  MAX(calls_start_date_id) AS start_date,
  MAX(calls_end_date_id) AS end_date,
  SUM(calls_total_duration) AS total_duration,
  MAX(calls_customer_segment) AS customer_segment,
  MAX(calls_ivr_language) AS ivr_language,
  COUNT(DISTINCT calls_steps_module) AS steps_module,
  STRING_AGG(DISTINCT calls_module_aggregation, ', ') AS module_aggregation,
  MAX(document_type) AS document_type,
  MAX(document_identification) AS document_identification,
  MAX(customer_phone) AS customer_phone,
  MAX(billing_account_id) AS billing_account_id,

  -- Campo calculado vdn_aggregation
  CASE
    WHEN MAX(calls_vdn_label) LIKE 'ATC%' THEN 'FRONT'
    WHEN MAX(calls_vdn_label) LIKE 'TECH%' THEN 'TECH'
    WHEN MAX(calls_vdn_label) = 'ABSORPTION' THEN 'ABSORPTION'
    ELSE 'RESTO'
  END AS vdn_aggregation,

  -- Flags calculados
  MAX(CASE WHEN module_name = 'AVERIA_MASIVA' THEN 1 ELSE 0 END) AS masiva_lg,
  MAX(CASE WHEN step_name = 'CUSTOMERINFOBYPHONE.TX' AND step_description_error IS NULL THEN 1 ELSE 0 END) AS info_by_phone_lg,
  MAX(CASE WHEN step_name = 'CUSTOMERINFOBYDNI.TX' AND step_description_error IS NULL THEN 1 ELSE 0 END) AS info_by_dni_lg
  
FROM keepcoding.ivr_detail

GROUP BY
  calls_ivr_id;