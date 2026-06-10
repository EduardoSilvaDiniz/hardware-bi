CREATE OR REPLACE FUNCTION date_format(texto_data TEXT)
    RETURNS DATE AS
$$
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

CREATE OR REPLACE FUNCTION if_exist_date(release_date TEXT)
    RETURNS BOOLEAN AS
$$
BEGIN
    RETURN
        CASE
            WHEN release_date IS NOT NULL THEN true
            ELSE FALSE
            END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_gpu_chip_count(gpu_name TEXT)
    RETURNS SMALLINT AS
$$
DECLARE
    nome_limpo TEXT := UPPER(gpu_name);
BEGIN
    IF nome_limpo ILIKE '%X4%' THEN
        RETURN 4;

    ELSIF nome_limpo ILIKE '%X2%' THEN
        RETURN 2;

    ELSE
        RETURN 1;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION clean_gpu_architecture(gpu_name TEXT)
    RETURNS TEXT AS
$$
DECLARE
    nome_processado TEXT := UPPER(gpu_name);
BEGIN
    IF nome_processado ILIKE '%X4%'
        OR nome_processado ILIKE '%X2%'
        OR nome_processado ILIKE '%MOBILE%' THEN

        nome_processado := REPLACE(nome_processado, 'X4', '');
        nome_processado := REPLACE(nome_processado, 'X2', '');
        nome_processado := REPLACE(nome_processado, 'MOBILE', '');

        RETURN TRIM(REGEXP_REPLACE(nome_processado, '\s+', ' ', 'g'));
    END IF;

    RETURN nome_processado;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION format_memory_size(memory_size TEXT)
    RETURNS DECIMAL AS
$$
DECLARE
    texto_tratado TEXT;
BEGIN
    texto_tratado := CASE
                         WHEN memory_size ILIKE '%System Shared%' THEN NULL

                         WHEN memory_size ILIKE '%x2%' OR memory_size ILIKE '%x4%' THEN
                             (SPLIT_PART(memory_size, ' ', 1)::NUMERIC)::TEXT || ' ' ||
                             SPLIT_PART(memory_size, ' ', 2)

                         ELSE memory_size
        END;

    IF texto_tratado IS NULL THEN
        RETURN NULL;
    END IF;

    texto_tratado := TRIM(texto_tratado);

    RETURN CASE
               WHEN texto_tratado ILIKE '%GB%' THEN
                   REPLACE(texto_tratado, 'GB', '')::NUMERIC * 1024

               WHEN texto_tratado ILIKE '%MB%' THEN
                   REPLACE(texto_tratado, 'MB', '')::NUMERIC
        END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION format_clock(clock TEXT)
    RETURNS NUMERIC AS
$$
BEGIN
    RETURN CASE
               WHEN clock ILIKE '%System Shared%' THEN NULL
               ELSE
                   split_part(clock, ' ', 1)::NUMERIC
        END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION format_effective(clock TEXT)
    RETURNS NUMERIC AS
$$
DECLARE
    texto_tratado TEXT;
BEGIN
    texto_tratado := CASE
                         WHEN clock ILIKE '%effective%' THEN
                             SPLIT_PART(clock, ' ', 3) || ' ' || split_part(clock, ' ', 4)
        END;
    IF texto_tratado IS NULL THEN
        RETURN NULL;
    END IF;

    texto_tratado := TRIM(texto_tratado);

    RETURN CASE
               WHEN texto_tratado ILIKE '%GB%' THEN
                   (REPLACE(UPPER(texto_tratado), 'GBPS', '')::NUMERIC) * 1024

               WHEN texto_tratado ILIKE '%MB%' THEN
                   REPLACE(UPPER(texto_tratado), 'MBPS', '')::NUMERIC

               ELSE
                   texto_tratado::NUMERIC
        END;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION format_price(price TEXT)
    RETURNS NUMERIC AS
$$
BEGIN
    RETURN REPLACE(REPLACE(price, 'USD', ''), ',', '')::DECIMAL(10, 2);
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION format_memory_type(memory_type TEXT)
    RETURNS TEXT AS
$$
BEGIN
    RETURN CASE
               WHEN memory_type ILIKE '%System Shared%' THEN NULL
               ELSE
                   memory_type
        END;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_system_shared(input TEXT)
    RETURNS BOOLEAN AS
$$
BEGIN
    RETURN CASE
               WHEN input ILIKE '%System Shared%' THEN TRUE
               ELSE
                   FALSE
        END;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION format_key_word(input TEXT)
    RETURNS TEXT AS
$$
BEGIN
    RETURN CASE
               WHEN input ILIKE '%System Shared%' THEN NULL
               WHEN input ILIKE '%System Dependent%' THEN NULL
               ELSE
                   input
        END;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_gpu_pro(gpu_name TEXT, brand TEXT)
    RETURNS BOOLEAN AS
