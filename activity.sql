SET SERVEROUTPUT ON;


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
                    start_time        DATE NOT NULL,
                    end_time          DATE NOT NULL,
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


-- creating sequence for activity
CREATE OR REPLACE PROCEDURE create_activity_sequence AS
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

-- Call the procedure to create the sequence
BEGIN
    create_activity_sequence;
END;
/



-- creating insert_activity stored procedure

CREATE OR REPLACE PROCEDURE insert_activity(
    p_activity_name     VARCHAR2,
    p_capacity          NUMBER,
    p_start_time        DATE,
    p_end_time          DATE,
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

BEGIN
    -- Check if end_time is before start_time
    IF p_end_time <= p_start_time THEN
        RAISE invalid_time_exception;
    END IF;

    -- Check if date_posted is at least 1 week before scheduled_date
    IF p_date_posted >= p_scheduled_date - 7 THEN
        RAISE invalid_time_exception;
    END IF;

    -- Check if start_time, end_time, and scheduled_date have the same date
    IF TRUNC(p_start_time) <> TRUNC(p_scheduled_date)
       OR TRUNC(p_end_time) <> TRUNC(p_scheduled_date)
       OR TRUNC(p_start_time) <> TRUNC(p_end_time) THEN
        RAISE date_mismatch_exception;
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
        p_capacity, -- Set slots same as capacity
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
        DBMS_OUTPUT.PUT_LINE('Invalid date configuration: Start time, end time, and scheduled date should have the same date.');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        ROLLBACK; -- Rollback the transaction in case of any other exception
END insert_activity;
/




-------------------------------------
-- calling insert_activity procedure
-------------------------------------

-- Activity 1
BEGIN
    insert_activity(
        'Yoga Class',
        20,
        TO_DATE('2023-12-10 10:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2023-12-10 11:30:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2023-12-10', 'YYYY-MM-DD'),
        TO_DATE('2023-12-01', 'YYYY-MM-DD'),
        '3', -- Instructor: Deepta
        '1', -- Facility: Marino Centre
        'Active'
    );
END;

-- Activity 2
BEGIN
    insert_activity(
        'HIIT Workout',
        15,
        TO_DATE('2023-12-12 16:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2023-12-12 17:30:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2023-12-12', 'YYYY-MM-DD'),
        TO_DATE('2023-12-03', 'YYYY-MM-DD'),
        '5', -- Instructor: Lana
        '2', -- Facility: Cabot Gym
        'Active'
    );
END;

-- Activity 3
BEGIN
    insert_activity(
        'Dance Class',
        25,
        TO_DATE('2023-12-15 18:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2023-12-15 19:30:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2023-12-15', 'YYYY-MM-DD'),
        TO_DATE('2023-12-05', 'YYYY-MM-DD'),
        '6', -- Instructor: Elena
        '4', -- Facility: Squashbusters
        'Active'
    );
END;

-- Activity 4
BEGIN
    insert_activity(
        'Cycling Session',
        18,
        TO_DATE('2023-12-18 14:30:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2023-12-18 16:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2023-12-18', 'YYYY-MM-DD'),
        TO_DATE('2023-12-09', 'YYYY-MM-DD'),
        '2', -- Instructor: Robin
        '3', -- Facility: Cabot Cage
        'Active'
    );
END;

-- Activity 5
BEGIN
    insert_activity(
        'Body Sculpt Class',
        22,
        TO_DATE('2023-12-20 08:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2023-12-20 09:30:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2023-12-20', 'YYYY-MM-DD'),
        TO_DATE('2023-12-11', 'YYYY-MM-DD'),
        '23', -- Instructor: Ariana
        '5', -- Facility: Boston Common
        'Active'
    );
END;

-- Activity 6
BEGIN
    insert_activity(
        'TRX and Cycling',
        15,
        TO_DATE('2023-12-25 12:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2023-12-25 13:30:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2023-12-25', 'YYYY-MM-DD'),
        TO_DATE('2023-12-16', 'YYYY-MM-DD'),
        '4', -- Instructor: Sacha
        '1', -- Facility: Marino Centre
        'Active'
    );
END;

-- Activity 7
BEGIN
    insert_activity(
        'Yoga Session',
        20,
        TO_DATE('2023-12-28 17:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2023-12-28 18:30:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2023-12-28', 'YYYY-MM-DD'),
        TO_DATE('2023-12-19', 'YYYY-MM-DD'),
        '3', -- Instructor: Deepta
        '2', -- Facility: Cabot Gym
        'Active'
    );
END;

-- Activity 8
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

-- Activity 9
BEGIN
    insert_activity(
        'Dance Fitness',
        25,
        TO_DATE('2024-01-02 19:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2024-01-02 20:30:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2024-01-02', 'YYYY-MM-DD'),
        TO_DATE('2023-12-24', 'YYYY-MM-DD'),
        '6', -- Instructor: Elena
        '4', -- Facility: Squashbusters
        'Active'
    );
END;

-- Activity 10
BEGIN
    insert_activity(
        'Cycling Marathon',
        18,
        TO_DATE('2024-01-05 13:30:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2024-01-05 15:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        TO_DATE('2024-01-05', 'YYYY-MM-DD'),
        TO_DATE('2023-12-27', 'YYYY-MM-DD'),
        '2', -- Instructor: Robin
        '5', -- Facility: Boston Common
        'Active'
    );
END;
/



