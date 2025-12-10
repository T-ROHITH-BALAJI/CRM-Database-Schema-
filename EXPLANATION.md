# LearnLynk Technical Assessment - Explanation

## Section 1: Database Schema (backend.sql)

### What They Asked:
Create SQL schema for 3 tables with constraints, indexes, and relationships.

Requirements:
- Every table must include: id, tenant_id, created_at, updated_at
- applications references leads(id)
- tasks references applications(id) 
- Add proper FOREIGN KEY constraints
- Add indexing for common queries:
  - fetch leads by owner, stage, created_at
  - fetch applications by lead
  - fetch tasks due today
- Add constraint: tasks.due_at >= created_at
- Add check constraint: task.type IN ('call', 'email', 'review')

### What I Implemented:

1. Three Tables Created:
- `leads` - Stores student/lead information with tenant_id, owner_id, name, stage
- `applications` - Tracks applications linked to leads via lead_id foreign key
- `tasks` - Manages follow-up tasks linked to applications via application_id foreign key

2. Constraints Added:
- `CONSTRAINT due_at_after_created CHECK (due_at >= created_at)` - Ensures task due date is after creation
- `CONSTRAINT valid_task_type CHECK (type IN ('call', 'email', 'review'))` - Validates task types
- Foreign keys: `applications.lead_id REFERENCES leads(id)` and `tasks.application_id REFERENCES applications(id)`

3. Indexes for Performance:
- `idx_leads_tenant` - Filter leads by organization
- `idx_leads_owner_stage_created` - Composite index for fetching leads by owner, stage, and creation date
- `idx_applications_tenant` - Filter applications by organization
- `idx_applications_lead` - Fetch all applications for a specific lead
- `idx_tasks_tenant` - Filter tasks by organization
- `idx_tasks_due_today` - Partial index for fetching incomplete tasks due today

---

## Section 2: Row Level Security Policies (rls_policies.sql)

### What They Asked:
Write RLS policies for the leads table.

Goal:
- A counselor should only read leads that are either assigned to them OR assigned to their team
- Admins can read all leads
- Only admins and counselors can insert new leads

Inputs:
- leads.owner_id = counselor user id
- user_teams(user_id, team_id)
- teams(team_id)
- user role in JWT (auth.jwt() -> role: "admin" or "counselor")

### What I Implemented:

1. Enabled Row Level Security:
```sql
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
```
This turns on RLS for the leads table, so all queries must pass through policies.

2. SELECT Policy (Read Access):
Created `select_leads_policy` that allows a user to read leads if:
- They are in the same organization (tenant_id matches)
- AND one of these conditions is true:
  - User is an admin (can see all leads in their org)
  - User owns the lead (owner_id matches their user_id)
  - Lead belongs to a team the user is part of (checks user_teams table)

3. INSERT Policy (Create Access):
Created `insert_leads_policy` that allows creating leads if:
- Lead belongs to user's organization (tenant_id matches)
- User role is either 'admin' or 'counselor' (regular users cannot create leads)

How It Works:
- JWT token contains user_id, tenant_id, and role
- Policies extract these values using `auth.jwt() ->> 'field_name'`
- Subquery checks if user belongs to the same team as the lead
- Ensures data isolation between organizations (multi-tenancy)
- Protects against unauthorized access and data leaks

---

## Summary

These two files demonstrate:
-  Database design with proper relationships
- Data integrity through constraints
- Query optimization through indexes
-  Security implementation with RLS policies
- Multi-tenant architecture
- Role-based access control

---

## Access Control Design - Who Can Access What

### ADMIN Role:
READ: Can see ALL leads in their organization  
CREATE: Can create new leads

### COUNSELOR Role:
READ: Can see leads assigned to them (where owner_id = their user_id)  
READ: Can see leads assigned to their team  
READ: Cannot see other counselors' leads (outside their team)  
CREATE: Can create new leads

### REGULAR USER Role:
 READ: No access to leads table  
CREATE: Cannot create leads

### Examples:

Counselor John(user_id: john-123, Team: Sales Team A)
- Can see: All leads where owner_id = john-123
- Can see: All leads owned by other members of Sales Team A
- Cannot see: Leads from Sales Team B

Admin Sarah(role: admin)
- Can see: ALL leads in her entire organization
- No restrictions within her organization

Regular User Mike (role: user)
- Can see: Nothing from leads table
- Access completely denied

### Multi-Tenant Isolation:

Organization 1 (tenant_id: abc-123)
- Admin A → Sees ALL leads in Org 1 only
- Counselor B → Sees their leads in Org 1 only

**Organization 2** (tenant_id: xyz-789)  
- Admin D → Sees ALL leads in Org 2 only
- Counselor E → Sees their leads in Org 2 only

 Users from Org 1 CANNOT see any data from Org 2  
 Complete data isolation between organizations

