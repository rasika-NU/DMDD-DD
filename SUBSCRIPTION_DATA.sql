SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE create_subscription_table AS
    table_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(table_exists, -00942);

    no_such_table EXCEPTION;
    PRAGMA EXCEPTION_INIT(no_such_table, -00942);

    no_instructor_table EXCEPTION;
    no_student_table EXCEPTION;

    -- Check if the table already exists
    table_count NUMBER;
BEGIN
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
                EXECUTE IMMEDIATE 'SELECT 1 FROM Admin.Instructor WHERE ROWNUM = 1';
            EXCEPTION
                WHEN no_such_table THEN
                    RAISE no_instructor_table;
            END;

            -- Check if the Student table exists
            BEGIN
                EXECUTE IMMEDIATE 'SELECT 1 FROM Admin.Student WHERE ROWNUM = 1';
            EXCEPTION
                WHEN no_such_table THEN
                    RAISE no_student_table;
            END;

            -- Attempt to create the Subscription table
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE TABLE Subscription (
                        subscription_id VARCHAR2(40),
                        Student_neu_id NUMBER,
                        Instructor_id VARCHAR2(40),
                        CONSTRAINT Subscription_PK PRIMARY KEY (subscription_id)
                    )
                ';
                DBMS_OUTPUT.PUT_LINE('SUBSCRIPTION TABLE CREATED SUCCESSFULLY.');
            EXCEPTION
                WHEN no_instructor_table THEN
                    DBMS_OUTPUT.PUT_LINE('Please create the Instructor table first.');
                WHEN no_student_table THEN
                    DBMS_OUTPUT.PUT_LINE('Please create the Student table first.');
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



-- Call the procedure to insert values into the Subscription table
BEGIN
    insert_subscription('1', 1, '2');
    insert_subscription('1', 1, '36');
    insert_subscription('2', 1, '6');
    insert_subscription('4', 1, '23');
    insert_subscription('4', 1, '3');
    insert_subscription('4', 1, '1');
    insert_subscription('5', 1, '5');
END;
/

SELECT * FROM SUBSCRIPTION;

SHOW ERRORS PROCEDURE ADMIN.CREATE_SUBSCRIPTION_TABLE;