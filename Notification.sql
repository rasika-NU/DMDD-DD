SET SERVEROUTPUT ON;



-- CREATING NOTIFICATION TABLE
CREATE OR REPLACE PROCEDURE create_notification_table AS
    table_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(table_exists, -00955);

    no_such_table EXCEPTION;
    PRAGMA EXCEPTION_INIT(no_such_table, -00942);

    v_dummy NUMBER;
BEGIN
    -- Attempt to create the table
    BEGIN
        -- Check if the Activity table exists
        SELECT 1 INTO v_dummy FROM Admin.Activity WHERE ROWNUM = 1;
    EXCEPTION
        WHEN no_such_table THEN
            DBMS_OUTPUT.PUT_LINE('Activity table does not exist. Please create Activity before creating the Notification table.');
            RETURN;
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Activity table is empty!! Please insert values.');
            RETURN;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An error occurred while checking Activity table: ' || SQLERRM);
    END;

    -- Attempt to create the Notification table
    BEGIN
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
    EXCEPTION
        WHEN table_exists THEN
            DBMS_OUTPUT.PUT_LINE('Notification table already exists. Skipping.');
            RETURN;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An error occurred while creating Notification table: ' || SQLERRM);
    END;

    -- Create the index separately
    BEGIN
        EXECUTE IMMEDIATE 'CREATE INDEX Notification_IDX ON Notification(notification_date)';
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An error occurred while creating Notification index: ' || SQLERRM);
    END;

    DBMS_OUTPUT.PUT_LINE('Notification table created successfully.');
END create_notification_table;
/

BEGIN
    create_notification_table;
END;
/


-- CREATING NOTIFICATION SEQUENCE
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





-- TRIGGER FOR NOTIFICATION CREATION AS SOON AS ACTIVITY IS POSTED/UPDATED
CREATE OR REPLACE TRIGGER activity_posted_trigger
BEFORE INSERT OR UPDATE ON ACTIVITY
FOR EACH ROW
DECLARE
    v_notification_id NUMBER;
    v_notification_desc VARCHAR2(4000);
BEGIN
    -- Generate a unique ID for the notification
    SELECT notification_seq.NEXTVAL INTO v_notification_id FROM DUAL;

    -- Insert a new notification record for each subscribed student
    FOR subscription_rec IN (SELECT s.STUDENT_NEU_ID
                             FROM SUBSCRIPTION s
                             WHERE s.INSTRUCTOR_ID = :NEW.INSTRUCTOR_ID)
    LOOP
        -- Insert the notification for the subscribed student
        IF INSERTING THEN
            INSERT INTO NOTIFICATION (NOTIFICATION_ID, NOTIFICATION_DESC, NOTIFICATION_DATE, ACTIVITY_ID)
            VALUES (v_notification_id, 'New activity posted: ' || :NEW.ACTIVITY_NAME, SYSTIMESTAMP, :NEW.ACTIVITY_ID);
        ELSIF UPDATING THEN
            -- Check if the activity details have changed
            IF :OLD.ACTIVITY_NAME <> :NEW.ACTIVITY_NAME OR
               :OLD.CAPACITY <> :NEW.CAPACITY OR
               :OLD.START_TIME <> :NEW.START_TIME OR
               :OLD.END_TIME <> :NEW.END_TIME OR
               :OLD.SCHEDULED_DATE <> :NEW.SCHEDULED_DATE THEN
                INSERT INTO NOTIFICATION (NOTIFICATION_ID, NOTIFICATION_DESC, NOTIFICATION_DATE, ACTIVITY_ID)
                VALUES (v_notification_id, 'Activity details changed: ' || :NEW.ACTIVITY_NAME, SYSTIMESTAMP, :NEW.ACTIVITY_ID);
            END IF;

            -- Check if the activity is canceled
            IF :OLD.ACTIVITY_STATUS = 'ACTIVE' AND :NEW.ACTIVITY_STATUS = 'CANCELLED' THEN
                v_notification_desc := 'Activity "' || :NEW.ACTIVITY_NAME || '" has been cancelled. It was scheduled on ' || TO_CHAR(:NEW.SCHEDULED_DATE, 'DD-MON-YYYY') || ' at ' || TO_CHAR(:NEW.START_TIME, 'HH24:MI');
                INSERT INTO NOTIFICATION (NOTIFICATION_ID, NOTIFICATION_DESC, NOTIFICATION_DATE, ACTIVITY_ID)
                VALUES (v_notification_id, v_notification_desc, SYSTIMESTAMP, :NEW.ACTIVITY_ID);
            END IF;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Notification(s) created successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in trigger. ' || SQLERRM);
END;
/




--Exsting data into notification table
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

select * from notification;
