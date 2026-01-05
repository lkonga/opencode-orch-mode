# Main Branch Deployment Workflow

## Full Deployment Process

### Phase 1: Pre-flight Validation
1. **Environment Check**: Validates required tools (git, php, composer, npm)
2. **Laravel Directory Validation**: Ensures storage/, bootstrap/cache/ exist
3. **Tunnel Configuration Check**: Validates Cloudflare tunnel structure
4. **Permission Pre-flight**: Creates vendor/, node_modules/ with correct ownership

### Phase 2: Dependency Installation
1. **Composer Install**: Installs PHP dependencies as TARGET_USER
2. **NPM Install**: Installs JavaScript dependencies
3. **Asset Build**: Runs `npm run build` for Vite/Mix assets
4. **Permission Fixes**: Ensures web server can access files

### Phase 3: Laravel Configuration
1. **APP_KEY Generation**: Creates encryption key if missing
2. **Environment File Validation**: Checks .env.{PROJECT}.staging
3. **Cache Clearing**: Clears config, route, view caches
4. **Optimize**: Runs `php artisan optimize`

### Phase 4: Database Setup
1. **Database Creation**: Creates staging and testing databases
2. **User Permissions**: Grants necessary MySQL privileges
3. **Fresh Migrations**: Runs `migrate:fresh --force`
4. **Development Seeding**: Runs `db:seed-dev` for test data

### Phase 5: Apache & SSL Configuration
1. **SSL Certificate Generation**: Creates self-signed cert for .local domain
2. **Virtual Host Setup**: Configures Apache for .local and .staging domains
3. **Apache Reload**: Gracefully reloads Apache configuration
4. **DNS Flush**: Attempts to flush system DNS cache

### Phase 6: Cloudflare Tunnel Setup
1. **Tunnel Discovery**: Finds or creates Cloudflare tunnel
2. **Configuration File**: Writes tunnel YAML configuration
3. **Ingress Rules**: Maps hostname to local Apache port
4. **Credentials**: Links tunnel credentials file
5. **Note**: Tunnel NOT started automatically (use $CFLauncher)

### Phase 7: Testing
1. **Test Database Migration**: Runs migrations on testing database
2. **Test Suite Execution**: Runs PHPUnit/Pest tests
3. **Dusk Tests**: Runs browser automation tests (if available)
4. **Coverage Reporting**: Generates code coverage (optional)

### Phase 8: Verification
1. **HTTP Status Check**: Verifies .local domain returns 302
2. **Log Review**: Checks Laravel logs for errors
3. **Permission Verification**: Ensures storage/ is writable
4. **Summary Report**: Prints deployment URLs and next steps

## Deployment Timing

| Phase | Typical Duration |
|-------|------------------|
| Pre-flight | 5-10 seconds |
| Dependencies | 30-60 seconds |
| Laravel Config | 10-15 seconds |
| Database Setup | 20-40 seconds |
| Apache/SSL | 10-20 seconds |
| Tunnel Setup | 5-10 seconds |
| Testing | 60-180 seconds |
| **Total** | **2-5 minutes** |

## Output Locations

- **Logs**: `/tmp/test_suite_output_tmux-runner-SESSIONID.log`
- **Laravel Logs**: `storage/logs/laravel.log`
- **Apache Logs**: `/var/log/apache2/{PROJECT}-staging-error.log`
- **Test Results**: `storage/test-results/`

## Redeploy Detection

Script automatically detects existing deployment:

```bash
# Checks for existing:
- Database: {PROJECT}_{BRANCH}_staging
- Apache config: /etc/apache2/sites-available/{PROJECT}-staging.conf
- Tunnel config: ~/.cloudflared/{PROJECT}/config.yml

# If found: REDEPLOY mode (preserves data)
# If not found: FRESH DEPLOY mode (creates everything)
```

## Surgical Pre-flight Checks

Prevents vendor creation failures (learned from production issues):

```bash
# Pre-flight: Ensure writability BEFORE composer
for dir in storage bootstrap/cache vendor node_modules public/build; do
    if [ -d "$dir" ]; then
        chown -R "$TARGET_USER:www-data" "$dir"
        chmod -R 775 "$dir"
    elif [ "$dir" = "vendor" ] || [ "$dir" = "node_modules" ]; then
        mkdir -p "$dir"
        chown "$TARGET_USER:www-data" "$dir"
        chmod 775 "$dir"
    fi
done
```

This prevents the "vendor does not exist and could not be created" error.
