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

CREATE OR REPLACE FUNCTION search_dual_gpu(gpu_name TEXT)
    RETURNS BOOLEAN AS
$$
BEGIN
    RETURN array_length(string_to_array(UPPER(gpu_name), 'X2'), 1) = 2;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION replace_x2_to_none(name TEXT)
    RETURNS TEXT AS
$$
BEGIN
    RETURN CASE
               WHEN name ILIKE '%x2%' THEN REPLACE(REPLACE(UPPER(name), 'X2', ''), 'MOBILE', '')
               WHEN name ILIKE '%mobile%' THEN REPLACE(UPPER(name), 'MOBILE', '')
               ELSE name
        END;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION format_memory_size(memory_size TEXT)
    RETURNS DECIMAL AS
$$
DECLARE
    texto_tratado TEXT;
BEGIN
    texto_tratado := CASE
                         WHEN memory_size ILIKE '%System Shared%' THEN NULL

                         WHEN memory_size ILIKE '%x2%' THEN
                             (SPLIT_PART(memory_size, ' ', 1)::NUMERIC * 2)::TEXT || ' ' ||
                             SPLIT_PART(memory_size, ' ', 2)

                         WHEN memory_size ILIKE '%x4%' THEN
                             (SPLIT_PART(memory_size, ' ', 1)::NUMERIC * 4)::TEXT || ' ' ||
                             SPLIT_PART(memory_size, ' ', 2)

                         ELSE memory_size
        END;

    IF texto_tratado IS NULL THEN
        RETURN NULL;
    END IF;

    texto_tratado := TRIM(texto_tratado);

    RETURN CASE
               WHEN texto_tratado ILIKE '%GB%' THEN
                   (REPLACE(UPPER(texto_tratado), 'GB', '')::DECIMAL(12, 2)) * 1024

               WHEN texto_tratado ILIKE '%MB%' THEN
                   REPLACE(UPPER(texto_tratado), 'MB', '')::DECIMAL(12, 2)

               ELSE
                   texto_tratado::NUMERIC
        END;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION format_clock(clock TEXT)
    RETURNS NUMERIC AS
$$
BEGIN
    RETURN CASE
               WHEN clock ILIKE '%System Shared%' THEN NULL
               ELSE
                   (string_to_array(clock, ' '))[1]::NUMERIC
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
                         ELSE NULL
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
                   split_part(input, ' ', 1)::NUMERIC * 2
               WHEN input ILIKE '%x4%' THEN
                   split_part(input, ' ', 1)::NUMERIC * 4
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
    input_clean TEXT;
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

