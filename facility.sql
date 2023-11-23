SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE create_facility_table AS
    table_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(table_exists, -00942);
BEGIN
    -- Check if the table already exists
    DECLARE
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
                        facility_id VARCHAR2 PRIMARY KEY,
                        facility_name VARCHAR2 UNIQUE NOT NULL,
                        location VARCHAR2 NOT NULL,
                        CONSTRAINT Facility_PK PRIMARY KEY (facility_id)
                    )
                ';
                DBMS_OUTPUT.PUT_LINE('FACILITY TABLE CREATED SUCCESSFULLY.');
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
            END;
        END IF;
    END;
END create_facility_table;
/

-- Call the procedure to create the Facility table
BEGIN
    create_facility_table;
END;
/

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

-- Call the procedure to insert values into the Facility table
BEGIN
    insert_facility('1', 'MARINO CENTRE', 'BOSTON');
    insert_facility('2', 'CABOT GYM', 'BOSTON');
    insert_facility('3', 'CABOT CAGE', 'BOSTON');
    insert_facility('4', 'SQUASHBUSTERS', 'BOSTON');
    insert_facility('5', 'BOSTON COMMON', 'BOSTON');
END;
/

select * from facility;