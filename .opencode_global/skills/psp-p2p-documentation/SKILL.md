---
name: 'PSP-P2P Documentation'
description: 'Comprehensive documentation workflow for PSP-P2P project with feature, bug, and refactor documentation lifecycle management'
triggers: ['$PSPP2PDocumentation']
trigger_keywords: ['psp-p2p docs', 'documentation workflow', 'feature documentation', 'bug documentation', 'refactor documentation']
related_skills: ['$LaravelTestingExcellence', '$LaravelSecurityPatterns', '$LaravelAPIDevelopment']
references: {}
---

# PSP-P2P Documentation Skill

## Purpose
Provide comprehensive documentation workflow for PSP-P2P project with emphasis on proper documentation structure, lifecycle management, and integration with development processes.

## Scope
- **Documentation Structure**: docs/features, docs/bugs, docs/refactors with done/ subfolders
- **Documentation Lifecycle**: Create → Update → Move to done/
- **Feature Documentation**: Documenting new feature implementations
- **Bug Documentation**: Documenting bug fixes and resolutions
- **Refactor Documentation**: Documenting code refactoring and improvements
- **API Documentation**: Maintaining API.md and OpenAPI annotations

## When to Use This Skill

**Trigger Conditions**:
1. Adding new features to PSP-P2P project
2. Fixing bugs in existing code
3. Refactoring or improving existing functionality
4. Updating API endpoints or services
5. Creating new development workflows
6. Documenting project setup or deployment processes

**Examples**:
- "Create proper documentation for payment processing feature using $PSPP2PDocumentation"
- "Document the bug fix for authentication issues following PSP-P2P standards"
- "Set up documentation for the new UPI integration refactor"

## Core Principles

### 1. Documentation Structure

**Primary Documentation Folders**:

```
docs/
├── features/
│   ├── payment-processing.md          # Active feature documentation
│   ├── user-authentication.md        # Active feature documentation
│   └── done/
│       ├── upi-integration.md         # Completed feature documentation
│       └── merchant-panel.md          # Completed feature documentation
├── bugs/
│   ├── null-pointer-auth.md           # Active bug documentation
│   ├── webhook-timeout.md             # Active bug documentation
│   └── done/
│       ├── session-timeout.md         # Fixed bug documentation
│       └── payment-failure.md         # Fixed bug documentation
└── refactors/
    ├── payment-service.md             # Active refactor documentation
    ├── auth-refactor.md               # Active refactor documentation
    └── done/
        ├── api-refactor.md             # Completed refactor documentation
        └── database-optimization.md    # Completed refactor documentation
```

**Additional Documentation Files**:
- `docs/readme.md`: Project overview and getting started
- `docs/API.md`: API documentation and endpoint specifications
- `docs/API-AUTHENTICATION.md`: API authentication patterns
- `docs/deployment.md`: Deployment instructions and environment setup

### 2. Documentation Lifecycle

**Step 1: Create Documentation File**
- Create documentation file in appropriate folder (features, bugs, refactors)
- Use descriptive filenames with kebab-case
- Include initial structure and purpose

**Step 2: Update During Development**
- Document implementation progress
- Add technical details and decisions
- Note challenges and solutions
- Include test results

**Step 3: Move to Done Folder**
- When task is complete, move documentation to corresponding done/ subfolder
- Add completion date and final summary
- Reference related files or documentation

### 3. Documentation Standards

