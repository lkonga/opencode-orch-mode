# Repomix Command Variations

## Laravel Project Variations

### 1. Balanced Analysis (Recommended Default)

**Use When**: Standard Laravel project analysis needed

**Command**:
```bash
repomix \
  --compress \
  --include "app/**,config/**,database/**,resources/**,routes/**,tests/" \
  -i "docs/**,public/**,storage/**,*.log,*.cache,*.lock,*.env*" \
  --style xml \
  -o project-analysis-balanced-$(date +"%Y-%m-%d-%H%M").xml
```

**Includes**:
- `app/`: All application code (models, controllers, services, jobs, etc.)
- `config/`: Configuration files
- `database/`: Migrations, seeders, factories
- `resources/`: Views, frontend assets (Blade, Vue, React, etc.)
- `routes/`: Route definitions (web, api, console, channels)
- `tests/`: Unit and feature tests

**Excludes**:
- `docs/`: Documentation (usually large, text-heavy)
- `public/`: Compiled assets, static files
- `storage/`: Runtime files, logs, cache
- Log/cache/lock files
- Environment files

**Expected Size**: 5-20MB
**Expected Files**: 100-500 files
**Use Case**: General documentation, handoffs, AI context

---

### 2. Minimal Core Analysis

**Use When**: Quick snapshot needed, token budget tight

**Command**:
```bash
repomix \
  --compress \
  --include "app/**,config/**,routes/**" \
  -i "*.log,*.cache,*.lock,*.env*" \
  --style xml \
  -o project-analysis-minimal-$(date +"%Y-%m-%d-%H%M").xml
```

**Includes**:
- `app/`: Core application logic
- `config/`: Configuration
- `routes/`: Routing

**Excludes**:
- Database migrations
- Frontend resources
- Tests
- Everything else

**Expected Size**: 2-8MB
**Expected Files**: 50-200 files
**Use Case**: Quick code review, API analysis, bug investigation

---

### 3. Comprehensive Analysis

**Use When**: Thorough documentation needed, preparing major refactor

**Command**:
```bash
repomix \
  --compress \
  --include "app/**,config/**,database/**,resources/**,routes/**,tests/**,docs/**" \
  -i "storage/**,*.log,*.cache,*.lock,*.env*,node_modules/**,vendor/**" \
  --style xml \
  -o project-analysis-comprehensive-$(date +"%Y-%m-%d-%H%M").xml
```

**Includes**:
- All application code
- All configuration
- All database migrations
- All frontend resources
- All routes
- All tests
- All documentation

**Excludes**:
- Only runtime and dependency directories

**Expected Size**: 10-50MB
**Expected Files**: 200-1000 files
**Use Case**: Complete project handoff, comprehensive documentation, architecture review

---

### 4. Frontend-Focused Analysis

**Use When**: Working on frontend, Vue/React/Blade components

**Command**:
```bash
repomix \
  --compress \
  --include "resources/**,routes/web.php,routes/channels.php,public/*.js,public/*.css" \
  -i "storage/**,*.log,*.cache,node_modules/**" \
  --style xml \
  -o project-analysis-frontend-$(date +"%Y-%m-%d-%H%M").xml
```

**Includes**:
- `resources/`: All frontend assets (views, components, styles)
- `routes/web.php`: Web routes
- `routes/channels.php`: Broadcasting channels
- `public/*.js`, `public/*.css`: Compiled assets (for reference)

**Excludes**:
- Backend logic (except routes)
- Database files
- Tests
- Storage

**Expected Size**: 3-15MB
**Expected Files**: 50-300 files
**Use Case**: Frontend refactoring, UI/UX work, frontend documentation

---

### 5. Backend-Only Analysis

**Use When**: Working on API, business logic, no frontend needed

**Command**:
```bash
repomix \
  --compress \
  --include "app/**,config/**,database/**,routes/api.php,routes/console.php" \
  -i "resources/**,public/**,storage/**,*.log,*.cache,*.lock,*.env*" \
  --style xml \
  -o project-analysis-backend-$(date +"%Y-%m-%d-%H%M").xml
```

**Includes**:
- `app/`: All backend logic
- `config/`: Configuration
- `database/`: Schema and data
- `routes/api.php`: API routes
- `routes/console.php`: Console commands

**Excludes**:
- All frontend resources
- Web routes
- Public assets
- Storage

**Expected Size**: 5-20MB
**Expected Files**: 80-400 files
**Use Case**: API development, backend refactoring, service layer work

---

### 6. Testing-Focused Analysis

**Use When**: Test review, coverage analysis, test strategy planning

**Command**:
```bash
repomix \
  --compress \
  --include "tests/**,app/**,database/factories/**" \
  -i "*.log,*.cache,resources/**,public/**" \
  --style xml \
  -o project-analysis-testing-$(date +"%Y-%m-%d-%H%M").xml
```

