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

Would you like me to continue with the final set of problems, or would you like to review these first?