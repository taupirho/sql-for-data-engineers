-- Pattern 6: start a new session after more than 30 minutes of inactivity.
-- event_id makes tied event timestamps deterministic.
WITH ordered_events AS (
    SELECT
        event_id,
        user_id,
        event_time,
        event_type,
        LAG(event_time) OVER (
            PARTITION BY user_id
            ORDER BY event_time, event_id
        ) AS previous_event_time
    FROM web_events
),
flagged_events AS (
    SELECT
        event_id,
        user_id,
        event_time,
        event_type,
        CASE
            WHEN previous_event_time IS NULL THEN 1
            WHEN event_time > datetime(previous_event_time, '+30 minutes') THEN 1
            ELSE 0
        END AS new_session_flag
    FROM ordered_events
)
SELECT
    event_id,
    user_id,
    event_time,
    event_type,
    new_session_flag,
    SUM(new_session_flag) OVER (
        PARTITION BY user_id
        ORDER BY event_time, event_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS session_number
FROM flagged_events
ORDER BY user_id, event_time, event_id;