$$
BEGIN
    RETURN CASE
               WHEN (
                        gpu_name ILIKE '%quadro%'
                            OR gpu_name ILIKE '%firepro%'
                            OR gpu_name ILIKE '%instinct%'
                            OR gpu_name ILIKE '%xeon phi%'
                            OR gpu_name ILIKE '%arc pro%'
                            OR gpu_name ILIKE '%radeon pro%'
                            OR (brand ILIKE '%nvidia%' AND (
                            gpu_name ILIKE 'rtx a%'
                                OR gpu_name ILIKE 'rtx pro%'
                                OR gpu_name ILIKE 'h100%'
                                OR gpu_name ILIKE 'h200%'
                                OR gpu_name ILIKE 'tesla%'
                            ))
                        )
                   AND gpu_name NOT ILIKE '%geforce%'
                   AND gpu_name NOT ILIKE '%riva%'
                   THEN TRUE
               ELSE FALSE
        END;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION convert_to_gflops(input TEXT)
    RETURNS NUMERIC AS
$$
DECLARE
    partes_texto   TEXT[];
    valor_texto    TEXT;
    valor_numerico NUMERIC;
BEGIN
    partes_texto := string_to_array(input, ' ');

    valor_texto := REPLACE(partes_texto[1], ',', '');

    valor_numerico := valor_texto::NUMERIC;

    IF partes_texto[2] ILIKE '%T%' THEN
        valor_numerico := valor_numerico * 1000;
    END IF;

    RETURN valor_numerico;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_flops_calc(input TEXT)
    RETURNS TEXT AS
$$
DECLARE
BEGIN
    RETURN CASE
               WHEN input ILIKE '%:%' THEN
                   REGEXP_REPLACE(split_part(input, ' ', 3), '[()]', '', 'g')
        END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION format_core(input TEXT)
    RETURNS NUMERIC AS
$$
DECLARE
BEGIN
    RETURN CASE
               WHEN input ILIKE '%x2%' THEN
                   split_part(input, ' ', 1)::NUMERIC
               WHEN input ILIKE '%x4%' THEN
                   split_part(input, ' ', 1)::NUMERIC
               else input::NUMERIC
        END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION format_memory_bus(input TEXT)
    RETURNS NUMERIC AS
$$
DECLARE
    input_clean TEXT;
BEGIN
    input_clean := format_key_word(input);
    RETURN TRIM(split_part(input_clean, ' ', 1))::NUMERIC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION format_bandwidth(input TEXT)
    RETURNS NUMERIC AS
$$
DECLARE
    input_clean    TEXT;
    partes_texto   TEXT[];
    valor_numerico NUMERIC;
BEGIN
    input_clean := format_key_word(input);
    partes_texto := string_to_array(input_clean, ' ');
    valor_numerico := partes_texto[1];

    IF partes_texto[2] ILIKE '%GB%' THEN
        valor_numerico := valor_numerico * 1024;
    END IF;

    IF partes_texto[2] ILIKE '%TB%' THEN
        valor_numerico := valor_numerico * 1024 * 1024;
    END IF;

    RETURN valor_numerico;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION extract_ram_type(memory_text TEXT)
    RETURNS TEXT AS
$$
DECLARE
    texto_limpo TEXT := UPPER(memory_text);
    resultado TEXT;
BEGIN
    resultado := substring(texto_limpo FROM '(LPDDR\d[A-Z]?|DDR\d[A-Z]?)');

    IF resultado IS NULL THEN
        resultado := substring(texto_limpo FROM '(DDR\d)');
    END IF;

    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION format_amd_cache(l1 INT, l2 INT, l3 INT)
    RETURNS TEXT AS
$$
DECLARE
    resultado TEXT := '';
BEGIN
    IF l1 IS NOT NULL AND l1 > 0 THEN
        resultado := resultado || 'L1: ' || l1 || ' KB';
    END IF;

    IF l2 IS NOT NULL AND l2 > 0 THEN
        IF resultado <> '' THEN resultado := resultado || ' | '; END IF;

        IF l2 >= 1024 THEN
            resultado := resultado || 'L2: ' || (l2 / 1024) || ' MB';
        ELSE
            resultado := resultado || 'L2: ' || l2 || ' KB';
        END IF;
    END IF;

    IF l3 IS NOT NULL AND l3 > 0 THEN
        IF resultado <> '' THEN resultado := resultado || ' | '; END IF;

        IF l3 >= 1024 THEN
            resultado := resultado || 'L3: ' || (l3 / 1024) || ' MB';
        ELSE
            resultado := resultado || 'L3: ' || l3 || ' KB';
        END IF;
    END IF;

    IF resultado = '' THEN
        RETURN NULL;
    END IF;

    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_cpu_type(segment_text TEXT)
    RETURNS TEXT AS
$$
DECLARE
    texto_limpo TEXT := UPPER(TRIM(segment_text));
