# Multi-Tenant Azure Management with Lokka MCP

A comprehensive framework for managing multiple Azure tenants using Lokka MCP (Model Context Protocol) servers with flexible client interface support.

## Project Overview

This project enables seamless management of multiple Azure tenants through MCP servers, supporting various client interfaces including VS Code with GitHub Copilot Studio, Claude Desktop, and custom automation scripts.

### Target Tenants (Artificial Test Environment)

- **Dasein Research Group** - Primary test tenant for mature configuration testing
- **Spectral Solutions** - Secondary test tenant for scalability pattern testing

*Note: These are entirely artificial tenants created for testing and demonstration purposes.*

## Supported Client Interfaces

- **VS Code with GitHub Copilot Studio** *(Recommended for teams)*
  - Automation scripting and version control integration
  - Team collaboration and workspace sharing
  - Code generation and automation capabilities

- **Claude Desktop**
  - Natural language processing for complex queries
  - Real-time interaction capabilities

- **Custom Scripts & APIs**
  - Automated workflows and CI/CD integration
  - Programmatic access for specialized use cases

## Project Structure

```text
Multi-Tenant Azure Management/
├── .vscode/                  # VS Code workspace configuration
├── automation/               # Scripts and automation workflows
├── documentation/            # Project documentation
├── config/                   # Configuration templates
└── README.md                # This file
```

## Documentation

- [**Multi-Tenant Management Logic and Approach**](Multi-Tenant%20Management%20Logic%20and%20Approach.md) - Complete methodology and implementation guide
- [**Command Log - Graph API Interactions**](Command%20Log%20-%20Graph%20API%20Interactions.md) - Flexible logging framework for API interactions
- [**User Account Generation Prompt**](User%20Account%20Generation%20Prompt.md) - Guidelines for creating test user accounts

## Key Features

- **Unified Management Interface** - Single AI model interface for multi-tenant operations
- **Security Isolation** - Proper tenant separation with individual authentication
- **Platform Flexibility** - Support for multiple client interfaces
- **Automation Ready** - Scriptable workflows and version-controlled procedures
- **Team Collaboration** - Shared workspaces and collaborative development

## Getting Started

1. **Clone this repository**

   ```bash
   git clone <repository-url>
   cd "Multi-Tenant Azure Management"
   ```

2. **Set up VS Code workspace** (recommended)
   - Open the folder in VS Code
   - Install recommended extensions
   - Configure MCP servers

3. **Configure Azure tenants**
   - Set up Lokka MCP server instances
   - Configure client secrets and authentication
   - Test connectivity

4. **Review documentation**
   - Read the Logic and Approach document
   - Familiarize yourself with the Command Log format
   - Follow implementation phases

## Security Considerations

- Client secrets and authentication tokens are excluded from version control
- Each tenant has isolated authentication and permissions
- Audit logging is maintained for all tenant interactions
- Regular credential rotation is recommended

## Contributing

This project supports team collaboration through:

- Version-controlled documentation and scripts
- Shared VS Code workspace configuration
- Code reviews for automation scripts
- GitHub Issues for tracking improvements

## License

This project is for internal use and testing purposes.

---

**Last updated:** July 11, 2025
