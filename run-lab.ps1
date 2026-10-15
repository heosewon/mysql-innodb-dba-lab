param(
    [switch]$Seed,
    [ValidateSet('execution-plan', 'deadlock', 'monitoring')]
    [string]$Exercise
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'Docker Desktop이 필요합니다. 설치·실행한 뒤 다시 시도하세요.'
}

docker compose up -d

if ($Seed) {
    Get-Content -Raw "$PSScriptRoot\sql\02_seed.sql" |
        docker compose exec -T mysql mysql -uroot -pportfolio_root GameOps
}

if ($Exercise) {
    $file = switch ($Exercise) {
        'execution-plan' { '03_execution_plan.sql' }
        'deadlock'        { '04_deadlock.sql' }
        'monitoring'      { '05_monitoring.sql' }
    }

    Get-Content -Raw "$PSScriptRoot\sql\$file" |
        docker compose exec -T mysql mysql -uroot -pportfolio_root GameOps
}