**Includes**:
- `tests/`: All tests (unit, feature, browser)
- `app/`: Application code being tested
- `database/factories/**`: Test factories

**Excludes**:
- Frontend resources
- Public assets
- Configuration (unless needed)

**Expected Size**: 8-25MB
**Expected Files**: 150-500 files
**Use Case**: Test coverage analysis, test strategy review, TDD workflow

---

### 7. Database-Focused Analysis

**Use When**: Database schema review, migration analysis

**Command**:
```bash
repomix \
  --compress \
  --include "database/**,app/Models/**,config/database.php" \
  -i "*.log,*.cache" \
  --style xml \
  -o project-analysis-database-$(date +"%Y-%m-%d-%H%M").xml
```

**Includes**:
- `database/`: Migrations, seeders, factories
- `app/Models/`: Eloquent models
- `config/database.php`: Database configuration

**Excludes**:
- Everything else

**Expected Size**: 2-10MB
**Expected Files**: 30-150 files
**Use Case**: Database migration planning, schema review, model analysis

---

### 8. Configuration-Only Analysis

**Use When**: Environment setup, configuration review

**Command**:
```bash
repomix \
  --compress \
  --include "config/**,.env.example,composer.json,package.json,artisan" \
  -i "*.log,*.cache" \
  --style xml \
  -o project-analysis-config-$(date +"%Y-%m-%d-%H%M").xml
```

**Includes**:
- `config/`: All configuration files
- `.env.example`: Environment template
- `composer.json`: PHP dependencies
- `package.json`: Node dependencies
- `artisan`: CLI entry point

**Expected Size**: < 1MB
**Expected Files**: 20-50 files
**Use Case**: Environment setup documentation, deployment configuration

---

## Non-Laravel Variations

### Node.js/Express Project

```bash
repomix \
  --compress \
  --include "src/**,routes/**,models/**,controllers/**,config/**,tests/**" \
  -i "node_modules/**,dist/**,build/**,*.log,*.cache" \
  --style xml \
  -o project-analysis-$(date +"%Y-%m-%d-%H%M").xml
```

### React/Next.js Frontend

```bash
repomix \
  --compress \
  --include "src/**,pages/**,components/**,public/**,styles/**" \
  -i "node_modules/**,.next/**,out/**,dist/**,build/**" \
  --style xml \
  -o project-analysis-$(date +"%Y-%m-%d-%H%M").xml
```

### Python/Django Project

```bash
repomix \
  --compress \
  --include "**/*.py,templates/**,static/**,requirements.txt" \
  -i "__pycache__/**,*.pyc,*.pyo,venv/**,.venv/**,*.log" \
  --style xml \
  -o project-analysis-$(date +"%Y-%m-%d-%H%M").xml
```

### Generic Project (Unknown Structure)

```bash
repomix \
  --compress \
  --include "src/**,lib/**,config/**,tests/**" \
  -i "node_modules/**,vendor/**,dist/**,build/**,*.log,*.cache" \
  --style xml \
  -o project-analysis-$(date +"%Y-%m-%d-%H%M").xml
```

---

## Advanced Inclusion/Exclusion Patterns

### Include Specific File Types Only

**PHP Files Only**:
```bash
--include "**/*.php"
```

**JavaScript/TypeScript Only**:
```bash
--include "**/*.js,**/*.ts,**/*.jsx,**/*.tsx"
```

**Configuration Files Only**:
```bash
--include "**/*.json,**/*.yaml,**/*.yml,**/*.xml,**/*.toml,**/*.ini"
```

### Exclude by File Pattern

**Exclude Test Files**:
```bash
-i "**/*Test.php,**/*test.js,**/tests/**,**/test/**"
```

**Exclude Generated Files**:
```bash
-i "**/generated/**,**/*.gen.*,**/*.generated.*"
```

**Exclude Large Media Files**:
```bash
-i "**/*.png,**/*.jpg,**/*.jpeg,**/*.gif,**/*.mp4,**/*.pdf"
```

### Combine Multiple Patterns

**Laravel API Backend (No Blade, No Frontend)**:
```bash
repomix \
  --compress \
  --include "app/**/*.php,config/**,database/**,routes/api.php,routes/console.php" \
  -i "**/*Test.php,*.log,*.cache" \
  --style xml \
  -o api-backend-$(date +"%Y-%m-%d-%H%M").xml
```

**Frontend Components Only (Vue)**:
```bash
repomix \
  --compress \
  --include "resources/js/components/**/*.vue,resources/js/*.js" \
  -i "node_modules/**,public/**" \
  --style xml \
  -o vue-components-$(date +"%Y-%m-%d-%H%M").xml
```

---

## Output Format Variations

### JSON Output

