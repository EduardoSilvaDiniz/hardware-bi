DROP TABLE IF EXISTS cpu;
SELECT get_cpu_type(sca.vertical_segment)                                        AS tipo_cpu,
       bpc.cores::SMALLINT                                                       AS cores,
       sca.threads::SMALLINT                                                     AS threads,
       split_part(name, ' ', 1)::tipo_fabricante                                 AS fabricante,
       REPLACE(name, split_part(name, ' ', 1), '')                               AS nome,
       product_line::TEXT                                                        AS modelo,
       (base_frequency::DECIMAL(8, 3) / 1000)::DECIMAL(6, 2)                     AS clock_base,
       (turbo_frequency::DECIMAL(8, 3) / 1000)::DECIMAL(6, 2)                    AS clock_boost,
       launch_date::DATE                                                         AS data_lancamento,
       lithography::SMALLINT                                                     AS litografia,
       extract_ram_type(sca.memory_type)                                         AS tipo_memoria,
       price::DECIMAL(10, 2)                                                     AS preço_em_dolar,
       format_amd_cache(sca.cache_l1::INT, sca.cache_l2::INT, sca.cache_l3::INT) as tamanho_cache,
       bpc.socket                                                                AS socket,
       max_temp                                                                  AS temp_maxima,
       bpc.tdp::SMALLINT                                                         AS tdp_watts
INTO cpu
FROM datasets.specification_cpu_amd as sca
         JOIN datasets.benchmark_passmark_cpu bpc on sca.name = bpc.cpuname

UNION ALL

SELECT get_cpu_type(vertical_segment)                         AS tipo_cpu,
       cores::SMALLINT                                        AS cores,
       threads::SMALLINT                                      AS threads,
       CASE
           WHEN name ILIKE '%AMD%' THEN 'AMD'::tipo_fabricante
           WHEN name ILIKE '%INTEL%' THEN 'INTEL'::tipo_fabricante
           WHEN name ILIKE '%NVIDIA%' THEN 'NVIDIA'::tipo_fabricante
           WHEN UPPER(split_part(name, ' ', 1)) IN ('PENTIUM', '64-BIT', 'MOBILE', 'CELERON', 'XEON') THEN
               'INTEL'::tipo_fabricante
           END                                                AS fabricante,

       name                                                   AS nome,
       product_line::TEXT                                     AS modelo,
       (base_frequency::DECIMAL(8, 3) / 1000)::DECIMAL(6, 2)  AS clock_base,
       (turbo_frequency::DECIMAL(8, 3) / 1000)::DECIMAL(6, 2) AS clock_boost,
       launch_date::DATE                                      AS data_lancamento,
       lithography::SMALLINT                                  AS litografia,
       extract_ram_type(memory_type)                          AS tipo_memoria,
       price::DECIMAL(10, 2)                                  AS preço_em_dolar,
       cache_size                                             as tamanho_cache,
       REPLACE(socket, 'FC', '')                              AS socket,
       max_temp                                               AS temp_maxima,
       tdp::DECIMAL(6, 2)                                     AS tdp_watts
FROM datasets.specification_cpu_intel;


--UPDATE cpu
--SET nome = 'Core i5-8500'
--where nome = 'Core i5+8500 (9M Cache';
--
--UPDATE cpu
--SET nome = 'Core i5-8400'
--where nome = 'Core i5+8400 (9M Cache';
--
--UPDATE cpu
--SET nome = 'Core i5-8700'
--where nome = 'Core i7+8700 (12M Cache';
--
--DELETE
--FROM cpu
--where fabricante IS NULL;

SELECT *
FROM cpu;

select *
FROM datasets.specification_cpu_intel;
select *
FROM datasets.specification_cpu_amd;
