
set serveroutput on;
BEGIN
insert_activity(
    'Dance Class',
    25,
    '18:00:00',
    '19:30:00',
    TO_DATE('2023-12-15', 'YYYY-MM-DD'),
    TO_DATE('2023-12-05', 'YYYY-MM-DD'),
    '6', -- Instructor: Elena
    '4', -- Facility: Squashbusters
    'Active'
);

insert_activity(
    'Dance Class',
    25,
    '18:00:00',
    '19:30:00',
    TO_DATE('2023-12-15', 'YYYY-MM-DD'),
    TO_DATE('2023-12-05', 'YYYY-MM-DD'),
    '6', -- Instructor: Elena
    '4', -- Facility: Squashbusters
    'Active'
);

insert_activity(
    'Yoga Class',
    20,
    '10:00:00',
    '11:30:00',
    TO_DATE('2023-12-10', 'YYYY-MM-DD'),
    TO_DATE('2023-12-01', 'YYYY-MM-DD'),
    '3', -- Instructor: Ariana
    '1', -- Facility: Yoga Studio
    'Active'
);

insert_activity(
    'HIIT Workout',
    15,
    '16:00:00',
    '17:30:00',
    TO_DATE('2023-12-12', 'YYYY-MM-DD'),
    TO_DATE('2023-12-03', 'YYYY-MM-DD'),
    '5', -- Instructor: Antonella
    '2', -- Facility: Fitness Center
    'Active'
);

insert_activity(
    'Dance Class',
    25,
    '18:00:00',
    '19:30:00',
    TO_DATE('2023-12-15', 'YYYY-MM-DD'),
    TO_DATE('2023-12-05', 'YYYY-MM-DD'),
    '6', -- Instructor: Elena
    '4', -- Facility: Squashbusters
    'Active'
);

insert_activity(
    'Cycling Session',
    18,
    '14:30:00',
    '16:00:00',
    TO_DATE('2023-12-18', 'YYYY-MM-DD'),
    TO_DATE('2023-12-09', 'YYYY-MM-DD'),
    '2', -- Instructor: Robin
    '3', -- Facility: Cycling Studio
    'Active'
);

-- ... (Insertion queries for other activities)

insert_activity(
    'Aerial Yoga',
    15,
    '14:00:00',
    '15:30:00',
    TO_DATE('2024-01-08', 'YYYY-MM-DD'),
    TO_DATE('2023-12-28', 'YYYY-MM-DD'),
    '3', -- Instructor: Ariana
    '1', -- Facility: Yoga Studio
    'Active'
);

insert_activity(
    'Boxing Training',
    22,
    '18:00:00',
    '19:30:00',
    TO_DATE('2024-01-10', 'YYYY-MM-DD'),
    TO_DATE('2023-12-30', 'YYYY-MM-DD'),
    '5', -- Instructor: Antonella
    '4', -- Facility: Squashbusters
    'Active'
);

insert_activity(
    'Cycling Marathon',
    18,
    '13:30:00',
    '15:00:00',
    TO_DATE('2024-01-05', 'YYYY-MM-DD'),
    TO_DATE('2023-12-27', 'YYYY-MM-DD'),
    '2', -- Instructor: Robin
    '5', -- Facility: Cycling Studio
    'Active'
);

insert_activity(
    'Yoga Class',
    20,
    '10:00:00',
    '11:30:00',
    TO_DATE('2023-12-10', 'YYYY-MM-DD'),
    TO_DATE('2023-12-01', 'YYYY-MM-DD'),
    '3', -- Instructor: Ariana
    '1', -- Facility: Yoga Studio
    'Active'
);

insert_activity(
    'CYCLING',
    25,
    '16:00:00',
    '17:00:00',
    TO_DATE('2024-01-10', 'YYYY-MM-DD'),
    TO_DATE('2023-12-25', 'YYYY-MM-DD'),
    '2', -- Instructor: Robin
    '1', -- Facility: Cycling Studio
    'Active'
);

insert_activity(
    'CYCLING',
    25,
    '16:00:00',
    '17:00:00',
    TO_DATE('2024-01-10', 'YYYY-MM-DD'),
    TO_DATE('2023-12-25', 'YYYY-MM-DD'),
    '2', -- Instructor: Robin
    '1', -- Facility: Cycling Studio
    'Active'
);

insert_activity(
    'Zumba Fitness',
    30,
    '17:30:00',
    '19:00:00',
    TO_DATE('2023-12-20', 'YYYY-MM-DD'),
    TO_DATE('2023-12-10', 'YYYY-MM-DD'),
    '6', -- Instructor: Elena
    '5', -- Facility: Zumba Studio
    'Active'
);

insert_activity(
    'Kickboxing',
    20,
    '18:30:00',
    '20:00:00',
    TO_DATE('2023-12-22', 'YYYY-MM-DD'),
    TO_DATE('2023-12-12', 'YYYY-MM-DD'),
    '5', -- Instructor: Antonella
    '2', -- Facility: Fitness Center
    'Active'
);

insert_activity(
    'Bootcamp Training',
    25,
    '06:00:00',
    '07:30:00',
    TO_DATE('2023-12-25', 'YYYY-MM-DD'),
    TO_DATE('2023-12-15', 'YYYY-MM-DD'),
    '4', -- Instructor: Deepta
    '4', -- Facility: Outdoor
    'Active'
);

insert_activity(
    'Meditation Session',
    10,
    '20:00:00',
    '21:00:00',
    TO_DATE('2023-12-28', 'YYYY-MM-DD'),
    TO_DATE('2023-12-18', 'YYYY-MM-DD'),
    '3', -- Instructor: Ariana
    '1', -- Facility: Yoga Studio
    'Active'
);

insert_activity(
    'CrossFit Workout',
    25,
    '12:00:00',
    '13:30:00',
    TO_DATE('2023-12-31', 'YYYY-MM-DD'),
    TO_DATE('2023-12-21', 'YYYY-MM-DD'),
    '2', -- Instructor: Robin
    '3', -- Facility: CrossFit Studio
    'Active'
);

insert_activity(
    'Piloxing Class',
    18,
    '16:30:00',
    '18:00:00',
    TO_DATE('2024-01-02', 'YYYY-MM-DD'),
    TO_DATE('2023-12-22', 'YYYY-MM-DD'),
    '6', -- Instructor: Elena
    '5', -- Facility: Zumba Studio
    'Active'
);

insert_activity(
    'Functional Training',
    20,
    '09:30:00',
    '11:00:00',
    TO_DATE('2024-01-05', 'YYYY-MM-DD'),
    TO_DATE('2023-12-25', 'YYYY-MM-DD'),
    '4', -- Instructor: Deepta
    '2', -- Facility: Fitness Center
    'Active'
);

insert_activity(
    'Aerial Yoga',
    15,
    '14:00:00',
    '15:30:00',
    TO_DATE('2024-01-08', 'YYYY-MM-DD'),
    TO_DATE('2023-12-28', 'YYYY-MM-DD'),
    '3', -- Instructor: Ariana
    '1', -- Facility: Yoga Studio
    'Active'
);

insert_activity(
    'Boxing Training',
    22,
    '18:00:00',
    '19:30:00',
    TO_DATE('2024-01-10', 'YYYY-MM-DD'),
    TO_DATE('2023-12-30', 'YYYY-MM-DD'),
    '5', -- Instructor: Antonella
    '4', -- Facility: Squashbusters
    'Active'
);
END;
/

