SELECT 
    u.id AS customer_id,
    u.name,
    DATE_PART('month', AGE(CURRENT_DATE, u.signup_date)) AS tenure_months,
    COUNT(s.id) AS total_transactions,
    ROUND(
        (COUNT(s.id) / NULLIF(DATE_PART('month', AGE(CURRENT_DATE, u.signup_date)), 0)) * 12 * (0.001 * SUM(COALESCE(s.confirmed_amount, 0))),
        2
    ) AS estimated_clv
FROM users_customuser u
LEFT JOIN savings_savingsaccount s 
    ON u.id = s.owner_id
GROUP BY u.id, u.name, u.signup_date
HAVING COUNT(s.id) > 0
ORDER BY estimated_clv DESC;
