-- Looks at the average total yards by offensive formation and receiver alignment
-- Good target for linear regression
SELECT offenseFormation, receiverAlignment, avg(rushing_yards + receiving_yards)
  FROM silver.agg_play_summary
  GROUP BY offenseFormation, receiverAlignment
  ORDER BY avg(rushing_yards + receiving_yards) DESC