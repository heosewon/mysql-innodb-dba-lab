USE GameOps;

-- 1) 인덱스 적용 전: PK(LogID) 외에는 조건을 탈 수 없어 넓게 읽는다.
EXPLAIN ANALYZE
SELECT LogID, CreateAt, AccountID, EventType, Amount
FROM GameLog
WHERE ServerID = 7
  AND CreateAt >= '2026-01-10'
  AND CreateAt <  '2026-01-11'
ORDER BY CreateAt DESC
LIMIT 100;

-- 2) 복합 인덱스 생성. 동등 조건(ServerID) 뒤에 범위 조건(CreateAt)을 둔다.
CREATE INDEX IX_GameLog_ServerID_CreateAt
ON GameLog (ServerID, CreateAt DESC);

ANALYZE TABLE GameLog;

-- 3) 다시 확인한다. SELECT 컬럼까지 모두 덮지는 않으므로 PK 재탐색 가능성도 계획에서 확인한다.
EXPLAIN ANALYZE
SELECT LogID, CreateAt, AccountID, EventType, Amount
FROM GameLog
WHERE ServerID = 7
  AND CreateAt >= '2026-01-10'
  AND CreateAt <  '2026-01-11'
ORDER BY CreateAt DESC
LIMIT 100;

-- 4) 목록 화면처럼 필요한 컬럼이 고정된 경우에는 커버링 인덱스도 비교할 수 있다.
CREATE INDEX IX_GameLog_ServerID_CreateAt_Covering
ON GameLog (ServerID, CreateAt DESC, AccountID, EventType, Amount);

EXPLAIN ANALYZE
SELECT CreateAt, AccountID, EventType, Amount
FROM GameLog
WHERE ServerID = 7
  AND CreateAt >= '2026-01-10'
  AND CreateAt <  '2026-01-11'
ORDER BY CreateAt DESC
LIMIT 100;
