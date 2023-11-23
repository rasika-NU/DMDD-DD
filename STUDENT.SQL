SET SERVEROUTPUT ON;
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
BEGIN
    insert_student(1, 'John', 'Doe', 'john.j@northeastern.edu', '123-456-7890');
    insert_student(2, 'Jane', 'Smith', 'jane.s@northeastern.edu', '987-654-3210');
    insert_student(3, 'Alice', 'Johnson', 'alice.j@northeastern.edu', '555-555-5555');
    insert_student(4, 'Bob', 'Brown', 'bob.b@northeastern.edu', '123-789-4560');
    insert_student(6,'rasika','rahane','rasika.r@northeastern.edu','123455689');
END;
/


select* from student;