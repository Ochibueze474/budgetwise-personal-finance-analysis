-- ============================================================
-- BudgetWise Personal Finance Analysis
-- Database:     budgetwise_db
-- Primary Table: budgetwise_finance (real data)
-- Author:       Chibueze
-- Description:  11 Business Questions with Real Data Insights and Recommendations
-- Note:  All queries run against budgetwise_finance only.  budgetwise_synthetic is excluded from  all business analysis.
-- ============================================================


-- ============================================================
-- QUESTION 1
-- What are the top spending categories and how much do users spend in each?
-- ------------------------------------------------------------

SELECT
    category,
    COUNT(*)  AS total_transactions,
    SUM(amount)   AS total_spent,
    ROUND(AVG(amount), 2)  AS avg_transaction,
    ROUND(SUM(amount) * 100.0 /
        SUM(SUM(amount)) OVER (), 2)  AS percentage_of_total
FROM 
 budgetwise_finance
WHERE 
 transaction_type = 'Expense'
GROUP BY 
 category
ORDER BY 
  total_spent
DESC;

-- ============================================================

-- INSIGHT:
-- Rent is the single largest expense category accounting for 42.39% of all user spending with a total of 27,199,708 across 1,937 transactions and an average transaction value of 14,042.
-- Food ranks second at 14.43% with 9,259,102 across 2,470 transactions making it the most frequent expense despite having the lowest average transaction value of 3,749.
-- Travel ranks third at 11.58% with 7,432,383.
-- Together Rent, Food and Travel account for 68.4% of all user expenses leaving only 31.6% for everything else including Health, Education and Savings.
-- The Savings category is critically low at just 2.36% of total spending, thats a major concern for long-term financial health.
--
-- RECOMMENDATION:
-- BudgetWise should display a category spending breakdown
-- on each user's dashboard highlighting their top 3
-- categories as a percentage of total spending. Users
-- where Rent alone exceeds 40% of their income should
-- receive a housing cost alert. Given that Savings
-- accounts for only 2.36% of total spending the platform
-- should actively push users to set a minimum savings
-- target of 10% of their monthly income and track
-- progress automatically.
-- ============================================================


-- QUESTION 2
-- What is the total income vs total expenses across all users?
-- ------------------------------------------------------------

SELECT
    transaction_type,
    COUNT(*)              AS total_transactions,
    SUM(amount)           AS total_amount,
    ROUND(AVG(amount), 2) AS avg_amount
FROM
 budgetwise_finance
GROUP BY
 transaction_type
ORDER BY
 total_amount DESC;


-- ============================================================
-- INSIGHT:
-- Total income across all users is 119,699,913 against total expenses of 64,170,070 giving a net balance of 55,529,843.
-- Users are spending approximately 53.6% of their total income which is well below the 85% risk threshold.
-- The average income transaction is 66,722 compared to an average expense transaction of just 6,535, meaning income arrives in large amounts (salaries, bonuses, freelance) while spending happens in smaller frequent transactions.
-- This pattern means users may feel cash rich after receiving income but gradually drain their balance through smaller daily expenses without realising it.
--
-- RECOMMENDATION:
-- BudgetWise should segment users into three financial health groups based on their personal expense-to-income ratio.
-- Green users spending 0-60% of income should be encouraged to invest their surplus through the platform.
-- Amber users spending 61-85% should receive monthly budget review reminders.
-- Red users spending above 86% should trigger immediate intervention with a personalised spending reduction plan.
-- This turns one platform-wide metric into an actionable per-user financial health monitoring system.
-- ============================================================


-- QUESTION 3
-- Which users are spending more than they earn? (Financial risk flag)
-- ------------------------------------------------------------

WITH user_summary AS (
    SELECT
        user_id,
        SUM(CASE WHEN transaction_type = 'Income'  THEN amount ELSE 0 END) AS total_income,
        SUM(CASE WHEN transaction_type = 'Expense' THEN amount ELSE 0 END) AS total_expense
    FROM budgetwise_finance
    GROUP BY user_id
)
SELECT
    user_id,
    total_income,
    total_expense,
    (total_income - total_expense)   AS net_balance,
    CASE
        WHEN total_expense > total_income THEN 'High Risk'
        WHEN total_expense = total_income THEN 'Break Even'
        ELSE 'Healthy'
    END     AS financial_status
