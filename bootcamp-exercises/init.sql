-- Define user and password variables
\set user_db `echo "$EHRBASE_USER"`
\set password_db `echo "$EHRBASE_PASSWORD"`

\set admin_user_db `echo "$EHRBASE_USER_ADMIN"`
\set admin_password_db `echo "$EHRBASE_PASSWORD_ADMIN"`

-- Create roles for database access
CREATE ROLE :user_db WITH LOGIN PASSWORD :'password_db';
CREATE ROLE :admin_user_db WITH LOGIN PASSWORD :'admin_password_db';

-- Create the main database with UTF-8 encoding
CREATE DATABASE ehrbase ENCODING 'UTF-8' LOCALE 'C' TEMPLATE template0;

-- Grant administrative privileges
GRANT ALL PRIVILEGES ON DATABASE ehrbase TO :admin_user_db;
GRANT ALL PRIVILEGES ON DATABASE ehrbase TO :user_db;

\c ehrbase

-- Restrict public schema creation rights
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- Create a dedicated schema for EHR data and assign ownership
CREATE SCHEMA IF NOT EXISTS ehr AUTHORIZATION :admin_user_db;
GRANT USAGE ON SCHEMA ehr TO :user_db;

-- Adjust default privileges for new tables and sequences
ALTER DEFAULT PRIVILEGES FOR USER :admin_user_db IN SCHEMA ehr 
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :user_db;
ALTER DEFAULT PRIVILEGES FOR USER :admin_user_db IN SCHEMA ehr 
    GRANT SELECT ON SEQUENCES TO :user_db;

-- Create an extension schema and assign appropriate rights
CREATE SCHEMA IF NOT EXISTS ext AUTHORIZATION :admin_user_db;
GRANT USAGE ON SCHEMA ext TO :user_db;

-- Enable UUID generation extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA ext;

-- Configure search path to ensure extensions are available
ALTER DATABASE ehrbase SET search_path TO ext;

-- Ensure interval formatting follows ISO 8601 standards
ALTER DATABASE ehrbase SET intervalstyle = 'iso_8601';

-- Optimize JSON query function behavior
ALTER FUNCTION jsonb_path_query(jsonb, jsonpath, jsonb, boolean) ROWS 1;
