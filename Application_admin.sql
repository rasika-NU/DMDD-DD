SET SERVEROUTPUT ON;
ALTER SESSION SET ddl_lock_timeout = 60;
--Drop Tables if exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE SUBSCRIPTION';
    EXECUTE IMMEDIATE 'DROP TABLE BOOKING';
    EXECUTE IMMEDIATE 'DROP TABLE NOTIFICATION';
    EXECUTE IMMEDIATE 'DROP TABLE ACTIVITY'; 
    EXECUTE IMMEDIATE 'DROP TABLE INSTRUCTOR';
    EXECUTE IMMEDIATE 'DROP TABLE STUDENT';
    EXECUTE IMMEDIATE 'DROP TABLE FACILITY'; 
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

--Drop Sequences if exists
BEGIN
        EXECUTE IMMEDIATE 'DROP SEQUENCE seq_instructor_id';
        EXECUTE IMMEDIATE 'DROP SEQUENCE seq_activity_id';      
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN
      RAISE;
    END IF;
END;
/

---------------------------------------------------------------STUDENT DATA ---------------------------------------------------------------------------------
-----------------------------------------------------STUDENT TABLE------------------------------------
CREATE OR REPLACE PROCEDURE create_student_table AS
    table_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(table_exists, -00942);
BEGIN
    
    DECLARE
        table_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO table_count
        FROM USER_TABLES
        WHERE TABLE_NAME = 'STUDENT';

        
        IF table_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('STUDENT TABLE ALREADY EXISTS! SKIPPING.');
            RETURN;
        ELSE
            
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE TABLE STUDENT (
                        NEU_ID NUMBER,
                        FIRSTNAME VARCHAR2(40) NOT NULL,
                        LASTNAME VARCHAR2(40) NOT NULL,
                        EMAIL VARCHAR2(40) NOT NULL,
                        STUDENT_CONTACT VARCHAR2(15) NOT NULL,
                        CONSTRAINT STUDENT_PK PRIMARY KEY(NEU_ID)
                    )
                ';
                DBMS_OUTPUT.PUT_LINE('STUDENT TABLE CREATED SUCCESSFULLY.');
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
            END;
        END IF;
    END;
END create_student_table;
/

BEGIN
    create_student_table;
END;
/

--------------------------------------------PROCEDURE TO INSERT STUDENT---------------------------------------------------
CREATE OR REPLACE PROCEDURE insert_student(
    p_neu_id           NUMBER,
    p_firstname        VARCHAR2,
    p_lastname         VARCHAR2,
    p_email            VARCHAR2,
    p_student_contact  VARCHAR2
)
IS
    duplicate_entry EXCEPTION;
    PRAGMA EXCEPTION_INIT(duplicate_entry, -00001);
BEGIN
    
    INSERT INTO STUDENT (NEU_ID, FIRSTNAME, LASTNAME, EMAIL, STUDENT_CONTACT)
    VALUES (p_neu_id, p_firstname, p_lastname, p_email, p_student_contact);

    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('STUDENT DATA INSERTED SUCCESSFULLY.');

EXCEPTION
    WHEN duplicate_entry THEN
     
        DBMS_OUTPUT.PUT_LINE('VALUE ALREADY EXISTS. TRY ADDING A NEW VALUE.');
       
        ROLLBACK; 
    WHEN OTHERS THEN
        
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        ROLLBACK; 
END insert_student;
/

-------------------------------------------------INSTRUCTOR DATA-----------------------------------------------------
---------------------------------------------------------INSTRUCTOR TABLE-----------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE create_instructor_table AS
    table_exists NUMBER;
