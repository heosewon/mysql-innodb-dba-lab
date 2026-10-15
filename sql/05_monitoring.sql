-- Performance Schema에서 현재 잠금 대기와 대기 원인을 확인한다.
SELECT
    w.REQUESTING_ENGINE_TRANSACTION_ID AS WaitingTransaction,
    w.BLOCKING_ENGINE_TRANSACTION_ID AS BlockingTransaction,
    rl.OBJECT_SCHEMA,
    rl.OBJECT_NAME,
    rl.INDEX_NAME,
    rl.LOCK_TYPE,
    rl.LOCK_MODE,
    rl.LOCK_STATUS
FROM performance_schema.data_lock_waits AS w
JOIN performance_schema.data_locks AS rl
  ON rl.ENGINE_LOCK_ID = w.REQUESTING_ENGINE_LOCK_ID;

-- 버퍼 풀과 Dirty Page 등 InnoDB 상태를 확인한다.
SHOW ENGINE INNODB STATUS;

SHOW GLOBAL STATUS WHERE Variable_name IN (
    'Innodb_buffer_pool_read_requests',
    'Innodb_buffer_pool_reads',
    'Innodb_buffer_pool_pages_dirty',
    'Innodb_row_lock_waits',
    'Innodb_row_lock_time'
);

-- 현재 실행 중인 트랜잭션을 확인한다.
SELECT * FROM information_schema.innodb_trx;
