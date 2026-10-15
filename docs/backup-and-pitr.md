# MySQL 백업과 PITR

## 용어

- **논리 백업**: `mysqldump`처럼 SQL 문으로 데이터를 추출하는 백업이다.
- **물리 백업**: 데이터 파일을 직접 백업하는 방식이다. 대용량 운영 환경에서는 보통 전용 백업 도구 또는 관리형 DB 백업 기능을 쓴다.
- **Binary Log(binlog)**: 변경 이력을 담는 파일이다. 복제와 시점 복구에 사용한다.
- **Redo Log**: InnoDB가 장애 복구를 위해 쓰는 내부 변경 로그다. binlog와 역할이 다르다.
- **PITR**: 전체 백업을 복원한 뒤 binlog를 원하는 시각 직전까지 적용하는 복구다.

## 실습용 전체 백업

```powershell
docker compose exec mysql sh -c "mysqldump -uroot -pportfolio_root --single-transaction --routines --events --databases GameOps" > GameOps_full.sql
```

`--single-transaction`은 InnoDB에서 일관된 스냅샷을 사용한다. 장기 실행 DDL은 별도 조율이 필요하다.

## binary log 확인

```sql
SHOW BINARY LOGS;
SHOW MASTER STATUS;
```

컨테이너에서 내용을 조회한다.

```powershell
docker compose exec mysql mysqlbinlog --base64-output=DECODE-ROWS -vv /var/lib/mysql/mysql-bin.000001
```

## 복구 흐름

```text
1. 전체 백업 시점 확인
2. 별도 복구 인스턴스에 전체 백업 복원
3. 필요한 binlog 파일·시작 위치 확인
4. 목표 시각 직전까지만 mysqlbinlog 적용
5. 데이터 정합성 및 애플리케이션 연결 확인
```

운영에서는 원본 인스턴스에 곧바로 적용하지 않는다. 별도 인스턴스에서 검증하고, RDS/Aurora라면 관리형 스냅샷 및 Point-in-time restore 절차를 사용한다.