BEGIN
    -- Check if the table already exists
    SELECT COUNT(*)
    INTO table_exists
    FROM USER_TABLES
    WHERE TABLE_NAME = 'INSTRUCTOR';

    -- If the table exists, print a message and exit
    IF table_exists > 0 THEN
        DBMS_OUTPUT.PUT_LINE('TABLE ALREADY EXISTS! SKIPPING.');
        RETURN;
    ELSE
        -- Attempt to create the table
        BEGIN
            EXECUTE IMMEDIATE '
                CREATE TABLE Instructor (
                    INSTRUCTOR_ID VARCHAR2(40),
                    FIRST_NAME VARCHAR2(40) NOT NULL,
                    EMAIL_ID VARCHAR2(40) UNIQUE NOT NULL,
                    LAST_NAME VARCHAR2(40) NOT NULL,
                    ALT_EMAIL VARCHAR2(40),
                    CONTACT VARCHAR2(40) NOT NULL,
                    SPECIALITY VARCHAR2(40) NOT NULL,
                    CONSTRAINT Instructor_PK PRIMARY KEY (Instructor_id)
                )
            ';
            DBMS_OUTPUT.PUT_LINE('TABLE CREATED SUCCESSFULLY.');
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        END;
    END IF;
END create_instructor_table;
/

-- Call the procedure to create the table
BEGIN
    create_instructor_table;
END;
/

----------------------------------------------------INSTRUCTOR SEQUENCE PROCEDURE-----------------------------------------------------------
CREATE OR REPLACE PROCEDURE create_instructor_sequence AS
    sequence_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(sequence_exists, -955); -- ORA-00955: name is already used by an existing object
BEGIN
    -- Attempt to create the sequence
    BEGIN
        EXECUTE IMMEDIATE '
            CREATE SEQUENCE seq_instructor_id
            START WITH 1
            INCREMENT BY 1
            NOCACHE
            NOCYCLE
        ';
        DBMS_OUTPUT.PUT_LINE('SEQUENCE CREATED SUCCESSFULLY.');
        COMMIT; -- Commit the transaction after successful sequence creation
    EXCEPTION
        WHEN sequence_exists THEN
            DBMS_OUTPUT.PUT_LINE('SEQUENCE ALREADY EXISTS! SKIPPING.');
    END;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        ROLLBACK; -- Rollback the transaction in case of any other exception
END create_instructor_sequence;
/

-- Call the procedure to create the sequence
BEGIN
    create_instructor_sequence;
END;
/

----------------------------------------------------PROCEDURE TO INSERT INSTRUCTOR-----------------------------------------------------------
CREATE OR REPLACE PROCEDURE insert_instructor(
    p_first_name       VARCHAR2,
    p_email_id         VARCHAR2,
    p_last_name        VARCHAR2,
    p_alt_email        VARCHAR2,
    p_contact          VARCHAR2,
    p_speciality       VARCHAR2
)
IS
    duplicate_entry EXCEPTION;
    PRAGMA EXCEPTION_INIT(duplicate_entry, -00001);

    v_instructor_id    VARCHAR2(40);

BEGIN
    -- Get the next value from the sequence
    SELECT seq_instructor_id.NEXTVAL INTO v_instructor_id FROM dual;

    -- Attempt to insert values into the table
    INSERT INTO Instructor (INSTRUCTOR_ID, FIRST_NAME, EMAIL_ID, LAST_NAME, ALT_EMAIL, CONTACT, SPECIALITY)
    VALUES (v_instructor_id, p_first_name, p_email_id, p_last_name, p_alt_email, p_contact, p_speciality);

    -- Commit the transaction if the insertion is successful
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('DATA INSERTED SUCCESSFULLY.');

EXCEPTION
    WHEN duplicate_entry THEN
        -- Handle unique constraint violation
        DBMS_OUTPUT.PUT_LINE('ENTRY ALREADY EXISTS IN TABLE! Try adding a new value.');
        -- You can perform additional actions or log the error as needed
        ROLLBACK; -- Rollback the transaction in case of a duplicate entry
    WHEN OTHERS THEN
        -- Handle other exceptions
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        ROLLBACK; -- Rollback the transaction in case of any other exception
END insert_instructor;
/

------------------------------------------------------------------FACILITY DATA--------------------------------------------------
------------------------------------------------------CREATE FACILITY TABLE PROCEDURE---------------------------
CREATE OR REPLACE PROCEDURE create_facility_table AS
    table_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(table_exists, -00942);

    -- Check if the table already exists
    table_count NUMBER;

