SET search_path TO datasets;

SELECT spec_gpu.brand, spec_gpu.name
FROM datasets.specification_gpu as spec_gpu
         JOIN datasets.benchmark_passmark_gpu as pass_gpu ON spec_gpu.name = pass_gpu.gpuname
         JOIN datasets.benchmark_geekbench_gpu AS geek_gpu ON spec_gpu.name = geek_gpu.device;

SELECT COALESCE(brand, 'Total Geral') as brand, count(*) as total
FROM datasets.specification_gpu as spec_gpu
WHERE brand ilike '%nvidia%'
   OR brand ilike '%amd%'
   OR brand ilike '%intel%'
GROUP BY ROLLUP (brand);

DROP TABLE IF EXISTS gpus_silver;
SELECT CASE
           WHEN mobile_release_date IS NOT NULL THEN true
           ELSE FALSE
           END                                                              AS apu,
       TRUE                                                                 AS profissional,
       CASE
           WHEN integrated_release_date IS NOT NULL THEN true
           ELSE FALSE
           END                                                              AS mobile,
       CASE
           WHEN name ilike '%x2%' THEN TRUE
           ELSE FALSE
           END                                                              AS dual_gpu,
       brand                                                                AS fabricante,
       CASE
           WHEN name ilike '%x2%' THEN REPLACE(name, 'X2', '')
           ELSE name
           END                                                              AS nome,
       CASE
           WHEN graphics_processor ilike '%x2%' THEN replace(graphics_processor, 'x2', '')
           ELSE graphics_processor
           END                                                              AS geracao,
       limpar_date(
               COALESCE(release_date, mobile_release_date, integrated_release_date)
       )                                                                    AS data_de_lancamento,
       CASE
           WHEN memory_size ILIKE '%x2%' THEN
               (SPLIT_PART(memory_size, ' ', 1)::numeric * 2)::text || split_part(memory_size, ' ', 2)
           ELSE memory_size
           END                                                              AS tamanho_memoria,
       memory_type                                                          AS tipo_memoria,
       COALESCE(launch_price, mobile_launch_price, integrated_launch_price) as valor,
       gpu_clock,
       memory_clock,
       NULLIF(mobile_generation, 'unknown')                                 AS tdp
INTO gpus_silver
FROM datasets.specification_gpu
WHERE (brand ILIKE '%nvidia%'
    OR brand ILIKE '%amd%'
    OR brand ILIKE '%intel%')

  AND name NOT ILIKE '%firepro%'
  AND name NOT ILIKE '%instinct%'
  AND name NOT ILIKE '%xeon phi%'
  AND name NOT ILIKE '%arc pro%'
  AND name NOT ILIKE '%radeon pro%'
  AND name NOT ILIKE '%quadro%'
  AND NOT (brand ILIKE '%nvidia%' AND
           (name ILIKE 'rtx a%'
               OR name ILIKE 'rtx pro%'
               OR name ILIKE 'h100%'
               OR name ILIKE 'h200%'
               OR name ILIKE 'tesla%'))

UNION ALL

SELECT CASE
           WHEN mobile_release_date IS NOT NULL THEN true
           ELSE FALSE
           END                                                              AS apu,
       TRUE                                                                 AS profissional,
       CASE
           WHEN integrated_release_date IS NOT NULL THEN true
           ELSE FALSE
           END                                                              AS mobile,
       CASE
           WHEN name ilike '%x2%' THEN TRUE
           ELSE FALSE
           END                                                              AS dual_gpu,
       brand                                                                AS fabricante,
       CASE
           WHEN name ilike '%x2%' THEN REPLACE(name, 'X2', '')
           ELSE name
           END                                                              AS nome,
       CASE
           WHEN graphics_processor ilike '%x2%' THEN replace(graphics_processor, 'x2', '')
           ELSE graphics_processor
           END                                                              AS geracao,
       limpar_date(
               COALESCE(release_date, mobile_release_date, integrated_release_date)
       )                                                                    AS data_de_lancamento,
       CASE
           WHEN memory_size ILIKE '%x2%' THEN
               (SPLIT_PART(memory_size, ' ', 1)::numeric * 2)::text || split_part(memory_size, ' ', 2)
           ELSE memory_size
           END                                                              AS tamanho_memoria,
       memory_type                                                          AS tipo_memoria,
       COALESCE(launch_price, mobile_launch_price, integrated_launch_price) as valor,
       gpu_clock,
       memory_clock,
       NULLIF(mobile_generation, 'unknown')                                 AS tdp
FROM datasets.specification_gpu
WHERE name ILIKE '%quadro%'
   OR name ILIKE '%firepro%'
   OR name ILIKE '%instinct%'
   OR name ILIKE '%xeon phi%'
   OR name ILIKE '%arc pro%'
   OR name ILIKE '%radeon pro%'
   OR (brand ILIKE '%nvidia%' AND
       (name ILIKE 'rtx a%' OR name ILIKE 'rtx pro%' OR name ILIKE 'h100%' OR name ILIKE 'h200%' OR
        name ILIKE 'tesla%'))
    AND name NOT ILIKE '%geforce%'
    AND name NOT ILIKE '%riva%';

SELECT OR REPLACE FUNCTION datasets.limpar_date(texto_data TEXT)
    RETURNS DATE AS $$
BEGIN
    RETURN CASE
        -- 1. '2010'
               WHEN texto_data ~ '^\d{4}$'
                   THEN TO_DATE(texto_data || '-01-01', 'YYYY-MM-DD')
        -- 2. 'Sep 2015'
               WHEN texto_data ~ '^[A-Za-z]{3}\s+\d{4}$'
                   THEN TO_DATE(UPPER(REGEXP_REPLACE(texto_data, '\s+', ' 01 ')), 'MON DD YYYY')

        -- 3.  'Sep 5th, 2015'
               WHEN texto_data ~ '^[A-Za-z]{3}\s'
                   THEN TO_DATE(UPPER(texto_data), 'MON DDTH, YYYY')

        -- 4. 'September 5th, 2015'
               WHEN texto_data ~ '^[A-Za-z]'
                   THEN TO_DATE(UPPER(texto_data), 'MONTH DDTH, YYYY')
        END;
END;
$$ LANGUAGE plpgsql;