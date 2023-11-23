SET SERVEROUTPUT ON;

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

-- Call the procedure to insert data
BEGIN
    insert_instructor('ARIANA', 'ariana_grande@northeastern.edu', 'GRANDE', NULL, '297-847-3857', 'BODY SCULPT');
    insert_instructor('SOPHIE', 'sophie_blaine@northeastern.edu', 'Blaine', 'sophie_blaine@gmail.com', '123-456-7890', 'BARRE');
    insert_instructor('ROBIN', 'robin_john@northeastern.edu', 'JOHN', NULL, '987-654-3210', 'CYCLING');
    insert_instructor('DEEPTA', 'deepta_suresh@northeastern.edu', 'SURESH', 'deepta_suresh@gmail.com', '657-432-2560', 'YOGA');
    insert_instructor('SACHA', 'sacha_lowell@northeastern.edu', 'LOWELL', 'sacha_lowell@gmail.com', '672-386-9054', 'TRX, CYCLE');
    insert_instructor('ELENA', 'elena_stuart@northeastern.edu', 'STUART', NULL, '265-835-6513', 'DANCE');
    insert_instructor('ANTONELLA', 'antonella_ell@northeastern.edu', 'ELL', 'antonella_ell@gmail.com', '252-186-8742', 'HIIT');
    insert_instructor('LANA', 'lana_del@northeastern.edu', 'DEL', 'lana_del@gmail.com', '253-873-1984', 'HIIT');
END;
/

-- Query to check the data in the table
SELECT * FROM INSTRUCTOR;