BEGIN
    SELECT COUNT(*)
    INTO table_count
    FROM USER_TABLES
    WHERE TABLE_NAME = 'FACILITY';

    -- If the table exists, print a message and exit
    IF table_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('FACILITY TABLE ALREADY EXISTS! SKIPPING.');
        RETURN;
    ELSE
        -- Attempt to create the table
        BEGIN
            EXECUTE IMMEDIATE '
                CREATE TABLE Facility (
                    facility_id VARCHAR2(50) PRIMARY KEY,
                    facility_name VARCHAR2(255) UNIQUE NOT NULL,
                    location VARCHAR2(255) NOT NULL
                )';
            DBMS_OUTPUT.PUT_LINE('FACILITY TABLE CREATED SUCCESSFULLY.');
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        END;
    END IF;
END create_facility_table;
/

-- Call the procedure to create the Facility table
BEGIN
    create_facility_table;
END;
/

------------------------------------------------------------PROCEDURE TO INSERT FACILITY DATA--------------------------------------------------

CREATE OR REPLACE PROCEDURE insert_facility(
    p_facility_id    VARCHAR2,
    p_facility_name  VARCHAR2,
    p_location       VARCHAR2
)
IS
    duplicate_entry EXCEPTION;
    PRAGMA EXCEPTION_INIT(duplicate_entry, -00001);
BEGIN
    -- Attempt to insert values into the table
    INSERT INTO Facility (facility_id, facility_name, location)
    VALUES (p_facility_id, p_facility_name, p_location);

    -- Commit the transaction if the insertion is successful
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('DATA INSERTED INTO FACILITY TABLE SUCCESSFULLY.');

EXCEPTION
    WHEN duplicate_entry THEN
        -- Handle unique constraint violation
        DBMS_OUTPUT.PUT_LINE('DUPLICATE FACILITY_NAME DETECTED. TRY ADDING A DIFFERENT VALUE.');
        -- You can perform additional actions or log the error as needed
        ROLLBACK; -- Rollback the transaction in case of a duplicate entry
    WHEN OTHERS THEN
        -- Handle other exceptions
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        ROLLBACK; -- Rollback the transaction in case of any other exception
END insert_facility;
/

----------------------------------------------------------------------SUBSCRIPTION DATA-------------------------------------------------------------
---------------------------------------------PROCEDURE TO CREATE SUBSCRIPTION TABLE-------------------------------------------------
CREATE OR REPLACE PROCEDURE create_subscription_table AS
    -- Custom exceptions for better error handling
    no_instructor_table EXCEPTION;
    no_student_table EXCEPTION;

    -- Check if the table already exists
    table_count NUMBER;

    -- Debug flag
    debug_flag BOOLEAN := TRUE;

BEGIN
    -- Check if the Subscription table already exists
    SELECT COUNT(*)
    INTO table_count
    FROM USER_TABLES
    WHERE TABLE_NAME = 'SUBSCRIPTION';

    -- If the table exists, print a message and exit
    IF table_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('SUBSCRIPTION TABLE ALREADY EXISTS! SKIPPING.');
        RETURN;
    ELSE
        -- Attempt to create the table
        BEGIN
            -- Check if the Instructor table exists
            BEGIN
                IF debug_flag THEN
                    DBMS_OUTPUT.PUT_LINE('Checking if Admin.Instructor table exists...');
                END IF;
                EXECUTE IMMEDIATE 'SELECT 1 FROM ALL_TABLES WHERE OWNER = ''ADMIN'' AND TABLE_NAME = ''INSTRUCTOR''';
                IF debug_flag THEN
                    DBMS_OUTPUT.PUT_LINE('Admin.Instructor table found.');
                END IF;
            EXCEPTION
                WHEN no_instructor_table THEN
                    DBMS_OUTPUT.PUT_LINE('Please create the Instructor table first.');
                    RETURN;
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('An error occurred while checking Admin.Instructor table existence: ' || SQLERRM);
            END;

            -- Check if the Student table exists
            BEGIN
                IF debug_flag THEN
                    DBMS_OUTPUT.PUT_LINE('Checking if Admin.Student table exists...');
                END IF;
                EXECUTE IMMEDIATE 'SELECT 1 FROM ALL_TABLES WHERE OWNER = ''ADMIN'' AND TABLE_NAME = ''STUDENT''';
                IF debug_flag THEN
                    DBMS_OUTPUT.PUT_LINE('Admin.Student table found.');
                END IF;
            EXCEPTION
                WHEN no_student_table THEN
                    DBMS_OUTPUT.PUT_LINE('Please create the Student table first.');
                    RETURN;
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('An error occurred while checking Admin.Student table existence: ' || SQLERRM);
            END;

            -- Attempt to create the Subscription table
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE TABLE Subscription (
                        subscription_id VARCHAR2(50),
                        student_neu_id NUMBER,
                        instructor_id VARCHAR2(50),
                        CONSTRAINT Subscription_PK PRIMARY KEY (subscription_id)
                    )
                ';
                DBMS_OUTPUT.PUT_LINE('SUBSCRIPTION TABLE CREATED SUCCESSFULLY.');
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
            END;

        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occurred while checking table existence: ' || SQLERRM);
        END;
    END IF;
