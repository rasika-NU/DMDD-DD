drop user activity_manager;
create user activity_manager identified by "PasswordForActivityManager123";


GRANT CONNECT, RESOURCE TO activity_manager;
GRANT CREATE SESSION TO activity_manager WITH ADMIN OPTION;

-- Grant specific privileges on the activity table
GRANT SELECT, INSERT, UPDATE, DELETE ON application_admin.activity TO activity_manager;

-- Assuming that the trigger operates on the "Notification" table in the application_admin schema
GRANT SELECT, INSERT, UPDATE, DELETE ON application_admin.Notification TO activity_manager;

-- Grant execute privilege on the activity_notification_trigger (if applicable)
-- This is not required if it's a trigger; privileges on underlying tables are sufficient
-- GRANT EXECUTE ON application_admin.activity_notification_trigger TO activity_manager;

-- Grant execute privilege on the insert_activity procedure in the application_admin schema
GRANT EXECUTE ON application_admin.insert_activity TO activity_manager;

-- Set quota for the user
ALTER USER activity_manager QUOTA UNLIMITED ON DATA;