---
name: 'Laravel Testing Excellence'
description: 'Comprehensive testing workflow for Laravel projects with atomic TDD implementation, test grouping strategies, and verification patterns'
triggers: ['$LaravelTestingExcellence']
trigger_keywords: ['laravel testing', 'test workflow', 'atomic testing', 'tdd implementation', 'php testing']
related_skills: ['$TmuxProtectedExecution', '$SurgicalImplementation', '$ArchitectCoder']
references: {}
---

# Laravel Testing Excellence Skill

## Purpose
Provide a comprehensive, atomic testing workflow for Laravel 10+ projects with emphasis on TDD methodology, intelligent test grouping, minimal integration testing, and token-efficient execution patterns.

## Scope
- **Atomic TDD workflow**: Test-first development with iterative implementation
- **Test grouping strategies**: Parallel execution and log-dependent sequencing
- **Token-efficient execution**: Background test running via trunner
- **Minimal integration testing**: Focus on unit/feature tests, manual acceptance testing
- **Documentation workflow**: Test documentation lifecycle management

## When to Use This Skill

**Trigger Conditions**:
1. Implementing new Laravel features with test coverage
2. Fixing bugs that require test verification
3. Refactoring code with regression prevention
4. Setting up test infrastructure for Laravel projects
5. User explicitly mentions testing workflows or TDD

**Examples**:
- "Implement user authentication with $LaravelTestingExcellence approach"
- "Use TDD to add payment processing feature"
- "Setup Laravel testing workflow with proper test grouping"

## Core Principles

### 1. Atomic Implementation Approach
**Break features into smallest testable units**. After each atomic change:
1. Add/update specific test for that unit
2. Run the specific test to ensure it passes
3. Run full test suite to verify no regressions
4. Move to next atomic unit

**Anti-pattern**: Adding multiple features then running all tests → increases debugging complexity.

### 2. Test-First Mentality
Write test BEFORE implementing feature logic:
```
Test (Red) → Implementation (Green) → Refactor → Verify → Next
```

### 3. Intelligent Test Grouping
Laravel PHPUnit supports test groups for execution control:

- **parallel** (default): Tests that can run concurrently
- **log-dependent**: Tests that interact with log files (must run sequentially)
- **integration**: Minimal integration tests for critical paths only
- **unit**: Pure unit tests (fastest execution)

**Annotation Example**:
```php
/**
 * @group log-dependent
 */
public function test_log_entry_created()
{
    // Test that writes/reads logs
}
```

### 4. Minimal Integration Testing
**Philosophy**: Keep integration tests VERY minimal, focusing only on core happy paths.

**Rationale**:
- Prioritize developer experience (DX) and simplicity
- Manual acceptance testing catches edge cases
- Integration tests are slower and more brittle
- Trade-off: Faster development velocity over exhaustive automation

**What to test**:
✓ Core happy path end-to-end flows
✓ Critical authentication/authorization paths
✓ Payment processing success scenarios

**What NOT to test**:
✗ Every edge case and error condition
✗ UI interactions (use Dusk sparingly, prone to DNS issues in worktrees)
✗ Third-party API integrations (mock them)

### 5. Test Encapsulation
**Goal**: Tests should be self-contained and not modify unrelated logic.

- Minimize shared state between tests
- Use database transactions or `RefreshDatabase` trait
- Mock external dependencies
- Avoid coupling tests to implementation details

## Workflow: Feature Implementation with Tests

### Phase 1: Planning and Setup

**Step 1.1**: Break feature into atomic, testable units

```
Feature: User Registration
↓
Atomic Units:
1. Validate email format
2. Check email uniqueness
3. Hash password
4. Create user record
5. Send welcome email (async)
```

**Step 1.2**: Identify test groups for each unit

```
Unit 1-4: @group parallel (can run concurrently)
Unit 5: @group log-dependent (if logging email dispatch)
```

**Step 1.3**: Setup test environment (if needed)

```bash
# Ensure log channels are configured
php artisan logging:setup --test
```

### Phase 2: Atomic Implementation Loop

For **each atomic unit**:

**Step 2.1**: Write failing test first (RED)

```php
<?php
/** @test */
public function user_email_must_be_valid()
{
    $this->post('/api/register', [
        'email' => 'invalid-email'
    ])->assertStatus(422)
      ->assertJsonValidationErrors('email');
}
```

**Step 2.2**: Run specific test (expect failure)

