-- Pattern 2: find source keys that are absent from the target.
SELECT
    s.tenant_id,
    s.order_id,
    s.order_date,
    s.customer_id
FROM source_orders AS s
WHERE NOT EXISTS (
    SELECT 1
    FROM fact_orders AS f
    WHERE f.tenant_id = s.tenant_id
      AND f.order_id = s.order_id
)
ORDER BY s.tenant_id, s.order_id;