END create_subscription_table;
/

-- Call the procedure to create the Subscription table
BEGIN
    create_subscription_table;
END;
/
------------------------------------------------------------INSERT SUBSCRIPTION PROCEDURE---------------------------------------------------
create or replace PROCEDURE insert_subscription(
    p_subscription_id    VARCHAR2,
    p_student_neu_id     NUMBER,
    p_instructor_id      VARCHAR2
)
IS
    duplicate_entry EXCEPTION;
    PRAGMA EXCEPTION_INIT(duplicate_entry, -00001);
BEGIN
    -- Attempt to insert values into the table
    INSERT INTO Subscription (subscription_id, Student_neu_id, Instructor_id)
    VALUES (p_subscription_id, p_student_neu_id, p_instructor_id);

    -- Commit the transaction if the insertion is successful
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('SUBSCRIPTION DATA INSERTED SUCCESSFULLY.');

EXCEPTION
    WHEN duplicate_entry THEN
        -- Handle unique constraint violation
        DBMS_OUTPUT.PUT_LINE('STUDENT IS ALREADY SUBSCRIBED TO AN INSTRUCTOR. SKIPPING.');
        -- You can perform additional actions or log the error as needed
        ROLLBACK; -- Rollback the transaction in case of a duplicate entry
    WHEN OTHERS THEN
        -- Handle other exceptions
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        ROLLBACK; -- Rollback the transaction in case of any other exception
END insert_subscription;
/
---------------------------------------------------------------------ACTIVITY DATA-------------------------------------------------------------
-------------------------------------------------CREATE ACTIVITY TABLE PROCEDURE------------------------------------------------------
CREATE OR REPLACE PROCEDURE create_activity_table AS
    table_exists NUMBER;
BEGIN
    -- Check if the table already exists
    SELECT COUNT(*)
    INTO table_exists
    FROM USER_TABLES
    WHERE TABLE_NAME = 'ACTIVITY';

    -- If the table exists, print a message and exit
    IF table_exists > 0 THEN
        DBMS_OUTPUT.PUT_LINE('TABLE ALREADY EXISTS! SKIPPING.');
        RETURN;
    ELSE
        -- Attempt to create the table
        BEGIN
            EXECUTE IMMEDIATE '
                CREATE TABLE Activity (
                    activity_id       VARCHAR2(40) NOT NULL,
                    activity_name     VARCHAR2(40) NOT NULL,
                    capacity          NUMBER NOT NULL,
                    start_time        VARCHAR2(8) NOT NULL, -- Use VARCHAR2 for time without date
                    end_time          VARCHAR2(8) NOT NULL, -- Use VARCHAR2 for time without date
                    scheduled_date    DATE NOT NULL,
                    date_posted       DATE NOT NULL,
                    instructor_id     VARCHAR2(40),
                    facility_id       VARCHAR2(40),
                    activity_status   VARCHAR2(40),
                    slots             NUMBER NOT NULL, -- New column added
                    CONSTRAINT pk_activity PRIMARY KEY (activity_id),
                    CONSTRAINT fk_instructor FOREIGN KEY (instructor_id) REFERENCES Instructor(instructor_id),
                    CONSTRAINT fk_facility FOREIGN KEY (facility_id) REFERENCES Facility(facility_id)
                )
            ';
            DBMS_OUTPUT.PUT_LINE('TABLE CREATED SUCCESSFULLY.');
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        END;
    END IF;
END create_activity_table;
/

-- Call the procedure to create the Activity table
BEGIN
    create_activity_table;
END;
/

