---
name: 'Laravel Security Patterns'
description: 'Comprehensive security implementation for Laravel projects with input sanitization, authentication patterns, OWASP compliance, and PSP-P2P specific security requirements'
triggers: ['$LaravelSecurityPatterns']
trigger_keywords: ['laravel security', 'input sanitization', 'api authentication', 'hmac signature', 'owasp security', 'rate limiting']
related_skills: ['$LaravelAPIDevelopment', '$LaravelTestingExcellence', '$PSPP2PDocumentation']
references: {}
---

# Laravel Security Patterns Skill

## Purpose
Provide comprehensive security implementation patterns for Laravel 10+ projects with emphasis on PSP-P2P specific requirements including input sanitization, HMAC authentication, OWASP compliance, and environment variable management.

## Scope
- **Input Sanitization**: Using InputSanitizationService for data cleaning
- **Authentication Patterns**: HMAC signature verification with ApiAuthService
- **Authorization Patterns**: Role-based access control and permissions
- **OWASP Security**: Implementing OWASP guidelines for Laravel applications
- **Environment Security**: Proper handling of sensitive data and configuration
- **Rate Limiting**: Throttling and abuse prevention mechanisms
- **Security Middleware**: Request filtering and security headers

## When to Use This Skill

**Trigger Conditions**:
1. Implementing authentication/authorization in Laravel projects
2. Sanitizing user input or API payloads
3. Setting up HMAC signature verification for API endpoints
4. Implementing OWASP security guidelines
5. Managing environment variables and sensitive data
6. Setting up rate limiting for API endpoints
7. Implementing security middleware

**Examples**:
- "Implement secure API authentication using $LaravelSecurityPatterns"
- "Add input sanitization to payment processing endpoints"
- "Set up HMAC signature verification following PSP-P2P patterns"
- "Implement OWASP security guidelines for Laravel application"

## Core Principles

### 1. Input Sanitization Patterns

**Always sanitize input data** before processing or storage:

```php
<?php

namespace App\Services;

class InputSanitizationService
{
    public function sanitizeString(string $input): string
    {
        return htmlspecialchars(strip_tags(trim($input)), ENT_QUOTES, 'UTF-8');
    }

    public function sanitizeEmail(string $email): string
    {
        return filter_var(trim(strtolower($email)), FILTER_SANITIZE_EMAIL);
    }

    public function sanitizeNumeric(mixed $input): float
    {
        return filter_var($input, FILTER_SANITIZE_NUMBER_FLOAT, FILTER_FLAG_ALLOW_FRACTION);
    }

    public function sanitizeArray(array $data): array
    {
        return array_map(function ($item) {
            if (is_string($item)) {
                return $this->sanitizeString($item);
            }
            return $item;
        }, $data);
    }
}
```

**Implementation in Form Requests**:

```php
<?php

namespace App\Http\Requests;

use App\Services\InputSanitizationService;

class PaymentRequest extends FormRequest
{
    protected InputSanitizationService $sanitizer;

    public function __construct(InputSanitizationService $sanitizer)
    {
        $this->sanitizer = $sanitizer;
    }

    protected function prepareForValidation()
    {
        $this->merge([
            'customer_email' => $this->sanitizer->sanitizeEmail($this->customer_email),
            'order_id' => $this->sanitizer->sanitizeString($this->order_id),
            'amount' => $this->sanitizer->sanitizeNumeric($this->amount),
        ]);
    }

    public function rules(): array
    {
        return [
            'customer_email' => ['required', 'email'],
            'order_id' => ['required', 'string', 'max:255'],
            'amount' => ['required', 'numeric', 'min:0.01'],
        ];
    }
}
```

### 2. HMAC Authentication Pattern

**PSP-P2P API Authentication** requires three headers:

```php
// Required headers for all merchant-facing API calls
X-API-KEY: merchant_api_key
X-API-SIGNATURE: hmac_sha256_signature
X-REQUEST-ID: unique_request_identifier
```

