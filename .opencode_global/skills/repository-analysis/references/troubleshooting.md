# Repomix Troubleshooting Guide

## Common Issues and Solutions

### Issue 1: Command Not Found

**Symptoms**:
```bash
$ repomix --help
bash: repomix: command not found
```

**Causes**:
- Repomix not installed
- Not in PATH
- Installed locally vs globally

**Solutions**:

**Solution A: Install globally**
```bash
npm install -g repomix

# Verify installation
repomix --version
which repomix
```

**Solution B: Use npx (no installation needed)**
```bash
npx repomix [options]
```

**Solution C: Check PATH**
```bash
# Check if npm global bin is in PATH
echo $PATH | grep npm

# Add to PATH if missing (add to ~/.bashrc or ~/.zshrc)
export PATH="$PATH:$(npm config get prefix)/bin"
source ~/.bashrc
```

**Solution D: Install locally and run**
```bash
npm install repomix
npx repomix [options]
```

---

### Issue 2: Output File Too Large (> 50MB)

**Symptoms**:
```bash
$ repomix --compress --include "**" --style xml -o output.xml
# Output: output.xml (78MB)
```

**Causes**:
- Including too many files
- Including dependencies (node_modules, vendor)
- Including binary files
- Not using compression

**Solutions**:

**Solution A: Add more exclusions**
```bash
repomix \
  --compress \
  --include "app/**,config/**,routes/**" \
  -i "vendor/**,node_modules/**,storage/**,public/**,*.log,*.cache" \
  --style xml \
  -o output.xml
```

**Solution B: Use selective inclusion (fewer directories)**
```bash
# Instead of including everything
--include "**"

# Include only what you need
--include "app/**,config/**,routes/**"
```

**Solution C: Split into multiple analyses**
```bash
# Backend analysis
repomix --compress --include "app/**,config/**" --style xml -o backend.xml

# Frontend analysis
repomix --compress --include "resources/**" --style xml -o frontend.xml
```

**Solution D: Verify exclusions are working**
```bash
# Test with list mode first
repomix \
  --compress \
  --include "app/**,config/**" \
  -i "vendor/**,node_modules/**" \
  --list-only

# Then run full analysis if file count reasonable
```

---

### Issue 3: Missing Expected Files

**Symptoms**:
```bash
# Expected app/Services/ files but they're not in output
```

**Causes**:
- Incorrect glob pattern
- Files excluded by broader pattern
- File permissions issue
- Directory doesn't exist

**Solutions**:

**Solution A: Check glob pattern**
```bash
# Wrong (only matches direct children)
--include "app/*"

# Correct (recursive)
--include "app/**"

# Correct (specific subdirectory)
--include "app/Services/**"
```

**Solution B: Verify exclusion patterns aren't too broad**
```bash
# Bad: This excludes app/Services if Services contains "cache"
-i "**/*cache*/**"

# Good: Be specific
-i "storage/cache/**,*.cache,**/cache/**"
```

**Solution C: Test with list-only mode**
```bash
repomix \
  --include "app/**,config/**" \
  -i "vendor/**" \
  --list-only | grep Services

# Should show: app/Services/SomeService.php
```

**Solution D: Check file permissions**
```bash
# Check if you have read access
ls -la app/Services/

# Fix permissions if needed
chmod +r app/Services/*.php
```

**Solution E: Verify directory exists**
```bash
# Check if directory exists
ls -la app/Services/

# If it doesn't exist, adjust your include pattern
```

---

### Issue 4: Long Execution Time (> 2 minutes)

**Symptoms**:
```bash
$ repomix --compress --include "**" --style xml -o output.xml
# Hangs for 5+ minutes
```

**Causes**:
- Including large dependency directories
- No exclusion patterns
- Large codebase (> 1000 files)
- Analyzing binary files

**Solutions**:

**Solution A: Add dependency exclusions**
```bash
repomix \
  --compress \
  --include "app/**,config/**" \
  -i "vendor/**,node_modules/**,.git/**,storage/**" \
  --style xml \
  -o output.xml
```

**Solution B: Use specific inclusion paths**
```bash
# Instead of "**" (scans everything)
--include "**"

# Use specific paths
--include "app/**,config/**,database/**,routes/**"
```

**Solution C: Exclude large file types**
```bash
-i "**/*.png,**/*.jpg,**/*.jpeg,**/*.gif,**/*.pdf,**/*.zip,**/*.tar.gz"
```

**Solution D: Check what's being scanned**
```bash
# Use --list-only to see file count without full analysis
repomix --include "**" -i "vendor/**,node_modules/**" --list-only | wc -l

# If count > 1000, add more exclusions
```

---

### Issue 5: Invalid XML Output

**Symptoms**:
```bash
$ cat output.xml
# XML is malformed or contains syntax errors
```