BEGIN
    IF segment_text IS NULL OR texto_limpo = '' THEN
        RETURN NULL;
    END IF;

    RETURN CASE
        WHEN texto_limpo LIKE '%SERVER%'
          OR texto_limpo LIKE '%WORKSTATION%' THEN 'Servidor'

        WHEN texto_limpo LIKE '%LAPTOP%'
          OR texto_limpo LIKE '%MOBILE%'
          OR texto_limpo LIKE '%TABLE%' THEN 'Notebook'

        WHEN texto_limpo LIKE '%EMBEDDED%' THEN 'Embarcado'

        WHEN texto_limpo LIKE '%DESKTOP%'
          OR texto_limpo LIKE '%BOXED%'
          OR texto_limpo LIKE '%ALL-IN-ONE%' THEN 'Desktop'

        ELSE INITCAP(segment_text)
    END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION clean_cpu_name(raw_name TEXT)
    RETURNS TEXT AS
$$
DECLARE
    nome_limpo TEXT := TRIM(raw_name);
    modelo TEXT;
    clock TEXT;
BEGIN
    IF raw_name IS NULL OR nome_limpo = '' THEN
        RETURN NULL;
    END IF;


    clock := substring(nome_limpo FROM '(?i)(\d+(?:\.\d+)?\s*[GM]Hz)');

    modelo := CASE
        WHEN nome_limpo ~* 'Core\s+i\d\+\d+' THEN
            substring(nome_limpo FROM '(?i)(Intel\s+Core\s+i\d\+\d+)')

        WHEN nome_limpo ~* 'Xeon' THEN
            CASE
                WHEN nome_limpo ~* 'Pentium\s+III\s+Xeon' THEN 'Intel Pentium III Xeon'
                WHEN nome_limpo ~* 'Pentium\s+II\s+Xeon' THEN 'Intel Pentium II Xeon'
                ELSE 'Intel Xeon'
            END

        WHEN nome_limpo ~* 'Itanium' THEN 'Intel Itanium'

        WHEN nome_limpo ~* 'Celeron' THEN
            CASE
                WHEN nome_limpo ~* 'Mobile\s+Intel\s+Celeron' THEN 'Mobile Intel Celeron'
                WHEN nome_limpo ~* 'Celeron\s+M' THEN 'Intel Celeron M'
                ELSE 'Intel Celeron'
            END

        WHEN nome_limpo ~* 'Pentium' THEN
            CASE
                WHEN nome_limpo ~* 'Mobile\s+Intel\s+Pentium\s+4\s*-\s*M' THEN 'Mobile Intel Pentium 4 - M'
                WHEN nome_limpo ~* 'Mobile\s+Intel\s+Pentium\s+III\s*-\s*M' THEN 'Mobile Intel Pentium III - M'
                WHEN nome_limpo ~* 'Mobile\s+Intel\s+Pentium\s+III' THEN 'Mobile Intel Pentium III'
                WHEN nome_limpo ~* 'Mobile\s+Intel\s+Pentium\s+II' THEN 'Mobile Intel Pentium II'
                WHEN nome_limpo ~* 'Pentium\s+M\s+ULV' THEN 'Intel Pentium M ULV'
                WHEN nome_limpo ~* 'Pentium\s+M\s+LV' THEN 'Intel Pentium M LV'
                WHEN nome_limpo ~* 'Pentium\s+M' THEN 'Intel Pentium M'
                WHEN nome_limpo ~* 'Pentium\s+Pro' THEN 'Intel Pentium Pro'
                WHEN nome_limpo ~* 'MMX' THEN 'Intel Pentium w/ MMX'
                WHEN nome_limpo ~* 'Pentium\s+4' THEN 'Intel Pentium 4'
                WHEN nome_limpo ~* 'Pentium\s+III' THEN 'Intel Pentium III'
                ELSE 'Intel Pentium'
            END

        ELSE split_part(nome_limpo, '(', 1)
    END;

    IF modelo IS NULL THEN
        RETURN NULL;
    END IF;

    IF clock IS NOT NULL THEN
        RETURN TRIM(modelo) || ' (' || LOWER(TRIM(clock)) || ')';
    ELSE
        RETURN TRIM(modelo);
    END IF;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_fabricante_by_name(processor_name TEXT)
    RETURNS tipo_fabricante AS
$$
DECLARE
    nome_limpo TEXT := TRIM(processor_name);
    primeira_palavra TEXT;
BEGIN
    IF processor_name IS NULL OR nome_limpo = '' THEN
        RETURN NULL;
    END IF;

    primeira_palavra := UPPER(split_part(nome_limpo, ' ', 1));

    RETURN CASE
        WHEN nome_limpo ~* 'AMD'    THEN 'AMD'::tipo_fabricante
        WHEN nome_limpo ~* 'INTEL'  THEN 'INTEL'::tipo_fabricante
        WHEN nome_limpo ~* 'NVIDIA' THEN 'NVIDIA'::tipo_fabricante

        WHEN primeira_palavra IN ('PENTIUM', '64-BIT', 'MOBILE', 'CELERON', 'XEON')
                                    THEN 'INTEL'::tipo_fabricante
    END;
END;
$$ LANGUAGE plpgsql;