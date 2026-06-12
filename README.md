# git-fluky

Анализатор нестабильных (flaky) тестов в GitHub Actions.

## Быстрый старт

### 1. Авторизация

```bash
gh auth login
```

Выберите GitHub.com → HTTPS → авторизацию через браузер.

### 2. Анализ репозитория

```bash
chmod +x analyze-flaky.sh
./analyze-flaky.sh owner/repo
# или с указанием количества запусков:
./analyze-flaky.sh owner/repo 100
```

### 3. Просмотр конкретного упавшего запуска

```bash
gh run view <run_id> --repo owner/repo --log-failed
```

## Что показывает скрипт

- Общее количество запусков / упавших / успешных
- Процент ошибок
- Топ-10 workflow по количеству падений
- ID последних упавших запусков с веткой и датой