--------------------------------------------------------------------ACTIVITY SEQUENCE PROCEDURE----------------------------------------
create or replace PROCEDURE create_activity_sequence AS
    sequence_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(sequence_exists, -955); -- ORA-00955: name is already used by an existing object
BEGIN
    -- Attempt to create the sequence
    BEGIN
        EXECUTE IMMEDIATE '
            CREATE SEQUENCE seq_activity_id
            START WITH 1
            INCREMENT BY 1
            NOCACHE
            NOCYCLE
        ';
        DBMS_OUTPUT.PUT_LINE('SEQUENCE CREATED SUCCESSFULLY.');
        COMMIT; -- Commit the transaction after successful sequence creation
    EXCEPTION
        WHEN sequence_exists THEN
            DBMS_OUTPUT.PUT_LINE('SEQUENCE ALREADY EXISTS! SKIPPING.');
    END;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        ROLLBACK; -- Rollback the transaction in case of any other exception
END create_activity_sequence;
/

BEGIN
    create_activity_sequence;
END;
/
----------------------------------------------------INSERT ACTIVITY PROCEDURE----------------------------------------------------------
CREATE OR REPLACE PROCEDURE insert_activity(
    p_activity_name     VARCHAR2,
    p_capacity          NUMBER,
    p_start_time        VARCHAR2, -- Use VARCHAR2 for time without date
    p_end_time          VARCHAR2, -- Use VARCHAR2 for time without date
    p_scheduled_date    DATE,
    p_date_posted       DATE,
    p_instructor_id     VARCHAR2,
    p_facility_id       VARCHAR2,
    p_activity_status   VARCHAR2
)
IS
    invalid_time_exception EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_time_exception, -20001);

    date_mismatch_exception EXCEPTION;
    PRAGMA EXCEPTION_INIT(date_mismatch_exception, -20002);

    v_activity_id VARCHAR2(40);
    p_slots NUMBER := 0; -- Initialize p_slots

BEGIN
    -- Check if end_time is before start_time
    IF p_end_time <= p_start_time THEN
        RAISE invalid_time_exception;
    END IF;

    -- Check if date_posted is at least 1 week before scheduled_date
    IF p_date_posted >= p_scheduled_date - 7 THEN
        RAISE invalid_time_exception;
    END IF;

    

    -- Get the next value from the sequence
    SELECT seq_activity_id.NEXTVAL INTO v_activity_id FROM dual;

    -- Attempt to insert values into the table
    INSERT INTO Activity (
        activity_id,
        activity_name,
        capacity,
        slots, -- New column added
        start_time,
        end_time,
        scheduled_date,
        date_posted,
        instructor_id,
        facility_id,
        activity_status
    )
    VALUES (
        v_activity_id,
        p_activity_name,
        p_capacity,
        p_capacity,
        p_start_time,
        p_end_time,
        p_scheduled_date,
        p_date_posted,
        p_instructor_id,
        p_facility_id,
        p_activity_status
    );

    -- Commit the transaction if the insertion is successful
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('DATA INSERTED SUCCESSFULLY.');

EXCEPTION
    WHEN invalid_time_exception THEN
        DBMS_OUTPUT.PUT_LINE('Invalid time configuration: End time should be after start time, and date posted should be at least 1 week before scheduled date.');
        ROLLBACK;
    WHEN date_mismatch_exception THEN
        DBMS_OUTPUT.PUT_LINE('Invalid date configuration: Start time and end time should have the same time.');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        ROLLBACK; -- Rollback the transaction in case of any other exception
END insert_activity;
/
-------------------------------------------------------------NOTIFICATION DATA-------------------------------------------
--------------------------------------------NOTIFICATION SEQUENCE PROCEDURE----------------------------------------------
DECLARE
    v_sequence_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_sequence_exists
    FROM user_sequences
    WHERE sequence_name = 'NOTIFICATION_SEQ';

    IF v_sequence_exists = 0 THEN
        EXECUTE IMMEDIATE 'CREATE SEQUENCE notification_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
        DBMS_OUTPUT.PUT_LINE('NOTIFICATION_SEQ created.');
        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('NOTIFICATION_SEQ already exists.');
    END IF;
END;
/

