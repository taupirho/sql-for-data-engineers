-- Pattern 4: compare tracked attributes with NULL-safe semantics.
SELECT
    s.customer_id,
    s.email,
    s.status,
    s.updated_at
FROM staging_customers AS s
JOIN dim_customers AS d
    ON s.customer_id = d.customer_id
WHERE s.email IS DISTINCT FROM d.email
   OR s.status IS DISTINCT FROM d.status
ORDER BY s.customer_id;

-- If IS DISTINCT FROM is unavailable in another SQL dialect, use a
-- dialect-appropriate NULL-safe comparison or carefully chosen sentinels.