FROM user_summary
ORDER BY net_balance ASC;


-- ============================================================

-- INSIGHT:
-- Out of 150 users, 29 users (19.3%) are classified as High Risk, meaning their total expenses exceed their total income.
-- 121 users (80.7%) are in a Healthy financial position.
-- While the majority of users are healthy, nearly 1 in 5 users is overspending which is a significant concern.
-- These 29 high risk users are accumulating a financial deficit that will lead to debt if not addressed.
-- No users are at Break Even suggesting spending patterns are clearly either healthy or problematic with little middle ground.
--
-- RECOMMENDATION:
-- BudgetWise should implement an automated financial risk scoring system that monitors each user's expense to income ratio monthly.
-- The 29 high risk users should immediately receive an in app alert showing them exactly how much they are overspending and which categories are causing it.
-- Users flagged as High Risk for three consecutive months should be offered a free financial coaching session through the platform to prevent long term debt accumulation.
-- ============================================================

-- QUESTION 4
-- How does spending change month over month?
-- ------------------------------------------------------------

SELECT
 year,
 month,
 month_name,
 SUM(CASE WHEN transaction_type = 'Expense' THEN amount ELSE 0 END) AS total_expense,
 SUM(CASE WHEN transaction_type = 'Income' THEN amount ELSE 0 END) AS total_income,
 SUM(CASE WHEN transaction_type = 'Income' THEN amount ELSE 0 END) -
 SUM(CASE WHEN transaction_type = 'Expense' THEN amount ELSE 0 END) AS net_balance
FROM 
 budgetwise_finance
GROUP BY 
 year,
 month,
 month_name
ORDER BY
 year,
 month,
 month_name;

-- ============================================================

-- INSIGHT:
-- Monthly spending is not consistent throughout the year.
-- Certain months show sharp spikes in expenses while income remains relatively stable.
-- These spikes often coincide with festive seasons, school periods or annual bill payments.
-- Months where expenses spike without a corresponding income increase represent the highest financial risk periods for users.
--
-- RECOMMENDATION:
-- BudgetWise should use month over month trend data to send proactive budget alerts to users one month before a historically high spending period.
-- For example if December consistently shows higher spending, users should receive a budget planning reminder in November to prepare them financially before the spike occurs.
-- ============================================================

-- QUESTION 5
-- Which month has the highest total spending?
-- ------------------------------------------------------------

SELECT
 year,
 month_name,
 SUM(amount) AS total_spent
FROM
 budgetwise_finance
WHERE
 transaction_type = 'Expense'
GROUP BY
 year,
 month_name
ORDER BY
 total_spent
DESC
LIMIT 10;

-- ============================================================

-- INSIGHT:
-- May 2022 recorded the highest total spending of 1,587,756 followed by November 2024 at 1,568,798 and August 2023 at 1,564,631.
-- Notably November appears twice in the top 10 (2024 and 2023) and so does June (2022 and 2023) suggesting these months consistently drive above average spending.
-- May and November are historically high-spend months likely driven by seasonal events, back to school expenses and pre holiday spending.
-- The spread across multiple years confirms these are recurring seasonal patterns rather than one off events.
--
-- RECOMMENDATION:
-- BudgetWise should build a personalised seasonal spending calendar for each user flagging their historically high spend months.
-- Before May and November each year the platform should send users a spending preview showing what they spent in the same month the previous year and a suggested budget cap for the upcoming month.
-- This gives users advance warning and the tools to plan before the high spend period arrives rather than reacting after the damage is done.
-- ============================================================

-- QUESTION 6 
-- How does spending change year over year?
-- ------------------------------------------------------------

SELECT
 year,
 SUM(CASE WHEN transaction_type = 'Income' THEN amount ELSE 0 END) AS total_income,
 SUM(CASE WHEN transaction_type = 'Expense' THEN amount ELSE 0 END) AS total_expense,
 SUM(CASE WHEN transaction_type = 'Income' THEN amount ELSE 0 END) - 
 SUM(CASE WHEN transaction_type = 'Expense' THEN amount ELSE 0 END) AS net_balance
FROM 
 budgetwise_finance
GROUP BY
 year
ORDER BY
 year;

-- ============================================================

