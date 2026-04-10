-- inserting values

insert into stg_employee values
(101, 'B101', 'Popescu Andrei', 'QA',   'G5', 'Ionescu Maria', 'DU1', date '2025-01-01', date '2025-01-14');

insert into stg_employee values
(101, 'B101', 'Popescu Andrei', 'DATA', 'G5', 'Ionescu Maria', 'DU1', date '2025-01-15', date '9999-12-31');  -- discipline changed

insert into stg_employee values
(102, 'B102', 'Georgescu Elena', 'DEV', 'G6', 'Pavel Ioana', 'DU1', date '2025-01-01', date '9999-12-31');

insert into stg_employee values
(103, 'B103', 'Marin Vlad', 'DEV', 'G5', 'Pavel Ioana', 'DU2', date '2025-01-01', date '9999-12-31');

insert into stg_employee values
(104, 'B104', 'Dumitru Ana', 'QA',  'G4', 'Ionescu Maria', 'DU2', date '2025-01-01', date '9999-12-31');




insert into stg_timesheet values
(101, date '2025-01-13', 'P1', 'Testing', 8);

insert into stg_timesheet values
(101, date '2025-01-14', 'P1', 'Testing', 8);

insert into stg_timesheet values
(101, date '2025-01-15', 'P2', 'Data Validation', 6);

insert into stg_timesheet values
(102, date '2025-01-13', 'P1', 'Development', 8);

insert into stg_timesheet values
(102, date '2025-01-14', 'P1', 'Development', 7.5);

insert into stg_timesheet values
(102, date '2025-01-15', 'P1', 'Development', 8);

insert into stg_timesheet values
(103, date '2025-01-13', 'P3', 'Bug Fixing', 8);

insert into stg_timesheet values
(103, date '2025-01-14', 'P3', 'Bug Fixing', 8);

insert into stg_timesheet values
(103, date '2025-01-16', 'P3', 'Bug Fixing', 4);

insert into stg_timesheet values
(104, date '2025-01-13', 'P1', 'Automation', 8);

insert into stg_timesheet values
(104, date '2025-01-15', 'P1', 'Automation', 8);

insert into stg_timesheet values
(104, date '2025-01-16', 'P1', 'Automation', 8);

-- checking the result
select *
from stg_employee
order by employee_id, valid_from;

select *
from stg_timesheet
order by employee_id, work_date;

select
    t.employee_id,
    t.work_date,
    t.task_name,
    e.discipline,
    e.valid_from,
    e.valid_to
from stg_timesheet t
join stg_employee e
    on e.employee_id = t.employee_id
   and t.work_date between e.valid_from and e.valid_to
order by t.employee_id, t.work_date;

-- importing the remaining tables from csv
-- ... ---
-- checking the result for each table
select *
from stg_absence
order by employee_id, start_date;

select
    employee_id,
    start_date,
    end_date,
    end_date - start_date + 1 as nr_zile
from stg_absence
order by employee_id;


select *
from stg_training_attendance
order by session_id, employee_badge_id, join_time;

select
    session_id,
    employee_badge_id,
    join_time,
    leave_time,
    round((leave_time - join_time) * 24 * 60) as duration_minutes
from stg_training_attendance
order by session_id, employee_badge_id;

select
    session_id,
    employee_badge_id,
    to_char(join_time, 'YYYY-MM-DD HH24:MI') as join_time_fmt,
    to_char(leave_time, 'YYYY-MM-DD HH24:MI') as leave_time_fmt,
    round((leave_time - join_time) * 24 * 60) as duration_minutes
from stg_training_attendance
order by session_id, employee_badge_id;

select *
from stg_missing_hours
order by employee_id, activity_date;

select
    employee_id,
    activity_date,
    missing_hours,
    missing_hours * 60 as missing_minutes,
    reason_text
from stg_missing_hours
order by employee_id, activity_date;

-- staged layer finish --