**Signature Generation (Client-side)**:

```php
function generateSignature(string $body, string $timestamp, string $requestId, string $apiSecret): string
{
    $payload = $body . $timestamp . $requestId;
    return hash_hmac('sha256', $payload, $apiSecret);
}

// Example usage
$body = json_encode([
    'amount' => 1000,
    'currency' => 'INR',
    'order_id' => 'ORD123456'
]);
$timestamp = time();
$requestId = uniqid();
$signature = generateSignature($body, $timestamp, $requestId, $apiSecret);
```

**Signature Verification (Server-side)**:

```php
<?php

namespace App\Services\Auth;

use App\Models\Merchant;
use Illuminate\Http\Request;

class ApiAuthService
{
    public function verifySignature(Request $request): bool
    {
        $apiKey = $request->header('X-API-KEY');
        $signature = $request->header('X-API-SIGNATURE');
        $requestId = $request->header('X-REQUEST-ID');

        if (!$apiKey || !$signature || !$requestId) {
            return false;
        }

        $merchant = Merchant::where('api_key', $apiKey)->first();

        if (!$merchant) {
            return false;
        }

        $expectedSignature = hash_hmac(
            'sha256',
            $request->getContent() . $request->header('X-TIMESTAMP', time()) . $requestId,
            $merchant->api_secret
        );

        return hash_equals($expectedSignature, $signature);
    }

    public function generateResponseSignature(string $responseBody, string $requestId, string $apiSecret): string
    {
        return hash_hmac('sha256', $responseBody . $requestId, $apiSecret);
    }
}
```

**Authentication Middleware**:

```php
<?php

namespace App\Http\Middleware;

use App\Services\Auth\ApiAuthService;
use Closure;
use Illuminate\Http\Request;

class VerifyApiSignature
{
    private ApiAuthService $authService;

    public function __construct(ApiAuthService $authService)
    {
        $this->authService = $authService;
    }

    public function handle(Request $request, Closure $next)
    {
        if (!$this->authService->verifySignature($request)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid or missing authentication credentials'
            ], 401);
        }

        // Add merchant to request for use in controllers
        $merchant = $this->authService->getMerchantFromRequest($request);
        $request->merge(['merchant' => $merchant]);

        return $next($request);
    }
}
```

### 3. Authorization Patterns

**Role-based Access Control**:

```php
<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use Notifiable;

    protected $fillable = [
        'name', 'email', 'password', 'is_admin'
    ];

    protected $hidden = [
        'password', 'remember_token'
    ];

    protected $casts = [
        'is_admin' => 'boolean',
    ];

    public function hasPermission(string $permission): bool
    {
        if ($this->is_admin) {
            return true;
        }

        return $this->permissions()->where('name', $permission)->exists();
    }

    public function permissions()
    {
        return $this->belongsToMany(Permission::class);
    }
}
```

**Policy-based Authorization**:

```php
<?php

namespace App\Policies;

use App\Models\Payment;
use App\Models\User;

class PaymentPolicy
{
    public function view(User $user, Payment $payment): bool
    {
        return $user->id === $payment->user_id || $user->is_admin;
    }

    public function update(User $user, Payment $payment): bool
    {
        return $user->id === $payment->user_id;
    }

    public function delete(User $user, Payment $payment): bool
    {
        return $user->is_admin;
    }
}
```

### 4. OWASP Security Guidelines

**SQL Injection Prevention**:

```php
// Always use parameterized queries (Eloquent does this by default)
$users = User::where('email', $email)->get(); // Safe

// Never use raw queries with user input
$users = DB::select("SELECT * FROM users WHERE email = '$email'"); // DANGEROUS

// If you must use raw queries, use parameter binding
$users = DB::select("SELECT * FROM users WHERE email = ?", [$email]); // Safe
```

**Cross-Site Scripting (XSS) Prevention**:

