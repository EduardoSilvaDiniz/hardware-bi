CREATE SCHEMA IF NOT EXISTS datasets;
SET search_path TO datasets;

DROP TABLE IF EXISTS datasets.specification_gpu;
CREATE TABLE datasets.specification_gpu
(
    Brand                    TEXT,
    Name                     TEXT,
    GRAPHICS_PROCESSOR       TEXT,
    PIXEL_SHADERS            TEXT,
    VERTEX_SHADERS           TEXT,
    TMUS                     TEXT,
    ROPS                     TEXT,
    MEMORY_SIZE              TEXT,
    MEMORY_TYPE              TEXT,
    BUS_WIDTH                TEXT,
    GPU_Name                 TEXT,
    Architecture             TEXT,
    Process_Size             TEXT,
    Transistors              TEXT,
    Die_Size                 TEXT,
    Release_Date             TEXT,
    Generation               TEXT,
    Successor                TEXT,
    Production               TEXT,
    Bus_Interface            TEXT,
    GPU_Clock                TEXT,
    Memory_Clock             TEXT,
    Memory_Size_Detail       TEXT,
    Memory_Type_Detail       TEXT,
    Memory_Bus               TEXT,
    Bandwidth                TEXT,
    Pixel_Shaders_Detail     TEXT,
    Vertex_Shaders_Detail    TEXT,
    TMUs_Detail              TEXT,
    ROPs_Detail              TEXT,
    Pixel_Rate               TEXT,
    Texture_Rate             TEXT,
    Slot_Width               TEXT,
    TDP                      TEXT,
    Suggested_PSU            TEXT,
    Outputs                  TEXT,
    Board_Number             TEXT,
    DirectX                  TEXT,
    OpenGL                   TEXT,
    OpenCL                   TEXT,
    Vulkan                   TEXT,
    Pixel_Shader             TEXT,
    Vertex_Shader            TEXT,
    source_file              TEXT,
    Foundry                  TEXT,
    Predecessor              TEXT,
    Recommended_Resolutions  TEXT,
    Launch_Price             TEXT,
    Length                   TEXT,
    GPU_Variant              TEXT,
    Power_Connectors         TEXT,
    Density                  TEXT,
    Vertex_Rate              TEXT,
    Height                   TEXT,
    Weight                   TEXT,
    Width                    TEXT,
    Reviews                  TEXT,
    Inputs                   TEXT,
    Mobile_Release_Date      TEXT,
    Mobile_Generation        TEXT,
    Mobile_Production        TEXT,
    Mobile_Bus_Interface     TEXT,
    Mobile_Reviews           TEXT,
    Chip_Package             TEXT,
    Integrated_Release_Date  TEXT,
    Integrated_Generation    TEXT,
    Integrated_Production    TEXT,
    Integrated_Bus_Interface TEXT,
    Integrated_Reviews       TEXT,
    Mobile_Successor         TEXT,
    Mobile_Predecessor       TEXT,
    Base_Clock               TEXT,
    Boost_Clock              TEXT,
    Integrated_Successor     TEXT,
    Shader_Model             TEXT,
    CORES                    TEXT,
    Shading_Units            TEXT,
    Compute_Units            TEXT,
    L2_Cache                 TEXT,
    FP32_float               TEXT,
    FP64_double              TEXT,
    L1_Cache                 TEXT,
    Integrated_Predecessor   TEXT,
    IGP_Variants__List       TEXT,
    Integrated_Launch_Price  TEXT,
    Announced                TEXT,
    Storage                  TEXT,
    FP16_half                TEXT,
    Availability             TEXT,
    Part_Number              TEXT,
    Current_Price            TEXT,
    SOC_Clock                TEXT,
    Game_Clock               TEXT,
    Peak_Clock               TEXT,
    BIOS_Number              TEXT,
    UVD_Clock                TEXT,
    RT_Cores                 TEXT,
    L0_Cache                 TEXT,
    L3_Cache                 TEXT,
    MCM                      TEXT,
    Codename                 TEXT,
    MCD_Process              TEXT,
    Process_Type             TEXT,
    GCD_Transistors          TEXT,
    MCD_Transistors          TEXT,
    GCD_Density              TEXT,
    MCD_Density              TEXT,
    GCD_Die_Size             TEXT,
    MCD_Die_Size             TEXT,
    Shader_Clock             TEXT,
    Matrix_Cores             TEXT,
    Base_Storage             TEXT,
    GCD_Size                 TEXT,
    MCD_Size                 TEXT,
    Package_Size             TEXT,
    Mobile_Availability      TEXT,
    Integrated_Announced     TEXT,
    Execution_Units          TEXT,
    GPU_Generation           TEXT,
    XMX_Cores                TEXT,
    S_Spec                   TEXT,
    SM_Count                 TEXT,
    CUDA                     TEXT,
    CUDA_SDK                 TEXT,
    SMX_Count                TEXT,
    Mobile_Launch_Price      TEXT,
    SMM_Count                TEXT,
    Tensor_Cores             TEXT,
    BF16                     TEXT,
    TF32                     TEXT,
    FP64_Tensor              TEXT,
    NVENC                    TEXT,
    NVDEC                    TEXT,
    Mobile_Announced         TEXT
);

