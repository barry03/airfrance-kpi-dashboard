-- Petite exploration
SELECT COUNT(*) FROM flights2023;
SELECT * FROM ref_aircraft LIMIT 5;


--KPI 1 : Calcul du taux de ponctualité (vols partis avec ≤ 15 min de retard)--
-- Filtrage des vols avec date réelle de départ exploitable
WITH vols_valides AS (
    SELECT *
    FROM all_flights
    WHERE LEG_ACT_DEP_DATE_UTC IS NOT NULL
      AND LEG_ACT_DEP_DATE_UTC ~ '^\d{2}/\d{2}/\d{4}$'
),

-- Calcul des timestamps théoriques et réels et écart en minutes
vols_avec_retard AS (
    SELECT 
        FLIGHT_CARRIER_CODE,
        FLIGHT_NUMBER,
        LEG_SCH_DEP_DATE_UTC,
        CAST(LEG_SCH_DEP_TIME_UTC AS TIME) AS heure_dep_theorique,
        CAST(STRPTIME(LEG_ACT_DEP_DATE_UTC, '%d/%m/%Y') AS DATE) AS date_dep_reelle,
        CAST(LEG_ACT_DEP_TIME_UTC AS TIME) AS heure_dep_reelle,

        -- Timestamps combinés
        LEG_SCH_DEP_DATE_UTC + CAST(LEG_SCH_DEP_TIME_UTC AS TIME) AS ts_theorique,
        CAST(STRPTIME(LEG_ACT_DEP_DATE_UTC, '%d/%m/%Y') AS DATE) + CAST(LEG_ACT_DEP_TIME_UTC AS TIME) AS ts_reel,

        -- Calcul du retard
        DATE_DIFF('minute',
            LEG_SCH_DEP_DATE_UTC + CAST(LEG_SCH_DEP_TIME_UTC AS TIME),
            CAST(STRPTIME(LEG_ACT_DEP_DATE_UTC, '%d/%m/%Y') AS DATE) + CAST(LEG_ACT_DEP_TIME_UTC AS TIME)
        ) AS retard_minutes
    FROM vols_valides
),

-- Agrégation pour calculer la ponctualité
indicateurs_ponctualite AS (
    SELECT 
        COUNT(*) AS total_vols,
        COUNT(*) FILTER (WHERE retard_minutes <= 15) AS vols_ponctuels
    FROM vols_avec_retard
)
-- Résultat final : nombre de vols, nombre à l’heure, % de ponctualité
SELECT 
    total_vols,
    vols_ponctuels,
    ROUND(vols_ponctuels * 100.0 / total_vols, 2) AS taux_ponctualite_percent
FROM indicateurs_ponctualite;


------------- KPI 1 : Evolution mensuelle de la ponctualité au départ (retards ≤ 15 minutes)-----------
WITH vols_filtrés AS (
    SELECT *
    FROM all_flights
    WHERE LEG_ACT_DEP_DATE_UTC IS NOT NULL
      AND LEG_ACT_DEP_DATE_UTC ~ '^\d{2}/\d{2}/\d{4}$'
),
-- Calcul du retard en minutes et extraction du mois (YYYY-MM)
retards_par_vol AS (
    SELECT 
        LEG_SCH_DEP_DATE_UTC,
        STRFTIME(LEG_SCH_DEP_DATE_UTC, '%Y-%m') AS mois,
        DATE_DIFF(
            'minute',
            LEG_SCH_DEP_DATE_UTC + CAST(LEG_SCH_DEP_TIME_UTC AS TIME),
            CAST(STRPTIME(LEG_ACT_DEP_DATE_UTC, '%d/%m/%Y') AS DATE) + CAST(LEG_ACT_DEP_TIME_UTC AS TIME)
        ) AS retard_minutes
    FROM vols_filtrés
)
-- Agrégation mensuelle des retards
SELECT 
    mois,
    COUNT(*) AS nb_vols,
    COUNT(*) FILTER (WHERE retard_minutes <= 15) AS nb_vols_ponctuels,
    ROUND(COUNT(*) FILTER (WHERE retard_minutes <= 15) * 100.0 / COUNT(*), 2) AS taux_ponctualite_percent
FROM retards_par_vol
GROUP BY mois
ORDER BY mois;


