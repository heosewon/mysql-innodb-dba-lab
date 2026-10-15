USE GameOps;

-- Docker 환경에서 약 100만 건을 생성한다. 이미 생성했으면 다시 실행하지 않는다.
-- MySQL에서는 INSERT 뒤, SELECT 앞에 WITH 절을 둔다.
INSERT INTO GameLog (CreateAt, ServerID, AccountID, EventType, Amount, Detail)
WITH RECURSIVE digits AS (
    SELECT 0 AS n
    UNION ALL
    SELECT n + 1 FROM digits WHERE n < 9
),
numbers AS (
    SELECT a.n + b.n * 10 + c.n * 100 + d.n * 1000 + e.n * 10000 + f.n * 100000 AS n
    FROM digits a CROSS JOIN digits b CROSS JOIN digits c
    CROSS JOIN digits d CROSS JOIN digits e CROSS JOIN digits f
)
SELECT
    TIMESTAMP('2026-01-01 00:00:00') + INTERVAL (n % 8640000) SECOND,
    (n % 20) + 1,
    (n % 200000) + 1,
    ELT((n % 4) + 1, 'ITEM_CREATE', 'GOLD_CHANGE', 'DUNGEON_CLEAR', 'LOGIN'),
    (n % 1000) + 1,
    CONCAT('seed-', n)
FROM numbers;

ANALYZE TABLE GameLog;
