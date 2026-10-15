# MySQL InnoDB 운영 전환 포트폴리오

SQL Server DBA 운영 경험을 MySQL/Aurora 환경으로 확장하기 위한 실습 프로젝트입니다. 대용량 게임 로그 조회, InnoDB 인덱스 설계, 잠금·데드락, 백업·시점 복구, 운영 지표 수집을 한 흐름으로 다룹니다.

## 이 프로젝트가 보여 주는 역량

- `EXPLAIN ANALYZE`로 실행계획과 실제 행 수를 비교하고 복합 인덱스를 설계합니다.
- InnoDB의 **클러스터드 인덱스(PK)** 와 **보조 인덱스(secondary index)** 의 재탐색 구조를 확인합니다.
- `SELECT ... FOR UPDATE`로 데드락을 재현하고, 테이블 접근 순서 통일로 해결합니다.
- 전체 백업과 binary log를 이용한 **PITR(Point-In-Time Recovery, 시점 복구)** 흐름을 문서화합니다.
- Performance Schema에서 잠금 대기와 주요 InnoDB 지표를 조회합니다.

## 환경

- Docker Desktop
- MySQL 8.4
- PowerShell 또는 MySQL Client

```powershell
cd mysql-dba-transition-portfolio
docker compose up -d
docker compose exec mysql mysql -uroot -pportfolio_root GameOps
```

초기화 SQL은 컨테이너 첫 생성 때 자동 실행됩니다. 다시 처음부터 구성하려면 아래 명령을 사용합니다. 이 명령은 이 실습 컨테이너의 데이터만 삭제합니다.

```powershell
docker compose down -v
docker compose up -d
```

테스트 데이터와 실습 SQL은 아래처럼 실행합니다.

```powershell
.\run-lab.ps1 -Seed
.\run-lab.ps1 -Exercise execution-plan
.\run-lab.ps1 -Exercise monitoring
```

## 실습 순서

1. `sql/01_schema.sql` — 게임 로그 테이블과 조회용 테이블 생성
2. `sql/02_seed.sql` — 약 100만 건의 테스트 로그 생성
3. `sql/03_execution_plan.sql` — 인덱스 적용 전/후 실행계획 비교
4. `sql/04_deadlock.sql` — 두 세션에서 데드락 재현 및 해결안 확인
5. `sql/05_monitoring.sql` — 잠금과 InnoDB 상태 관찰
6. `docs/backup-and-pitr.md` — 백업 및 binary log 시점 복구 절차 확인

## 검증 결과

환경: Docker Desktop, MySQL 8.4, `GameLog` 1,000,000건. 아래 수치는 `ServerID = 7`과 하루 범위, 최신 100건 조회에서 `EXPLAIN ANALYZE`로 확인했습니다.

| 단계 | 실행계획 | 실제 실행 시간 | 관찰 내용 |
|---|---|---:|---|
| 인덱스 없음 | Table Scan → Filter → Sort → Limit | 약 154ms | 100만 행을 읽고 조건에 맞는 4,320행을 정렬 |
| `(ServerID, CreateAt DESC)` | Index Range Scan | 약 0.42ms | 서버·기간 조건을 인덱스 범위로 축소 |
| 커버링 인덱스 | Covering Index Range Scan | 약 0.08ms | 필요한 조회 컬럼을 인덱스에서 바로 반환 |

데드락, 모니터링, 백업·시점 복구 결과는 각 실습을 완료한 뒤 같은 방식으로 추가합니다.

## SQL Server 경험과의 연결

| SQL Server | MySQL/InnoDB | 이 프로젝트에서 확인하는 내용 |
|---|---|---|
| Clustered Index | Primary Key | PK 리프에 행 데이터 저장 |
| Nonclustered Index + Key Lookup | Secondary Index + PK 재탐색 | 커버링 인덱스 필요성 |
| Buffer Pool | InnoDB Buffer Pool | 페이지 캐시와 Dirty Page |
| LDF(Transaction Log) | Redo Log | 장애 복구를 위한 변경 기록 |
| 로그 백업 | Binary Log | 복제·시점 복구에 쓰는 변경 이력 |
| `UPDLOCK` | `SELECT ... FOR UPDATE` | 변경 예정 행을 먼저 잠금 |

## 범위와 기록 원칙

- 실제 실행 결과와 재현 가능한 절차만 기록합니다.
- SQL Server 운영 경험과 MySQL 실습 경험은 구분합니다.
- 측정값은 Docker Desktop과 로컬 MySQL 8.4 환경에서 확인한 값이며, 운영 환경의 성능을 보장하지 않습니다.
