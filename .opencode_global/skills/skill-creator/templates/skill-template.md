---
name: '{{SKILL_NAME}}'
description: '{{DESCRIPTION}}'
trigger: ['${{SKILL_NAME}}', '{{TRIGGER_KEYWORD_1}}', '{{TRIGGER_KEYWORD_2}}']
related_skills: ['${{RELATED_SKILL_1}}', '${{RELATED_SKILL_2}}']
references: {'{{REFERENCE_TITLE_1}}': 'references/{{REFERENCE_FILE_1}}.md', '{{REFERENCE_TITLE_2}}': 'references/{{REFERENCE_FILE_2}}.md'}
---

# {{SKILL_NAME}}

## Quickstart ({{TIME_ESTIMATE}})

**Purpose**: {{ONE_SENTENCE_PURPOSE}}

**Core Workflow**:
1. {{STEP_1}}
2. {{STEP_2}}
3. {{STEP_3}}

**Trigger When**:
- {{TRIGGER_CONDITION_1}}
- {{TRIGGER_CONDITION_2}}
- {{TRIGGER_CONDITION_3}}

## Core Principle

**{{CORE_PRINCIPLE_BOLD}}** - {{PRINCIPLE_EXPLANATION}}

## When to Use

- {{USE_CASE_1}}
- {{USE_CASE_2}}
- {{USE_CASE_3}}
- {{USE_CASE_4}}

## {{WORKFLOW_TITLE}}

### Phase 1: {{PHASE_1_NAME}} ({{PHASE_1_TIME}})

{{PHASE_1_DESCRIPTION}}

**{{PHASE_1_SECTION_1}}**:
- {{PHASE_1_STEP_1}}
- {{PHASE_1_STEP_2}}

**{{PHASE_1_SECTION_2}}**:
- {{PHASE_1_STEP_3}}
- {{PHASE_1_STEP_4}}

<reference title="{{INLINE_REF_1_TITLE}}" path="references/{{INLINE_REF_1_FILE}}.md" description="{{INLINE_REF_1_DESCRIPTION}}" />

### Phase 2: {{PHASE_2_NAME}} ({{PHASE_2_TIME}})

{{PHASE_2_DESCRIPTION}}

**{{PHASE_2_APPROACH}}**:
```bash
# {{PHASE_2_EXAMPLE_DESCRIPTION}}
{{PHASE_2_EXAMPLE_COMMAND}}
```

<reference title="{{INLINE_REF_2_TITLE}}" path="references/{{INLINE_REF_2_FILE}}.md" description="{{INLINE_REF_2_DESCRIPTION}}" />

### Phase 3: {{PHASE_3_NAME}} ({{PHASE_3_TIME}})

{{PHASE_3_DESCRIPTION}}

**{{PHASE_3_SECTION}}**:
- [ ] {{PHASE_3_CHECK_1}}
- [ ] {{PHASE_3_CHECK_2}}
- [ ] {{PHASE_3_CHECK_3}}

## Integration Examples

**With {{INTEGRATION_SKILL_1}}**:
```bash
# {{INTEGRATION_EXAMPLE_1_DESCRIPTION}}
${{INTEGRATION_SKILL_1}} {{INTEGRATION_EXAMPLE_1_COMMAND}}

# {{SKILL_USAGE_WITH_INTEGRATION_1}}
${{SKILL_NAME}} {{SKILL_COMMAND_1}}
```

**With {{INTEGRATION_SKILL_2}}**:
```bash
# {{INTEGRATION_EXAMPLE_2_DESCRIPTION}}
${{INTEGRATION_SKILL_2}} {{INTEGRATION_EXAMPLE_2_COMMAND}}
```

## Success Criteria

- [ ] {{SUCCESS_CRITERION_1}}
- [ ] {{SUCCESS_CRITERION_2}}
- [ ] {{SUCCESS_CRITERION_3}}
- [ ] {{SUCCESS_CRITERION_4}}

## Progressive Disclosure

**References** (load only when needed):
<references>
  <reference title="{{PD_REF_1_TITLE}}" path="references/{{PD_REF_1_FILE}}.md" description="{{PD_REF_1_DESCRIPTION}}" />
  <reference title="{{PD_REF_2_TITLE}}" path="references/{{PD_REF_2_FILE}}.md" description="{{PD_REF_2_DESCRIPTION}}" />
  <reference title="{{PD_REF_3_TITLE}}" path="references/{{PD_REF_3_FILE}}.md" description="{{PD_REF_3_DESCRIPTION}}" />
</references>

<!--
TEMPLATE USAGE NOTES:
- Replace all {{PLACEHOLDERS}} with actual content
- Keep SKILL.md under 150 lines - move detailed content to references/
- Inline references should be contextually placed near related content
- Progressive Disclosure references are for general/supplementary content
- If a reference is inlined, do NOT add it to Progressive Disclosure section
- Descriptions should be 5-15 words, brief yet descriptive
- Use concrete examples rather than abstract descriptions
-->
