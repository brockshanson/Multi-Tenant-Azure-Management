# Multi-Tenant Azure Management Framework

A comprehensive framework for managing multiple Azure tenants using Lokka MCP servers with AI-powered interfaces and secure automation.

## 🚀 Quick Start

**Option 1: Automated Setup (Recommended)**
```bash
git clone <repository-url>
cd "Tenant Automation Workbook"
./scripts/utilities/setup-azure-credentials.sh
```

**Option 2: Manual Setup**
```bash
# 1. Copy environment template
cp config/templates/.env.template .env.local

# 2. Configure your Azure credentials in .env.local

# 3. Load environment and test
source scripts/utilities/load-env.sh
./scripts/utilities/check-env.sh --test-auth
```

**Start Your Client**
```bash
# Load environment variables
source scripts/utilities/load-env.sh

# Start your preferred MCP client
code .              # VS Code
open -a "Claude"    # Claude Desktop
```

📖 **Detailed Setup:** [Quick Start Guide](docs/guides/quick-start-guide.md) | [Local Credential Setup Walkthrough](docs/guides/local-credential-setup-walkthrough.md)

## 📁 Repository Structure

```text
├── docs/
│   ├── guides/           # Step-by-step implementation guides
│   ├── references/       # Technical documentation & API references  
│   └── templates/        # Reusable templates and prompts
├── workflows/
│   ├── generic/          # Public workflow templates
│   └── specific/         # Your actual workflow logs (git-ignored)
├── config/
│   ├── templates/        # Configuration templates
│   └── secrets/          # Secret management (git-ignored)
├── scripts/
│   ├── automation/       # Workflow automation scripts
│   └── utilities/        # Setup and maintenance utilities
└── assets/               # Images, diagrams, and other resources
```

## 📚 Documentation

### 🎯 Getting Started
- [**Multi-Tenant Management Guide**](docs/guides/multi-tenant-management-guide.md) - Complete implementation guide
- [**Secret Management**](docs/references/secret-management.md) - Secure credential handling
- [**Tenant Setup Guide**](docs/guides/tenant-setup-guide.md) - Azure tenant configuration

### 🔧 Technical References  
- [**MCP Configuration**](docs/references/mcp-configuration.md) - Lokka MCP server setup
- [**Authentication Guide**](docs/references/authentication-guide.md) - Azure authentication setup
- [**API Reference**](docs/references/api-reference.md) - Microsoft Graph API usage patterns

### 📝 Templates & Workflows
- [**User Account Generation**](docs/templates/user-account-generation-prompt.md) - Create test user accounts
- [**Command Log Template**](workflows/templates/command-log-template.md) - API interaction logging
- [**Generic Workflows**](workflows/generic/) - Reusable workflow patterns

## 🛡️ Security Features

- **Environment-based Secret Management** - No secrets in version control
- **Tenant Isolation** - Separate authentication per tenant
- **Audit Logging** - Comprehensive interaction tracking
- **Credential Rotation** - Automated secret rotation scripts

## 🎯 Key Features

### Multi-Interface Support
- **VS Code Integration** - Team collaboration, version control, automation scripting
- **Claude Desktop** - Natural language processing, real-time interaction  
- **API/Script Access** - Automated workflows, CI/CD integration

### License Optimization
- **Usage Tracking** - Monitor Microsoft 365 license utilization
- **Cost Analysis** - Identify optimization opportunities
- **Cross-Tenant Comparison** - Benchmark usage patterns

### Team Collaboration
- **Version Control** - Git-based workflow management
- **Shared Workspaces** - Consistent development environment
- **Code Reviews** - Peer review of automation scripts

## 🏗️ Architecture

### Tenant Configuration
```text
├── Dasein Research Group (Tenant 1)
│   ├── Tenant ID: ef63f3e9-134f-428f-b601-1bfe781034f8
│   ├── Client ID: 16554e45-c734-480d-bb04-9f9fe7a3ab5e
│   └── 12 User Test Environment
│
└── Spectral Solutions (Tenant 2) 
    ├── Tenant ID: 049d5c8d-0cb4-4880-bc97-8a770b44be56
    ├── Client ID: 15315bba-3aa4-46c6-be01-955198f119e0
    └── 12 User Test Environment
```

### Implementation Status

- ✅ **Foundation Setup** - Repository, documentation, secret management
- 🚧 **Multi-Tenant Configuration** - MCP servers, authentication, testing
- 📋 **Operational Validation** - User population, usage simulation
- 📝 **Documentation & Automation** - SOPs, emergency procedures

## 🚀 Usage Examples

### License Optimization Query
```
Find all users in both tenants who haven't sent an email in the last 28 days
```

### Cross-Tenant Analysis  
```
Compare SharePoint usage patterns between Dasein and Spectral tenants
```

### Automated Reporting
```
Generate weekly license utilization report for both organizations
```

## 🤝 Contributing

This framework supports team collaboration through:

- **Version-controlled Documentation** - All guides and templates tracked in Git
- **Shared VS Code Workspace** - Consistent development environment  
- **Code Reviews** - Peer review of automation scripts and configurations
- **Issue Tracking** - GitHub Issues for bug reports and feature requests

## 📄 License

This project is for internal use and testing purposes.

---

**Framework Version:** 1.0  
**Last Updated:** July 11, 2025  
**Maintained By:** Multi-Tenant Management Team
