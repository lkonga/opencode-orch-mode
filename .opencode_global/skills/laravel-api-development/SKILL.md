---
name: 'Laravel API Development'
description: 'RESTful API development standards for Laravel with OpenAPI/Swagger documentation, authentication patterns, and endpoint best practices'
triggers: ['$LaravelAPIDevelopment']
trigger_keywords: ['laravel api', 'api development', 'swagger documentation', 'restful api', 'openapi annotations']
related_skills: ['$LaravelSecurityPatterns', '$LaravelTestingExcellence', '$SurgicalImplementation']
references: {}
---

# Laravel API Development Skill

## Purpose
Provide comprehensive API development standards for Laravel 10+ projects with emphasis on RESTful design, OpenAPI/Swagger documentation, proper authentication, and maintainable endpoint structures.

## Scope
- **RESTful API design**: Standard HTTP methods, status codes, resource naming
- **OpenAPI/Swagger**: Annotation patterns and documentation generation
- **API authentication**: HMAC signature verification, API key management
- **Request/Response handling**: Resource classes, validation patterns
- **Error handling**: Consistent error responses and exception patterns
- **Documentation workflow**: Keeping API docs synchronized with code

## When to Use This Skill

**Trigger Conditions**:
1. Implementing new API endpoints in Laravel projects
2. Documenting existing APIs with OpenAPI/Swagger
3. Implementing API authentication mechanisms
4. Refactoring API structure for consistency
5. User explicitly mentions API development or REST patterns

**Examples**:
- "Create new payment API endpoint with $LaravelAPIDevelopment standards"
- "Add Swagger documentation to user authentication API"
- "Implement RESTful API for product catalog using Laravel best practices"

## Core Principles

### 1. RESTful Design Patterns

**Resource-based URLs**: Use nouns, not verbs
```
✓ GET /api/v1/users          (List users)
✓ GET /api/v1/users/123      (Get specific user)
✓ POST /api/v1/users         (Create user)
✓ PUT /api/v1/users/123      (Update user)
✓ DELETE /api/v1/users/123   (Delete user)

✗ GET /api/v1/getUsers
✗ POST /api/v1/createUser
✗ POST /api/v1/user/delete
```

**Standard HTTP Methods**:
- `GET`: Retrieve resources (safe, idempotent)
- `POST`: Create new resources
- `PUT`/`PATCH`: Update existing resources
- `DELETE`: Remove resources
- `HEAD`: Get headers only
- `OPTIONS`: Get available methods

**HTTP Status Codes**:
```
Success:
- 200 OK: Standard success response
- 201 Created: Resource successfully created
- 204 No Content: Success with no response body

Client Errors:
- 400 Bad Request: Invalid request data
- 401 Unauthorized: Missing or invalid authentication
- 403 Forbidden: Authenticated but not authorized
- 404 Not Found: Resource doesn't exist
- 422 Unprocessable Entity: Validation failed

Server Errors:
- 500 Internal Server Error: Unexpected server issue
- 503 Service Unavailable: Temporary unavailability
```

### 2. API Versioning

**URL-based versioning** (recommended for Laravel):
```
/api/v1/resource
/api/v2/resource
```

**Route organization**:
```php
// routes/api.php
Route::prefix('v1')->group(function () {
    Route::middleware(['api.auth'])->group(function () {
        Route::post('/payin', [PaymentController::class, 'processPayin']);
        Route::get('/transactions', [TransactionController::class, 'index']);
    });
});
```

### 3. Request/Response Structure

**Request Resources**: Use Form Request classes for validation
```php
<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;

class PayinRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // Handle in middleware
    }

    public function rules(): array
    {
        return [
            'amount' => ['required', 'numeric', 'min:1'],
            'currency' => ['required', 'string', 'in:INR,USD'],
            'order_id' => ['required', 'string', 'unique:transactions'],
            'customer_email' => ['required', 'email'],
        ];
    }
}
```

**Response Resources**: Use API Resource classes for consistent formatting
```php
<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class PaymentResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'order_id' => $this->order_id,
            'amount' => $this->amount,
            'currency' => $this->currency,
            'status' => $this->status,
            'redirect_url' => $this->when($this->redirect_url, $this->redirect_url),
            'created_at' => $this->created_at->toISOString(),
        ];
    }
}
```

