I'll continue with the next set of 5 problems:

#### 180. Consecutive Numbers

**Solution:**
```sql
-- Write your PostgreSQL query statement below
WITH NumberRanks AS (
    SELECT 
        id,
        num,
        LEAD(num, 1) OVER (ORDER BY id) AS next_num,
        LEAD(num, 2) OVER (ORDER BY id) AS next_next_num
    FROM 
        Logs
)
SELECT DISTINCT num AS ConsecutiveNums
FROM NumberRanks
WHERE num = next_num AND num = next_next_num;
```

**Explanation:**
- This query identifies numbers that appear at least three times consecutively in the Logs table.
- The solution uses a Common Table Expression (CTE) with window functions to look ahead at subsequent rows.
- `LEAD(num, 1) OVER (ORDER BY id)` retrieves the value from the next row, while `LEAD(num, 2)` gets the value from two rows ahead.
- The main query then filters for rows where the current number equals both the next number and the number after that, indicating three consecutive occurrences.
- `DISTINCT` ensures each consecutive number appears only once in the results, even if it occurs consecutively multiple times.
- Time complexity: O(n log n) where n is the number of log entries, due to the sorting operation implicit in the window functions.
- Space complexity: O(n) for the CTE results and O(m) for the final output where m is the number of distinct consecutive numbers.
- Window functions provide an elegant way to compare values across rows without requiring complex self-joins.
- This approach efficiently handles the "consecutive" requirement by leveraging PostgreSQL's LEAD function to look ahead.
- For larger datasets, an index on the id column would improve the performance of the window functions.
- The solution assumes that ids are sequential without gaps, as implied by the problem description stating id is an autoincrement column.

#### 1164. Product Price at a Given Date

**Solution:**
```sql
-- Write your PostgreSQL query statement below
WITH LatestPriceBeforeDate AS (
    SELECT 
        product_id,
        new_price,
        ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY change_date DESC) AS rn
    FROM 
        Products
    WHERE 
        change_date <= '2019-08-16'
)
SELECT 
    DISTINCT p.product_id,
    COALESCE(lp.new_price, 10) AS price
FROM 
    (SELECT DISTINCT product_id FROM Products) p
LEFT JOIN 
    LatestPriceBeforeDate lp ON p.product_id = lp.product_id AND lp.rn = 1;
```

**Explanation:**
- This query finds the price of each product on a specific date (2019-08-16), with a default price of 10 for products without any price changes before that date.
- The solution uses a Common Table Expression (CTE) to identify the most recent price change for each product before or on the target date.
- Within the CTE, `ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY change_date DESC)` assigns row numbers to price changes for each product, with the most recent change getting row number 1.
- The main query performs a LEFT JOIN between all unique product IDs and the filtered latest price changes.
- `COALESCE(lp.new_price, 10)` handles products that have no price changes before the target date, defaulting to the specified price of 10.
- Time complexity: O(n log n) where n is the number of price change records, due to the window function and partitioning.
- Space complexity: O(p) where p is the number of unique products.
- The solution correctly handles all three cases:
  - Products with price changes on the exact target date
  - Products with price changes before the target date
  - Products with no price changes before the target date (default price of 10)
- The use of ROW_NUMBER() to identify the most recent price change is more efficient than using self-joins or subqueries with MAX().
- For large datasets, indexes on product_id and change_date would significantly improve performance.

#### 1204. Last Person to Fit in the Bus

**Solution:**
```sql
-- Write your PostgreSQL query statement below
WITH RunningWeight AS (
    SELECT 
        person_name,
        weight,
        SUM(weight) OVER (ORDER BY turn) AS total_weight
    FROM 
        Queue
    ORDER BY 
        turn
)
SELECT 
    person_name
FROM 
    RunningWeight
WHERE 
    total_weight <= 1000
ORDER BY 
    total_weight DESC
LIMIT 1;
```