```php
// Escape output in Blade templates
{{ $userInput }} // Escaped by default

{!! $userInput !!} // Unescaped - only use for trusted content

// In controllers, sanitize before storage
$sanitizedInput = htmlspecialchars($userInput, ENT_QUOTES, 'UTF-8');
```

**Cross-Site Request Forgery (CSRF) Prevention**:

```php
// Verify CSRF token in routes
Route::post('/payment', function () {
    // Laravel automatically verifies CSRF token
})->middleware(['web', 'auth']);

// For API routes, use token-based authentication
Route::middleware(['auth:api'])->group(function () {
    // API routes protected by token authentication
});
```

**Security Headers Middleware**:

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class SecurityHeaders
{
    public function handle(Request $request, Closure $next)
    {
        $response = $next($request);

        $response->headers->set('X-Content-Type-Options', 'nosniff');
        $response->headers->set('X-Frame-Options', 'DENY');
        $response->headers->set('X-XSS-Protection', '1; mode=block');
        $response->headers->set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
        $response->headers->set('Content-Security-Policy', "default-src 'self'");

        return $response;
    }
}
```

### 5. Environment Variable Management

**Secure Environment Configuration**:

```php
// config/services.php
return [
    'payment_gateway' => [
        'api_key' => env('PAYMENT_GATEWAY_API_KEY'),
        'api_secret' => env('PAYMENT_GATEWAY_API_SECRET'),
        'webhook_secret' => env('PAYMENT_GATEWAY_WEBHOOK_SECRET'),
    ],
];
```

**Environment Variable Validation**:

```php
<?php

namespace App\Providers;

use Illuminate\Support\Facades\Validator;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        Validator::extend('required_env', function ($attribute, $value, $parameters) {
            return !empty(env($value));
        });
    }
}
```

**Encrypted Environment Variables**:

```bash
# Encrypt sensitive environment variables
php artisan env:encrypt

# Decrypt when deploying
php artisan env:decrypt --key=your-encryption-key
```

### 6. Rate Limiting Implementation

**API Rate Limiting**:

```php
// routes/api.php
Route::middleware('throttle:60,1')->group(function () {
    Route::post('/payin', [PaymentController::class, 'processPayin']);
    // 60 requests per minute
});

// Different limits for different user types
Route::middleware('throttle:30,1')->group(function () {
    Route::post('/admin/users', [AdminController::class, 'createUser']);
    // 30 requests per minute for admin endpoints
});
```

**Custom Rate Limiting Rules**:

```php
<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class RouteServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        RateLimiter::for('api', function (Request $request) {
            return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
        });

        RateLimiter::for('payments', function (Request $request) {
            return $request->user()
                ? Limit::perMinute(30)->by($request->user()->id)
                : Limit::perMinute(5)->by($request->ip());
        });
    }
}
```

## Workflow: Implementing Secure API Endpoint

### Phase 1: Planning and Setup

**Step 1.1**: Identify security requirements

```
Endpoint: POST /api/v1/payin
Authentication: HMAC signature (X-API-KEY, X-API-SIGNATURE, X-REQUEST-ID)
Input Sanitization: Amount, currency, order_id, customer_email
Rate Limiting: 30 requests per minute per authenticated user
Rate Limiting: 5 requests per minute per unauthenticated IP
```

**Step 1.2**: Set up authentication middleware

```php
// app/Http/Kernel.php
protected $middlewareGroups = [
    'api' => [
        \App\Http\Middleware\SecurityHeaders::class,
        'throttle:api',
    ],
];

protected $middlewareAliases = [
    'api.signature' => \App\Http\Middleware\VerifyApiSignature::class,
];
```

### Phase 2: Implementation

**Step 2.1**: Create Form Request with input sanitization

```bash
php artisan make:request Api/PayinRequest
```

```php
<?php

namespace App\Http\Requests\Api;

use App\Services\InputSanitizationService;
use Illuminate\Foundation\Http\FormRequest;

class PayinRequest extends FormRequest
{
    private InputSanitizationService $sanitizer;