```bash
# Using trunner for token efficiency
trunner "php artisan test --filter=user_email_must_be_valid"

# Monitor briefly
sleep 5 && tail -20 /tmp/test_suite_output_tmux-runner-*.log
```

**Step 2.3**: Implement minimal code to make test pass (GREEN)

```php
// In RegisterController or FormRequest
'email' => ['required', 'email', 'max:255']
```

**Step 2.4**: Run specific test again (expect success)

```bash
trunner "php artisan test --filter=user_email_must_be_valid"
```

**Step 2.5**: Run full test suite (verify no regressions)

```bash
# Use project's test runner script for proper group orchestration
trunner "./run_full_test_suite.sh"

# Monitor progress
sleep 10 && tail -30 /tmp/test_suite_output_tmux-runner-*.log
```

**Step 2.6**: Document test implementation

- If implementing feature: Add notes to `docs/features/<feature-name>.md`
- If fixing bug: Add notes to `docs/bugs/<bug-name>.md`
- If refactoring: Add notes to `docs/refactors/<refactor-name>.md`

**Step 2.7**: Proceed to next atomic unit

Repeat steps 2.1-2.6 for each remaining unit.

### Phase 3: Integration Testing (Minimal)

**Only after all units pass**, add minimal integration test for happy path:

```php
<?php
/** @test */
public function user_can_complete_registration_flow()
{
    $response = $this->post('/api/register', [
        'name' => 'John Doe',
        'email' => 'john@example.com',
        'password' => 'SecurePassword123',
        'password_confirmation' => 'SecurePassword123'
    ]);

    $response->assertStatus(201);
    $this->assertDatabaseHas('users', [
        'email' => 'john@example.com'
    ]);
}
```

Run integration tests separately if needed:
```bash
trunner "php artisan test --group=integration"
```

### Phase 4: Verification and Documentation

**Step 4.1**: Run full test suite one final time

```bash
trunner "./run_full_test_suite.sh"
```

**Step 4.2**: Verify all tests pass

```bash
# Check final output
tail -50 /tmp/test_suite_output_tmux-runner-*.log | grep -E "PASS|FAIL|Error"
```

**Step 4.3**: Move documentation to completed folder

```bash
# For completed feature
mv docs/features/user-registration.md docs/features/done/

# For completed bug fix
mv docs/bugs/null-pointer-login.md docs/bugs/done/

# For completed refactor
mv docs/refactors/auth-refactor.md docs/refactors/done/
```

## Test Execution Strategies

### Using Project Test Runner Scripts

**Recommended approach**: Use project-provided scripts that handle test group orchestration:

```bash
# Full test suite (unit + feature tests with proper grouping)
trunner "./run_full_test_suite.sh"

# Production tests (E2E, Playwright, UI-heavy)
trunner "./run_production_tests.sh"

# With specific flags (see script --help for options)
trunner "./run_full_test_suite.sh --group=unit"
trunner "./run_full_test_suite.sh --exclude-group=log-dependent"
```

**Why use scripts over direct `php artisan test`?**
- Scripts orchestrate parallel and sequential execution correctly
- Handle log-dependent tests specially (sequential execution)
- Provide consistent flags and options
- Avoid race conditions with log files

### Direct PHPUnit Commands (Use Sparingly)

Only use direct commands for targeted debugging:

```bash
# Single test method
trunner "php artisan test --filter=test_method_name"

# Single test class
trunner "php artisan test tests/Feature/UserRegistrationTest.php"

# Specific group
trunner "php artisan test --group=unit"

# Exclude group
trunner "php artisan test --exclude-group=integration"
```

### Monitoring Long-Running Tests

**Token-efficient polling pattern**:

```bash
# Start test suite
trunner "./run_full_test_suite.sh"

# Note session ID from output
# SESSION_ID: tmux-runner-1234567890-12345

# Poll progress (STRICT: use sleep 5 only)
sleep 5 && tail -10 /tmp/test_suite_output_tmux-runner-1234567890-12345.log

# Repeat polling as needed
sleep 5 && tail -20 /tmp/test_suite_output_tmux-runner-1234567890-12345.log

# Check for completion
tail -30 /tmp/test_suite_output_tmux-runner-1234567890-12345.log | grep -i "complete\|error\|done"
```

**Never**: Use longer sleep times (slows workflow) or attach to tmux session (human-only).

## Test Group Strategies

### When to Use Each Group

