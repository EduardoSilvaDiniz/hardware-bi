DO
$$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_fabricante') THEN
            CREATE TYPE tipo_fabricante AS ENUM ('NVIDIA', 'INTEL', 'AMD', 'ATI');
        END IF;
    END
$$;