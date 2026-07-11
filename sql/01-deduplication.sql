-- Pattern 1: retain the winning version for each business key.
WITH ranked_customers AS (
    SELECT
        customer_id,
        email,
        status,
        updated_at,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY
                updated_at IS NULL,
                updated_at DESC,
                ingestion_time DESC,
                source_row_id DESC
        ) AS row_num
    FROM raw_customers
)
SELECT
    customer_id,
    email,
    status,
    updated_at
FROM ranked_customers
WHERE row_num = 1
ORDER BY customer_id;
