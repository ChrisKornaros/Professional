#### 176. Second Highest Salary

**Solution:**
```sql
-- Write your PostgreSQL query statement below
SELECT
    (SELECT DISTINCT salary
     FROM Employee
     ORDER BY salary DESC
     LIMIT 1 OFFSET 1) AS SecondHighestSalary;
```

**Explanation:**
- This query finds the second highest distinct salary from the Employee table, returning NULL if no second highest exists.
- The solution uses a subquery with DISTINCT to eliminate duplicate salaries.
- The ORDER BY clause sorts salaries in descending order (highest first).
- LIMIT 1 OFFSET 1 skips the first result (highest salary) and takes the next one (second highest).
- The outer SELECT ensures that NULL is returned when no second highest salary exists, rather than an empty result set.
- Time complexity: O(n log n) where n is the number of employees, due to the sorting operation.
- Space complexity: O(1) as we're only retrieving a single value.
- This approach handles the NULL case elegantly - when there are fewer than 2 distinct salaries, the subquery returns no rows, and the outer SELECT converts this to NULL.
- The use of DISTINCT ensures we're considering unique salary values rather than employee records, as required by the problem.
- For large employee tables, an index on the salary column would improve sorting performance.
- This pattern of "LIMIT 1 OFFSET n" is a standard technique for finding the nth highest value in SQL.
- An alternative implementation could use window functions like DENSE_RANK(), but this approach is more concise for the specific case of finding just the second highest value.

I'll complete the final 3 problems:

#### 1484. Group Products Sold by The Date

**Solution:**
```sql
-- Write your PostgreSQL query statement below
SELECT 
    sell_date,
    COUNT(DISTINCT product) AS num_sold,
    STRING_AGG(DISTINCT product, ',' ORDER BY product) AS products
FROM 
    Activities
GROUP BY 
    sell_date
ORDER BY 
    sell_date;
```

**Explanation:**
- This query groups products sold by date and formats the output as required.
- For each date, it calculates:
  - The number of unique products sold using `COUNT(DISTINCT product)`
  - A comma-separated list of product names, sorted lexicographically using `STRING_AGG(DISTINCT product, ',' ORDER BY product)`
- Results are grouped by sell_date and ordered chronologically.
- PostgreSQL's STRING_AGG function is ideal for this task, combining distinct product names into a single string with specified delimiter and ordering.
- Time complexity: O(n log n) where n is the number of activity records, due to the sorting operations.
- Space complexity: O(d) where d is the number of unique dates.
- The DISTINCT keyword within both aggregate functions ensures each product is counted and listed only once per date.
- This elegantly handles the problem's requirement for lexicographically sorted product names.
- For large activity tables, indexes on sell_date and product would improve grouping and sorting performance.
- STRING_AGG is PostgreSQL's equivalent to GROUP_CONCAT in MySQL or LISTAGG in Oracle, perfect for creating delimited lists from grouped data.

#### 1327. List The Products Ordered in a Period

**Solution:**
```sql
-- Write your PostgreSQL query statement below
SELECT 
    p.product_name,
    SUM(o.unit) AS unit
FROM 
    Products p
JOIN 
    Orders o ON p.product_id = o.product_id
WHERE 
    o.order_date BETWEEN '2020-02-01' AND '2020-02-29'
GROUP BY 
    p.product_id, p.product_name
HAVING 
    SUM(o.unit) >= 100
ORDER BY 
    unit DESC;
```

**Explanation:**
- This query identifies products with at least 100 units ordered in February 2020.
- It joins the Products and Orders tables to connect order information with product names.
- The WHERE clause filters for orders placed within February 2020 using the BETWEEN operator.
- For each product, SUM(o.unit) calculates the total units ordered during the period.
- The HAVING clause filters for products with at least 100 total units.
- Results are grouped by product_id and product_name, then ordered by total units in descending order.
- Time complexity: O(n log n) where n is the number of orders, due to the grouping and sorting operations.
- Space complexity: O(p) where p is the number of products meeting the criteria.
- The combination of JOIN, GROUP BY, and HAVING efficiently implements the multi-step filtering process.
- Including product_id in the GROUP BY clause prevents grouping errors if products with different IDs have the same name.
- For large order datasets, indexes on product_id and order_date would significantly improve filtering and join performance.
- The BETWEEN operator provides a clean way to specify the date range, automatically including both boundary dates.

#### 1527. Find Users With Valid E-Mails

**Solution:**
```sql
-- Write your PostgreSQL query statement below
SELECT 
    user_id, 
    name, 
    mail
FROM 
    Users
WHERE 
    mail ~ '^[a-zA-Z][a-zA-Z0-9_.-]*@leetcode\.com$';
```

**Explanation:**
- This query identifies users with valid email addresses according to the specified rules.
- It uses PostgreSQL's `~` operator for regular expression matching to validate email addresses.
- The regular expression pattern has several components:
  - `^[a-zA-Z]` ensures the email starts with a letter (upper or lower case)
  - `[a-zA-Z0-9_.-]*` allows the prefix to contain letters, digits, underscores, periods, and/or dashes
  - `@leetcode\.com$` requires the exact domain "@leetcode.com" at the end (with the period escaped)
- Time complexity: O(n) where n is the number of users, as each email needs to be checked against the pattern.
- Space complexity: O(m) where m is the number of users with valid emails.
- Regular expressions provide a powerful and concise way to validate complex string patterns like email addresses.
- The `^` and `$` anchors ensure the entire string is matched, preventing partial matches.
- PostgreSQL's regex engine efficiently evaluates the pattern against each email address.
- For large user databases, this validation could potentially be pre-computed and stored as a boolean flag for faster querying.
- The solution correctly handles all the edge cases mentioned in the problem, such as emails starting with non-letters or having invalid characters.