--------------------------------------------------------NOTIFICATION TABLE PROCEDURE------------------------------------------------------
CREATE OR REPLACE PROCEDURE create_notification_table AS
    table_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(table_exists, -00955); -- ORA-00955: name is already used by an existing object

    index_does_not_exist EXCEPTION;
    PRAGMA EXCEPTION_INIT(index_does_not_exist, -01418); -- ORA-01418: specified index does not exist

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
        BEGIN
            -- Drop index only if it exists
            EXECUTE IMMEDIATE 'DROP INDEX Notification_IDX';
            DBMS_OUTPUT.PUT_LINE('Existing Notification index dropped.');
        EXCEPTION
            WHEN index_does_not_exist THEN
                DBMS_OUTPUT.PUT_LINE('Notification index does not exist. Proceeding.');
        END;

        BEGIN
            -- Create index
            EXECUTE IMMEDIATE 'CREATE INDEX Notification_IDX ON Notification(notification_date)';
            DBMS_OUTPUT.PUT_LINE('Notification index created successfully.');
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occurred while creating Notification index: ' || SQLERRM);
        END;
    END;
END create_notification_table;
/

-- Call the procedure to create the Notification table
BEGIN
    create_notification_table;
END;
/

---------------------------------------------------NOTIFICATION TRIGGER---------------------------------------------------------
CREATE OR REPLACE TRIGGER activity_notification_trigger
AFTER INSERT OR UPDATE ON ACTIVITY
FOR EACH ROW
DECLARE
    v_notification_id   NUMBER;
    v_notification_desc VARCHAR2(4000);
    v_subscription_count NUMBER;
BEGIN
    -- Check if there are subscriptions for the activity
    SELECT COUNT(*)
    INTO v_subscription_count
    FROM SUBSCRIPTION s
    WHERE s.INSTRUCTOR_ID = :NEW.INSTRUCTOR_ID;

    IF v_subscription_count = 0 THEN
        -- No subscriptions, so exit the trigger
        DBMS_OUTPUT.PUT_LINE('No subscriptions found for the activity. Skipping trigger.');
        RETURN;
    END IF;

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

-----------------------------------------------CREATING NOTIFICATIONS FOR EXISTING ACTIVITIES----------------------------------------------------------------

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
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error inserting notification record. ' || SQLERRM);
                ROLLBACK;
        END;
        
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Notification(s) created successfully for existing data.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in manual trigger execution. ' || SQLERRM);
        ROLLBACK;
END;
/

---------------------------------------------------------------------BOOKING DATA--------------------------------------------------------------------
---------------------------------------------------------------PROCEDURE FOR BOOKING TABLE---------------------------------------------------------
CREATE OR REPLACE PROCEDURE create_booking_table AS
    table_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(table_exists, -00942);
BEGIN
    DECLARE
        table_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO table_count
        FROM USER_TABLES
        WHERE TABLE_NAME = 'BOOKING';

        IF table_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('BOOKING TABLE ALREADY EXISTS! SKIPPING.');
            RETURN;
        ELSE
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE TABLE BOOKING (
                        BOOKING_ID VARCHAR2(40),
                        BOOKING_DATE DATE NOT NULL,
                        NEU_ID NUMBER NOT NULL,
                        ACTIVITY_ID VARCHAR2(40) ,
                        STATUS VARCHAR2(40) NOT NULL,
                        CONSTRAINT BOOKING_PK PRIMARY KEY (BOOKING_ID),
                        CONSTRAINT BOOKING_STUDENT_FK FOREIGN KEY (NEU_ID) REFERENCES STUDENT(NEU_ID),
                        CONSTRAINT BOOKING_ACTIVITY_FK FOREIGN KEY (ACTIVITY_ID) REFERENCES ACTIVITY(ACTIVITY_ID)
                    )
                ';
                DBMS_OUTPUT.PUT_LINE('BOOKING TABLE CREATED SUCCESSFULLY.');
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
            ROLLBACK;
            END;
        END IF;
    END;
END create_booking_table;
/
BEGIN
create_booking_table;
END;
/