**Markdown Format**:
- Use standard Markdown syntax
- Include proper headings (##, ###)
- Use code blocks for code examples
- Add tables for structured data
- Include links to related documentation

**Content Structure**:
```markdown
# Feature/Bug/Refactor Name

## Purpose
Brief description of what this documentation covers

## Background
Context and reasons for the feature/bug/refactor

## Implementation
Technical details of the implementation

## Files Modified
List of files that were changed

## Testing
Test results and verification steps

## Challenges
Issues encountered and how they were resolved

## Impact
Effect on the system and other components

## Completion Date
Date when the work was completed
```

## Workflow: Feature Documentation

### Phase 1: Initial Documentation

**Step 1.1**: Create feature documentation file

```bash
# For new feature
touch docs/features/payment-processing.md
```

**Step 1.2**: Add initial structure

```markdown
# Payment Processing Feature

## Purpose
Implement payment processing functionality for merchants to accept payments from customers.

## Background
This feature enables merchants to create payment requests, handle payment confirmations, and manage payment status throughout the payment lifecycle.

## Requirements
- Create payment requests with amount and customer details
- Handle payment confirmations from PSP
- Update payment status based on PSP callbacks
- Provide payment history and reporting

## Implementation Plan
- [ ] Create Payment model and migration
- [ ] Implement PaymentService for business logic
- [ ] Create API endpoints for payment creation
- [ ] Implement webhook handling for payment confirmations
- [ ] Add payment status management

## Files to be Modified
- [ ] app/Models/Payment.php (new)
- [ ] app/Services/Payment/PaymentService.php (new)
- [ ] app/Http/Controllers/Api/PaymentController.php (new)
- [ ] database/migrations/xxx_create_payments_table.php (new)
- [ ] routes/api.php (modify)

## Testing Plan
- [ ] Unit tests for PaymentService
- [ ] Feature tests for API endpoints
- [ ] Integration tests for webhook handling

## Progress
- [ ] Initial setup complete
- [ ] Model and migration created
- [ ] Service implementation in progress
```

### Phase 2: Documentation Updates During Development

**Step 2.1**: Update implementation progress

```markdown
## Implementation Progress

### Payment Model
- [x] Created Payment model with required fields
- [x] Implemented relationships with Merchant and User
- [x] Added accessors for formatted amounts

### PaymentService
- [x] Implemented createPayment method
- [x] Added validation for payment amounts
- [x] Implemented status update functionality
- [ ] Payment reconciliation logic in progress

### API Controller
- [x] Created payment creation endpoint
- [x] Added input validation and sanitization
- [x] Implemented proper error handling
- [ ] Response formatting needs improvement

### Webhook Handling
- [x] Created webhook controller for payment confirmations
- [x] Implemented signature verification
- [ ] Status update logic needs testing
```

**Step 2.2**: Document challenges and solutions

```markdown
## Challenges and Solutions

### Challenge: Payment ID Collision
**Problem**: Multiple payment requests with the same order_id causing database conflicts.
**Solution**: Implemented unique constraint on order_id per merchant and added proper error handling.

### Challenge: Webhook Security
**Problem**: Ensuring webhook callbacks are authentic and not tampered with.
**Solution**: Implemented HMAC signature verification using PSP API secret.

### Challenge: Race Conditions
**Problem**: Multiple simultaneous updates to payment status causing inconsistent state.
**Solution**: Added database transactions and proper locking mechanisms.
```

### Phase 3: Completion and Finalization

**Step 3.1**: Final documentation update

```markdown
## Testing Results

### Unit Tests
- [x] PaymentService tests: 15/15 passing
- [x] Payment model tests: 8/8 passing
- [x] Validation tests: 12/12 passing

### Feature Tests
- [x] Payment creation API: 5/5 passing
- [x] Payment status updates: 3/3 passing
- [x] Error handling: 4/4 passing

### Integration Tests
- [x] Webhook processing: 2/2 passing
- [x] Payment reconciliation: 1/1 passing

## Final Implementation Summary

The payment processing feature has been successfully implemented with:
- Secure payment creation with proper validation
- Reliable webhook handling with signature verification
- Robust error handling and logging
- Comprehensive test coverage

## Performance Considerations
- Payment creation: <200ms average response time
- Webhook processing: <100ms average processing time
- Database queries optimized with proper indexes

## Security Measures
- All input sanitized using InputSanitizationService
- HMAC signature verification for webhooks
- Proper authentication and authorization for API endpoints
- Sensitive data encrypted in database

## Completion Date
2025-01-15
```

**Step 3.2**: Move to done folder

```bash
mv docs/features/payment-processing.md docs/features/done/
```

## Workflow: Bug Documentation

### Phase 1: Bug Discovery and Documentation

**Step 1.1**: Create bug documentation file

```bash
# For bug fix
touch docs/bugs/null-pointer-auth.md
```

**Step 1.2**: Document bug details

```markdown
# Null Pointer Exception in Authentication

## Bug Description
Users experiencing null pointer exceptions when trying to authenticate with invalid credentials.

## Error Details
```
TypeError: Return value of App\Models\User::getAuthIdentifier() must be of the type int|null, string returned
in /app/Models/User.php on line 45
```

## Steps to Reproduce
1. Attempt to login with invalid email
2. System attempts to retrieve user record
3. User record not found returns null
4. Authentication method tries to access properties on null object

## Affected Components
- app/Models/User.php
- app/Http/Controllers/Auth/AuthController.php
- app/Services/Auth/AuthService.php

## Priority
High - Affects user login functionality

## Bug Fix Plan
- [ ] Identify root cause in User model
- [ ] Implement null checks in authentication methods
- [ ] Add proper error handling for invalid credentials
- [ ] Create regression tests
- [ ] Verify fix doesn't break existing functionality
```

### Phase 2: Bug Fix Implementation

**Step 2.1**: Document fix implementation

```markdown
## Root Cause Analysis
The issue occurs when User::findByEmail() returns null for non-existent email addresses, but the authentication service doesn't properly handle this case before attempting to access user properties.

## Fix Implementation

### Code Changes
1. **app/Services/Auth/AuthService.php**
   - Added null check after user retrieval
   - Implemented proper error response for invalid credentials

```php
// Before
$user = User::findByEmail($email);
if (!Hash::check($password, $user->password)) {
    return false;
}

// After
$user = User::findByEmail($email);
if (!$user || !Hash::check($password, $user->password)) {
    return false;
}
```

2. **app/Http/Controllers/Auth/AuthController.php**
   - Added specific error message for invalid credentials
   - Improved error logging

```php
// Added error handling
if (!$authResult) {
    Log::warning('Authentication failed', [
        'email' => $request->email,
        'ip' => $request->ip()
    ]);

    return response()->json([
        'success' => false,
        'message' => 'Invalid credentials'
    ], 401);
}
```

## Testing
- [x] Created test for invalid email authentication
- [x] Created test for invalid password authentication
- [x] Verified existing authentication still works
- [x] Checked error responses are properly formatted
```

### Phase 3: Bug Fix Completion

**Step 3.1**: Final documentation

```markdown
## Verification Results
- [x] Invalid email returns proper error message
- [x] Invalid password returns proper error message
- [x] No more null pointer exceptions
- [x] Existing functionality unaffected
- [x] Error logging working correctly

## Impact Assessment
- Fixed authentication failure for invalid credentials
- Improved error messaging for better user experience
- Added proper logging for security monitoring
- No breaking changes to existing API

## Prevention Measures
- Added comprehensive input validation
- Implemented proper null checks throughout authentication flow
- Created regression tests to prevent future occurrences
- Added code review checklist for authentication changes

## Completion Date
2025-01-16
```

**Step 3.2**: Move to done folder

```bash
mv docs/bugs/null-pointer-auth.md docs/bugs/done/
```

## Workflow: Refactor Documentation

### Phase 1: Refactor Planning

**Step 1.1**: Create refactor documentation file

```bash
# For refactor
touch docs/refactors/payment-service.md
```

**Step 1.2**: Document refactor scope

```markdown
# Payment Service Refactor

## Refactor Purpose
Improve code maintainability and performance of payment processing logic by extracting common patterns and implementing better separation of concerns.

## Current Issues
- PaymentService class is too large (500+ lines)
- Mixed responsibilities (validation, processing, notifications)
- Difficult to test individual components
- Performance issues with excessive database queries
- Code duplication across payment methods

## Refactor Goals
- Extract validation logic into separate service
- Create dedicated notification service
- Implement payment method strategy pattern
- Optimize database queries
- Improve testability

## Current Structure
```
app/Services/Payment/PaymentService.php
├── Validation logic (lines 50-150)
├── Payment processing (lines 151-350)
├── Notification logic (lines 351-450)
├── Status updates (lines 451-500)
```

## Target Structure
```
app/Services/Payment/
├── PaymentValidationService.php (new)
├── PaymentProcessingService.php (extract)
├── PaymentNotificationService.php (new)
├── PaymentMethodStrategy/
│   ├── UpiPaymentStrategy.php (new)
│   ├── CardPaymentStrategy.php (new)
│   └── NetBankingPaymentStrategy.php (new)
└── PaymentService.php (refactored)
```

## Refactor Plan
- [ ] Create PaymentValidationService
- [ ] Extract PaymentProcessingService
- [ ] Create PaymentNotificationService
- [ ] Implement payment method strategies
- [ ] Refactor main PaymentService
- [ ] Update controllers to use new services
- [ ] Add comprehensive tests
- [ ] Performance testing
```

### Phase 2: Refactor Implementation

**Step 2.1**: Document progress

```markdown
## Refactor Progress

### Phase 1: Validation Service
- [x] Created PaymentValidationService
- [x] Extracted validation logic from PaymentService
- [x] Added comprehensive validation rules
- [x] Created unit tests for validation service

### Phase 2: Processing Service
- [x] Extracted PaymentProcessingService
- [x] Optimized database queries
- [x] Implemented transaction handling
- [x] Added performance monitoring
- [x] Created unit tests

### Phase 3: Notification Service
- [x] Created PaymentNotificationService
- [x] Implemented queue-based notifications
- [x] Added retry logic for failed notifications
- [x] Created unit tests

### Phase 4: Payment Method Strategies
- [x] Created strategy interface
- [x] Implemented UpiPaymentStrategy
- [x] Implemented CardPaymentStrategy
- [x] Implemented NetBankingPaymentStrategy
- [x] Added strategy factory

### Phase 5: Main Service Refactor
- [x] Refactored PaymentService to use new services
- [x] Maintained backward compatibility
- [x] Updated method signatures
- [x] Added comprehensive tests

## Challenges and Solutions

### Challenge: Backward Compatibility
**Problem**: Existing controllers depend on PaymentService interface.
**Solution**: Maintained existing public methods while delegating to new services.

### Challenge: Database Transaction Management
**Problem**: Multiple service calls needed to be in single transaction.
**Solution**: Implemented transaction wrapper service to coordinate multiple services.

### Challenge: Performance Optimization
**Problem**: Excessive database queries in original implementation.
**Solution**: Implemented query optimization and eager loading patterns.
```

### Phase 3: Refactor Completion

**Step 3.1**: Final documentation

```markdown
## Performance Improvements

### Before Refactor
- Payment creation: 450ms average
- Database queries: 15 per payment
- Memory usage: 25MB per payment
- Test coverage: 65%

### After Refactor
- Payment creation: 180ms average (60% improvement)
- Database queries: 5 per payment (67% reduction)
- Memory usage: 12MB per payment (52% reduction)
- Test coverage: 92%

## Code Quality Improvements

### Metrics
- Cyclomatic complexity: Reduced from 15 to 8 per method
- Class size: Reduced from 500 lines to 120 lines
- Method size: Reduced from 50 lines to 15 lines average
- Coupling: Reduced dependency on external classes

### Maintainability
- Clear separation of concerns
- Single responsibility principle followed
- Dependency injection implemented
- Comprehensive test coverage

## Testing Results
- [x] All existing tests still pass
- [x] New unit tests for all services
- [x] Integration tests for service interactions
- [x] Performance tests show improvements
- [x] Load tests confirm stability

## Migration Notes
- No database schema changes required
- API endpoints unchanged
- No breaking changes to public interfaces
- Backward compatibility maintained

## Completion Date
2025-01-17
```

**Step 3.2**: Move to done folder

```bash
mv docs/refactors/payment-service.md docs/refactors/done/
```

## Best Practices

### Do's
✓ Create documentation file at the start of any task
✓ Update documentation regularly during development
✓ Include technical details and implementation decisions
✓ Document challenges and solutions
✓ Add test results and verification steps
✓ Move documentation to done/ folder when task is complete
✓ Use consistent markdown formatting
✓ Include completion dates in final documentation
✓ Cross-reference related documentation
✓ Keep documentation concise but comprehensive

### Don'ts
✗ Skip documentation for "small" changes
✗ Write documentation after completing the task
✗ Include sensitive information in documentation
✗ Forget to update documentation when requirements change
✗ Leave documentation in active folders after completion
✗ Use inconsistent formatting or structure
✗ Include excessive implementation details
✗ Forget to document challenges and solutions
✗ Skip documentation of test results
✗ Ignore documentation for refactoring tasks

## Integration with Other Skills

### $LaravelTestingExcellence
**Documentation integration**: Test results documented in feature/bug/refactor documentation.

```
$LaravelTestingExcellence executes → Tests
↓
$PSPP2PDocumentation records → Test results
↓
Combined result → Complete implementation record
```

### $LaravelSecurityPatterns
**Security integration**: Security measures documented in relevant documentation files.

```
$LaravelSecurityPatterns implements → Security measures
↓
$PSPP2PDocumentation documents → Security implementations
↓
Result → Security compliance record
```

### $LaravelAPIDevelopment
**API documentation integration**: API changes documented and API.md updated.

```
$LaravelAPIDevelopment creates → New API endpoints
↓
$PSPP2PDocumentation updates → API documentation
↓
Result → Complete API documentation
```

## Common Issues and Solutions

### Documentation Becomes Outdated
**Symptom**: Documentation doesn't match current implementation

**Solution**:
```bash
# Review active documentation files
find docs/features docs/bugs docs/refactors -name "*.md" -not -path "*/done/*"

# Schedule regular documentation reviews
# Add documentation review to pull request checklist
```

### Too Much Detail in Documentation
**Symptom**: Documentation becomes lengthy and hard to read

**Solution**:
- Focus on key decisions and challenges
- Use code snippets sparingly
- Link to code rather than including full implementations
- Use bullet points and concise descriptions

### Missing Documentation for Small Changes
**Symptom**: Small changes and fixes not documented

**Solution**:
```bash
# Create template for small changes
touch docs/bugs/minor-fix-template.md

# Include in development workflow:
# 1. Create documentation file for any change
# 2. Update file during development
# 3. Move to done/ when complete
```

## Success Criteria

✓ Documentation created at start of every task
✓ Regular updates during development process
✓ Technical details and decisions documented
✓ Challenges and solutions recorded
✓ Test results and verification steps included
✓ Documentation moved to done/ folder on completion
✓ Consistent markdown formatting used
✓ Completion dates included in final documentation
✓ Related documentation cross-referenced
✓ API documentation updated when endpoints change

## Related Skills

- **$LaravelTestingExcellence**: For testing documentation and results
- **$LaravelSecurityPatterns**: For security implementation documentation
- **$LaravelAPIDevelopment**: For API endpoint documentation

---

**Remember**: Documentation is not just about recording what was done—it's about creating a knowledge base that helps future developers understand decisions, solve similar problems, and maintain the codebase effectively. Good documentation is as important as good code.
