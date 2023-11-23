SET SERVEROUTPUT ON;


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
            END;
        END IF;
    END;
END create_booking_table;
/


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
BEGIN
    BEGIN
        INSERT INTO BOOKING (BOOKING_ID, BOOKING_DATE, NEU_ID, ACTIVITY_ID, STATUS)
        VALUES (p_booking_id, p_booking_date, p_neu_id, p_activity_id, p_status);

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('BOOKING DATA INSERTED SUCCESSFULLY.');
    EXCEPTION
        WHEN duplicate_entry THEN
            DBMS_OUTPUT.PUT_LINE('VALUE ALREADY EXISTS. TRY ADDING A NEW VALUE.');
            ROLLBACK;
        WHEN OTHERS THEN
            -- Check if the error is related to a foreign key violation
            IF SQLCODE = -2291 THEN
                DBMS_OUTPUT.PUT_LINE('Foreign key violation: Parent key not found in ACTIVITY table.');
            ELSE
                DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
            END IF;
            ROLLBACK;
    END;
END insert_booking;
/
BEGIN
    create_booking_table;
    insert_booking('B001', TO_DATE('2023-01-01', 'YYYY-MM-DD'), 1, '1', 'Confirmed');
    insert_booking('B002', TO_DATE('2023-02-01', 'YYYY-MM-DD'), 2, '2', 'Pending');
    insert_booking('B003', TO_DATE('2023-03-01', 'YYYY-MM-DD'), 3, '3', 'Confirmed');
END;
/