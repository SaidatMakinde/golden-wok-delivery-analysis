-- 1. How many orders were placed, and how much recorded profit did they generate?

SELECT
    COUNT(*) AS total_orders,
    ROUND(SUM(order_value_ngn), 2) AS total_order_value,
    ROUND(SUM(order_profit_ngn), 2) AS total_recorded_profit,
    ROUND(AVG(order_profit_ngn), 2) AS profit_per_order
FROM fact_orders;



-- 2. How many orders arrived late, and what percentage of orders were late?

SELECT
    COUNT(*) AS total_orders,
    SUM(
        CASE
            WHEN actual_delivery_min > promised_delivery_min
            THEN 1 ELSE 0
        END
    ) AS late_orders,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN actual_delivery_min > promised_delivery_min
                THEN 1 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_delivery_percentage
FROM fact_orders;



-- 3. Which kitchen has the highest late-delivery percentage?

SELECT
    k.kitchen_name,
    COUNT(*) AS total_orders,
    SUM(
        CASE
            WHEN o.actual_delivery_min > o.promised_delivery_min
            THEN 1 ELSE 0
        END
    ) AS late_orders,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN o.actual_delivery_min > o.promised_delivery_min
                THEN 1 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_delivery_percentage
FROM fact_orders AS o
LEFT JOIN dim_kitchen AS k
    ON o.kitchen_id = k.kitchen_id
GROUP BY
    k.kitchen_id,
    k.kitchen_name
ORDER BY
    late_delivery_percentage DESC;



-- 4. How does delivery performance differ between zone tiers?

SELECT
    z.zone_tier,
    COUNT(*) AS total_orders,
    ROUND(AVG(1.0 * o.actual_delivery_min), 2) AS average_delivery_minutes,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN o.actual_delivery_min > o.promised_delivery_min
                THEN 1 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_delivery_percentage
FROM fact_orders AS o
LEFT JOIN dim_delivery_zone AS z
    ON o.zone_id = z.zone_id
GROUP BY
    z.zone_tier
ORDER BY
    late_delivery_percentage DESC;



-- 5. Are rush-hour orders more likely to arrive late?

SELECT
    CASE
        WHEN t.is_rush_hour = 1 THEN 'Yes'
        WHEN t.is_rush_hour = 0 THEN 'No'
    END AS rush_hour,

    COUNT(*) AS total_orders,

    ROUND(
        AVG(1.0 * o.actual_delivery_min),
        2
    ) AS average_delivery_minutes,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN o.actual_delivery_min > o.promised_delivery_min
                THEN 1 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_delivery_percentage

FROM fact_orders AS o

LEFT JOIN dim_time_slot AS t
    ON o.time_slot_id = t.time_slot_id

GROUP BY
    t.is_rush_hour

ORDER BY
    t.is_rush_hour;



-- 6. Do orders with higher traffic scores take longer to deliver?
-- These traffic groups are chosen for this analysis:
-- Low: up to 3. Medium: over 3 to 6. High: over 6.

WITH traffic_groups AS (
    SELECT
        actual_delivery_min,
        CASE
            WHEN traffic_friction_score <= 3 THEN 'Low'
            WHEN traffic_friction_score <= 6 THEN 'Medium'
            ELSE 'High'
        END AS traffic_level
    FROM fact_orders
)
SELECT
    traffic_level,
    COUNT(*) AS total_orders,
    ROUND(AVG(1.0 * actual_delivery_min), 2) AS average_delivery_minutes
FROM traffic_groups
GROUP BY
    traffic_level
ORDER BY
    average_delivery_minutes DESC;



-- 7. How do delivery time, traffic, and late deliveries differ by weather?

SELECT
    t.weather_condition,
    COUNT(*) AS total_orders,
    ROUND(AVG(1.0 * o.actual_delivery_min), 2) AS average_delivery_minutes,
    ROUND(AVG(o.traffic_friction_score), 2) AS average_traffic_score,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN o.actual_delivery_min > o.promised_delivery_min
                THEN 1 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_delivery_percentage
