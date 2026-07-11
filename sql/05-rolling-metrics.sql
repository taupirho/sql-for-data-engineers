-- Pattern 5a: seven rows, which equals seven days only when dates are complete.
SELECT
    order_date,
    daily_revenue,
    SUM(daily_revenue) OVER (
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS seven_row_revenue
FROM daily_sales
ORDER BY order_date;

-- Pattern 5b: a true seven-calendar-day range over available records.
SELECT
    d.order_date,
    d.daily_revenue,
    (
        SELECT SUM(d2.daily_revenue)
        FROM daily_sales AS d2
        WHERE d2.order_date BETWEEN date(d.order_date, '-6 days')
                                 AND d.order_date
    ) AS seven_calendar_day_revenue
FROM daily_sales AS d
ORDER BY d.order_date;

-- Pattern 5c: a rolling operational signal.
SELECT
    order_date,
    order_count,
    AVG(order_count) OVER (
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS seven_row_average_orders
FROM daily_order_counts
ORDER BY order_date;
