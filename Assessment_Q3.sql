    SELECT 
        s.plan_id,
        s.owner_id,
        'Savings' AS type,
        MAX(s.transaction_date) AS last_transaction_date
    FROM savings_savingsaccount s
    WHERE s.is_regular_savings = 1
        AND (COALESCE(s.confirmed_amount, 0) > 0 OR COALESCE(s.amount_withdrawn, 0) > 0)
    GROUP BY s.plan_id, s.owner_id
    
    UNION ALL
    
    SELECT 
        p.plan_id,
        p.owner_id,
        'Investment' AS type,
        MAX(p.transaction_date) AS last_transaction_date
    FROM plans_plan p
    WHERE p.is_a_fund = 1
        AND (COALESCE(p.confirmed_amount, 0) > 0 OR COALESCE(p.amount_withdrawn, 0) > 0)
    GROUP BY p.plan_id, p.owner_id
)
SELECT 
    plan_id,
    owner_id,
    type,
    COALESCE(last_transaction_date, 'Never') AS last_transaction_date,
    CASE 
        WHEN last_transaction_date IS NOT NULL THEN DATE_PART('day', CURRENT_DATE - last_transaction_date)
        ELSE 365
    END AS inactivity_days
FROM Last_Transactions
WHERE 
    (last_transaction_date IS NULL OR last_transaction_date <= CURRENT_DATE - INTERVAL '365 days')
ORDER BY inactivity_days DESC;
