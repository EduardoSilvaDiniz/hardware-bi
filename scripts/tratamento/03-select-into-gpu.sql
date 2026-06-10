DROP TABLE IF EXISTS gpu;

SELECT if_exist_date(mobile_release_date)                                                 AS video_integrado,
       search_gpu_pro(name, brand)                                                        AS profissional,
       if_exist_date(integrated_release_date)                                             AS notebook,
       get_gpu_chip_count(memory_size)                                                              AS quantidade_chips,
       search_system_shared(memory_bus)                                                   AS memoria_compatilhada,
       UPPER(brand)::tipo_fabricante                                                      AS fabricante,
       clean_gpu_architecture(name)                                                           AS nome,
       clean_gpu_architecture(graphics_processor)                                             AS arquitetura,
       date_format(
               COALESCE(release_date, mobile_release_date, integrated_release_date)
       )                                                                                         AS data_de_lancamento,
       format_memory_size(memory_size)                                              AS tamanho_memoria_mb,
       format_memory_type(memory_type)                                             AS tipo_memoria,
       format_price(COALESCE(launch_price, mobile_launch_price, integrated_launch_price)) AS preço_em_dolar,
       format_clock(COALESCE(gpu_clock, base_clock))                                      AS clock_mhz,
       TRIM(split_part(boost_clock, ' ', 1))::NUMERIC                                           AS clock_boost,
       format_memory_bus(memory_bus)                                                      AS barramento_memoria_bit,
       format_bandwidth(bandwidth)                                                        AS largura_banda_mb_segundo,
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
       split_part(NULLIF(tdp, 'unknown'), ' ', 1)::NUMERIC                                      AS tdp_watts
INTO gpu
FROM datasets.specification_gpu
where UPPER(brand) IN ('NVIDIA', 'AMD', 'INTEL', 'ATI');

SELECT * FROM gpu;

SELECT * FROM datasets.specification_gpu;

SELECT quantidade_chips, fabricante, nome, name, graphics_processor FROM gpu JOIN datasets.specification_gpu AS spec_gpu ON  UPPER(spec_gpu.name) = nome;