| Group | Use Case | Execution | Example |
|-------|----------|-----------|---------|
| No annotation (parallel) | Default for all tests | Concurrent | Unit tests, isolated feature tests |
| @group log-dependent | Tests that write/read logs | Sequential | Logging tests, audit trail tests |
| @group integration | Minimal happy path E2E tests | Parallel | Registration flow, checkout flow |
| @group unit | Pure unit tests (no DB) | Parallel | Validation tests, helper tests |

### Defining Custom Groups

```php
/**
 * Test payment processing creates audit log
 *
 * @group log-dependent
 * @group payment
 */
public function test_payment_creates_audit_log()
{
    // Implementation
}
```

### Running Specific Groups

```bash
# Run only log-dependent tests (sequentially)
trunner "php artisan test --group=log-dependent"

# Run everything except integration
trunner "php artisan test --exclude-group=integration"

# Multiple groups (AND logic)
trunner "php artisan test --group=payment --group=log-dependent"
```

## Documentation Workflow

### Documentation Structure

```
docs/
├── features/
│   ├── user-registration.md      # Active feature documentation
│   └── done/
│       └── oauth-login.md          # Completed feature documentation
├── bugs/
│   ├── null-pointer-auth.md       # Active bug documentation
│   └── done/
│       └── session-timeout.md      # Fixed bug documentation
└── refactors/
    ├── payment-service.md         # Active refactor documentation
    └── done/
        └── auth-service.md         # Completed refactor documentation
```

### Documentation Lifecycle

**1. Start**: Create documentation file

```bash
# For new feature
touch docs/features/user-registration.md

# For bug fix
touch docs/bugs/null-pointer-auth.md

# For refactor
touch docs/refactors/payment-service.md
```

**2. During development**: Add test implementation notes

```markdown
## Test Implementation

### Unit Tests
- [x] Email validation test (test_email_must_be_valid)
- [x] Unique email test (test_email_must_be_unique)
- [ ] Password hashing test (test_password_is_hashed)

### Integration Tests
- [ ] Complete registration flow (test_user_can_register)

### Test Results
- Unit tests: 2/3 passing
- Next: Implement password hashing
```

**3. On completion**: Move to done folder

```bash
mv docs/features/user-registration.md docs/features/done/
```

## Best Practices

### Do's
✓ Write test BEFORE implementation (true TDD)
✓ Keep tests atomic and focused on single responsibility
✓ Use `@group log-dependent` for tests that interact with logs
✓ Run specific test after each atomic change
✓ Run full suite to verify no regressions
✓ Use project test runner scripts for proper orchestration
✓ Keep integration tests minimal (happy paths only)
✓ Document test implementation progress
✓ Use trunner for all test executions (token efficiency)
✓ Poll logs with `sleep 5 && tail -N` pattern

### Don'ts
✗ Add multiple features before running tests
✗ Skip regression verification (full suite)
✗ Create exhaustive integration tests
✗ Modify existing logic unrelated to feature
✗ Run tests synchronously (blocks agent)
✗ Use longer sleep times for polling
✗ Forget to move documentation on completion
✗ Couple tests to implementation details
✗ Skip test groups annotation for log-dependent tests

## Common Workflows

### Workflow 1: New Feature with TDD

```bash
# 1. Create feature documentation
touch docs/features/payment-processing.md

# 2. For each atomic unit:
#    - Write failing test
#    - Run specific test (expect RED)
trunner "php artisan test --filter=test_payment_validation"

#    - Implement minimal code
#    - Run specific test (expect GREEN)
trunner "php artisan test --filter=test_payment_validation"

#    - Run full suite (verify no regressions)
trunner "./run_full_test_suite.sh"

#    - Document progress
#    - Move to next unit

# 3. Add minimal integration test
#    - Write happy path test
#    - Run integration tests
trunner "php artisan test --group=integration"

# 4. Final verification
trunner "./run_full_test_suite.sh"

# 5. Move documentation
mv docs/features/payment-processing.md docs/features/done/
```

### Workflow 2: Bug Fix with Regression Test

```bash
# 1. Create bug documentation
touch docs/bugs/null-pointer-auth.md

# 2. Write failing test that reproduces bug
# 3. Run test (expect FAIL - confirms bug)
trunner "php artisan test --filter=test_auth_handles_null_user"

# 4. Fix the bug
# 5. Run test (expect PASS - confirms fix)
trunner "php artisan test --filter=test_auth_handles_null_user"

# 6. Run full suite (verify no regressions)
trunner "./run_full_test_suite.sh"

# 7. Move documentation
mv docs/bugs/null-pointer-auth.md docs/bugs/done/
```

