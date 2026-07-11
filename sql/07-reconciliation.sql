-- Pattern 7a: compare high-level source and target measures.
SELECT
    'source_orders' AS table_name,
    COUNT(*) AS row_count,
    MAX(updated_at) AS latest_update
FROM source_orders
UNION ALL
SELECT
    'fact_orders' AS table_name,
    COUNT(*) AS row_count,
    MAX(updated_at) AS latest_update
FROM fact_orders;

-- Pattern 7b: compare business-level aggregates.
SELECT
    'source_orders' AS table_name,
    COUNT(*) AS row_count,
    COUNT(DISTINCT tenant_id || ':' || order_id) AS distinct_orders,
    ROUND(SUM(order_total), 2) AS total_revenue,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM source_orders
WHERE order_date >= '2026-07-01'
UNION ALL
SELECT
    'fact_orders' AS table_name,
    COUNT(*) AS row_count,
    COUNT(DISTINCT tenant_id || ':' || order_id) AS distinct_orders,
    ROUND(SUM(order_total), 2) AS total_revenue,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM fact_orders
WHERE order_date >= '2026-07-01';

-- Pattern 7c: anti-joins find missing and unexpected keys.
SELECT 'missing_from_target' AS issue, s.tenant_id, s.order_id
FROM source_orders AS s
WHERE NOT EXISTS (
    SELECT 1 FROM fact_orders AS f
    WHERE f.tenant_id = s.tenant_id AND f.order_id = s.order_id
)
UNION ALL
SELECT 'unexpected_in_target' AS issue, f.tenant_id, f.order_id
FROM fact_orders AS f
WHERE NOT EXISTS (
    SELECT 1 FROM source_orders AS s
    WHERE s.tenant_id = f.tenant_id AND s.order_id = f.order_id
)
ORDER BY issue, tenant_id, order_id;

-- Pattern 7d: joined comparison finds changed non-key values.
SELECT
    s.tenant_id,
    s.order_id,
    s.order_total AS source_order_total,
    f.order_total AS target_order_total,
    s.status AS source_status,
    f.status AS target_status
FROM source_orders AS s
JOIN fact_orders AS f
    ON f.tenant_id = s.tenant_id
   AND f.order_id = s.order_id
WHERE s.order_total IS DISTINCT FROM f.order_total
   OR s.status IS DISTINCT FROM f.status
ORDER BY s.tenant_id, s.order_id;
