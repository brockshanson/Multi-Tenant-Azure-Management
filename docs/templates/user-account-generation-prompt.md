# User Account Generation Prompt for Test Tenants

## Context

You are helping to populate two artificial Microsoft 365 test tenants with realistic but fictional user accounts. These accounts will be used to simulate active usage patterns for license optimization testing.

## Organizations

### Dasein Research Group

- **Industry**: Academic/Research Institution
- **Size**: ~50 users (simulating established organization)
- **Culture**: Collaborative, research-focused, academic environment
- **Technology**: Mature Microsoft 365 adoption
- **License Allocation**:
  - 5x Microsoft 365 F3 (Frontline workers - security, facilities)
  - 1x Microsoft 365 E5 (no Teams) (Executive/IT admin)
  - 4x Microsoft 365 Apps for Business (Faculty/researchers)
  - 1x Microsoft Teams Enterprise (Dedicated Teams-only user)

### Spectral Solutions

- **Industry**: Technology Consulting/Solutions Provider
- **Size**: ~25 users (simulating growing organization)
- **Culture**: Agile, client-focused, innovative technology firm
- **Technology**: Growing Microsoft 365 adoption
- **License Allocation**:
  - 6x Microsoft 365 F3 (Part-time/contract workers)
  - 1x Microsoft 365 E5 (CTO/IT admin)
  - 5x Microsoft 365 Apps for Business (Core team members)
  - 1x Teams Enterprise (All Teams access via other licenses)

## Requirements

For each organization, generate **12 themed user accounts** that include:

1. **Display Name** - Realistic but fictional (winks/nods to real people acceptable)
2. **Email Address** - username@[domain]
3. **Job Title** - Appropriate for organization type
4. **Department** - Logical organizational structure
5. **User Type** - Regular user, admin, service account, etc.
6. **Usage Profile** - Expected Microsoft 365 activity level (High/Medium/Low)

## Guidelines

- **No direct real names** - Use variations, combinations, or subtle references
- **Organizational authenticity** - Names and roles should fit the company culture
- **Diverse representation** - Include varied backgrounds, roles, and seniority levels
- **Testing utility** - Mix of active and inactive usage patterns for optimization testing
- **Professional realism** - Names that would realistically exist in these organizations

## Output Format

For each organization, provide a table with:

| Display Name | Email | Job Title | Department | User Type | License Type | Usage Profile | Notes |
|--------------|-------|-----------|------------|-----------|--------------|---------------|-------|
| | | | | | | | |

## License Type Options

- **F1**: Microsoft 365 F1 (Frontline workers, part-time staff)
- **E5**: Microsoft 365 E5 (Executives, IT admins, power users)
- **Business Premium**: Microsoft 365 Business Premium (Core knowledge workers)
- **Teams Enterprise**: Microsoft Teams Enterprise (Teams-focused users)

## Usage Profile Definitions

- **High**: Daily active across multiple Microsoft 365 workloads
- **Medium**: Regular usage of 2-3 workloads, occasional gaps
- **Low**: Minimal usage, potential license optimization candidate
- **Inactive**: Rarely uses services, prime optimization target

## Special Considerations

- Include at least 2 admin accounts per organization (assign E5 licenses)
- Include 1-2 service accounts for testing (can use F1 licenses)
- Respect license allocation limits:
  - **Dasein**: 6x F1, 1x E5, 4x Business Premium, 1x Teams Enterprise
  - **Spectral**: 3x F1, 1x E5, 8x Business Premium
- Mix of senior staff (high usage) and occasional users (optimization candidates)
- Ensure some accounts will demonstrate the 28-day active usage criteria
- Create realistic departmental distribution for each organization type
- F1 licenses typically for frontline workers with limited Office app needs
- E5 licenses for power users requiring advanced compliance/security features
- Business Premium for standard knowledge workers

## Example Starter (Modify/Expand)

### Dasein Research Group Sample

### Spectral Solutions Sample  

---

**Prompt**: Generate the complete user account lists for both organizations following these guidelines.
