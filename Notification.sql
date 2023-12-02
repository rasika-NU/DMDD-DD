SET SERVEROUTPUT ON;
-- Create the NOTIFICATION sequence if not exists
DECLARE
    v_sequence_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_sequence_exists
    FROM user_sequences
    WHERE sequence_name = 'NOTIFICATION_SEQ';

    IF v_sequence_exists = 0 THEN
        EXECUTE IMMEDIATE 'CREATE SEQUENCE notification_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
        DBMS_OUTPUT.PUT_LINE('NOTIFICATION_SEQ created.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('NOTIFICATION_SEQ already exists.');
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE create_notification_table AS
    table_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(table_exists, -00955); -- ORA-00955: name is already used by an existing object

BEGIN
    -- Attempt to create the Notification table
    BEGIN
        EXECUTE IMMEDIATE '
            CREATE TABLE Notification (
                notification_id VARCHAR2(40),
                notification_desc VARCHAR2(4000),
                notification_date DATE,
                activity_id VARCHAR2(40),
                CONSTRAINT Notification_PK PRIMARY KEY (notification_id),
                CONSTRAINT Notification_Activity_FK FOREIGN KEY (activity_id) REFERENCES Activity(activity_id)
            )
        ';
        DBMS_OUTPUT.PUT_LINE('Notification table created successfully.');
    EXCEPTION
        WHEN table_exists THEN
            DBMS_OUTPUT.PUT_LINE('Notification table already exists. Skipping.');
    END;

    -- Create an index separately
    BEGIN
        EXECUTE IMMEDIATE 'CREATE INDEX Notification_IDX ON Notification(notification_date)';
        DBMS_OUTPUT.PUT_LINE('Notification index created successfully.');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An error occurred while creating Notification index: ' || SQLERRM);
    END;
END create_notification_table;
/
-- Create the ACTIVITY_POSTED_TRIGGER trigger
SET SERVEROUTPUT ON;

-- Creating Notification Trigger
CREATE OR REPLACE TRIGGER activity_notification_trigger
AFTER INSERT OR UPDATE ON ACTIVITY
FOR EACH ROW
DECLARE
    v_notification_id   NUMBER;
    v_notification_desc VARCHAR2(4000);
BEGIN
    -- Common logic for both created and updated cases
    FOR subscription_rec IN (
        SELECT s.STUDENT_NEU_ID
        FROM SUBSCRIPTION s
        WHERE s.INSTRUCTOR_ID = :NEW.INSTRUCTOR_ID
    )
    LOOP
        -- Generate a unique ID for the notification outside the loop
        SELECT notification_seq.NEXTVAL INTO v_notification_id FROM DUAL;

        -- Insert the notification for the subscribed student
        IF INSERTING THEN
            BEGIN
                -- Attempt to insert the notification
                INSERT INTO NOTIFICATION (NOTIFICATION_ID, NOTIFICATION_DESC, NOTIFICATION_DATE, ACTIVITY_ID)
                VALUES (v_notification_id, 'New activity posted: ' || :NEW.ACTIVITY_NAME, SYSTIMESTAMP, :NEW.ACTIVITY_ID);
                
                DBMS_OUTPUT.PUT_LINE('Notification created for student ' || subscription_rec.STUDENT_NEU_ID || ': New activity posted.');
            EXCEPTION
                WHEN OTHERS THEN
                    -- Handle the exception, e.g., log the error
                    DBMS_OUTPUT.PUT_LINE('Error creating notification: ' || SQLERRM);
            END;
        END IF;

        -- Check if the activity details are modified
        IF UPDATING AND (
            :OLD.ACTIVITY_NAME <> :NEW.ACTIVITY_NAME OR
            :OLD.CAPACITY <> :NEW.CAPACITY OR
            :OLD.START_TIME <> :NEW.START_TIME OR
            :OLD.END_TIME <> :NEW.END_TIME OR
            :OLD.SCHEDULED_DATE <> :NEW.SCHEDULED_DATE
        ) THEN
            BEGIN
                -- Attempt to insert the notification
                INSERT INTO NOTIFICATION (NOTIFICATION_ID, NOTIFICATION_DESC, NOTIFICATION_DATE, ACTIVITY_ID)
                VALUES (v_notification_id, 'Activity details changed: ' || :NEW.ACTIVITY_NAME, SYSTIMESTAMP, :NEW.ACTIVITY_ID);
                
                DBMS_OUTPUT.PUT_LINE('Notification created for student ' || subscription_rec.STUDENT_NEU_ID || ': Activity details changed.');
            EXCEPTION
                WHEN OTHERS THEN
                    -- Handle the exception, e.g., log the error
                    DBMS_OUTPUT.PUT_LINE('Error creating notification: ' || SQLERRM);
            END;
        END IF;

        -- Check if the activity is cancelled
        IF UPDATING AND :OLD.ACTIVITY_STATUS = 'ACTIVE' AND :NEW.ACTIVITY_STATUS = 'CANCELLED' THEN
            BEGIN
                -- Attempt to insert the notification
                v_notification_desc := 'Activity "' || :NEW.ACTIVITY_NAME || '" with ID ' || :NEW.ACTIVITY_ID ||
                                   ' which was on ' || TO_CHAR(:NEW.SCHEDULED_DATE, 'DD-MON-YYYY') ||
                                   ' at ' || TO_CHAR(:NEW.START_TIME, 'HH24:MI') || ' is cancelled.';

                INSERT INTO NOTIFICATION (NOTIFICATION_ID, NOTIFICATION_DESC, NOTIFICATION_DATE, ACTIVITY_ID)
                VALUES (v_notification_id, v_notification_desc, SYSTIMESTAMP, :NEW.ACTIVITY_ID);
                
                DBMS_OUTPUT.PUT_LINE('Notification created for student ' || subscription_rec.STUDENT_NEU_ID || ': Activity cancelled.');
            EXCEPTION
                WHEN OTHERS THEN
                    -- Handle the exception, e.g., log the error
                    DBMS_OUTPUT.PUT_LINE('Error creating notification: ' || SQLERRM);
            END;
        END IF;
    END LOOP;

    --DBMS_OUTPUT.PUT_LINE('Notifications created successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in trigger. ' || SQLERRM);
END;
/



DECLARE
    v_notification_id NUMBER;
    v_notification_exists NUMBER;
BEGIN
    -- Insert a new notification record for each subscribed student
    FOR activity_rec IN (SELECT * FROM ACTIVITY)
    LOOP
        BEGIN
            -- Check if the notification already exists for the same activity
            SELECT COUNT(*) INTO v_notification_exists
            FROM NOTIFICATION
            WHERE NOTIFICATION_DESC = 'New activity posted: ' || activity_rec.ACTIVITY_NAME AND ACTIVITY_ID = activity_rec.ACTIVITY_ID;

            IF v_notification_exists = 0 THEN
                -- Use the sequence to automatically generate a new ID
                SELECT notification_seq.NEXTVAL INTO v_notification_id FROM DUAL;

                INSERT INTO NOTIFICATION (NOTIFICATION_ID, NOTIFICATION_DESC, NOTIFICATION_DATE, ACTIVITY_ID)
                VALUES (v_notification_id, 'New activity posted: ' || activity_rec.ACTIVITY_NAME, SYSTIMESTAMP, activity_rec.ACTIVITY_ID);
            ELSE
                DBMS_OUTPUT.PUT_LINE('Notification already exists for activity ' || activity_rec.ACTIVITY_ID);
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error inserting notification record. ' || SQLERRM);
        END;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Notification(s) created successfully for existing data.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in manual trigger execution. ' || SQLERRM);
END;
/

select * from activity;
select * from notification;
--select * from subscription;

BEGIN
    insert_activity(
        'HIIT Training',
        15,
        TO_DATE('2023-12-30 09:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2023-12-30 10:30:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2023-12-30', 'YYYY-MM-DD'),
        TO_DATE('2023-12-21', 'YYYY-MM-DD'),
        '5', -- Instructor: Lana
        '3', -- Facility: Cabot Cage
        'Active'
    );
END;
/
select * from notification;
