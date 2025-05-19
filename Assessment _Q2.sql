WITH TransactionsPerMonth AS (
    SELECT 
        s.owner_id AS customer_id,
        DATE_TRUNC('month', s.transaction_date) AS month,
        COUNT(*) AS transaction_count
    FROM savings_savingsaccount s
    WHERE s.savings_plan = 1 
        AND (COALESCE(s.confirmed_amount, 0) > 0 OR COALESCE(s.amount_withdrawn, 0) > 0)
    GROUP BY s.owner_id, DATE_TRUNC('month', s.transaction_date)
),
AvgTransactions AS (
    SELECT 
        customer_id,
        AVG(transaction_count) AS avg_transactions_per_month
    FROM TransactionsPerMonth
    GROUP BY customer_id
)
SELECT 
    CASE 
        WHEN COALESCE(a.avg_transactions_per_month, 0) >= 10 THEN 'High Frequency'
        WHEN COALESCE(a.avg_transactions_per_month, 0) BETWEEN 3 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    COUNT(u.id) AS customer_count,
    ROUND(AVG(COALESCE(a.avg_transactions_per_month, 0)), 1) AS avg_transactions_per_month
FROM users_customuser u
LEFT JOIN AvgTransactions a ON u.id = a.customer_id
GROUP BY frequency_category
ORDER BY 
    CASE 
        WHEN frequency_category = 'High Frequency' THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        ELSE 3
    END;