    public function __construct(InputSanitizationService $sanitizer)
    {
        $this->sanitizer = $sanitizer;
    }

    protected function prepareForValidation()
    {
        $this->merge([
            'amount' => $this->sanitizer->sanitizeNumeric($this->amount),
            'currency' => $this->sanitizer->sanitizeString(strtoupper($this->currency)),
            'order_id' => $this->sanitizer->sanitizeString($this->order_id),
            'customer_email' => $this->sanitizer->sanitizeEmail($this->customer_email),
        ]);
    }

    public function authorize(): bool
    {
        // Authorization handled by VerifyApiSignature middleware
        return true;
    }

    public function rules(): array
    {
        return [
            'amount' => ['required', 'numeric', 'min:0.01', 'max:100000'],
            'currency' => ['required', 'string', 'in:INR,USD'],
            'order_id' => ['required', 'string', 'max:255'],
            'customer_email' => ['required', 'email'],
        ];
    }
}
```

**Step 2.2**: Create secure controller

```bash
php artisan make:controller Api/PaymentController
```

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\PayinRequest;
use App\Http\Resources\PaymentResource;
use App\Models\Merchant;
use App\Services\Payment\PaymentService;
use Illuminate\Http\JsonResponse;

class PaymentController extends Controller
{
    private PaymentService $paymentService;

    public function __construct(PaymentService $paymentService)
    {
        $this->paymentService = $paymentService;
    }

    /**
     * Process payment request with HMAC authentication
     */
    public function processPayin(PayinRequest $request): JsonResponse
    {
        try {
            // Get merchant from middleware
            $merchant = $request->input('merchant');

            // Create payment with validated (sanitized) data
            $payment = $this->paymentService->createPayment(
                $request->validated(),
                $merchant
            );

            return (new PaymentResource($payment))
                ->response()
                ->setStatusCode(201);

        } catch (\Exception $e) {
            // Log error without exposing sensitive information
            \Log::error('Payment processing failed', [
                'order_id' => $request->order_id,
                'merchant_id' => $merchant->id ?? null,
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Payment processing failed'
            ], 500);
        }
    }
}
```

**Step 2.3**: Set up secure routes

```php
// routes/api.php
use App\Http\Controllers\Api\PaymentController;

Route::prefix('v1')->group(function () {
    Route::middleware(['api.signature', 'throttle:payments'])->group(function () {
        Route::post('/payin', [PaymentController::class, 'processPayin']);
    });
});
```

**Step 2.4**: Create secure service class

```php
<?php

namespace App\Services\Payment;

use App\Models\Merchant;
use App\Models\Payment;
use Illuminate\Database\Eloquent\Model;

class PaymentService
{
    public function createPayment(array $data, Merchant $merchant): Model
    {
        // Additional validation in service layer
        $this->validatePaymentAmount($data['amount'], $merchant);

        return Payment::create([
            'merchant_id' => $merchant->id,
            'order_id' => $data['order_id'],
            'amount' => $data['amount'],
            'currency' => $data['currency'],
            'customer_email' => $data['customer_email'],
            'status' => 'pending',
        ]);
    }

    private function validatePaymentAmount(float $amount, Merchant $merchant): void
    {
        if ($amount > $merchant->max_transaction_amount) {
            throw new \InvalidArgumentException('Amount exceeds merchant limit');
        }
    }
}
```

### Phase 3: Testing

**Step 3.1**: Create security tests

