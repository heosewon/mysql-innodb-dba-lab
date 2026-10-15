USE GameOps;

-- 아래 두 블록을 서로 다른 MySQL 세션에서 거의 동시에 실행한다.
-- Session A: AccountID 1001을 먼저 잠그고 1002를 요청한다.
-- Session B: AccountID 1002를 먼저 잠그고 1001을 요청한다.
-- 둘 중 하나가 ERROR 1213(Deadlock found...)로 종료되는 것을 확인한다.

-- [Session A]
-- START TRANSACTION;
-- SELECT * FROM Inventory WHERE AccountID = 1001 AND ItemID = 5001 FOR UPDATE;
-- SELECT SLEEP(3);
-- UPDATE Inventory SET Quantity = Quantity - 10 WHERE AccountID = 1002 AND ItemID = 5001;
-- COMMIT;

-- [Session B]
-- START TRANSACTION;
-- SELECT * FROM Inventory WHERE AccountID = 1002 AND ItemID = 5001 FOR UPDATE;
-- SELECT SLEEP(3);
-- UPDATE Inventory SET Quantity = Quantity + 10 WHERE AccountID = 1001 AND ItemID = 5001;
-- COMMIT;

-- 해결: 항상 AccountID 오름차순으로 잠근다. 애플리케이션에서는 1213을 짧은 지수 백오프로 재시도한다.
-- [두 세션 공통]
-- START TRANSACTION;
-- SELECT * FROM Inventory
-- WHERE AccountID IN (1001, 1002) AND ItemID = 5001
-- ORDER BY AccountID
-- FOR UPDATE;
-- -- 이후 차감/지급 UPDATE 실행
-- COMMIT;

SHOW ENGINE INNODB STATUS;