**Controller pattern**:
```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\Api\PayinRequest;
use App\Http\Resources\PaymentResource;
use App\Services\Payment\PaymentService;

class PaymentController extends Controller
{
    public function __construct(
        private PaymentService $paymentService
    ) {}

    /**
     * Process payment request
     *
     * @OA\Post(
     *     path="/api/v1/payin",
     *     summary="Create payment transaction",
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(ref="#/components/schemas/PayinRequest")
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Payment created successfully",
     *         @OA\JsonContent(ref="#/components/schemas/PaymentResource")
     *     )
     * )
     */
    public function processPayin(PayinRequest $request): JsonResponse
    {
        $payment = $this->paymentService->createPayment(
            $request->validated()
        );

        return (new PaymentResource($payment))
            ->response()
            ->setStatusCode(201);
    }
}
```

### 4. OpenAPI/Swagger Documentation

**Annotation patterns**: Document endpoints directly in controller methods

**Controller-level annotations**:
```php
/**
 * @OA\Info(
 *     title="PSP Payment API",
 *     version="1.0.0",
 *     description="Payment processing API for PSP platform"
 * )
 * @OA\Server(
 *     url="https://api.example.com",
 *     description="Production server"
 * )
 */
class Controller extends BaseController
{
    // Base controller with API info
}
```

**Endpoint annotations**:
```php
/**
 * @OA\Post(
 *     path="/api/v1/payin",
 *     summary="Create payment transaction",
 *     tags={"Payments"},
 *     security={{"ApiKeyAuth":{}, "SignatureAuth":{}}},
 *
 *     @OA\RequestBody(
 *         required=true,
 *         description="Payment request data",
 *         @OA\JsonContent(
 *             required={"amount","currency","order_id"},
 *             @OA\Property(property="amount", type="number", example=1000),
 *             @OA\Property(property="currency", type="string", example="INR"),
 *             @OA\Property(property="order_id", type="string", example="ORD123456"),
 *             @OA\Property(property="customer_email", type="string", example="customer@example.com")
 *         )
 *     ),
 *
 *     @OA\Response(
 *         response=201,
 *         description="Payment created successfully",
 *         @OA\JsonContent(
 *             @OA\Property(property="id", type="integer", example=1),
 *             @OA\Property(property="order_id", type="string", example="ORD123456"),
 *             @OA\Property(property="status", type="string", example="pending"),
 *             @OA\Property(property="redirect_url", type="string", example="https://payment.example.com/...")
 *         )
 *     ),
 *
 *     @OA\Response(
 *         response=400,
 *         description="Bad request",
 *         @OA\JsonContent(
 *             @OA\Property(property="message", type="string", example="Invalid request data")
 *         )
 *     ),
 *
 *     @OA\Response(
 *         response=401,
 *         description="Unauthorized",
 *         @OA\JsonContent(
 *             @OA\Property(property="message", type="string", example="Invalid API credentials")
 *         )
 *     )
 * )
 */
public function processPayin(PayinRequest $request): JsonResponse
{
    // Implementation
}
```

**Schema definitions** (reusable models):
```php
/**
 * @OA\Schema(
 *     schema="PayinRequest",
 *     required={"amount","currency","order_id"},
 *     @OA\Property(property="amount", type="number", description="Payment amount", example=1000),
 *     @OA\Property(property="currency", type="string", description="Currency code", example="INR"),
 *     @OA\Property(property="order_id", type="string", description="Unique order identifier", example="ORD123456"),
 *     @OA\Property(property="customer_email", type="string", format="email", description="Customer email", example="customer@example.com")
 * )
 */
class PayinRequest extends FormRequest
{
    // Implementation
}
```

**Security schemes**:
```php
/**
 * @OA\SecurityScheme(
 *     type="apiKey",
 *     in="header",
 *     name="X-API-KEY",
 *     securityScheme="ApiKeyAuth"
 * )
 *
 * @OA\SecurityScheme(
 *     type="apiKey",
 *     in="header",
 *     name="X-API-SIGNATURE",
 *     securityScheme="SignatureAuth"
 * )
 *
 * @OA\SecurityScheme(
 *     type="apiKey",
 *     in="header",
 *     name="X-REQUEST-ID",
 *     securityScheme="RequestIdAuth"
 * )
 */
```

**Generate documentation**:
```bash
# Generate Swagger JSON/YAML
php artisan l5-swagger:generate

# Access documentation
# https://your-domain/api/documentation
```

### 5. API Authentication