```bash
repomix \
  --compress \
  --include "app/**,config/**" \
  --style json \
  -o project-analysis-$(date +"%Y-%m-%d-%H%M").json
```

**Use When**: Programmatic processing, JSON parsing tools

### Markdown Output

```bash
repomix \
  --compress \
  --include "app/**,config/**" \
  --style markdown \
  -o project-analysis-$(date +"%Y-%m-%d-%H%M").md
```

**Use When**: Human readability, GitHub/GitLab rendering

### Plain Text Output

```bash
repomix \
  --compress \
  --include "app/**,config/**" \
  --style plain \
  -o project-analysis-$(date +"%Y-%m-%d-%H%M").txt
```

**Use When**: Simple text processing, grep/awk scripts

---

## Size Optimization Strategies

### Strategy 1: Incremental Inclusion

Start minimal, add more as needed:

```bash
# Step 1: Core only
repomix --compress --include "app/Http/**,app/Models/**,routes/**" --style xml -o core.xml

# Step 2: Add services if needed
repomix --compress --include "app/Http/**,app/Models/**,app/Services/**,routes/**" --style xml -o core-services.xml

# Step 3: Add config if needed
repomix --compress --include "app/Http/**,app/Models/**,app/Services/**,routes/**,config/**" --style xml -o full-backend.xml
```

### Strategy 2: Exclude Large Directories

Identify and exclude large non-essential directories:

```bash
# Find large directories first
du -sh app/* | sort -h

# Exclude the largest
repomix --compress --include "app/**" -i "app/Console/Commands/**,app/LargeFeature/**" --style xml -o optimized.xml
```

### Strategy 3: Use --no-compress for Debugging

If output seems wrong, disable compression temporarily:

```bash
repomix \
  --include "app/**,config/**" \
  --style xml \
  -o project-analysis-debug-$(date +"%Y-%m-%d-%H%M").xml
```

**Note**: Output will be much larger, but easier to verify

---

## Task-Specific Command Recipes

### Recipe 1: "Analyze Authentication System"

```bash
repomix \
  --compress \
  --include "app/Http/Middleware/**,app/Auth/**,app/Models/User.php,config/auth.php,routes/auth.php" \
  --style xml \
  -o auth-system-$(date +"%Y-%m-%d-%H%M").xml
```

### Recipe 2: "Analyze Payment Flow"

```bash
repomix \
  --compress \
  --include "app/Services/Payment/**,app/Http/Controllers/*Payment*,database/migrations/*payment*,config/services.php" \
  --style xml \
  -o payment-flow-$(date +"%Y-%m-%d-%H%M").xml
```

### Recipe 3: "Analyze API Endpoints"

```bash
repomix \
  --compress \
  --include "app/Http/Controllers/Api/**,app/Http/Resources/**,app/Http/Requests/**,routes/api.php" \
  --style xml \
  -o api-endpoints-$(date +"%Y-%m-%d-%H%M").xml
```

### Recipe 4: "Analyze Database Schema"

```bash
repomix \
  --compress \
  --include "database/migrations/**,app/Models/**,database/seeders/**,database/factories/**" \
  --style xml \
  -o database-schema-$(date +"%Y-%m-%d-%H%M").xml
```

### Recipe 5: "Analyze Job Queue System"

```bash
repomix \
  --compress \
  --include "app/Jobs/**,app/Listeners/**,app/Events/**,config/queue.php,database/migrations/*jobs*" \
  --style xml \
  -o job-queue-$(date +"%Y-%m-%d-%H%M").xml
```

---

## Conditional Inclusion Examples

### Include Only Recent Changes

Combine with Git:

```bash
# Get files changed in last 7 days
changed_files=$(git diff --name-only HEAD@{7.days.ago} HEAD | grep -E '\.(php|js|vue)$' | tr '\n' ',' | sed 's/,$//')

# Analyze only those files
repomix --compress --include "$changed_files" --style xml -o recent-changes.xml
```

### Include Only Modified Files (Current Branch)

```bash
# Get files modified in current branch
modified_files=$(git diff --name-only main | grep -E '\.(php|js|vue)$' | tr '\n' ',' | sed 's/,$//')

# Analyze only those files
repomix --compress --include "$modified_files" --style xml -o branch-changes.xml
```

---

## Performance Optimization Tips

1. **Use --compress Always**: Reduces file size by 30-50%
2. **Exclude Tests if Not Needed**: Saves 20-40% of file size
3. **Exclude Resources for Backend Work**: Saves 30-50% of file size
4. **Use Specific File Type Filters**: Faster than directory scanning
5. **Avoid Wildcards at Root**: Use specific paths when possible

**Bad** (Slow):
```bash
--include "**/*.php"
```

**Good** (Fast):
```bash
--include "app/**/*.php,config/**/*.php"
```
