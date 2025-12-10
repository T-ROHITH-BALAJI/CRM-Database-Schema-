# CRM-Database-Schema-


This project demonstrates database design, security implementation, and multi-tenant architecture for a CRM system.
## Project Overview
This is a database schema and security implementation for a CRM (Customer Relationship Management) system designed for educational institutions to manage student leads, applications, and follow-up tasks.

## Context: What is this CRM for?
This CRM helps educational counselors and admissions teams:
- Track potential students (leads)
- Manage their applications
- Schedule follow-up tasks (calls, emails, reviews)s
- Maintain data security with role-based access control
- Support multiple organizations on the same platform (multi-tenancy)

## Files Included

### 1. `backend.sql` - Database Schema
Creates the core database structure with 3 main tables:
- leads - Potential students interested in the institution
-applications - Formal applications submitted by leads
- tasks - Follow-up activities (calls, emails, reviews) linked to applications

Key Features:
- Foreign key relationships between tables
- Constraints to ensure data integrity (due dates, task types)
- Optimized indexes for common queries
- Multi-tenant support (tenant_id in all tables)

### 2. `rls_policies.sql` - Row Level Security
Implements security policies to control data access:
-*Admin can see all leads in their organization
- Counselors can only see leads assigned to them or their team
-*Regular users have no access to leads
- Prevents data leaks between different organizations

### 3. `EXPLANATION.md` - Detailed Documentation
Complete explanation of:
- What was asked in the assessment
- How each requirement was implemented
- Access control design with examples
- Multi-tenant architecture explanation

## How the CRM Works
### User Flow Example:
1. Lead Creation: A student shows interest → Admin/Counselor creates a lead
2. Application: Student applies → Application record linked to the lead
3. Task: System creates follow-up tasks (call student, review documents)
4. Security: Only authorized counselors can see their assigned leads

### Data Relationships:

Leads (Students)
    ↓
Applications (Student applies)
    ↓
Tasks (Follow-up activities)


## Security & Access Control implemented 
## Technical Implementation
### Database Features:
- PostgreSQL with Row Level Security (RLS)
- Foreign key constraints for referential integrity
- Check constraints for data validation
- Composite indexes for query optimization
- Multi-tenant architecture (tenant_id)

### Security Features:
- JWT-based authentication
- Role-based access control (admin, counselor, user)
- Team-based data visibility
- Organization-level data isolation

## Setup Instructions

1. Create a Supabase project (or PostgreSQL database)
2. Run `backend.sql` to create tables
3. Run `rls_policies.sql` to enable security policies
4. Configure JWT authentication with roles

## Technologies Used
- PostgreSQL - Relational database
- Supabase - Backend platform with built-in RLS
- SQL - Schema and policy definitions

"I used Supabase as the backend platform. I created the database schema in Supabase's PostgreSQL database and implemented Row Level Security policies using Supabase's built-in RLS features. The policies use Supabase's auth.jwt() function to extract user information from the JWT token for role-based access control."
