
/*
1.
 If more than one student created the same number of challenges 
 and the count is less than the maximum number of challenges created, 
 then exclude those students from the result.
*/ 
-- CTE version
WITH cte AS (
SELECT 
    H.hacker_id AS id,
    H.name AS name,
    COUNT(*) AS frequency
FROM Hackers AS H
INNER JOIN Challenges AS C
ON H.hacker_id = C.hacker_id
GROUP BY 1,2
)
SELECT 
    id,
    name,
    frequency
FROM cte
WHERE
    frequency = (
        SELECT MAX(frequency)
        FROM cte
    ) 
    OR
    frequency in (
        SELECT frequency
        FROM cte
        GROUP By 1
        HAVING COUNT(frequency) = 1
    )
ORDER BY 3 DESC, 1;
-- Subquery version
SELECT
    H.hacker_id AS id,
    H.name AS name,
    COUNT(*) AS freq
FROM Hackers AS H
INNER JOIN Challenges AS C
ON H.hacker_id = C.hacker_id
GROUP BY id, name
HAVING 
    freq IN (
        SELECT tb_1.freq1
        FROM (
            SELECT            
                H1.hacker_id,
                COUNT(*) AS freq1
            FROM Hackers AS H1
            INNER JOIN Challenges AS C1
            ON H1.hacker_id = C1.hacker_id 
            GROUP BY H1.hacker_id
            ) AS tb_1
        GROUP BY tb_1.freq1
        HAVING COUNT(tb_1.freq1) = 1
        ) OR 
    freq = (
        SELECT MAX(tb_2.freq2)
        FROM (
            SELECT 
                H2.hacker_id,
                COUNT(*) as freq2
            FROM Hackers AS H2
            INNER JOIN Challenges AS C2
            ON H2.hacker_id = C2.hacker_id 
            GROUP BY H2.hacker_id
            ) AS tb_2
        )
ORDER BY freq DESC, id;

/*
2.
The total score of a hacker is the sum of their maximum scores for all of the challenges. 
Write a query to print the hacker_id, name, and total score of the hackers ordered by the descending score. 
If more than one hacker achieved the same total score, then sort the result by ascending hacker_id. 
Exclude all hackers with a total score of 0 from your result.
*/
-- Subquery version
SELECT 
    t1.hacker_id AS hacker_id,
    t1.name AS name,
    SUM(t2.max_score) AS total_score
FROM Hackers as t1
INNER JOIN (
    SELECT 
        hacker_id,
        MAX(score) as max_score
    FROM Submissions
    GROUP BY hacker_id, challenge_id
    ) AS t2
ON t1.hacker_id = t2.hacker_id
GROUP BY t1.hacker_id, t1.name
HAVING total_score != 0
ORDER BY total_score DESC, hacker_id;
-- CTE version
WITH t1 AS (
    SELECT 
        hacker_id,
        name,
        MAX(score) AS score
    FROM Submissions
    GROUP BY hacker_id, challenge_id),
    t2 AS (
        SELECT 
            score AS total_score
        FROM t1
    )
SELECT 
    hacker_id,
    name,
    SUM(score) AS total_score
FROM t1, t2
WHERE t2.total_score 1 != 0
ORDER BY total_score DESC, hacker_id;

/* 3.  Write a query to print the respective hacker_id and name of hackers who achieved full scores for more than one challenge. 
Order your output in descending order by the total number of challenges in which the hacker earned a full score. If more than one hacker received full scores in same number of challenges, then sort them by ascending hacker_id.
*/
-- subquery version
SELECT 
    h.hacker_id, 
    h.name
FROM submissions AS s
    JOIN challenges AS c
    ON s.challenge_id = c.challenge_id
    JOIN difficulty AS d
    ON c.difficulty_level = d.difficulty_level 
    JOIN hackers AS h
    ON s.hacker_id = h.hacker_id
WHERE c.difficulty_level = d.difficulty_level  
    AND s.score = d.score 
GROUP BY h.hacker_id, h.name
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC, h.hacker_id ASC;
