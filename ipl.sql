CREATE database ipl;
USE ipl;
DROP database dengue;
SHOW tables;
SELECT * FROM deliveries;
-- Total match played
SELECT COUNT(*) 
FROM ipl.match;

-- Total runs scored
SELECT SUM(total_runs) 
FROM deliveries;

-- matches won by each team
SELECT winner, COUNT(*) AS wins
FROM ipl.match
GROUP BY winner
ORDER BY wins DESC;

-- tOP 5 teams with most wins
SELECT winner , Count(*) as wins
FROM ipl.match
GROUP BY winner
ORDER BY wins DESC
limit 5;

-- Top batsmen (striker column used)
SELECT striker AS player_name, SUM(batsman_runs) AS total_runs
FROM deliveries GROUP BY striker
ORDER BY total_runs DESC LIMIT 5;

-- most consistent player
SELECT striker , COUNT(DISTINCT match_id) as matches
FROM deliveries
GROUP BY striker
ORDER BY matches DESC;

-- total matches per season
SELECT season, COUNT(*) AS total_matches
FROM ipl.match
GROUP BY season
ORDER BY season;

-- winner per season
SELECT season, winner
FROM ipl.match;

-- Rank batsman
SELECT striker, total_runs,
RANK() OVER (order by total_runs DESC) 
FROM(
	SELECT striker, SUM(total_runs) as total_runs
    FROM deliveries
    GROUP BY striker
    ) t;

-- matches won per team per season
SELECT season, winner, COUNT(*) AS wins
FROM ipl.match
GROUP BY season, winner
ORDER BY season, wins DESC;

-- remove null winners
SELECT * FROM ipl.match
WHERE winner is not null;

SELECT *
FROM (
  SELECT 
    m.season,
    d.striker,
    SUM(d.total_runs) AS runs,
    RANK() OVER (
      PARTITION BY m.season 
      ORDER BY SUM(d.total_runs) DESC
    ) AS rnk
  FROM ipl.match m
  JOIN deliveries d
    ON m.match_id = d.match_id
  GROUP BY m.season, d.striker
) t
WHERE rnk = 1;

-- basic dismissal stats
SELECT 
  COUNT(*) AS balls_faced,
  SUM(CASE WHEN is_wicket = 1 THEN 1 ELSE 0 END) AS dismissals
FROM deliveries;

-- strike rate
SELECT 
  striker,
  SUM(batsman_runs) AS runs,
  COUNT(*) AS balls,
  (SUM(batsman_runs) * 100.0 / COUNT(*)) AS strike_rate
FROM deliveries
GROUP BY striker
ORDER BY strike_rate DESC;

-- economy rate(for bowlers)
SELECT 
  bowler,
  COUNT(*) AS balls,
  SUM(total_runs) AS runs_given,
  (SUM(total_runs) * 6.0 / COUNT(*)) AS economy_rate
FROM deliveries
GROUP BY bowler
ORDER BY economy_rate;

-- most valueable players
SELECT 
  striker,
  SUM(batsman_runs) AS runs,
  COUNT(DISTINCT match_id) AS matches
FROM deliveries
GROUP BY striker
ORDER BY runs DESC;

-- boundary analysis
SELECT 
  striker,
  SUM(CASE WHEN batsman_runs = 4 THEN 1 ELSE 0 END) AS fours,
  SUM(CASE WHEN batsman_runs = 6 THEN 1 ELSE 0 END) AS sixes
FROM deliveries
GROUP BY striker
ORDER BY sixes DESC;

-- toss winner
SELECT 
  toss_winner,
  COUNT(*) AS toss_win_match_win
FROM ipl.match
WHERE toss_winner = winner
GROUP BY toss_winner;

-- venue analysis
SELECT 
  venue,
  COUNT(*) AS matches
FROM ipl.match
GROUP BY venue
ORDER BY matches DESC;

-- season winner summary table
SELECT 
  season,
  COUNT(*) AS matches,
  COUNT(DISTINCT winner) AS teams_won
FROM ipl.match
GROUP BY season;

-- dot ball analysis
SELECT 
  striker,
  COUNT(*) AS balls,
  SUM(CASE WHEN batsman_runs = 0 THEN 1 ELSE 0 END) AS dot_balls
FROM deliveries
GROUP BY striker;

-- power hitter ratio
SELECT 
  striker,
  SUM(CASE WHEN batsman_runs IN (4,6) THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS boundary_ratio
FROM deliveries
GROUP BY striker;

SHOW databases;