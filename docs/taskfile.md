# Taskfile.yml Documentation

## Overview

The `Taskfile.yml` automates Terraform operations across infrastructure layers in the Vault Kubernetes lab environment. It provides a consistent interface for deploying, managing, and destroying infrastructure components using [Task](https://taskfile.dev).

## Prerequisites

- **Task**: `brew install go-task` (macOS) or see [taskfile.dev](https://taskfile.dev)
- **Terraform**: >= 1.0
- **kubectl**: Configured with cluster access
- **AWS CLI**: Configured for KMS operations

## Architecture

### Variables
- `STACK`: Infrastructure stack (`common`, `helm`)
- `LAYER`: Specific layer (`base`, `ingress-nginx`, `vault-core`)

### Structure
```
stacks/
├── common/base/          # CA certificates, KMS keys
└── helm/
    ├── ingress-nginx/    # NGINX Ingress Controller  
    └── vault-core/       # HashiCorp Vault
```

## Quick Start

```bash
# Deploy everything
task deploy:all

# Deploy individual components
task deploy STACK=common LAYER=base
task deploy STACK=helm LAYER=vault-core

# Destroy everything
task destroy:all
```

## Available Tasks

| Task | Description | Example |
|------|-------------|---------|
| `init` | Initialize Terraform | `task init STACK=common LAYER=base` |
| `plan` | Show planned changes | `task plan STACK=helm LAYER=vault-core` |
| `apply` | Apply changes | `task apply STACK=helm LAYER=ingress-nginx` |
| `destroy` | Destroy resources | `task destroy STACK=helm LAYER=vault-core` |
| `deploy` | Init + Plan + Apply | `task deploy STACK=common LAYER=base` |
| `deploy:all` | Deploy full stack | `task deploy:all` |
| `destroy:all` | Destroy full stack | `task destroy:all` |
| `echo` | Debug directory context | `task echo STACK=helm LAYER=vault-core` |

## Features

- **Automatic Variable Detection**: Uses `layer.tfvars` files when present
- **Proper Deployment Order**: `deploy:all` maintains dependencies
- **Safety**: Auto-approve with predictable behavior
- **Error Handling**: Fail-fast with clear messages

## Best Practices for Contributors

### Adding New Tasks
```yaml
tasks:
  validate:
    desc: Validate Terraform configuration
    dir: stacks/{{.STACK}}/layers/{{.LAYER}}
    cmds:
      - terraform validate
```

### Adding New Layers
1. **Create structure**: `mkdir -p stacks/new-stack/layers/new-layer/`
2. **Update deploy:all**:
   ```yaml
   deploy:all:
     cmds:
       - task: deploy STACK=common LAYER=base
       - task: deploy STACK=new-stack LAYER=new-layer  # Add here
   ```
3. **Update destroy:all** (reverse order):
   ```yaml
   destroy:all:
     cmds:
       - task: destroy STACK=new-stack LAYER=new-layer  # Add first
       - task: destroy STACK=helm LAYER=vault-core
   ```

### Guidelines
- Always add meaningful `desc` fields
- Use `dir` for tasks needing specific context
- Test tasks individually before integration
- Follow naming conventions: `action` or `action:target`
- Handle errors gracefully with conditional logic

### Example: Complex Task
```yaml
  upgrade:
    desc: Upgrade Helm chart to latest version
    dir: stacks/{{.STACK}}/layers/{{.LAYER}}
    preconditions:
      - sh: "helm version"
        msg: "Helm must be installed"
    cmds:
      - |
        if [ -f "Chart.yaml" ]; then
          helm dependency update
        else
          echo "Not a Helm chart directory"
          exit 1
        fi
```

## Getting Help

### Debugging
```bash
task --list                    # Show all available tasks
task --summary <task-name>     # Show task details
task --verbose <task-name>     # Run with debug output
task echo STACK=x LAYER=y      # Check directory context
```

### Common Issues
- **Missing variables**: Always provide both `STACK` and `LAYER`
- **Directory not found**: Verify stack/layer names match directory structure
- **Terraform state issues**: Navigate to layer directory for troubleshooting
- **Permission issues**: Check AWS and Kubernetes access

### CI/CD Integration
```yaml
# GitHub Actions
- name: Deploy Infrastructure
  run: task deploy:all

# GitLab CI
deploy:
  script:
    - task deploy:all
```

For more Task features, visit [taskfile.dev](https://taskfile.dev).