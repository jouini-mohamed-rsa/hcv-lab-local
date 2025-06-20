# How to Use Taskfile.yml in hcv-lab-local

This project uses a `Taskfile.yml` to automate common Terraform operations for different infrastructure layers and stacks. The tasks are managed using the [Task](https://taskfile.dev) runner.

## Prerequisites

- Install [Task](https://taskfile.dev/).
- Ensure you have Terraform installed and configured.

## Common Variables

- `STACK`: The stack name (e.g., `common`, `helm`).
- `LAYER`: The layer name within the stack (e.g., `ca`, `ingress-nginx`, `vault-core`).

## Available Tasks

### 1. `init`
Initializes Terraform in the selected layer.
```sh
task init STACK=<stack> LAYER=<layer>
```

### 2. `plan`
Runs `terraform plan` for the selected layer.
```sh
task plan STACK=<stack> LAYER=<layer>
```

### 3. `apply`
Applies the Terraform plan for the selected layer.
```sh
task apply STACK=<stack> LAYER=<layer>
```

### 4. `destroy`
Destroys the Terraform-managed resources for the selected layer.
```sh
task destroy STACK=<stack> LAYER=<layer>
```

### 5. `deploy`
Runs `init`, `plan`, and `apply` in sequence for a single layer.
```sh
task deploy STACK=<stack> LAYER=<layer>
```

### 6. `deploy:all`
Deploys all main layers (CA, Ingress, Vault, etc.) in sequence.
```sh
task deploy:all
```

### 7. `destroy:all`
Destroys all main layers in sequence.
```sh
task destroy:all
```

## Example Usage

Initialize and apply the `ca` layer in the `common` stack:
```sh
task deploy STACK=common LAYER=ca
```

Deploy all main layers:
```sh
task deploy:all
```

Destroy all main layers:
```sh
task destroy:all
```

---

For more details, see the comments and descriptions in the `Taskfile.yml`.