FROM fact_orders AS o
LEFT JOIN dim_time_slot AS t
    ON o.time_slot_id = t.time_slot_id
GROUP BY
    t.weather_condition
ORDER BY
    average_delivery_minutes DESC;



-- 8. How do delivery cost and recorded profit per order differ by distance?

WITH distance_groups AS (
    SELECT
        delivery_distance_km,
        delivery_cost_ngn,
        order_profit_ngn,
        CASE
            WHEN delivery_distance_km <= 4 THEN 'Up to 4 km'
            WHEN delivery_distance_km <= 8 THEN 'Over 4-8 km'
            WHEN delivery_distance_km <= 12 THEN 'Over 8-12 km'
            ELSE 'Over 12 km'
        END AS distance_band
    FROM fact_orders
)
SELECT
    distance_band,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_cost_ngn), 2) AS delivery_cost_per_order,
    ROUND(AVG(order_profit_ngn), 2) AS profit_per_order
FROM distance_groups
GROUP BY
    distance_band
ORDER BY
    MIN(delivery_distance_km);



-- 9. Are orders travelling more than 8 km making a loss?

SELECT
    COUNT(*) AS orders_over_8km,
    ROUND(AVG(order_profit_ngn), 2) AS profit_per_order,
    SUM(
        CASE
            WHEN order_profit_ngn < 0 THEN 1
            ELSE 0
        END
    ) AS loss_making_orders
FROM fact_orders
WHERE
    delivery_distance_km > 8;



-- 10. Which kitchen-to-zone routes have the lowest recorded profit per order?

WITH route_profit AS (
    SELECT
        k.kitchen_id,
        k.kitchen_name,
        z.zone_id,
        z.zone_name,
        COUNT(*) AS total_orders,
        AVG(o.order_profit_ngn) AS profit_per_order
    FROM fact_orders AS o
    LEFT JOIN dim_kitchen AS k
        ON o.kitchen_id = k.kitchen_id
    LEFT JOIN dim_delivery_zone AS z
        ON o.zone_id = z.zone_id
    GROUP BY
        k.kitchen_id,
        k.kitchen_name,
        z.zone_id,
        z.zone_name
)
SELECT
    kitchen_name,
    zone_id,
    zone_name,
    total_orders,
    ROUND(profit_per_order, 2) AS profit_per_order,
    RANK() OVER (
        ORDER BY profit_per_order ASC
    ) AS profit_rank
FROM route_profit
ORDER BY
    profit_rank;



-- 11. Do late orders receive lower customer ratings?

WITH delivery_groups AS (
    SELECT
        customer_rating,
        CASE
            WHEN actual_delivery_min > promised_delivery_min
            THEN 'Late'
            ELSE 'On time'
        END AS delivery_status
    FROM fact_orders
)
SELECT
    delivery_status,
    COUNT(*) AS total_orders,
    ROUND(AVG(customer_rating), 3) AS average_customer_rating
FROM delivery_groups
GROUP BY
    delivery_status;



-- 12. How do food temperature and customer ratings compare for deliveries
--     within and above 60 minutes?
-- Temperature readings above 100 C need checking. The temperature results
-- cannot reliably tell us whether longer deliveries lead to cold food.

WITH delivery_groups AS (
    SELECT
        food_temp_on_arrival_c,
        customer_rating,
        CASE
            WHEN actual_delivery_min <= 60
            THEN 'Within 60 minutes'
            ELSE 'Over 60 minutes'
        END AS delivery_group
    FROM fact_orders
)
SELECT
    delivery_group,
    COUNT(*) AS total_orders,
    ROUND(AVG(food_temp_on_arrival_c), 2) AS average_recorded_temperature,
    SUM(
        CASE
            WHEN food_temp_on_arrival_c < 45
            THEN 1 ELSE 0
        END
    ) AS recorded_temperatures_below_45,
    SUM(
        CASE
            WHEN food_temp_on_arrival_c > 100
            THEN 1 ELSE 0
        END
    ) AS temperatures_needing_review,
    ROUND(AVG(customer_rating), 3) AS average_customer_rating
FROM delivery_groups
GROUP BY
    delivery_group;

	