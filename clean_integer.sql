CREATE OR REPLACE FUNCTION dataset_name.clean_integer(input INT64) AS (
  IFNULL(input, -999999)
);