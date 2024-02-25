SELECT
    COALESCE(SUM(cumulative_score_value), 0) AS cumulative_score
FROM (VALUES
        ('critical', 55),
        ('error',    25),
        ('warning',  12),
        ('notice',    3)
    ) AS t(check_level, cumulative_score_value)
    INNER JOIN (
-- >>> db_verifier
) AS r ON t.check_level = r.check_level
;