```php
<?php

namespace Tests\Feature\Api;

use App\Models\Merchant;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PaymentSecurityTest extends TestCase
{
    use RefreshDatabase;

    private Merchant $merchant;

    protected function setUp(): void
    {
        parent::setUp();

        $this->merchant = Merchant::factory()->create([
            'api_key' => 'test_api_key',
            'api_secret' => 'test_api_secret',
        ]);
    }

    /** @test */
    public function payment_endpoint_requires_authentication()
    {
        $response = $this->postJson('/api/v1/payin', [
            'amount' => 1000,
            'currency' => 'INR',
            'order_id' => 'ORD123456',
            'customer_email' => 'test@example.com'
        ]);

        $response->assertStatus(401)
                 ->assertJson(['success' => false]);
    }

    /** @test */
    public function payment_endpoint_accepts_valid_hmac_signature()
    {
        $body = json_encode([
            'amount' => 1000,
            'currency' => 'INR',
            'order_id' => 'ORD123456',
            'customer_email' => 'test@example.com'
        ]);

        $timestamp = time();
        $requestId = 'test-request-id';
        $signature = hash_hmac(
            'sha256',
            $body . $timestamp . $requestId,
            $this->merchant->api_secret
        );

        $response = $this->postJson('/api/v1/payin', json_decode($body, true), [
            'X-API-KEY' => $this->merchant->api_key,
            'X-API-SIGNATURE' => $signature,
            'X-REQUEST-ID' => $requestId,
            'X-TIMESTAMP' => $timestamp,
        ]);

        $response->assertStatus(201);
    }

    /** @test */
    public function payment_endpoint_sanitizes_input()
    {
        $body = json_encode([
            'amount' => '<script>alert("xss")</script>1000',
            'currency' => 'inr',  // Should be converted to uppercase
            'order_id' => '  ORD123456  ',  // Should be trimmed
            'customer_email' => 'Test@Example.COM'  // Should be lowercase
        ]);

        $timestamp = time();
        $requestId = 'test-request-id';
        $signature = hash_hmac(
            'sha256',
            $body . $timestamp . $requestId,
            $this->merchant->api_secret
        );

        $response = $this->postJson('/api/v1/payin', json_decode($body, true), [
            'X-API-KEY' => $this->merchant->api_key,
            'X-API-SIGNATURE' => $signature,
            'X-REQUEST-ID' => $requestId,
            'X-TIMESTAMP' => $timestamp,
        ]);

        $response->assertStatus(201);

        $this->assertDatabaseHas('payments', [
            'amount' => 1000.0,  // Numeric value extracted
            'currency' => 'INR',  // Uppercase
            'order_id' => 'ORD123456',  // Trimmed
            'customer_email' => 'test@example.com',  // Lowercase
        ]);
    }
}
```

### Phase 4: Documentation

**Step 4.1**: Create API-AUTHENTICATION.md

```markdown
# API Authentication

## HMAC Signature Authentication

All merchant-facing API endpoints require HMAC signature authentication.

### Required Headers

- `X-API-KEY`: Your merchant API key
- `X-API-SIGNATURE`: HMAC SHA256 signature
- `X-REQUEST-ID`: Unique request identifier
- `X-TIMESTAMP`: Unix timestamp

### Signature Generation

1. Concatenate request body, timestamp, and request ID
2. Generate HMAC SHA256 hash with your API secret
3. Include signature in `X-API-SIGNATURE` header

### Example (PHP)

```php
$body = json_encode([
    'amount' => 1000,
    'currency' => 'INR',
    'order_id' => 'ORD123456'
]);

$timestamp = time();
$requestId = uniqid();
$signature = hash_hmac(
    'sha256',
    $body . $timestamp . $requestId,
    $api_secret
);

$headers = [
    'X-API-KEY: ' . $api_key,
    'X-API-SIGNATURE: ' . $signature,
    'X-REQUEST-ID: ' . $requestId,
    'X-TIMESTAMP: ' . $timestamp,
    'Content-Type: application/json'
];
```
```

**Step 4.2**: Update docs/API.md

```markdown
## Security

All API endpoints implement the following security measures:

- Input sanitization for all user-provided data
- HMAC signature authentication for merchant APIs
- Rate limiting to prevent abuse
- SQL injection prevention through parameterized queries
- XSS prevention through output escaping
- Security headers for browser protection
```

## Best Practices