COPY datasets.specification_gpu FROM '/datasets/specifications/gpu_1986-2026.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

DROP TABLE IF EXISTS datasets.specification_cpu_amd;
CREATE TABLE datasets.specification_cpu_amd
(
    cores              TEXT,
    threads            TEXT,
    name               TEXT,
    launch_date        TEXT,
    lithography        TEXT,
    base_frequency     TEXT,
    turbo_frequency    TEXT,
    cache_l1           TEXT,
    cache_l2           TEXT,
    cache_l3           TEXT,
    tdp                TEXT,
    product_line       TEXT,
    socket             TEXT,
    memory_type        TEXT,
    url                TEXT,
    vertical_segment   TEXT,
    max_temp           TEXT,
    max_memory_speed   TEXT,
    opn_tray           TEXT,
    opn_pib            TEXT,
    revision           TEXT,
    first_mention_year TEXT,
    sku                TEXT
);

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


DROP TABLE IF EXISTS datasets.specification_cpu_intel;
CREATE TABLE datasets.specification_cpu_intel
(
    cores                         TEXT,
    threads                       TEXT,
    name                          TEXT,
    processor_number              TEXT,
    launch_date                   TEXT,
    lithography                   TEXT,
    bus_speed                     TEXT,
    base_frequency                TEXT,
    turbo_frequency               TEXT,
    configurable_tdp_up_frequency TEXT,
    cache_size                    TEXT,
    tdp                           TEXT,
    configurable_tdp_up           TEXT,
    price                         TEXT,
    product_line                  TEXT,
    socket                        TEXT,
    memory_type                   TEXT,
    url                           TEXT,
    vertical_segment              TEXT,
    max_memory_size               TEXT,
    status                        TEXT,
    max_temp                      TEXT,
    sku                           TEXT,
    package_size                  TEXT,
    fullname                      TEXT
);

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

DROP TABLE IF EXISTS datasets.benchmark_geekbench_gpu;
CREATE TABLE datasets.benchmark_geekbench_gpu
(
    Manufacturer TEXT,
    Device       TEXT,
    CUDA         TEXT,
    Metal        TEXT,
    OpenCL       TEXT,
    Vulkan       TEXT
);

COPY datasets.benchmark_geekbench_gpu FROM '/datasets/benchmarks/geekbench_gpus.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');

DROP TABLE IF EXISTS datasets.benchmark_passmark_cpu;
CREATE TABLE datasets.benchmark_passmark_cpu
(
    cpuName     TEXT,
    price       TEXT,
    cpuMark     TEXT,
    cpuValue    TEXT,
    threadMark  TEXT,
    threadValue TEXT,
    TDP         TEXT,
    powerPerf   TEXT,
    cores       TEXT,
    testDate    TEXT,
    socket      TEXT,
    category    TEXT
);

COPY datasets.benchmark_passmark_cpu FROM '/datasets/benchmarks/passmark_cpus.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');

DROP TABLE IF EXISTS datasets.benchmark_passmark_gpu;
CREATE TABLE datasets.benchmark_passmark_gpu
(
    gpuName          TEXT,
    G3Dmark          TEXT,
    G2Dmark          TEXT,
    price            TEXT,
    gpuValue         TEXT,
    TDP              TEXT,
    powerPerformance TEXT,
    testDate         TEXT,
    category         TEXT
);

COPY datasets.benchmark_passmark_gpu FROM '/datasets/benchmarks/passmark_gpus.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');

DROP TABLE IF EXISTS datasets.benchmark_cinebench_cpu;
CREATE TABLE datasets.benchmark_cinebench_cpu
(
    manufacturer TEXT,
    cpuName      TEXT,
    singleScore  TEXT,
    multiScore   TEXT,
    cores        TEXT,
    threads      TEXT,
    baseClock    TEXT,
    turboClock   TEXT,
    type         TEXT
);

COPY datasets.benchmark_cinebench_cpu FROM '/datasets/benchmarks/cinebench_cpus.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');

DROP TABLE IF EXISTS datasets.steam_survey;
CREATE TABLE datasets.steam_survey
(
    date       TEXT,
    category   TEXT,
    name       TEXT,
    change     TEXT,
    percentage TEXT
);

COPY datasets.steam_survey FROM '/datasets/search/steam-hardware-survey.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');

SELECT *
FROM datasets.specification_gpu;

SELECT *
FROM datasets.specification_cpu_intel;

SELECT *
FROM datasets.specification_cpu_amd;

SELECT *
FROM datasets.benchmark_cinebench_cpu;

SELECT *
FROM datasets.benchmark_passmark_gpu;

SELECT *
FROM datasets.benchmark_passmark_cpu;

SELECT *
FROM datasets.benchmark_geekbench_gpu;

SELECT *
FROM datasets.steam_survey;