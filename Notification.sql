SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE create_notification_table AS
    table_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(table_exists, -00942);

    no_such_table EXCEPTION;
    PRAGMA EXCEPTION_INIT(no_such_table, -00942);
BEGIN
    -- Attempt to create the table
    BEGIN
        -- Check if the Activity table exists
        BEGIN
            EXECUTE IMMEDIATE 'SELECT 1 FROM Admin.Activity WHERE ROWNUM = 1';
        EXCEPTION
            WHEN no_such_table THEN
                DBMS_OUTPUT.PUT_LINE('Activity table does not exist. Please create Activity before creating the Notification table.');
                RETURN;
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occurred while checking Activity table: ' || SQLERRM);
        END;

        EXECUTE IMMEDIATE '
            CREATE TABLE Notification (
                notification_id VARCHAR2(40),
                notification_desc VARCHAR2(40),
                notification_date DATE,
                Activity_id VARCHAR2(40),
                CONSTRAINT Notification_PK PRIMARY KEY (notification_id),
                CONSTRAINT Notification_Activity_FK FOREIGN KEY (Activity_id) REFERENCES Activity(activity_id)
            )
        ';

        -- Create the index separately
        EXECUTE IMMEDIATE 'CREATE INDEX Notification_IDX ON Notification(notification_date)';
        
        DBMS_OUTPUT.PUT_LINE('Notification table created successfully.');
    EXCEPTION
        WHEN table_exists THEN
            DBMS_OUTPUT.PUT_LINE('Notification table already exists. Skipping.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
    END;
END create_notification_table;
/

BEGIN
    create_notification_table;
END;
/

SELECT * FROM NOTIFICATION;