**HMAC Signature Pattern** (for PSP-P2P style authentication):

**Required headers**:
```
X-API-KEY: merchant_api_key
X-API-SIGNATURE: hmac_sha256_signature
X-REQUEST-ID: unique_request_identifier
```

**Signature generation** (client-side):
```php
$signature = hash_hmac(
    'sha256',
    $requestBody . $timestamp . $requestId,
    $apiSecret
);
```

**Verification middleware**:
```php
<?php

namespace App\Http\Middleware;

use App\Services\Auth\ApiAuthService;
use Closure;
use Illuminate\Http\Request;

class VerifyApiSignature
{
    public function __construct(
        private ApiAuthService $apiAuthService
    ) {}

    public function handle(Request $request, Closure $next)
    {
        $apiKey = $request->header('X-API-KEY');
        $signature = $request->header('X-API-SIGNATURE');
        $requestId = $request->header('X-REQUEST-ID');

        if (!$apiKey || !$signature || !$requestId) {
            return response()->json([
                'message' => 'Missing required authentication headers'
            ], 401);
        }

        if (!$this->apiAuthService->verifySignature($request)) {
            return response()->json([
                'message' => 'Invalid API signature'
            ], 401);
        }

        return $next($request);
    }
}
```

**Register middleware**:
```php
// app/Http/Kernel.php
protected $middlewareGroups = [
    'api' => [
        \App\Http\Middleware\VerifyApiSignature::class,
        // Other middleware...
    ],
];

// Or apply selectively
Route::middleware(['api.signature'])->group(function () {
    // Protected routes
});
```

### 6. Error Handling

**Consistent error responses**:
```php
<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\PaymentException;
use Illuminate\Http\JsonResponse;

trait ApiResponseTrait
{
    protected function successResponse(
        mixed $data,
        string $message = 'Success',
        int $statusCode = 200
    ): JsonResponse {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data
        ], $statusCode);
    }

    protected function errorResponse(
        string $message,
        int $statusCode = 400,
        array $errors = []
    ): JsonResponse {
        $response = [
            'success' => false,
            'message' => $message
        ];

        if (!empty($errors)) {
            $response['errors'] = $errors;
        }

        return response()->json($response, $statusCode);
    }
}
```

**Exception handling**:
```php
// app/Exceptions/Handler.php
public function render($request, Throwable $exception)
{
    if ($request->is('api/*')) {
        return $this->handleApiException($request, $exception);
    }

    return parent::render($request, $exception);
}

protected function handleApiException($request, Throwable $exception): JsonResponse
{
    $statusCode = 500;
    $message = 'Internal server error';

    if ($exception instanceof ValidationException) {
        $statusCode = 422;
        $message = 'Validation failed';
        return response()->json([
            'success' => false,
            'message' => $message,
            'errors' => $exception->errors()
        ], $statusCode);
    }

    if ($exception instanceof AuthenticationException) {
        $statusCode = 401;
        $message = 'Unauthenticated';
    }

    if ($exception instanceof AuthorizationException) {
        $statusCode = 403;
        $message = 'Unauthorized action';
    }

    if ($exception instanceof ModelNotFoundException) {
        $statusCode = 404;
        $message = 'Resource not found';
    }

    if (method_exists($exception, 'getStatusCode')) {
        $statusCode = $exception->getStatusCode();
    }

    return response()->json([
        'success' => false,
        'message' => $message
    ], $statusCode);
}
```

## Workflow: Creating New API Endpoint

### Phase 1: Planning and Design

**Step 1.1**: Define endpoint specification

```
Endpoint: Create Payment
Method: POST
Path: /api/v1/payin
Authentication: API Key + HMAC Signature
Request: { amount, currency, order_id, customer_email }
Response: { id, order_id, status, redirect_url }
Status Codes: 201 (success), 400 (validation), 401 (auth), 422 (validation)
```

**Step 1.2**: Plan database schema (if needed)

```php
Schema::create('payments', function (Blueprint $table) {
    $table->id();
    $table->string('order_id')->unique();
    $table->decimal('amount', 10, 2);
    $table->string('currency', 3);
    $table->string('customer_email');
    $table->string('status');
    $table->string('redirect_url')->nullable();
    $table->timestamps();
});
```

### Phase 2: Implementation

**Step 2.1**: Create Form Request class

```bash
php artisan make:request Api/PayinRequest
```

