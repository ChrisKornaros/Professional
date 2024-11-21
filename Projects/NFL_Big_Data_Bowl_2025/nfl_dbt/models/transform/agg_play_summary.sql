WITH game AS (
    SELECT
        gameId,
        homeTeamAbbr,
        visitorTeamAbbr
    FROM bronze.games
),

play AS (
    SELECT
        gameId,
        playId,
        possessionTeam AS team_name,
        offenseFormation,
        receiverAlignment,
        CASE
            WHEN passResult IS NOT NULL THEN 'Pass'
            WHEN rushLocationType IS NOT NULL THEN 'Rush'
            ELSE 'Other'
        END AS play_type,
        yardsGained,
        CASE
            WHEN passResult = 'C' THEN 'Complete Pass'
            WHEN passResult = 'I' THEN 'Incomplete Pass'
            WHEN passResult = 'IN' THEN 'Intercepted Pass'
            WHEN passResult = 'S' THEN 'Sacked'
            WHEN rushLocationType IS NOT NULL THEN 'Rushing Play'
            ELSE 'Other'
        END AS play_outcome
    FROM bronze.plays
    WHERE playNullifiedByPenalty = 'N'
),

player_play AS (
    SELECT
        gameId,
        playId,
        MAX(hadRushAttempt) AS hadRushAttempt,
        MAX(hadDropback) AS hadDropback,
        MAX(hadPassReception) AS hadPassReception,
        SUM(rushingYards) AS rushing_yards,
        SUM(passingYards) AS passing_yards,
        SUM(receivingYards) AS receiving_yards
    FROM bronze.player_play
    GROUP BY gameId, playId
)

SELECT
    p.gameId,
    p.playId,
    p.team_name,
    p.offenseFormation,
    p.receiverAlignment,
    p.play_type,
    p.yardsGained,
    p.play_outcome,
    pp.rushing_yards,
    pp.passing_yards,
    pp.receiving_yards
FROM play p
LEFT JOIN game g ON p.gameId = g.gameId
LEFT JOIN player_play pp ON p.gameId = pp.gameId AND p.playId = pp.playId