### Workflow 3: Refactoring with Test Coverage

```bash
# 1. Create refactor documentation
touch docs/refactors/auth-service-refactor.md

# 2. Run baseline tests BEFORE refactoring
trunner "./run_full_test_suite.sh"

# 3. Document baseline results

# 4. Refactor code incrementally
#    - Small refactor
#    - Run affected tests
trunner "php artisan test tests/Feature/AuthTest.php"

#    - Run full suite
trunner "./run_full_test_suite.sh"

#    - Repeat for each refactor step

# 5. Final verification
trunner "./run_full_test_suite.sh"

# 6. Move documentation
mv docs/refactors/auth-service-refactor.md docs/refactors/done/
```

## Integration with Other Skills

### $TmuxProtectedExecution
**Primary integration**: All test execution uses trunner for token efficiency.

```
$LaravelTestingExcellence triggers → Test execution needed
↓
$TmuxProtectedExecution activated → Background execution
↓
Monitor via log files → Continue other work
↓
Verify results → Proceed with next step
```

### $SurgicalImplementation
**Implementation pattern**: After test planning, use surgical edits.

```
$LaravelTestingExcellence planning → Identify units to test
↓
$SurgicalImplementation → Make precise code changes
↓
$LaravelTestingExcellence verification → Run tests
```

### $ArchitectCoder
**Orchestration pattern**: Architect plans testing strategy, coder implements.

```
Architect ($LaravelTestingExcellence) → Plan test structure
↓
Delegate to Coder → Implement tests + code
↓
Coder uses $TmuxProtectedExecution → Run tests in background
↓
Report back to Architect → Verify and proceed
```

## Troubleshooting

### Tests Hanging or Timing Out
**Symptom**: Test execution stalls indefinitely

**Solutions**:
```bash
# Check if trunner session is still running
./tmux-runner.sh --list

# Check log file for last output
tail -50 /tmp/test_suite_output_tmux-runner-*.log

# Kill hanging session
./tmux-runner.sh --kill SESSION_ID

# Restart with verbose output
trunner "php artisan test --verbose"
```

### Log-Dependent Test Failures
**Symptom**: Inconsistent failures in tests that write/read logs

**Solutions**:
```bash
# Ensure tests are marked with @group log-dependent
grep -r "@group log-dependent" tests/

# Use script that handles sequential execution
trunner "./run_full_test_suite.sh"  # Handles log-dependent properly

# Or run log-dependent tests separately
trunner "php artisan test --group=log-dependent"
```

### Database State Issues
**Symptom**: Tests fail due to shared database state

**Solutions**:
```php
// Use RefreshDatabase trait
use Illuminate\Foundation\Testing\RefreshDatabase;

class UserTest extends TestCase
{
    use RefreshDatabase;

    // Tests run in transaction, auto-rollback
}

// Or use DatabaseTransactions trait
use Illuminate\Foundation\Testing\DatabaseTransactions;
```

### Dusk Test DNS Errors
**Symptom**: `net::ERR_NAME_NOT_RESOLVED` in Dusk/browser tests

**Solution**:
```php
// Comment out affected test method
// Document in deployment plan
/**
 * @test
 * FIXME: DNS resolution issue in worktree environment
 * Requires manual DNS record verification
 */
// public function test_user_can_login_via_browser()
// {
//     // Test implementation
// }
```

## Success Criteria

✓ Tests written BEFORE implementation (true TDD)
✓ Each atomic unit has specific test coverage
✓ Full test suite passes after each atomic change
✓ Log-dependent tests properly annotated and sequenced
✓ Integration tests kept minimal (happy paths only)
✓ All test execution via trunner (token-efficient)
✓ Documentation lifecycle maintained
✓ No regressions introduced during development

## Related Skills

- **$TmuxProtectedExecution**: For token-efficient test execution in background
- **$SurgicalImplementation**: For precise code modifications guided by tests
- **$ArchitectCoder**: For orchestrating test-driven development workflows
- **$PSPP2PDocumentation**: For project-specific documentation structure

---

**Remember**: The goal is NOT exhaustive test coverage. The goal is CONFIDENT, ATOMIC development with MINIMAL integration testing, prioritizing developer experience and velocity. Trust the process: Test → Implement → Verify → Document → Next.
