DROP TABLE  IF EXISTS pesquisa_valve;
WITH PctInicialPorAno AS (
    -- 1. Tratamos o Infinity no valor inicial
    SELECT DISTINCT ON (EXTRACT(YEAR FROM date::DATE), category, name)
        EXTRACT(YEAR FROM date::DATE) AS ano,
        category,
        name,
        CASE
            WHEN percentage::TEXT = 'Infinity' OR percentage::TEXT = '-Infinity' THEN 0
            ELSE percentage::NUMERIC
        END AS pct_inicial
    FROM datasets.steam_survey
    ORDER BY EXTRACT(YEAR FROM date::DATE), category, name, date::DATE ASC
),
SomasMensais AS (
    -- 2. Tratamos o Infinity nas somas mensais (usando change_limpo)
    SELECT
        EXTRACT(YEAR FROM date::DATE) AS ano,
        category,
        name,
        ROUND(SUM(CASE WHEN EXTRACT(MONTH FROM date::DATE) = 1 THEN change_limpo ELSE 0 END), 4) AS jan,
        ROUND(SUM(CASE WHEN EXTRACT(MONTH FROM date::DATE) = 2 THEN change_limpo ELSE 0 END), 4) AS fev,
        ROUND(SUM(CASE WHEN EXTRACT(MONTH FROM date::DATE) = 3 THEN change_limpo ELSE 0 END), 4) AS mar,
        ROUND(SUM(CASE WHEN EXTRACT(MONTH FROM date::DATE) = 4 THEN change_limpo ELSE 0 END), 4) AS abr,
        ROUND(SUM(CASE WHEN EXTRACT(MONTH FROM date::DATE) = 5 THEN change_limpo ELSE 0 END), 4) AS mai,
        ROUND(SUM(CASE WHEN EXTRACT(MONTH FROM date::DATE) = 6 THEN change_limpo ELSE 0 END), 4) AS jun,
        ROUND(SUM(CASE WHEN EXTRACT(MONTH FROM date::DATE) = 7 THEN change_limpo ELSE 0 END), 4) AS jul,
        ROUND(SUM(CASE WHEN EXTRACT(MONTH FROM date::DATE) = 8 THEN change_limpo ELSE 0 END), 4) AS ago,
        ROUND(SUM(CASE WHEN EXTRACT(MONTH FROM date::DATE) = 9 THEN change_limpo ELSE 0 END), 4) AS set,
        ROUND(SUM(CASE WHEN EXTRACT(MONTH FROM date::DATE) = 10 THEN change_limpo ELSE 0 END), 4) AS out,
        ROUND(SUM(CASE WHEN EXTRACT(MONTH FROM date::DATE) = 11 THEN change_limpo ELSE 0 END), 4) AS nov,
        ROUND(SUM(CASE WHEN EXTRACT(MONTH FROM date::DATE) = 12 THEN change_limpo ELSE 0 END), 4) AS dez,
        SUM(change_limpo) AS total_change_bruto
    FROM (
        -- Subquery para limpar o 'change' antes de fazer o SUM
        SELECT
            date, category, name,
            CASE
                WHEN change::TEXT = 'Infinity' OR change::TEXT = '-Infinity' THEN 0
                ELSE change::NUMERIC
            END AS change_limpo
        FROM datasets.steam_survey
    ) sub
    GROUP BY EXTRACT(YEAR FROM date::DATE), category, name
)
-- 3. Juntamos tudo com segurança para o Java ler
SELECT
    s.ano,
    s.category,
    s.name,
    ROUND(p.pct_inicial, 4) AS pct_inicial,
    s.jan, s.fev, s.mar, s.abr, s.mai, s.jun, s.jul, s.ago, s.set, s.out, s.nov, s.dez,
    ROUND(p.pct_inicial + s.total_change_bruto, 4) AS total_change_ano
INTO pesquisa_valve
FROM SomasMensais s
JOIN PctInicialPorAno p ON s.ano = p.ano AND s.category = p.category AND s.name = p.name
ORDER BY s.ano, s.category, s.name;

SELECT * FROM pesquisa_valve;
