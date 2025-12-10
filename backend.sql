-- SECTION 1: Database Schema

-- Leads table
CREATE TABLE leads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  owner_id uuid,
  name text,
  stage text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Applications table
CREATE TABLE applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  lead_id uuid NOT NULL REFERENCES leads(id),
  status text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Tasks table with constraints
CREATE TABLE tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  application_id uuid NOT NULL REFERENCES applications(id),
  type text NOT NULL,
  status text DEFAULT 'pending',
  due_at timestamptz NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  -- Constraint: due_at must be >= created_at
  CONSTRAINT due_at_after_created CHECK (due_at >= created_at),
  
  -- Check constraint: task type must be 'call', 'email', or 'review'
  CONSTRAINT valid_task_type CHECK (type IN ('call', 'email', 'review'))
);

-- Indexes for common queries
-- fetch leads by owner, stage, created_at
CREATE INDEX idx_leads_tenant ON leads(tenant_id);
CREATE INDEX idx_leads_owner_stage_created ON leads(owner_id, stage, created_at);

-- fetch applications by lead
CREATE INDEX idx_applications_tenant ON applications(tenant_id);
CREATE INDEX idx_applications_lead ON applications(lead_id);

-- fetch tasks due today
CREATE INDEX idx_tasks_tenant ON tasks(tenant_id);
CREATE INDEX idx_tasks_due_today ON tasks(due_at) WHERE status != 'completed';