-- INSIGHT:
-- Total income exceeded total expenses in all four years from 2021 to 2024 giving the platform a positive net balance each year.
-- However the gap between income and expenses narrowed over time for certain users suggesting spending grew faster than income in later years.
-- Years with the lowest net balance represent the highest financial pressure periods for the platform and signal the need for proactive budgeting intervention before the following year.
--
-- RECOMMENDATION:
-- BudgetWise should use the yearly trend to set platform wide financial health targets at the start of each new year.
-- The platform should publish a year in review report showing each user how their income, expenses and net balance changed vs the previous year.
-- Users whose net balance declined year over year should receive a personalised financial recovery plan showing them exactly how much to reduce spending to return to a positive balance within 6 months.
-- ============================================================

-- QUESTION 7
-- Who are the top 10 highest spending users and what categories do they spend most on?
-- ------------------------------------------------------------

SELECT
    user_id,
    category,
    COUNT(*)        AS total_transactions,
    SUM(amount)     AS total_spent
FROM budgetwise_finance
WHERE transaction_type = 'Expense'
GROUP BY user_id, category
ORDER BY total_spent DESC;

-- ============================================================
-- INSIGHT:
-- Rent dominates top spending records across almost all high spending users with individual Rent totals reaching as high as 405,205 for a single user.
-- Food is the most frequent category across all users but at a much lower average of 3,749 per transaction compared to Rent at 14,042.
-- Entertainment and Travel are moderate and controllable while Health and Education have the lowest transaction counts suggesting these are underfunded or undertracked categories across the platform.
--
-- RECOMMENDATION:
-- BudgetWise should build personalised monthly category reports for each user showing their top 3 spending categories compared to the platform average.
-- Users where Rent exceeds 40% of total expense should receive a housing cost alert.
-- Users with high Food and Entertainment transaction counts should receive a micro spending tracker showing cumulative weekly costs.
-- Users with zero Health or Education spending should receive a prompt to allocate a minimum monthly budget to these categories.
-- ============================================================

-- QUESTION 8
-- Which payment mode is used most for high value transactions? 
-- ------------------------------------------------------------

WITH avg_amount AS (
SELECT
 ROUND(AVG(amount), 2) AS avg_transaction
FROM
 budgetwise_finance
WHERE
 transaction_type = 'Expense'
)
SELECT 
 payment_mode,
 COUNT(*) AS total_transactions,
 SUM(amount) AS total_spent,
 ROUND(AVG(amount), 2) AS avg_amount
FROM
 budgetwise_finance, avg_amount
WHERE 
  transaction_type = 'Expense' 
  AND
  amount > avg_transaction
GROUP BY
 payment_mode
ORDER BY
 total_transactions
DESC
;
-- ============================================================
High value = above average amount (6,535)

-- INSIGHT:
-- For transactions above the average amount of 6,535, Card leads with 860 high value transactions totalling 11,396,759 and the highest average of 13,252 per transaction.
-- Cash follows closely with 867 transactions totalling 10,720,772 at an average of 12,365.
-- UPI ranks third with 824 transactions at 12,722 average.
-- The near equal distribution across all four payment modes for high value transactions is concerning because Cash transactions above average value have no digital trail making them impossible to verify or track automatically.
-- Cash and Card together account for 43% of all high-value transactions.
--
-- RECOMMENDATION:
-- BudgetWise should flag all cash transactions above the platform average of 6,535 on the user dashboard and prompt users to manually log the purpose of that transaction.
-- For users where Cash accounts for more than 30% of their high value transactions the platform should recommend switching to UPI or Bank Transfer to improve financial tracking accuracy.
-- Reducing untracked cash spending directly improves the quality of insights the platform generates for each user.

-- ============================================================
-- QUESTION 9
-- Which locations have the highest total spending?
-- ------------------------------------------------------------

SELECT
 location,
 COUNT(*) AS total_transaction,
 SUM(amount) AS total_spent,
 ROUND(AVG(amount),2) AS avg_amount
FROM
 budgetwise_finance
WHERE
 transaction_type = 'Expense'
 AND
 location != 'Unknown'
GROUP BY
 location
ORDER BY
 total_spent
DESC
;

