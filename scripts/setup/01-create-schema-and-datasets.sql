DROP SCHEMA IF EXISTS datasets cascade;
DROP SCHEMA IF EXISTS public cascade;
CREATE SCHEMA IF NOT EXISTS datasets;
CREATE SCHEMA IF NOT EXISTS public;
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

DROP TABLE IF EXISTS datasets.steam_survey;
CREATE TABLE datasets.steam_survey
(
    date       TEXT,
    category   TEXT,
    name       TEXT,
    change     TEXT,
    percentage TEXT
);

DROP TABLE IF EXISTS datasets.fabricantes_semicondutores;
CREATE TABLE IF NOT EXISTS datasets.fabricantes_semicondutores (
    empresa TEXT,
    planta_tipo TEXT,
    cidade TEXT,
    pais TEXT,
    latitude TEXT,
    longitude TEXT
);
