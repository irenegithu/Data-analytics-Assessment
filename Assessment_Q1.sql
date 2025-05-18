SELECT 
    u.id AS owner_id, 
    u.name, 
    COUNT(DISTINCT s.plan_id) AS savings_count, 
    COUNT(DISTINCT p.plan_id) AS investment_count, 
    (COALESCE(SUM(s.confirmed_amount - s.amount_withdrawn), 0) + 
     COALESCE(SUM(p.confirmed_amount - p.amount_withdrawn), 0)) / 100 AS total_deposits
FROM users_customuser u
JOIN savings_savingsaccount s 
    ON u.id = s.owner_id 
    AND s.is_regular_savings = 1 
    AND (s.confirmed_amount - s.amount_withdrawn) > 0
JOIN plans_plan p 
    ON u.id = p.owner_id 
    AND p.is_a_fund = 1 
    AND (p.confirmed_amount - p.amount_withdrawn) > 
GROUP BY u.id, u.name
ORDER BY total_deposits DESC;
