### SQL Hard
#### 185. Department Top Three Salaries
**Description:** 

Table: Employee

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| id           | int     |
| name         | varchar |
| salary       | int     |
| departmentId | int     |
+--------------+---------+

id is the primary key (column with unique values) for this table.
departmentId is a foreign key (reference column) of the ID from the Department table.
Each row of this table indicates the ID, name, and salary of an employee. It also contains the ID of their department.

 

Table: Department

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| id          | int     |
| name        | varchar |
+-------------+---------+

id is the primary key (column with unique values) for this table.
Each row of this table indicates the ID of a department and its name.

A company's executives are interested in seeing who earns the most money in each of the company's departments. A high earner in a department is an employee who has a salary in the top three unique salaries for that department.

Write a solution to find the employees who are high earners in each of the departments.

Return the result table in any order.

**Solution:** 
```sql
WITH base AS (
    SELECT d.name AS Department, e.name AS Employee, e.salary AS Salary, DENSE_RANK() OVER (PARTITION BY d.name ORDER BY e.salary DESC) AS rank
    FROM Employee e INNER JOIN Department d
        ON e.departmentId = d.id
    GROUP BY d.name, e.name, e.salary
)

SELECT Department, Employee, Salary
FROM base
WHERE rank <= 3;
```

**Explanation:**

- This query identifies the highest-paid employees in each department, specifically those with salaries in the top three within their department.
- The solution uses a Common Table Expression (CTE) with a window function to rank employees within each department based on salary.
- `DENSE_RANK() OVER (PARTITION BY e.departmentId ORDER BY e.salary DESC)` assigns a rank to each employee's salary within their department, with 1 being the highest.
- Unlike regular RANK(), DENSE_RANK() doesn't skip ranks for ties, which is important when multiple employees have the same salary.
- The main query then filters for employees with a rank of 3 or less, capturing the top three salary tiers in each department.
- The solution joins the Employee and Department tables to include department names in the output.
- Time complexity: O(n log n) where n is the number of employees, due to the sorting operations in the window function.
- Space complexity: O(n) for the CTE and result set.
- The DENSE_RANK() function ensures that if multiple employees have the same salary, they get the same rank and all count toward the top three.
- For example, if two employees have the highest salary in a department, both get rank 1, and the employee with the next highest salary gets rank 2.
- This approach efficiently handles departments of different sizes without requiring complex subqueries.
- For large datasets, indexes on departmentId and salary would improve join and sorting performance.

#### 262. Trips and Users
**Description:** 

Table: Trips

+-------------+----------+
| Column Name | Type     |
+-------------+----------+
| id          | int      |
| client_id   | int      |
| driver_id   | int      |
| city_id     | int      |
| status      | enum     |
| request_at  | varchar  |     
+-------------+----------+

id is the primary key (column with unique values) for this table.
The table holds all taxi trips. Each trip has a unique id, while client_id and driver_id are foreign keys to the users_id at the Users table.
Status is an ENUM (category) type of ('completed', 'cancelled_by_driver', 'cancelled_by_client').

Table: Users

+-------------+----------+
| Column Name | Type     |
+-------------+----------+
| users_id    | int      |
| banned      | enum     |
| role        | enum     |
+-------------+----------+

users_id is the primary key (column with unique values) for this table.
The table holds all users. Each user has a unique users_id, and role is an ENUM type of ('client', 'driver', 'partner').
banned is an ENUM (category) type of ('Yes', 'No').

The cancellation rate is computed by dividing the number of canceled (by client or driver) requests with unbanned users by the total number of requests with unbanned users on that day.

Write a solution to find the cancellation rate of requests with unbanned users (both client and driver must not be banned) each day between "2013-10-01" and "2013-10-03" with at least one trip. Round Cancellation Rate to two decimal points.

Return the result table in any order.

**Solution:** 
```sql
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
```

**Explanation:**

- This query calculates the daily cancellation rate for taxi trips between Oct 1-3, 2013, where both client and driver are not banned.
- It creates two Common Table Expressions (CTEs) to simplify the logic: one for unbanned users and another for cancelled trips.
- The first CTE (`unbanned`) filters the Users table to include only those who aren't banned.
- The second CTE (`cancelled`) identifies all trips with status starting with "can" (cancelled trips).
- The main query joins all trips with the cancelled trips using a LEFT JOIN to preserve all eligible trips.
- The WHERE clause ensures both driver and client are unbanned by using IN subqueries against the unbanned CTE.
- Date filtering with BETWEEN ensures only trips from Oct 1-3, 2013 are included.
- The cancellation rate is calculated by dividing cancelled trips count by total trips count for each day.
- The ROUND function with type casting to numeric ensures the result is formatted to two decimal places.
- Time complexity: O(n + m) where n is the number of trips and m is the number of users, due to the table scans and joins.
- Space complexity: O(u + c) where u is the number of unbanned users and c is the number of cancelled trips.
- Using CTEs improves query readability and maintenance compared to multiple subqueries.
- The LEFT JOIN is crucial as it preserves all trips even if they weren't cancelled, ensuring correct denominator in the rate calculation.
- Using `LEFT(status, 3) LIKE 'can'` efficiently captures both cancellation types in a single condition.
- For large datasets, indexes on users_id, client_id, driver_id, and request_at would significantly improve query performance.
- Explicitly casting to numeric when calculating the rate prevents integer division issues that would result in truncated values.

#### 569. Median Employee Salary
**Description:** 

Table: Employee

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| id           | int     |
| company      | varchar |
| salary       | int     |
+--------------+---------+