**Causes**:
- File contains invalid characters
- XML special characters not escaped
- Encoding issues
- Incomplete write (disk full, interrupted)

**Solutions**:

**Solution A: Validate XML**
```bash
# Check if XML is valid
xmllint --noout output.xml

# Or use Python
python3 -c "import xml.etree.ElementTree as ET; ET.parse('output.xml')"
```

**Solution B: Try different output format**
```bash
# Try JSON instead
repomix --compress --include "app/**" --style json -o output.json

# Or plain text
repomix --compress --include "app/**" --style plain -o output.txt
```

**Solution C: Check for encoding issues**
```bash
# Check file encoding
file output.xml

# Convert if needed
iconv -f UTF-8 -t UTF-8//IGNORE output.xml -o output-fixed.xml
```

**Solution D: Exclude problematic files**
```bash
# If specific files cause issues, exclude them
repomix \
  --compress \
  --include "app/**" \
  -i "app/ProblematicFile.php" \
  --style xml \
  -o output.xml
```

---

### Issue 6: Disk Space Issues

**Symptoms**:
```bash
$ repomix --compress --include "**" --style xml -o output.xml
# Error: No space left on device
```

**Causes**:
- Output file growing too large
- Temp files consuming space
- Disk actually full

**Solutions**:

**Solution A: Check available disk space**
```bash
df -h .
```

**Solution B: Use smaller inclusion set**
```bash
# Minimal analysis
repomix --compress --include "app/**,config/**,routes/**" --style xml -o output.xml
```

**Solution C: Output to different location**
```bash
# Output to drive with more space
repomix --compress --include "app/**" --style xml -o /mnt/backup/output.xml
```

**Solution D: Clean up temp files**
```bash
# Clear temp directory
rm -rf /tmp/repomix-*

# Clear npm cache
npm cache clean --force
```

---

### Issue 7: Permission Denied Errors

**Symptoms**:
```bash
$ repomix --compress --include "app/**" --style xml -o output.xml
# Error: Permission denied: app/SomeFile.php
```

**Causes**:
- No read permission on files
- No write permission on output directory
- Running as wrong user

**Solutions**:

**Solution A: Fix file permissions**
```bash
# Grant read permission to all PHP files
chmod -R +r app/

# Or specific file
chmod +r app/SomeFile.php
```

**Solution B: Check output directory permissions**
```bash
# Check if you can write to current directory
touch test-write && rm test-write

# If not, output elsewhere
repomix --compress --include "app/**" --style xml -o ~/output.xml
```

**Solution C: Run with appropriate user**
```bash
# If files owned by different user
sudo chown -R $USER:$USER app/

# Then run repomix
repomix --compress --include "app/**" --style xml -o output.xml
```

---

### Issue 8: Unexpected File Count

**Symptoms**:
```bash
# Expected 200 files, got 2000
# Or: Expected 200 files, got 20
```

**Causes**:
- Glob patterns matching more/less than expected
- Hidden files included/excluded
- Exclusion patterns too aggressive

**Solutions**:

**Solution A: Use --list-only to verify**
```bash
repomix \
  --include "app/**" \
  -i "vendor/**" \
  --list-only

# Count files
repomix --include "app/**" -i "vendor/**" --list-only | wc -l
```

**Solution B: Check for hidden files**
```bash
# List hidden files in target directory
ls -la app/ | grep "^\."

# Exclude if needed
-i ".*,**/.*"
```

**Solution C: Test glob patterns**
```bash
# Test include pattern
find app/ -type f

# Test with glob
find app/ -type f -name "*.php"
```

---

### Issue 9: Empty Output File

**Symptoms**:
```bash
$ repomix --compress --include "app/**" --style xml -o output.xml
$ ls -lh output.xml
-rw-rw-r-- 1 user user 0 Dec 19 12:00 output.xml
```

**Causes**:
- No files matched inclusion pattern
- All files excluded
- Directory doesn't exist
- Command syntax error

**Solutions**:

**Solution A: Verify files exist**
```bash
# Check if files exist
ls -la app/

# Check if any PHP files
find app/ -name "*.php"
```

**Solution B: Test with minimal command**
```bash
# Remove all exclusions first
repomix --compress --include "app/**" --style xml -o test.xml

# Check if output has content
ls -lh test.xml
```

**Solution C: Check command syntax**
```bash
# Verify quotes and escaping
repomix \
  --compress \
  --include "app/**,config/**" \
  --style xml \
  -o output.xml

# Not:
repomix --compress --include app/**,config/** --style xml -o output.xml
# (Missing quotes can cause issues)
```

**Solution D: Run from correct directory**
```bash
# Make sure you're in project root
pwd
# Should show: /path/to/project

# If not, cd to project root
cd /path/to/project
repomix --compress --include "app/**" --style xml -o output.xml
```

---

### Issue 10: Version Compatibility Issues