```php
<?php
// app/Http/Requests/Api/PayinRequest.php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;

/**
 * @OA\Schema(
 *     schema="PayinRequest",
 *     required={"amount","currency","order_id"},
 *     @OA\Property(property="amount", type="number", example=1000),
 *     @OA\Property(property="currency", type="string", example="INR"),
 *     @OA\Property(property="order_id", type="string", example="ORD123456")
 * )
 */
class PayinRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // Handled by middleware
    }

    public function rules(): array
    {
        return [
            'amount' => ['required', 'numeric', 'min:1'],
            'currency' => ['required', 'string', 'in:INR,USD'],
            'order_id' => ['required', 'string', 'unique:payments,order_id'],
            'customer_email' => ['required', 'email'],
        ];
    }
}
```

**Step 2.2**: Create API Resource class

```bash
php artisan make:resource PaymentResource
```

```php
<?php
// app/Http/Resources/PaymentResource.php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @OA\Schema(
 *     schema="PaymentResource",
 *     @OA\Property(property="id", type="integer", example=1),
 *     @OA\Property(property="order_id", type="string", example="ORD123456"),
 *     @OA\Property(property="status", type="string", example="pending")
 * )
 */
class PaymentResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'order_id' => $this->order_id,
            'amount' => $this->amount,
            'currency' => $this->currency,
            'status' => $this->status,
            'redirect_url' => $this->when($this->redirect_url, $this->redirect_url),
            'created_at' => $this->created_at->toISOString(),
        ];
    }
}
```

**Step 2.3**: Create or update controller

```bash
php artisan make:controller Api/PaymentController
```

```php
<?php
// app/Http/Controllers/Api/PaymentController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\PayinRequest;
use App\Http\Resources\PaymentResource;
use App\Services\Payment\PaymentService;
use Illuminate\Http\JsonResponse;

class PaymentController extends Controller
{
    public function __construct(
        private PaymentService $paymentService
    ) {}

    /**
     * Create payment transaction
     *
     * @OA\Post(
     *     path="/api/v1/payin",
     *     summary="Create payment transaction",
     *     tags={"Payments"},
     *     security={{"ApiKeyAuth":{}, "SignatureAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(ref="#/components/schemas/PayinRequest")
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Payment created successfully",
     *         @OA\JsonContent(ref="#/components/schemas/PaymentResource")
     *     )
     * )
     */
    public function processPayin(PayinRequest $request): JsonResponse
    {
        try {
            $payment = $this->paymentService->createPayment(
                $request->validated()
            );

            return (new PaymentResource($payment))
                ->response()
                ->setStatusCode(201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Payment processing failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
```

**Step 2.4**: Register route

```php
// routes/api.php
use App\Http\Controllers\Api\PaymentController;

Route::prefix('v1')->group(function () {
    Route::middleware(['api.signature'])->group(function () {
        Route::post('/payin', [PaymentController::class, 'processPayin']);
    });
});
```

**Step 2.5**: Generate Swagger documentation

```bash
php artisan l5-swagger:generate
```

**Step 2.6**: Update API documentation file (if exists)

```bash
# Update docs/API.md with new endpoint
echo "## POST /api/v1/payin" >> docs/API.md
echo "Create payment transaction..." >> docs/API.md
```

### Phase 3: Testing

**Step 3.1**: Create API tests (see $LaravelTestingExcellence skill)

```php
/** @test */
public function create_payment_with_valid_data()
{
    $response = $this->postJson('/api/v1/payin', [
        'amount' => 1000,
        'currency' => 'INR',
        'order_id' => 'ORD123456',
        'customer_email' => 'customer@example.com'
    ], [
        'X-API-KEY' => 'test_api_key',
        'X-API-SIGNATURE' => 'valid_signature',
        'X-REQUEST-ID' => 'unique_request_id'
    ]);

    $response->assertStatus(201)
             ->assertJsonStructure([
                 'id',
                 'order_id',
                 'status',
                 'redirect_url'
             ]);
}
```

**Step 3.2**: Test API authentication

```php
/** @test */
public function create_payment_requires_authentication()
{
    $response = $this->postJson('/api/v1/payin', [
        'amount' => 1000,
        'currency' => 'INR',
        'order_id' => 'ORD123456'
    ]);

    $response->assertStatus(401);
}
```

### Phase 4: Documentation

**Step 4.1**: Verify Swagger docs

