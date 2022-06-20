
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
    h1.hacker_id AS id,
    h1.name AS name,
    SUM(max_score.score) AS final_score
FROM Hackers AS h1
INNER JOIN (
    SELECT 
        hacker_id,
        MAX(score) AS score
    FROM Submissions
    GROUP BY hacker_id, challenge_id
    ) AS max_score
ON h1.hacker_id = max_score.hacker_id
GROUP BY id, name
HAVING final_score != 0
ORDER BY final_score DESC, id;
-- CTE version
WITH a AS (
    SELECT 
        hacker_id,
        name,
        MAX(score) AS score
    FROM Submissions
    GROUP BY hacker_id, challenge_id),
    b AS (
        SELECT 
            score AS total_score
        FROM a
    )
SELECT 
    hacker_id,
    name,
    SUM(score) AS total_score
FROM a,b
WHERE b.total_score 1 != 0
ORDER BY total_score DESC, hacker_id;


