COPY datasets.specification_gpu FROM '/datasets/specifications/gpu_1986-2026.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
SELECT *
FROM datasets.specification_gpu;

COPY datasets.specification_cpu_intel FROM PROGRAM 'cut -d"," -f2- /datasets/specifications/intel_processors.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
COPY datasets.specification_cpu_intel (
                                       cores, threads, name, processor_number, launch_date,
                                       lithography, bus_speed, base_frequency, turbo_frequency,
                                       configurable_tdp_up_frequency, cache_size, tdp,
                                       configurable_tdp_up, price, product_line, socket,
                                       memory_type, url, vertical_segment, max_memory_size,
                                       status, max_temp, sku, package_size
    )
    FROM PROGRAM 'cut -d"," -f2- /datasets/specifications/intel_ark_processors.csv'
    WITH (FORMAT CSV, HEADER TRUE);
SELECT *
FROM datasets.specification_cpu_intel;

COPY datasets.specification_cpu_amd (cores, threads, name, launch_date, lithography, base_frequency,
                                     turbo_frequency, cache_l1, cache_l2, cache_l3, tdp, product_line, socket,
                                     memory_type, url, vertical_segment, max_temp, max_memory_speed,
                                     sku) FROM PROGRAM 'cut -d"," -f2- /datasets/specifications/amd_processors.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY datasets.specification_cpu_amd (
                                     name,
                                     base_frequency,
                                     tdp,
                                     max_temp,
                                     url,
                                     socket,
                                     product_line,
                                     lithography,
                                     opn_tray,
                                     opn_pib,
                                     revision,
                                     cache_l1,
                                     cache_l2,
                                     cache_l3,
                                     first_mention_year
    )
    FROM PROGRAM 'cut -d"," -f2- /datasets/specifications/amd_archive_processors.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
SELECT *
FROM datasets.specification_cpu_amd;

COPY datasets.benchmark_cinebench_cpu FROM '/datasets/benchmarks/cinebench_cpus.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
SELECT *
FROM datasets.benchmark_cinebench_cpu;

COPY datasets.benchmark_passmark_gpu FROM '/datasets/benchmarks/passmark_gpus.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
SELECT *
FROM datasets.benchmark_passmark_gpu;

COPY datasets.benchmark_passmark_cpu FROM '/datasets/benchmarks/passmark_cpus.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
SELECT *
FROM datasets.benchmark_passmark_cpu;

COPY datasets.benchmark_geekbench_gpu FROM '/datasets/benchmarks/geekbench_gpus.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
SELECT *
FROM datasets.benchmark_geekbench_gpu;

COPY datasets.steam_survey FROM '/datasets/search/steam-hardware-survey.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
SELECT *
FROM datasets.steam_survey;