-- ============================================================
-- INSIGHT:
-- Delhi leads all locations with total spending of 6,408,324 across 906 transactions and the highest average spend of 7,073 per transaction.
-- Bangalore ranks second at 6,227,282 followed by Kolkata at 6,114,693.
-- Jaipur records the lowest total spending at 5,532,136 despite having 854 transactions suggesting lower average transaction values per user.
-- The difference between the highest spending city (Delhi at 6,408,324) and the lowest (Jaipur at 5,532,136) is 875,188, a 15.8% gap indicating that location has a meaningful but not extreme impact on spending levels across the platform.
--
-- RECOMMENDATION:
-- BudgetWise should introduce location aware spending benchmarks showing users how their spending compares to the average for their city.
-- A Delhi user spending significantly above the Delhi average of 7,073 per transaction should receive a targeted alert.
-- The platform should also publish a monthly city spending report to help users understand local cost of living trends and adjust their budgets accordingly.
-- ============================================================


-- QUESTION 10
-- Which category has the most transactions but lowest total value? (High frequency low value spending)
-- ------------------------------------------------------------
SELECT 
 category,
 COUNT(*) AS most_transactions,
 SUM(amount) AS total_spent,
 ROUND(AVG(amount), 2) AS avg_per_transaction
FROM
 budgetwise_finance
WHERE
 transaction_type = 'Expense'
GROUP BY
 category
ORDER BY
 most_transactions DESC,
 total_spent ASC;

-- ============================================================

-- INSIGHT:
-- Food is the clearest example of high frequency low value spending with 2,470 transactions the highest of any category  but an average of only 3,749 per transaction which is the lowest average across all categories.
-- This means users are making frequent small food purchases that individually feel insignificant but collectively total 9,259,102.
-- Rent has far fewer transactions (1,937) but a much higher average (14,042) showing it is a low frequency high value category.
-- Users are far more likely to notice and question a single large Rent payment than the cumulative cost of 2,470 small food purchases.
--
-- RECOMMENDATION:
-- BudgetWise should introduce a micro spending tracker specifically for the Food category showing users a running monthly total of their food spend in real time.
-- The platform should display a weekly food spending summary every Monday morning showing users what they spent on food the previous week and how it compares to their monthly food budget.
-- This creates regular awareness of cumulative small spending which is the category most likely to cause budget overruns without users realising it.
-- ============================================================


-- QUESTION 11
-- What is the average monthly income vs average monthly expense per user?
-- ------------------------------------------------------------
WITH monthly_user AS (
    SELECT
        user_id,
        year,
        month,
        SUM(CASE WHEN transaction_type = 'Income'  THEN amount ELSE 0 END) AS monthly_income,
        SUM(CASE WHEN transaction_type = 'Expense' THEN amount ELSE 0 END) AS monthly_expense
    FROM budgetwise_finance
    GROUP BY user_id, year, month
)
SELECT
    user_id,
    ROUND(AVG(monthly_income), 2)  AS avg_monthly_income,
    ROUND(AVG(monthly_expense), 2) AS avg_monthly_expense,
    ROUND(AVG(monthly_income) -
          AVG(monthly_expense), 2) AS avg_monthly_balance
FROM
 monthly_user
GROUP BY
 user_id
ORDER BY
 avg_monthly_balance 
DESC;

-- ============================================================
-- INSIGHT:
-- The platform average monthly income is 20,815 against an average monthly expense of 11,123 giving an average monthly balance of 9,693.
-- However 29 users have a negative average monthly balance meaning they consistently spend more than they earn each month.
-- The top performing user U085 has an average monthly income of 63,360 against expenses of only 10,156 giving a monthly surplus of 53,204.
-- The large variance between users from strong surpluses to consistent deficits shows the platform serves users across a very wide income and spending range.
-- Users with negative monthly balances are building debt month by month with no corrective intervention from the platform currently.
--
-- RECOMMENDATION:
-- BudgetWise should introduce a monthly savings target feature where each user sets a savings goal at the start of each month based on their average monthly balance.
-- The platform should send a mid month check in on the 15th of every month showing users their current balance trajectory and whether they are on track to meet their savings goal.
-- The 29 users with negative average monthly balances should be prioritised for the financial coaching programme with a personalised month by month recovery plan showing them how to eliminate their deficit over a 3 to 6 month period.

the total spent from the Q6_Top_Spenders is different from total spent from budgetwise_finance cause the top spender from Q6 is user U099 which is 405205 why the budgetwise_finance is user U093 which is 99487 and again the q6 own correspond with the dashboard but the budgetwise_finance is not corresponding or am i going to create another total spent?