id is the primary key (column with unique values) for this table.
Each row of this table indicates the company and the salary of one employee.

Write a solution to find the rows that contain the median salary of each company. While calculating the median, when you sort the salaries of the company, break the ties by id.

Return the result table in any order.

The result format is in the following example.

**Solution:** 
```sql
-- Write your PostgreSQL query statement below
WITH company_counts AS (
    SELECT company, COUNT(*) as emp_count
    FROM Employee
    GROUP BY company
),
ranked_salaries AS (
    SELECT e.id, e.company, e.salary, 
           ROW_NUMBER() OVER (PARTITION BY e.company ORDER BY e.salary, e.id) as row_rank,
           cc.emp_count
    FROM Employee e
    JOIN company_counts cc ON e.company = cc.company
)
SELECT id, company, salary
FROM ranked_salaries
WHERE 
    (emp_count % 2 = 1 AND row_rank = (emp_count + 1) / 2) OR  -- Odd count: middle value
    (emp_count % 2 = 0 AND (row_rank = emp_count / 2 OR row_rank = emp_count / 2 + 1))  -- Even count: two middle values
```

**Explanation:**

- This query identifies rows containing the median salary for each company, breaking ties by employee ID when sorting salaries.
- It uses a two-stage approach with Common Table Expressions (CTEs) to first count employees and then assign precise rankings.
- The first CTE calculates the total number of employees for each company, which is crucial for determining median positions.
- The second CTE employs ROW_NUMBER() to assign a sequential rank to each employee within their company, ordering first by salary and then by ID.
- For companies with an odd number of employees, only the middle row is selected (e.g., for 5 employees, the 3rd ranked employee).
- For companies with an even number of employees, both middle rows are included (e.g., for 6 employees, both the 3rd and 4th ranked employees).
- The WHERE clause uses a conditional expression to filter for the appropriate rows based on whether the employee count is odd or even.
- The formula (emp_count + 1) / 2 finds the median position for odd counts, while emp_count / 2 and emp_count / 2 + 1 identify both median positions for even counts.
- Time complexity is O(n log n) due to the sorting operations required within each company partition for ranking.
- Space complexity is O(n) where n is the number of employees, as we need to store all employee records with additional ranking information.
- Using ROW_NUMBER() instead of RANK() ensures unique positions even when salaries are identical, allowing the tie-breaking by ID to work correctly.
- The solution efficiently handles the multiple requirements: partitioning by company, ordering by salary, breaking ties by ID, and selecting median values.
- For large employee datasets, indexes on company and salary columns would significantly improve query performance.
- The modulo operation (%) provides a clean way to differentiate between companies with odd and even employee counts.
- This approach maintains data integrity by passing through the original employee IDs, company names, and salary values without manipulation.
- The solution is adaptable to handle additional requirements like excluding certain employees or adding weighted calculations.

#### 571. Find Median Given Frequency of Numbers
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 579. Find Cumulative Salary of an Employee
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 601. Human Traffic of a Stadium
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 615. Average Salary: Department VS Co
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 618. Students Report by Geography
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 1097. Gameplay Analysis V
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 1127. User Purchase Platform
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 1159. Market Analysis II
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 1194. Tournament Winners
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 1225. Report Contiguous Dates
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 1336. Number of Transactions per Visit
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 1369. Get the Second Most Recent Activity
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 1384. Total Sales Amount by Year
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 1412. Find the Quiet Students in All Exams
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 1479. Sales by Day of the Week
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 1635. Hopper Company Queries I
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 1645. Hopper Company Queries II
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 1651. Hopper Company Queries III
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 1767. Find the Subtasks That Did Not Execute
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 1892. Page Recommendations II
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 1917. Leetcodify Friends Recommendations
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 1919. Leetcodify Similar Friends
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 1972. First and Last Call On the Same Day
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 2004. The Number of Seniors and Juniors to Join the Company
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 2010. The Number of Seniors and Juniors to Join the Company II
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 2118. Build the Equation
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 2153. The Number of Passengers in Each Bus II
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 2173. Longest Winning Streak
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 2199. Finding the Topic of Each Post
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 2252. Dynamic Pivoting of a Table
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 2253. Dynamic Unpivoting of a Table
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 2362. Generate the Invoice
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 2474. Customers With Strictly Increasing Purchases
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 2494. Merge Overlapping Events in the Same Hall
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 2701. Consecutive Transactions with Increasing Amounts
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 2720. Popularity Percentage
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 2752. Customers with Maximum Number of Transactions on Consecutive Days
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 2793. Status of Flight Tickets
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 2991. Top Three Wineries
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 2994. Friday Purchases II
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 2995. Viewers Turned Streamers
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 2996. Maximize Items 
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 3057. Employees Project Allocation
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 3060. User Activities within Time Bounds
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 3061. Calculate Trapping Rain Water
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 3103. Find Trending Hashtags II
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 3156. Employee Task Duration and Concurrent Tasks
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 3188. Find Top Scoring Students II
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 3214. Year on Year Growth Rate
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 3236. CEO Subordinate Hierarchy
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 3268. Find Overlapping Shifts II
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 3368. First Letter Capitalization
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 3374. First Letter Capitalization II
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 3384. Team Dominance by Pass Success
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 3390. Longest Team Pass Streak
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 3401. Find Circular Gift Exchange Chains
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

#### 3451. Find Invalid IP Addresses
**Description:** 


**Solution:** 
```sql

```

**Explanation:**

- Need to add explanation

