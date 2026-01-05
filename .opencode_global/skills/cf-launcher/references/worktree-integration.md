# CF Launcher + Worktree Orchestration Integration

This guide shows how to integrate CF Launcher with Git worktrees for development workflow.

## Workflow Overview

1. Create worktree for feature/bugfix
2. Create tunnel for the worktree
3. Develop and test with public URL
4. Clean up tunnel when done

## Common Patterns

### Single Worktree Development

```bash
# 1. Create worktree
./scripts/create-worktree.sh feature-new-button

# 2. Create tunnel for the worktree
./scripts/cf-launcher.sh append --config feature-new-button

# 3. Check status
./scripts/cf-launcher.sh status | grep feature-new-button

# 4. Work on feature (tunnel provides public URL)

# 5. When done, remove tunnel
./scripts/cf-launcher.sh --kill-config feature-new-button

# 6. Delete worktree
./scripts/delete-worktree.sh feature-new-button
```

### Multiple Worktree Testing

```bash
# 1. Create multiple worktrees for testing
./scripts/create-worktree.sh api-v2-endpoints
./scripts/create-worktree.sh frontend-redesign

# 2. Create tunnels for all worktrees
echo -e "api-v2-endpoints\nfrontend-redesign" > workspaces.txt
./scripts/cf-launcher.sh --config-file workspaces.txt

# 3. Verify all tunnels are running
./scripts/cf-launcher.sh status --list-configs

# 4. Test integration between worktrees

# 5. Clean up all worktree tunnels
./scripts/cf-launcher.sh --kill-config api-v2-endpoints
./scripts/cf-launcher.sh --kill-config frontend-redesign
```

### Batch Worktree Operations

```bash
# Create all preview worktrees
for i in {13..15}; do
    ./scripts/create-worktree.sh "psp-p2p-preview-$i"
done

# Create configuration file
echo -e "psp-p2p-preview-13\npsp-p2p-preview-14\npsp-p2p-preview-15" > preview-worktrees.txt

# Start all tunnels
./scripts/cf-launcher.sh --config-file preview-worktrees.txt

# Work on all previews simultaneously
```

## Integration Commands

### Worktree Creation with Tunnel

```bash
# Combined command to create worktree and tunnel
WORKTREE_NAME="feature-x"
./scripts/create-worktree.sh "$WORKTREE_NAME"
./scripts/cf-launcher.sh append --config "$WORKTREE_NAME"
```

### Worktree Deletion with Cleanup

```bash
# Combined command to clean up and delete
WORKTREE_NAME="completed-feature"
./scripts/cf-launcher.sh --kill-config "$WORKTREE_NAME"
./scripts/delete-worktree.sh "$WORKTREE_NAME"
```

### Status Check for Active Worktrees

```bash
# Check which worktrees have active tunnels
./scripts/cf-launcher.sh status --list-configs | grep -E "preview|feature|bugfix"
```

## Configuration File Management

### Dynamic Worktree Configuration

```bash
# Generate config file from existing worktrees
ls worktrees/ | grep -E "preview|feature" > active-worktrees.txt

# Start tunnels for all worktrees
./scripts/cf-launcher.sh --config-file active-worktrees.txt
```

### Selective Tunnel Management

```bash
# Start only specific types of worktrees
grep "preview" worktrees-list.txt > preview-only.txt
./scripts/cf-launcher.sh --config-file preview-only.txt
```

## Best Practices

### Naming Conventions
- Use descriptive names: `feature-short-description`
- Include preview numbers: `psp-p2p-preview-13`
- Use consistent prefixes for grouping

### Resource Management
- Remove tunnels when worktrees are deleted
- Use status checks to identify orphaned tunnels
- Clean up test tunnels regularly

### Workflow Integration
- Create tunnel immediately after worktree creation
- Include tunnel cleanup in worktree deletion process
- Use configuration files for batch operations

## Troubleshooting

### Worktree Not Accessible
```bash
# Check if tunnel is running
./scripts/cf-launcher.sh status | grep worktree-name

# Verify worktree exists
ls worktrees/worktree-name

# Restart tunnel if needed
./scripts/cf-launcher.sh --kill-config worktree-name
./scripts/cf-launcher.sh append --config worktree-name
```

### Tunnel Configuration Issues
```bash
# Check configuration file exists
ls ~/.cloudflared/psp-p2p/config-worktree-name.yml

# Verify local server is running
curl -I http://localhost:port
```

### Cleanup After Failed Operations
```bash
# Remove orphaned tunnels
./scripts/cf-launcher.sh status --list-configs | grep -x "deleted-worktree"

# Kill specific orphaned tunnel
./scripts/cf-launcher.sh --kill-config deleted-worktree
```
