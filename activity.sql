SET SERVEROUTPUT ON

BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE Activity (
        activity_id       VARCHAR2(40) NOT NULL,
        activity_name     VARCHAR2(40) NOT NULL,
        capacity          NUMBER NOT NULL,
        start_time        DATE NOT NULL,
        end_time          DATE NOT NULL,
        scheduled_date    DATE NOT NULL,
        date_posted       DATE NOT NULL,
        instructor_id     VARCHAR2(40),
        facility_id       VARCHAR2(40),
        CONSTRAINT pk_activity PRIMARY KEY (activity_id),
        CONSTRAINT fk_instructor FOREIGN KEY (instructor_id) REFERENCES Instructor(instructor_id),
        CONSTRAINT fk_facility FOREIGN KEY (facility_id) REFERENCES Facility(facility_id)
    )';

EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
            -- Table already exists
            DBMS_OUTPUT.PUT_LINE('Activity table already exists.');
        ELSIF SQLCODE = -904 THEN
            -- Missing table (ORA-00904: "Facility": invalid identifier)
            DBMS_OUTPUT.PUT_LINE('Error: Referenced table is missing. Please create the missing table.');
        ELSE
            -- Unexpected error
            DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
            RAISE;
        END IF;
END;
/

-- Insert data into Activity table
SET SERVEROUTPUT ON

BEGIN
    FOR act IN (
        SELECT '1' AS activity_id, 'BARRE' AS activity_name, 10 AS capacity, TO_DATE('2023-11-22 08:00:00', 'YYYY-MM-DD HH24:MI:SS') AS start_time, TO_DATE('2023-11-22 09:00:00', 'YYYY-MM-DD HH24:MI:SS') AS end_time, TO_DATE('2023-11-22', 'YYYY-MM-DD') AS scheduled_date, TO_DATE('2023-11-20', 'YYYY-MM-DD') AS date_posted, '1' AS instructor_id, '1' AS facility_id FROM DUAL
        UNION ALL
        SELECT '2', 'CYCLING', 15, TO_DATE('2023-11-22 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-11-22 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-11-22', 'YYYY-MM-DD'), TO_DATE('2023-11-20', 'YYYY-MM-DD'), '2', '1' FROM DUAL
        UNION ALL
        SELECT '3', 'YOGA', 12, TO_DATE('2023-11-22 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-11-22 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-11-22', 'YYYY-MM-DD'), TO_DATE('2023-11-20', 'YYYY-MM-DD'), '3', '3' FROM DUAL
        UNION ALL
        SELECT '4', 'TRX, CYCLE', 8, TO_DATE('2023-11-22 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-11-22 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-11-22', 'YYYY-MM-DD'), TO_DATE('2023-11-20', 'YYYY-MM-DD'), '4', '2' FROM DUAL
        UNION ALL
        SELECT '5', 'HIIT', 20, TO_DATE('2023-11-22 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-11-22 17:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-11-22', 'YYYY-MM-DD'), TO_DATE('2023-11-20', 'YYYY-MM-DD'), '5', '2' FROM DUAL
    )
    LOOP
        BEGIN
            INSERT INTO Activity (
                activity_id,
                activity_name,
                capacity,
                start_time,
                end_time,
                scheduled_date,
                date_posted,
                instructor_id,
                facility_id
            )
            VALUES (
                act.activity_id,
                act.activity_name,
                act.capacity,
                act.start_time,
                act.end_time,
                act.scheduled_date,
                act.date_posted,
                act.instructor_id,
                act.facility_id
            );
            DBMS_OUTPUT.PUT_LINE('Inserted row with activity_id ' || act.activity_id);
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                DBMS_OUTPUT.PUT_LINE('Error: Duplicate activity_id ' || act.activity_id || '. Skipping.');
        END;
    END LOOP;
END;
/


