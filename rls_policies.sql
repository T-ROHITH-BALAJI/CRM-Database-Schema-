ALTER TABLE leads ENABLE ROW LEVEL SECURITY;

CREATE POLICY "select_leads_policy"
ON leads
FOR SELECT
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
  AND
  (
    (auth.jwt() ->> 'role') = 'admin'
    OR owner_id = (auth.jwt() ->> 'user_id')::uuid
    OR team_id IN (
      SELECT ut.team_id
      FROM user_teams ut
      WHERE ut.user_id = (auth.jwt() ->> 'user_id')::uuid
    )
  )
);

CREATE POLICY "insert_leads_policy"
ON leads
FOR INSERT
WITH CHECK (
  tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
  AND (auth.jwt() ->> 'role') IN ('admin', 'counselor')
);