--------------------------KPI 2 : Retard moyen regroupé par type d’appareil------------------
WITH vols_arrivées_valides AS (
    SELECT *
    FROM all_flights
    WHERE LEG_ACT_ARR_DATE_UTC IS NOT NULL
      AND LEG_ACT_ARR_DATE_UTC ~ '^\d{2}/\d{2}/\d{4}$'
),
-- Calcul du retard d’arrivée (heure réelle - heure prévue)
retards_arrivée_par_vol AS (
    SELECT 
        FLIGHT_CARRIER_CODE,
        FLIGHT_NUMBER,
        DATE_DIFF(
            'minute',
            LEG_SCH_ARR_DATE_UTC + CAST(LEG_SCH_ARR_TIME_UTC AS TIME),
            CAST(STRPTIME(LEG_ACT_ARR_DATE_UTC, '%d/%m/%Y') AS DATE) + CAST(LEG_ACT_ARR_TIME_UTC AS TIME)
        ) AS retard_arrivée_minutes
    FROM vols_arrivées_valides
),
-- Ajout du type d’appareil via la table de référence
vols_avec_type_appareil AS (
    SELECT 
        f.*,
        r.AIRCRAFT_TYPE
    FROM retards_arrivée_par_vol f
    LEFT JOIN ref_aircraft r
      ON f.FLIGHT_CARRIER_CODE = r.FLIGHT_CARRIER_CODE
     AND f.FLIGHT_NUMBER = r.FLIGHT_NUMBER
)
-- Agrégation par type d’appareil
SELECT 
    AIRCRAFT_TYPE,
    COUNT(*) AS nb_vols,
    ROUND(AVG(retard_arrivée_minutes), 2) AS retard_moyen_minutes
FROM vols_avec_type_appareil
WHERE AIRCRAFT_TYPE IS NOT NULL
GROUP BY AIRCRAFT_TYPE
ORDER BY retard_moyen_minutes DESC;


-------KPI 3 : causes de retard les plus fréquentes sur les vols nationaux-----------

-- Sélection des vols nationaux France -> France
WITH vols_nationaux AS (
    SELECT f.*
    FROM all_flights f
    JOIN flat_airports dep ON f.LEG_SCH_DEP_AIRPORT = dep.AIRPORT_CODE
    JOIN flat_airports arr ON f.LEG_SCH_ARR_AIRPORT = arr.AIRPORT_CODE
    WHERE dep.COUNTRY_NAME = 'France'
      AND arr.COUNTRY_NAME = 'France'
),
-- Transformation des colonnes multiples de codes retard en lignes (flatten)
codes_retards_explosés AS (
    SELECT LEG_DELAY_CODE_1 AS code FROM vols_nationaux WHERE LEG_DELAY_CODE_1 IS NOT NULL
    UNION ALL
    SELECT LEG_DELAY_CODE_2 FROM vols_nationaux WHERE LEG_DELAY_CODE_2 IS NOT NULL
    UNION ALL
    SELECT LEG_DELAY_CODE_3 FROM vols_nationaux WHERE LEG_DELAY_CODE_3 IS NOT NULL
    UNION ALL
    SELECT LEG_DELAY_CODE_4 FROM vols_nationaux WHERE LEG_DELAY_CODE_4 IS NOT NULL
    UNION ALL
    SELECT LEG_DELAY_CODE_5 FROM vols_nationaux WHERE LEG_DELAY_CODE_5 IS NOT NULL
),

-- Comptage du nombre d'occurrences par code de retard
comptage_retards AS (
    SELECT 
        TRIM(code) AS code, 
        COUNT(*) AS nb_occurrences
    FROM codes_retards_explosés
    GROUP BY TRIM(code)
),
-- Jointure avec la table de référence pour récupérer les libellés
causes_avec_libelle AS (
    SELECT 
        c.code, 
        c.nb_occurrences, 
        r.LIB_CSE_DLY_FRA AS libelle
    FROM comptage_retards c
    LEFT JOIN ref_delay r 
      ON LPAD(c.code, 3, '0') = LPAD(r.COD_CSE_DLY, 3, '0')
)
-- Extraction du top 3
SELECT *
FROM causes_avec_libelle
ORDER BY nb_occurrences DESC
LIMIT 3;