```
Visit: https://your-domain/api/documentation
Verify: Endpoint appears with correct request/response examples
Test: Try API directly from Swagger UI
```

**Step 4.2**: Update API documentation file

```markdown
# API Documentation

## Payment Endpoints

### POST /api/v1/payin

Create a new payment transaction.

**Authentication**: Required (API Key + HMAC Signature)

**Request**:
\`\`\`json
{
  "amount": 1000,
  "currency": "INR",
  "order_id": "ORD123456",
  "customer_email": "customer@example.com"
}
\`\`\`

**Response** (201 Created):
\`\`\`json
{
  "id": 1,
  "order_id": "ORD123456",
  "status": "pending",
  "redirect_url": "https://payment.example.com/..."
}
\`\`\`

**Error Responses**:
- 400: Bad request
- 401: Invalid authentication
- 422: Validation failed
```

## Best Practices

### Do's
✓ Use RESTful URL patterns (nouns, not verbs)
✓ Apply appropriate HTTP status codes
✓ Version your APIs (/api/v1/...)
✓ Use Form Request classes for validation
✓ Use API Resource classes for responses
✓ Document endpoints with OpenAPI annotations
✓ Generate Swagger docs after changes
✓ Implement consistent error responses
✓ Use middleware for authentication
✓ Keep business logic in services, not controllers
✓ Test API endpoints thoroughly

### Don'ts
✗ Use verbs in URL paths
✗ Return inconsistent response formats
✗ Skip OpenAPI documentation
✗ Hardcode authentication in controllers
✗ Return different error formats
✗ Expose internal exception details to clients
✗ Skip validation
✗ Put business logic in controllers
✗ Forget to regenerate Swagger docs
✗ Use non-standard HTTP status codes

## Integration with Other Skills

### $LaravelSecurityPatterns
**Authentication integration**: API auth patterns reference security skill.

```
$LaravelAPIDevelopment defines → API structure
↓
$LaravelSecurityPatterns provides → Auth/Security implementation
↓
Combined result → Secure, well-documented API
```

### $LaravelTestingExcellence
**Testing integration**: API tests follow testing workflow.

```
$LaravelAPIDevelopment implements → New endpoint
↓
$LaravelTestingExcellence guides → Test creation
↓
Verification → API works as documented
```

### $SurgicalImplementation
**Modification pattern**: Precise API updates using surgical edits.

```
$LaravelAPIDevelopment identifies → Endpoints to modify
↓
$SurgicalImplementation applies → Precise changes
↓
Regenerate → Swagger documentation
```

## Common Issues and Solutions

### Swagger Generation Fails
**Symptom**: `php artisan l5-swagger:generate` throws errors

**Solutions**:
```bash
# Check annotation syntax
grep -r "@OA\\" app/Http/Controllers/Api/

# Clear cache
php artisan optimize:clear

# Re-run generation
php artisan l5-swagger:generate
```

### Authentication Middleware Not Applied
**Symptom**: Endpoint accessible without authentication

**Solutions**:
```php
// Verify route middleware
Route::middleware(['api.signature'])->group(function () {
    Route::post('/payin', [PaymentController::class, 'processPayin']);
});

// Check middleware registration in Kernel.php
protected $middlewareAliases = [
    'api.signature' => \App\Http\Middleware\VerifyApiSignature::class,
];
```

### CORS Issues
**Symptom**: API calls fail from browser with CORS errors

**Solutions**:
```php
// config/cors.php
return [
    'paths' => ['api/*'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['https://your-frontend.com'],
    'allowed_headers' => ['*'],
    'supports_credentials' => false,
];
```

## Success Criteria

✓ Endpoint follows RESTful design patterns
✓ OpenAPI annotations complete and accurate
✓ Swagger documentation generated and accessible
✓ Authentication properly implemented
✓ Validation using Form Request classes
✓ Responses using API Resource classes
✓ Error handling consistent across endpoints
✓ API tests cover success and error cases
✓ Documentation file (docs/API.md) updated

## Related Skills

- **$LaravelSecurityPatterns**: For authentication and security implementation
- **$LaravelTestingExcellence**: For API endpoint testing strategies
- **$SurgicalImplementation**: For precise API modifications
- **$PSPP2PDocumentation**: For project-specific API documentation structure

---

**Remember**: Good API design is about CONSISTENCY, DOCUMENTATION, and SECURITY. Follow RESTful conventions, document every endpoint with OpenAPI, and always verify authentication before processing requests.
