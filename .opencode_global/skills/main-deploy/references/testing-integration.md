# Main Deploy Testing Integration

## Test Execution Strategy

Main deployments run comprehensive test suites to verify functionality before marking deployment complete.

## Test Groups

### Staging Environment Tests
```bash
# Executed against: .env.{PROJECT}.staging
php artisan test --env=staging
```

**Coverage**:
- API endpoints
- Database operations
- Authentication flows
- Integration tests

### Testing Environment Tests
```bash
# Executed against: .env.{PROJECT}.testing
php artisan migrate:fresh --env=testing --force
php artisan db:seed-dev --env=testing
php artisan test --env=testing
```

**Coverage**:
- Unit tests
- Feature tests
- Isolated database tests
- Service layer tests

### Browser Tests (Dusk)
```bash
# Executed if Dusk is available
php artisan dusk --env=staging
```

**Coverage**:
- End-to-end user flows
- JavaScript functionality
- Form submissions
- Navigation testing

## Test Failure Handling

### Soft Failures (Warnings)
- Individual test failures logged
- Deployment continues
- Summary report shows failures
- User notified to review

### Hard Failures (Blockers)
- Database migration failures → STOP
- Environment validation failures → STOP
- Apache configuration errors → STOP
- Critical dependency errors → STOP

## Monitoring Test Progress

Use $ArchitectCoder to monitor test execution:

```bash
# Look for these markers in logs:
"Running database migrations"
"Running tests"
"PASS Tests\\Feature\\..."
"FAIL Tests\\Feature\\..."
"Tests: X passed, Y failed"
```

## Test Output Formats

**PHPUnit/Pest Standard Output**:
```
PASS  Tests\Feature\ExampleTest
✓ example test passes
✓ another test passes

Tests:  2 passed
Time:   0.5s
```

**Dusk Output**:
```
PHPUnit 9.x by Sebastian Bergmann

.                                                                   1 / 1 (100%)

Time: 00:05.234, Memory: 28.00 MB

OK (1 test, 3 assertions)
```

## Test Database Management

- **Staging DB**: Persistent, re-used across deployments
- **Testing DB**: Fresh migration on every test run
- **Isolation**: Tests in testing DB never affect staging data

## Skipping Tests

Tests run automatically. To skip (not recommended):

```bash
# Not part of deploy-main.sh flags
# Must modify script or run setup commands manually
```

## Test Results Location

- **Console Output**: Captured in trunner log
- **Laravel Logs**: `storage/logs/laravel.log`
- **Coverage Reports**: `storage/test-results/coverage/`
- **Dusk Screenshots**: `tests/Browser/screenshots/`

## CI/CD Integration

Deploy-main.sh designed for:
- Local development deployments
- Automated staging deployments
- Preview environment setups

**NOT designed for**:
- Production deployments (use separate process)
- CI/CD pipelines (use dedicated CI config)
