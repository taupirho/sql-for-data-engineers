-- Pattern 3: reread a one-hour overlap so late-arriving rows can be retried.
-- The target write must be idempotent, for example via event_id as a key.
SELECT
    event_id,
    user_id,
    event_type,
    event_timestamp
FROM source_events
WHERE event_timestamp >= (
    SELECT COALESCE(
        datetime(MAX(event_timestamp), '-1 hour'),
        '1900-01-01 00:00:00'
    )
    FROM target_events
)
ORDER BY event_timestamp, event_id;