### Do's
✓ Sanitize all input data before processing
✓ Use parameterized queries to prevent SQL injection
✓ Implement HMAC signature verification for APIs
✓ Apply appropriate rate limits to prevent abuse
✓ Store sensitive data in environment variables
✓ Use HTTPS for all API communications
✓ Implement proper error handling without exposing sensitive information
✓ Add security headers to all responses
✓ Validate and authorize all user actions
✓ Log security events for monitoring

### Don'ts
✗ Store passwords in plain text
✗ Expose sensitive error messages to users
✗ Skip input validation and sanitization
✗ Use raw queries with user input
✗ Disable CSRF protection for web routes
✗ Forget to implement rate limiting
✗ Hardcode sensitive values in code
✗ Skip security headers
✗ Ignore OWASP security guidelines
✗ Forget to rotate API keys and secrets

## Integration with Other Skills

### $LaravelAPIDevelopment
**Security integration**: API endpoints require authentication patterns from this skill.

```
$LaravelAPIDevelopment creates → API structure
↓
$LaravelSecurityPatterns provides → Authentication and security
↓
Combined result → Secure API endpoints
```

### $LaravelTestingExcellence
**Testing integration**: Security tests follow testing workflow.

```
$LaravelSecurityPatterns implements → Security measures
↓
$LaravelTestingExcellence guides → Security testing
↓
Verification → Secure code implementation
```

### $PSPP2PDocumentation
**Documentation integration**: Security patterns documented in project structure.

```
$LaravelSecurityPatterns defines → Security requirements
↓
$PSPP2PDocumentation provides → Documentation structure
↓
Result → Well-documented security implementation
```

## Common Issues and Solutions

### HMAC Signature Verification Fails
**Symptom**: API requests return 401 Unauthorized despite correct credentials

**Solutions**:
```php
// Debug signature generation
$requestBody = $request->getContent();
$timestamp = $request->header('X-TIMESTAMP');
$requestId = $request->header('X-REQUEST-ID');
$signature = $request->header('X-API-SIGNATURE');

$expectedSignature = hash_hmac(
    'sha256',
    $requestBody . $timestamp . $requestId,
    $merchant->api_secret
);

// Log for debugging
\Log::debug('Signature verification', [
    'expected' => $expectedSignature,
    'received' => $signature,
    'match' => hash_equals($expectedSignature, $signature)
]);
```

### Input Sanitization Breaking Valid Data
**Symptom**: Valid input becomes invalid after sanitization

**Solutions**:
```php
// Sanitize before validation but preserve original format
protected function prepareForValidation()
{
    $this->merge([
        'email' => strtolower(trim($this->email)),
    ]);
}

// Use validation rules that allow sanitized format
public function rules(): array
{
    return [
        'email' => ['required', 'email', 'lowercase'],
    ];
}
```

### Rate Limiting Too Restrictive
**Symptom**: Legitimate users getting rate limited

**Solutions**:
```php
// Implement progressive rate limits
RateLimiter::for('api', function (Request $request) {
    $user = $request->user();

    if ($user && $user->is_premium) {
        return Limit::perMinute(100)->by($user->id);
    } elseif ($user) {
        return Limit::perMinute(60)->by($user->id);
    }

    return Limit::perMinute(10)->by($request->ip());
});
```

## Success Criteria

✓ All input data properly sanitized before processing
✓ HMAC authentication implemented for all merchant APIs
✓ Rate limiting applied to prevent abuse
✓ Environment variables properly configured and secured
✓ Security headers added to all responses
✓ OWASP security guidelines followed
✓ Security tests covering authentication and input validation
✓ API-AUTHENTICATION.md documentation created and maintained
✓ Security events logged for monitoring

## Related Skills

- **$LaravelAPIDevelopment**: For API endpoint structure and documentation
- **$LaravelTestingExcellence**: For security testing strategies
- **$PSPP2PDocumentation**: For project-specific documentation requirements

---

**Remember**: Security is not an afterthought—it should be integrated into every layer of your application. Always sanitize input, authenticate requests, authorize actions, and log security events. The cost of implementing security measures is minimal compared to the cost of a security breach.

```
