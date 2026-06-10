DROP TABLE IF EXISTS cpu;
SELECT get_cpu_type(sca.vertical_segment)                                        AS tipo_cpu,
       bpc.cores::SMALLINT                                                       AS cores,
       sca.threads::SMALLINT                                                     AS threads,
       split_part(name, ' ', 1)::tipo_fabricante                                 AS fabricante,
       clean_cpu_name(name)                                                      AS nome,
       NULLIF(product_line::TEXT, '')                                                AS modelo,
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
       get_fabricante_by_name(name)                           AS fabricante,
       clean_cpu_name(name)                                   AS nome,
       NULLIF(product_line::TEXT, '')                             AS modelo,
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

SELECT *
FROM cpu;