**Explanation:**
- This query identifies the last person who can board the bus without exceeding the 1000 kg weight limit.
- The solution uses a Common Table Expression (CTE) with a window function to calculate a running sum of weights as people board in order.
- `SUM(weight) OVER (ORDER BY turn)` creates a running total of weights based on boarding order.
- The main query filters for people whose added weight doesn't exceed the 1000 kg limit.
- `ORDER BY total_weight DESC` sorts the qualified people by their running total in descending order.
- `LIMIT 1` selects only the person with the highest running total, who would be the last to board.
- Time complexity: O(n log n) where n is the number of people in the queue, due to the sorting operations.
- Space complexity: O(n) for the CTE results.
- The window function approach elegantly handles the cumulative weight calculation without requiring loops or cursors.
- This solution correctly models the sequential boarding process, where each person boards in their turn order.
- The running sum approach is more efficient than calculating cumulative sums in a subquery for each person.
- For large datasets, an index on the turn column would improve the performance of the window function.

#### 1907. Count Salary Categories

**Solution:**
```sql
-- Write your PostgreSQL query statement below
SELECT 
    'Low Salary' AS category,
    COUNT(*) AS accounts_count
FROM 
    Accounts
WHERE 
    income < 20000

UNION ALL

SELECT 
    'Average Salary' AS category,
    COUNT(*) AS accounts_count
FROM 
    Accounts
WHERE 
    income BETWEEN 20000 AND 50000

UNION ALL

SELECT 
    'High Salary' AS category,
    COUNT(*) AS accounts_count
FROM 
    Accounts
WHERE 
    income > 50000;
```

**Explanation:**
- This query calculates the number of bank accounts in each of three salary categories: Low, Average, and High.
- The solution uses UNION ALL to combine the results of three separate COUNT queries, one for each salary category.
- For "Low Salary," it counts accounts with income strictly less than $20,000.
- For "Average Salary," it counts accounts with income between $20,000 and $50,000 (inclusive).
- For "High Salary," it counts accounts with income strictly greater than $50,000.
- Each query explicitly specifies the category name as a string literal.
- Time complexity: O(n) where n is the number of accounts, as each account needs to be evaluated against the income criteria.
- Space complexity: O(1) as the result set always has exactly 3 rows.
- The UNION ALL approach ensures that all three categories appear in the results, even if some have zero accounts.
- This is more efficient than using a GROUP BY with a CASE expression because we only need to scan the table once per category.
- For large account tables, indexes on the income column would significantly improve filtering performance.
- The solution meets the requirement to include all three categories in the output, with 0 counts for empty categories.

#### 1978. Employees Whose Manager Left The Company

**Solution:**
```sql
-- Write your PostgreSQL query statement below
SELECT 
    employee_id
FROM 
    Employees
WHERE 
    salary < 30000 
    AND manager_id IS NOT NULL
    AND manager_id NOT IN (SELECT employee_id FROM Employees)
ORDER BY 
    employee_id;
```

**Explanation:**
- This query identifies employees who meet three conditions:
  1. Their salary is strictly less than $30,000
  2. They have a manager (manager_id is not NULL)
  3. Their manager has left the company (manager_id doesn't exist in the employee_id column)
- The `NOT IN` subquery efficiently checks whether the manager_id exists among current employees.
- Results are ordered by employee_id as required by the problem.
- Time complexity: O(n log n) where n is the number of employees, due to the sorting operation and the subquery.
- Space complexity: O(m) where m is the number of employees meeting the criteria.
- This solution correctly identifies employees whose managers left by checking for manager_id values that don't appear in the employee_id column.
- The NOT IN approach is straightforward and readable, though for very large datasets, an anti-join pattern might be more efficient.
- The multiple conditions in the WHERE clause are evaluated together to filter the results in a single pass through the data.
- For large employee tables, indexes on employee_id, manager_id, and salary would significantly improve filtering and sorting performance.

Would you like me to continue with the next set of problems?