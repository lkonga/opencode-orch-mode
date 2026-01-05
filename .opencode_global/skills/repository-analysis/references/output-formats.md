# Output Formats Reference

## XML Structure

Default output format with hierarchical structure:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<repository>
  <metadata>
    <generated>2025-12-19T14:30:00Z</generated>
    <tool>repomix</tool>
    <compression>enabled</compression>
  </metadata>
  <files>
    <file path="app/Http/Controllers/AuthController.php">
      <content><![CDATA[
        <?php
        namespace App\Http\Controllers;
        // File content here
      ]]></content>
    </file>
    <file path="config/app.php">
      <content><![CDATA[
        <?php
        return [
            // Configuration content
        ];
      ]]></content>
    </file>
  </files>
</repository>
```

## Plain Text Format

Alternative format (`--style plain`):

```
=== Repository Analysis ===
Generated: 2025-12-19T14:30:00Z
Tool: repomix

--- app/Http/Controllers/AuthController.php ---
<?php
namespace App\Http\Controllers;
// File content

--- config/app.php ---
<?php
return [
    // Configuration content
];
```

## Token Estimates by Size

| Analysis Size | File Count | Typical Tokens | Use Case |
|---------------|------------|----------------|----------|
| Small         | < 50       | 50K-100K       | Quick snapshots, single feature |
| Medium        | 50-200     | 100K-300K      | Standard documentation, module analysis |
| Large         | 200-500    | 300K-800K      | Complete refactoring, system design |
| Very Large    | 500+       | 800K+          | Full codebase audit (split recommended) |

## Format Selection Guide

**Use XML when:**
- Parsing with AI/tooling
- Need structured metadata
- Integrating with other skills
- Building documentation automatically

**Use Plain when:**
- Human review focus
- Simple text processing
- Quick manual inspection
- Smaller token budgets

## Validation Quick Reference

```bash
# XML validation
head -50 output.xml                    # Check structure
grep -c "<file" output.xml             # Count files
xmllint --noout output.xml            # Validate syntax

# Plain validation
head -50 output.txt                    # Check format
grep -c "^---" output.txt              # Count files
wc -l output.txt                       # Total lines
```
