DROP TABLE IF EXISTS cpu;
SELECT bpc.cores::INTEGER                                     as cores,
       bpc.cores::INTEGER * 2                                 AS threads,
       split_part(name, ' ', 1)::tipo_fabricante              AS fabricante,
       REPLACE(name, split_part(name, ' ', 1), '')            AS nome,
       product_line::TEXT                                     AS familia,
       (base_frequency::DECIMAL(8, 3) / 1000)::DECIMAL(6, 2)  AS clock_base,
       (turbo_frequency::DECIMAL(8, 3) / 1000)::DECIMAL(6, 2) AS clock_boost,
       launch_date::DATE                                      AS data_lancamento,
       lithography::INTEGER                                   AS litografia,
       bpc.tdp::DECIMAL(6, 2)                                 AS tdp,
       price::DECIMAL(10, 2)                                  AS preco,
       bpc.socket                                             AS socket
INTO cpu
FROM datasets.specification_cpu_amd as sca
         JOIN datasets.benchmark_passmark_cpu bpc on sca.name = bpc.cpuname

UNION ALL

SELECT DISTINCT ON (
    TRIM(
            REGEXP_REPLACE(
                    TRIM(split_part(name, ',', 1)),
                    '(?i)^([64bitmobileintel\-]+)\s+(([64bitmobileintel\-]+)\s+)?',
                    '',
                    'g'
            )
    )
    ) cores::INTEGER                                         AS cores,
      cores::INTEGER * 2                                     AS threads,

      CASE
          WHEN name ILIKE '%AMD%' THEN 'AMD'::tipo_fabricante
          WHEN name ILIKE '%INTEL%' THEN 'INTEL'::tipo_fabricante
          WHEN name ILIKE '%NVIDIA%' THEN 'NVIDIA'::tipo_fabricante
          WHEN UPPER(split_part(name, ' ', 1)) IN ('PENTIUM', '64-BIT', 'MOBILE', 'CELERON', 'XEON') THEN
              'INTEL'::tipo_fabricante
          END                                                AS fabricante,

      TRIM(
              REGEXP_REPLACE(
                      TRIM(split_part(name, ',', 1)),
                      '(?i)^([64bitmobileintel\-]+)\s+(([64bitmobileintel\-]+)\s+)?',
                      '',
                      'g'
              )
      )                                                      AS nome,
      product_line::TEXT                                     AS familia,
      (base_frequency::DECIMAL(8, 3) / 1000)::DECIMAL(6, 2)  AS clock_base,
      (turbo_frequency::DECIMAL(8, 3) / 1000)::DECIMAL(6, 2) AS clock_boost,
      launch_date::DATE                                      AS data_lancamento,
      lithography::INTEGER                                   AS litografia,
      tdp::DECIMAL(6, 2)                                     AS tdp,
      price::DECIMAL(10, 2)                                  AS preco,
      REPLACE(socket, 'FC', '')                              AS socket
FROM datasets.specification_cpu_intel;


UPDATE cpu
SET nome = 'Core i5-8500'
where nome = 'Core i5+8500 (9M Cache';

UPDATE cpu
SET nome = 'Core i5-8400'
where nome = 'Core i5+8400 (9M Cache';

UPDATE cpu
SET nome = 'Core i5-8700'
where nome = 'Core i7+8700 (12M Cache';

DELETE
FROM cpu
where fabricante IS NULL;

SELECT *
FROM cpu;