-------------------------------------------------------------------------PROCEDURE FOR INSERTING BOOKING-----------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE insert_booking(
    p_booking_id VARCHAR2,
    p_booking_date DATE,
    p_neu_id NUMBER,
    p_activity_id VARCHAR2,
    p_status VARCHAR2
)
IS
    duplicate_entry EXCEPTION;
    PRAGMA EXCEPTION_INIT(duplicate_entry, -00001);

    max_activities_per_week CONSTANT NUMBER := 3;
    current_week_start DATE;
    activities_booked NUMBER;
    available_slots NUMBER;
BEGIN
    BEGIN
        -- Check the total number of activities booked by the student within the current week
        SELECT TRUNC(SYSDATE, 'IW') INTO current_week_start FROM DUAL;

        -- Declare the variable before using it
        activities_booked := 0;

        SELECT COUNT(*)
        INTO activities_booked
        FROM BOOKING
        WHERE NEU_ID = p_neu_id
          AND BOOKING_DATE >= current_week_start;

        IF activities_booked >= max_activities_per_week THEN
            DBMS_OUTPUT.PUT_LINE('Cannot book more than ' || max_activities_per_week || ' activities per week.');
            RETURN;
        END IF;
        
        SELECT slots
        INTO available_slots
        FROM Activity
        WHERE activity_id = p_activity_id;

        IF available_slots <= 0 THEN
        raise_application_error(-20002, 'There are no slots left. You are on a waitlist!');
        END IF;

        BEGIN
        INSERT INTO BOOKING (BOOKING_ID, BOOKING_DATE, NEU_ID, ACTIVITY_ID, STATUS)
        VALUES (p_booking_id, p_booking_date, p_neu_id, p_activity_id, p_status);
        EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            raise_application_error(-20003, 'Duplicate value in BOOKING_ID or other unique constraint violation.');
        END;

        DBMS_OUTPUT.PUT_LINE('BOOKING DATA INSERTED SUCCESSFULLY.');
        COMMIT;
    EXCEPTION
        WHEN duplicate_entry THEN
            DBMS_OUTPUT.PUT_LINE('VALUE ALREADY EXISTS. TRY ADDING A NEW VALUE.');
            ROLLBACK;
        WHEN OTHERS THEN
            -- Check if the error is related to a foreign key violation
            IF SQLCODE = -2291 THEN
                DBMS_OUTPUT.PUT_LINE('Foreign key violation: Parent key not found in ACTIVITY table or STUDENT table.');
            ELSE
                DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
            END IF;
            ROLLBACK;
    END;
END insert_booking;
/
-------------------------------------------------------DELETE BOOKING----------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE delete_booking(
    p_booking_id VARCHAR2,
    p_neu_id NUMBER
)
IS
    booking_date_time DATE;
    time_difference NUMBER;
BEGIN
    BEGIN
        -- Retrieve the booking date and time
        SELECT BOOKING_DATE
        INTO booking_date_time
        FROM BOOKING
        WHERE BOOKING_ID = p_booking_id
          AND NEU_ID = p_neu_id;

        -- Calculate the time difference in hours
        time_difference := (SYSDATE - booking_date_time) * 24;

        -- Check if the student is trying to drop from the activity after 24 hours
        IF time_difference >= 24 THEN
            DBMS_OUTPUT.PUT_LINE('Cannot drop from activity after 24 hours.');
            RETURN;
        END IF;

        -- Delete the booking if the time constraint is satisfied
        DELETE FROM BOOKING
        WHERE BOOKING_ID = p_booking_id
          AND NEU_ID = p_neu_id;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('BOOKING DELETED SUCCESSFULLY.');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Booking with ID ' || p_booking_id || ' not found for student ' || p_neu_id);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
    END;
END delete_booking;
/
--------------------------------------------------------------------------TRIGGER FOR UPDATING ACTIVITY SLOTS-------------------------------------------

CREATE OR REPLACE TRIGGER UPDATE_SLOTS_TRIGGER
AFTER INSERT OR DELETE ON BOOKING
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        -- Increment slots when a new booking is added
        UPDATE Activity
        SET slots = slots - 1
        WHERE activity_id = :new.activity_id;
        
    ELSIF DELETING THEN
        -- Decrement slots when a booking is deleted
        UPDATE Activity
        SET slots = slots + 1
        WHERE activity_id = :old.activity_id;
        
    END IF;
END UPDATE_SLOTS_TRIGGER;
/