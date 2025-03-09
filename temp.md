-- Write your PostgreSQL query statement below
WITH unbanned AS (
    SELECT *
    FROM Users
    WHERE banned = 'No'
),

cancelled AS (
    SELECT *
    FROM Trips
    WHERE LEFT(status, 3) LIKE 'can'
)

SELECT t.request_at AS "Day", ROUND(COUNT(c.id)::numeric / COUNT(t.id), 2) AS "Cancellation Rate"
FROM Trips t LEFT JOIN cancelled c
    ON t.id = c.id
WHERE t.client_id IN (SELECT users_id FROM unbanned) 
    AND t.driver_id IN (SELECT users_id FROM unbanned)
    AND t.request_at BETWEEN '2013-10-01' AND '2013-10-03'
GROUP BY t.request_at