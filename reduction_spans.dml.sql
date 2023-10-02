-- Build CTEs in sequence, adding one or two columns per CTE.

WITH

-- Add a sequence number per entity, called 'observation_num'.
observation_by_entity AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY entity ORDER BY year) AS observation_num
    FROM life_expectancy
),

-- Add max year per entity, called 'last_year_for_entity', along with a dummy row to
-- allow for correct calculations of life expectency reductions that end with the last 
-- year of data.
max_year_for_entity AS (
    SELECT *,
        (
            SELECT MAX(year)
            FROM observation_by_entity ss
            WHERE ss.entity = le.entity
        ) AS last_year_for_entity
    FROM observation_by_entity le

    UNION ALL

    SELECT
        entity,
        'dummy' AS code,
        MAX(year) + 1 AS year,
        MAX(life_expectancy) + 1 AS life_expectancy,
        MAX(observation_num) + 1 AS observation_num,
        MAX(year) + 1 AS last_year_for_entity
    FROM observation_by_entity
    GROUP BY entity
),

-- Add a boolean indicator of whether current observation is a reduction in life expectancy from the
-- prior, 'reduction'.  Also add the prior observation year, which is used to calculate span of years 
-- in sequence of years with life expectancy reductions, called 'prior_observation_year'.
-- Since this query compares two adjacent observations, inserting only the 2nd, the 1st year per 
-- entity is unioned in to avoid loss of data.
reduction AS (
    SELECT newer.*,
        CASE WHEN newer.life_expectancy < older.life_expectancy THEN TRUE ELSE FALSE END AS reduction,
        older.year AS prior_observation_year
    FROM max_year_for_entity newer
    JOIN max_year_for_entity older ON newer.entity = older.entity
    AND newer.year = (
        SELECT MIN(le.year)
        FROM max_year_for_entity le
        WHERE le.entity = older.entity
        AND le.year > older.year
    )

    UNION ALL

    SELECT *, FALSE, NULL
    FROM max_year_for_entity le
    WHERE year = (
        SELECT MIN(year)
        FROM life_expectancy ss
        WHERE le.entity = ss.entity
    )
),

-- Add a column indicating the first year of life expectancy increase after an observation of reductionj, 
-- 'first_increase_after_reduction'.  This is used to find the last observation in a series of reductions.
-- As with the 'reduction' cte, the first observation row is added back in due to the newer/older logic of the
-- first query.
first_increase_after_reduction AS (
    SELECT newer.*,
        CASE WHEN (newer.reduction = FALSE AND older.reduction = TRUE) THEN TRUE ELSE FALSE END AS first_increase_after_reduction
    FROM reduction newer
    JOIN reduction older ON newer.entity = older.entity
    AND newer.year = (
        SELECT MIN(le.year)
        FROM reduction le
        WHERE le.entity = older.entity
        AND le.year > older.year
    )

    UNION ALL

    SELECT *, FALSE
    FROM reduction le
    WHERE year = (
        SELECT MIN(year)
        FROM life_expectancy ss
        WHERE le.entity = ss.entity
    )
),

-- Add the last observation number, 'last_obs_in_sequence', per reduction observation sequence.
-- This column is needed to get the last year per sequence below.  Two CTEs are used due to
-- limitations with duckdb.
last_obs_in_sequence AS (
    SELECT le.*,
        CASE WHEN le.reduction = TRUE THEN MIN(obs.observation_num) - 1 ELSE NULL END AS last_obs_in_sequence
    FROM first_increase_after_reduction le
    LEFT JOIN first_increase_after_reduction obs ON le.entity = obs.entity
        AND obs.year > le.year
        AND obs.first_increase_after_reduction = TRUE
    GROUP BY le.entity, le.code, le.year, le.life_expectancy, le.observation_num, le.reduction, 
        le.first_increase_after_reduction, le.prior_observation_year, le.last_year_for_entity
    ORDER BY le.year
),

-- Add 'last_year_in_sequence', flagging the last observation row in a sequence of reductions.
last_year_in_sequence AS (
    SELECT *,
        (
            SELECT year
            FROM last_obs_in_sequence ss
            WHERE ss.observation_num = last_obs_in_sequence.last_obs_in_sequence
            AND ss.entity = last_obs_in_sequence.entity
        ) AS last_year_in_sequence
    FROM last_obs_in_sequence
),

-- Calculate the number of years, 'span', per sequence of reductions.
span AS (
    SELECT *,
        last_year_in_sequence - prior_observation_year AS span
    FROM last_year_in_sequence
),

-- Calculate the number of individual observations per span, 'observations_in_span'.  This is
-- used to determine whether the span observations were consecutive or skipped year.
observations_in_span AS (
    SELECT *,
        (
            SELECT COUNT(*)
            FROM span ss
            WHERE ss.year BETWEEN le.prior_observation_year AND le.last_year_in_sequence
            AND ss.entity = le.entity
            AND ss.reduction = TRUE
        ) AS observations_in_span
    FROM span le
),

-- Add a boolean 'span_has_gaps' column, indicating whether this span is contiguous ('FALSE')
-- in years, or skipps years ('TRUE').
span_gaps AS (
    SELECT *,
        CASE WHEN span > observations_in_span THEN TRUE ELSE FALSE END AS span_has_gaps
    FROM observations_in_span
),

-- Transform the above CTE data into a form useful for analysis.

transformed as (
SELECT entity, year AS first_year_in_sequence, last_year_in_sequence, span, observations_in_span, span_has_gaps,
    ROW_NUMBER() OVER (PARTITION by entity ORDER by span desc ) as rownum
FROM span_gaps le
WHERE le.span = (
        SELECT MAX(span)
        FROM span_gaps ss
        WHERE ss.entity = le.entity
    )
)

insert into reduction_spans
select entity, first_year_in_sequence, last_year_in_sequence, span, observations_in_span, span_has_gaps 
from transformed where rownum = 1 order by entity 

