Set serveroutput on;
-- Call the procedure to insert values into the Facility table
BEGIN
    insert_facility('1', 'MARINO CENTRE', 'BOSTON');
    insert_facility('2', 'CABOT GYM', 'BOSTON');
    insert_facility('3', 'CABOT CAGE', 'BOSTON');
    insert_facility('4', 'SQUASHBUSTERS', 'BOSTON');
    insert_facility('5', 'BOSTON COMMON', 'BOSTON');
END;
/
