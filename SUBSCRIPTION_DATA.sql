SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE create_subscription_table AS
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
        WHERE TABLE_NAME = 'SUBSCRIPTION';

        -- If the table exists, print a message and exit
        IF table_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('SUBSCRIPTION TABLE ALREADY EXISTS! SKIPPING.');
            RETURN;
        ELSE
            -- Attempt to create the table
            BEGIN
                EXECUTE IMMEDIATE '
                    CREATE TABLE Subscription (
                        subscription_id VARCHAR2(40),
                        Student_neu_id NUMBER,
                        Instructor_id VARCHAR2(40),
                        CONSTRAINT Subscription_PK PRIMARY KEY (subscription_id),
                        CONSTRAINT Subscription_Student_FK FOREIGN KEY (Student_neu_id) REFERENCES Student(neu_id),
                        CONSTRAINT Subscription_Instructor_FK FOREIGN KEY (Instructor_id) REFERENCES Instructor(Instructor_id)
                    )
                ';
                DBMS_OUTPUT.PUT_LINE('SUBSCRIPTION TABLE CREATED SUCCESSFULLY.');
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
            END;
        END IF;
    END;
END create_subscription_table;
/


-- Call the procedure to create the Subscription table
BEGIN
    create_subscription_table;
END;
/

CREATE OR REPLACE PROCEDURE insert_subscription(
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
