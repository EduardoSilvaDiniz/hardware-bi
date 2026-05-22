DROP TABLE IF EXISTS gpu;

SELECT if_exist_date(mobile_release_date)                                                 AS apu,
       search_gpu_pro(name, brand)                                                        AS profissional,
       if_exist_date(integrated_release_date)                                             AS mobile,
       search_dual_gpu(name)                                                              AS dual_gpu,
       search_system_shared(memory_bus)                                                   AS memoria_compatilhada,
       UPPER(brand)::tipo_fabricante                                                      AS fabricante,
       replace_x2_to_none(name)                                                           AS nome,
       replace_x2_to_none(graphics_processor)                                             AS geracao,
       date_format(
               COALESCE(release_date, mobile_release_date, integrated_release_date)
       )                                                                                  AS data_de_lancamento,
       format_memory_size(memory_size)                                                    AS tamanho_memoria_mb,
       format_memory_type(memory_type)                                                    AS tipo_memoria,
       format_price(COALESCE(launch_price, mobile_launch_price, integrated_launch_price)) as valor_usd,
       format_clock(COALESCE(gpu_clock, base_clock))                                      AS clock_mhz,
       TRIM(split_part(boost_clock, ' ', 1))::NUMERIC                                     AS clock_boost,
       format_memory_bus(memory_bus)                                                        AS barramento_memoria_bit,
       format_bandwidth(bandwidth)                                                         AS largura_banda_mb_segundo,
       shading_units::NUMERIC,
       compute_units::NUMERIC,
       format_core(cores)                                                                 AS cores,
       shader_clock,
       convert_to_gflops(fp16_half)                                                       AS fp16_half_gflops,
       get_flops_calc(fp16_half)                                                          AS fp16_half_calc,
       convert_to_gflops(fp32_float)                                                      AS fp32_float_gflops,
       convert_to_gflops(fp64_double)                                                     AS fp64_double_gflops,
       get_flops_calc(fp64_double)                                                        AS fp64_double_calc,
       convert_to_gflops(fp64_tensor)                                                     AS fp64_tensor_gflops,
       get_flops_calc(fp64_tensor)                                                        AS fp64_tensor_calc,
       format_clock(memory_clock)                                                         AS memory_clock_mhz,
       format_effective(memory_clock)                                                     AS effective_memory_mbps,
       NULLIF(tdp, 'unknown')                                                             AS tdp
INTO gpu
FROM datasets.specification_gpu
where UPPER(brand) IN ('NVIDIA', 'AMD', 'INTEL', 'ATI');

SELECT *
FROM gpu;