**Symptoms**:
```bash
$ repomix --compress --include "app/**"
# Error: Unknown option '--compress'
```

**Causes**:
- Old version of repomix
- Deprecated flags
- Breaking changes in new version

**Solutions**:

**Solution A: Check version**
```bash
repomix --version
npm list -g repomix
```

**Solution B: Update to latest**
```bash
npm update -g repomix

# Or reinstall
npm uninstall -g repomix
npm install -g repomix
```

**Solution C: Check documentation for version**
```bash
# Check help for available options
repomix --help

# Use options supported by your version
```

**Solution D: Install specific version**
```bash
# Install specific version if newer breaks things
npm install -g repomix@1.0.0
```

---

## Size Optimization Strategies

### Strategy 1: Measure Before Optimizing

**Step 1: Run minimal analysis**
```bash
repomix --compress --include "app/**,config/**,routes/**" --style xml -o baseline.xml
ls -lh baseline.xml
# Output: 5MB
```

**Step 2: Check file count**
```bash
grep -c "<file" baseline.xml
# Output: 150 files
```

**Step 3: If too large, add exclusions incrementally**
```bash
# Exclude tests
repomix --compress --include "app/**,config/**,routes/**" -i "tests/**" --style xml -o opt1.xml
ls -lh opt1.xml
# Output: 4MB (saved 1MB)

# Exclude more
repomix --compress --include "app/**,config/**,routes/**" -i "tests/**,docs/**" --style xml -o opt2.xml
ls -lh opt2.xml
# Output: 3.5MB (saved 1.5MB)
```

---

### Strategy 2: Identify Large Files

**Step 1: List files by size**
```bash
repomix --list-only --include "app/**" | while read file; do du -sh "$file"; done | sort -h
```

**Step 2: Exclude largest if not needed**
```bash
# Identify: app/LargeFeature.php is 500KB
# Exclude it
repomix --compress --include "app/**" -i "app/LargeFeature.php" --style xml -o output.xml
```

---

### Strategy 3: Use Component-Specific Analyses

**Instead of one large analysis:**
```bash
repomix --compress --include "app/**,config/**,database/**,resources/**,routes/**,tests/**" --style xml -o huge-analysis.xml
# Output: 45MB
```

**Create focused analyses:**
```bash
# Backend
repomix --compress --include "app/**,config/**,routes/**" -i "tests/**" --style xml -o backend-only.xml
# Output: 8MB

# Database
repomix --compress --include "database/**,app/Models/**" --style xml -o database-only.xml
# Output: 3MB

# Frontend
repomix --compress --include "resources/**" --style xml -o frontend-only.xml
# Output: 6MB

# Tests
repomix --compress --include "tests/**" --style xml -o tests-only.xml
# Output: 12MB

# Total: 29MB across 4 files (vs 45MB in one)
```

---

## Debugging Workflow

### Debugging Process

**Step 1: Verify repomix is installed and working**
```bash
repomix --version
repomix --help
```

**Step 2: Test with minimal command**
```bash
cd /path/to/project
repomix --include "app/**" --list-only | head -10
```

**Step 3: Check file count**
```bash
repomix --include "app/**" --list-only | wc -l
# Should match expected file count
```

**Step 4: Run actual analysis**
```bash
repomix --compress --include "app/**" --style xml -o test-output.xml
```

**Step 5: Verify output**
```bash
ls -lh test-output.xml
head -50 test-output.xml
grep -c "<file" test-output.xml
```

**Step 6: If issues, adjust and repeat**
```bash
# Add exclusions
repomix --compress --include "app/**" -i "tests/**,vendor/**" --style xml -o test-output-2.xml

# Verify improvement
ls -lh test-output-2.xml
```

---

## Quick Reference: Command Validation Checklist

Before running repomix analysis:

- [ ] Are you in the project root directory?
- [ ] Is repomix installed? (`repomix --version`)
- [ ] Do the include paths exist? (`ls app/`)
- [ ] Are there files to analyze? (`ls app/*.php`)
- [ ] Have you excluded dependencies? (`-i "vendor/**,node_modules/**"`)
- [ ] Have you excluded storage? (`-i "storage/**"`)
- [ ] Have you excluded logs/cache? (`-i "*.log,*.cache"`)
- [ ] Is compression enabled? (`--compress`)
- [ ] Is output path writable? (`touch test.xml && rm test.xml`)
- [ ] Is there enough disk space? (`df -h .`)

After running repomix analysis:

- [ ] Does the output file exist? (`ls -lh output.xml`)
- [ ] Is the file size reasonable? (< 50MB for typical projects)
- [ ] Is the XML valid? (`xmllint --noout output.xml`)
- [ ] Does it contain expected files? (`grep "app/Http" output.xml`)
- [ ] Is the file count correct? (`grep -c "<file" output.xml`)
