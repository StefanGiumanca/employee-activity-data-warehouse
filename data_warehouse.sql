/*Staging tables */
create table stg_employee (
    employee_id         number,
    badge_id            varchar2(50),
    employee_name       varchar2(100),
    discipline          varchar2(100),
    grade               varchar2(50),
    line_manager        varchar2(100),
    du_name             varchar2(100),
    valid_from          date,
    valid_to            date
);

create table stg_timesheet (    -- per day
    employee_id         number,
    work_date           date,
    project_code        varchar2(50),
    task_name           varchar2(100),
    worked_hours        number(5,2)
);

create table stg_absence (      -- absences per interval
    employee_id         number,
    absence_type        varchar2(50),
    start_date          date,
    end_date            date,
    hours_per_day       number(5,2)
);

create table stg_training_attendance (
    session_id          varchar2(50),
    session_name        varchar2(200),
    employee_badge_id   varchar2(50),
    join_time           date,
    leave_time          date
);

create table stg_missing_hours (
    employee_id         number,
    activity_date       date,
    missing_hours       number(5,2),
    reason_text         varchar2(100)
);

/*Dimensions table*/
create table dim_date (
    date_key            number primary key,
    full_date           date not null,
    day_num             number,
    month_num           number,
    year_num            number,
    month_name          varchar2(20),
    week_num            number,
    is_weekend          varchar2(1)
);

create table dim_employee (
    employee_key        number primary key,
    employee_id         number not null,
    badge_id            varchar2(50),
    employee_name       varchar2(100),
    discipline          varchar2(100),
    grade               varchar2(50),
    line_manager        varchar2(100),
    du_name             varchar2(100),
    valid_from          date,
    valid_to            date,
    is_current          varchar2(1)
);

create table dim_absence_type (
    absence_type_key    number primary key,
    absence_type_code   varchar2(50),
    absence_type_name   varchar2(100)
);

create table dim_training_session (
    training_session_key    number primary key,
    session_id              varchar2(50),
    session_name            varchar2(200),
    session_date            date
);

create table dim_activity_type (
    activity_type_key   number primary key,
    activity_type_name  varchar2(50)
);

/*fact table*/

create table fact_employee_activity (
    fact_id                  number primary key,
    date_key                 number not null,
    employee_key             number not null,
    activity_type_key        number not null,
    absence_type_key         number,
    training_session_key     number,
    duration_minutes         number,
    source_system            varchar2(50),

    constraint fk_fact_date
        foreign key (date_key) references dim_date(date_key),

    constraint fk_fact_employee
        foreign key (employee_key) references dim_employee(employee_key),

    constraint fk_fact_activity
        foreign key (activity_type_key) references dim_activity_type(activity_type_key),

    constraint fk_fact_absence
        foreign key (absence_type_key) references dim_absence_type(absence_type_key),

    constraint fk_fact_training
        foreign key (training_session_key) references dim_training_session(training_session_key)
);

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

-- now checking the data quality, standardization, normalization

select distinct absence_type
from stg_absence;

select *
from stg_training_attendance
where leave_time < join_time;

select *
from stg_employee
where valid_to < valid_from;

select *
from stg_missing_hours
where missing_hours < 0;

-- the querys should have 0 rows fetched 

-- static dimension populated manual
insert into dim_activity_type values (1, 'Worked');
insert into dim_activity_type values (2, 'Absent');
insert into dim_activity_type values (3, 'Training');
insert into dim_activity_type values (4, 'MissingHours');

select *
from dim_activity_type
order by activity_type_key;

-- migration step - Moving the staging data to dimension tables - ETL PIPELINE

insert into dim_absence_type (
    absence_type_key,
    absence_type_code,
    absence_type_name
)
select
    rownum as absence_type_key,
    absence_type_std as absence_type_code,
    absence_type_std as absence_type_name
from (
    select distinct upper(trim(absence_type)) as absence_type_std
    from stg_absence
) x;
commit;

select *
from dim_absence_type
order by absence_type_key;



insert into dim_date (
    date_key,
    full_date,
    day_num,
    month_num,
    year_num,
    month_name,
    week_num,
    is_weekend
)
select
    to_number(to_char(date '2025-01-01' + level - 1, 'yyyymmdd')),
    date '2025-01-01' + level - 1,
    extract(day from date '2025-01-01' + level - 1),
    extract(month from date '2025-01-01' + level - 1),
    extract(year from date '2025-01-01' + level - 1),
    trim(to_char(date '2025-01-01' + level - 1, 'Month')),
    to_number(to_char(date '2025-01-01' + level - 1, 'iw')),
    case
        when to_char(date '2025-01-01' + level - 1, 'dy', 'nls_date_language=english') in ('sat', 'sun')
        then 'Y'
        else 'N'
    end
from dual
connect by level <= 31;

commit;


select *
from dim_date
order by full_date;



insert into dim_employee (
    employee_key,
    employee_id,
    badge_id,
    employee_name,
    discipline,
    grade,
    line_manager,
    du_name,
    valid_from,
    valid_to,
    is_current
)
select
    rownum as employee_key,
    employee_id,
    trim(badge_id),
    trim(employee_name),
    upper(trim(discipline)),
    upper(trim(grade)),
    trim(line_manager),
    trim(du_name),
    valid_from,
    valid_to,
    case
        when valid_to = date '9999-12-31' then 'Y'
        else 'N'
    end as is_current
from stg_employee;
    
commit;

select *
from dim_employee
order by employee_id, valid_from;

select
    employee_id,
    count(*) as versions
from dim_employee
group by employee_id
order by employee_id;



insert into dim_training_session (
    training_session_key,
    session_id,
    session_name,
    session_date
)
select
    rownum as training_session_key,
    session_id,
    session_name,
    session_date
from (
    select distinct
        trim(session_id) as session_id,
        trim(session_name) as session_name,
        trunc(join_time) as session_date
    from stg_training_attendance
);

commit;

select *
from dim_training_session
order by session_date, session_id;

-- FACT TABLE --

-- Worked stg_timesheet -> fact_employee_activity --

insert into fact_employee_activity (
    fact_id,
    date_key,
    employee_key,
    activity_type_key,
    absence_type_key,
    training_session_key,
    duration_minutes,
    source_system
)
select
    rownum as fact_id,
    d.date_key,
    e.employee_key,
    1 as activity_type_key,         -- Worked
    null as absence_type_key,
    null as training_session_key,
    round(t.worked_hours * 60) as duration_minutes,
    'TIMESHEET' as source_system
from stg_timesheet t
join dim_date d
    on d.full_date = t.work_date
join dim_employee e
    on e.employee_id = t.employee_id
   and t.work_date between e.valid_from and e.valid_to;

commit;

select
    f.fact_id,
    d.full_date,
    e.employee_name,
    e.discipline,
    f.duration_minutes,
    f.source_system
from fact_employee_activity f
join dim_date d
    on d.date_key = f.date_key
join dim_employee e
    on e.employee_key = f.employee_key
where f.activity_type_key = 1
order by d.full_date, e.employee_name;




-- Load Training in fact --
insert into fact_employee_activity (
    fact_id,
    date_key,
    employee_key,
    activity_type_key,
    absence_type_key,
    training_session_key,
    duration_minutes,
    source_system
)
select
    (select nvl(max(fact_id), 0) from fact_employee_activity) + rownum,
    d.date_key,
    e.employee_key,
    3 as activity_type_key,      -- Training
    null as absence_type_key,
    ts.training_session_key,
    round((t.leave_time - t.join_time) * 24 * 60) as duration_minutes,
    'TRAINING' as source_system
from stg_training_attendance t
join dim_date d
    on d.full_date = trunc(t.join_time)
join dim_employee e
    on e.badge_id = t.employee_badge_id
   and trunc(t.join_time) between e.valid_from and e.valid_to
join dim_training_session ts
    on ts.session_id = trim(t.session_id)
   and ts.session_date = trunc(t.join_time);

commit;


insert into fact_employee_activity (
    fact_id,
    date_key,
    employee_key,
    activity_type_key,
    absence_type_key,
    training_session_key,
    duration_minutes,
    source_system
)
select
    (select nvl(max(fact_id), 0) from fact_employee_activity) + rownum,
    d.date_key,
    e.employee_key,
    3 as activity_type_key,      -- Training
    null as absence_type_key,
    ts.training_session_key,
    round((t.leave_time - t.join_time) * 24 * 60) as duration_minutes,
    'TRAINING' as source_system
from stg_training_attendance t
join dim_date d
    on d.full_date = trunc(t.join_time)
join dim_employee e
    on e.badge_id = t.employee_badge_id
   and trunc(t.join_time) between e.valid_from and e.valid_to
join dim_training_session ts
    on ts.session_id = trim(t.session_id)
   and ts.session_date = trunc(t.join_time);

commit;



select
    f.fact_id,
    d.full_date,
    e.employee_name,
    ts.session_name,
    f.duration_minutes,
    f.source_system
from fact_employee_activity f
join dim_date d
    on d.date_key = f.date_key
join dim_employee e
    on e.employee_key = f.employee_key
join dim_training_session ts
    on ts.training_session_key = f.training_session_key
where f.activity_type_key = 3
order by d.full_date, e.employee_name;

select count(*) from stg_training_attendance;



-- Missing Hours --

insert into fact_employee_activity (
    fact_id,
    date_key,
    employee_key,
    activity_type_key,
    absence_type_key,
    training_session_key,
    duration_minutes,
    source_system
)
select
    (select nvl(max(fact_id), 0) from fact_employee_activity) + rownum,
    d.date_key,
    e.employee_key,
    4 as activity_type_key,      -- MissingHours
    null as absence_type_key,
    null as training_session_key,
    round(m.missing_hours * 60) as duration_minutes,
    'MISSING_HOURS' as source_system
from stg_missing_hours m
join dim_date d
    on d.full_date = m.activity_date
join dim_employee e
    on e.employee_id = m.employee_id
   and m.activity_date between e.valid_from and e.valid_to;

commit;


select
    f.fact_id,
    d.full_date,
    e.employee_name,
    f.duration_minutes,
    f.source_system
from fact_employee_activity f
join dim_date d
    on d.date_key = f.date_key
join dim_employee e
    on e.employee_key = f.employee_key
where f.activity_type_key = 4
order by d.full_date, e.employee_name;


-- Load Absent in fact --

insert into fact_employee_activity (
    fact_id,
    date_key,
    employee_key,
    activity_type_key,
    absence_type_key,
    training_session_key,
    duration_minutes,
    source_system
)
select
    (select nvl(max(fact_id), 0) from fact_employee_activity) + rownum,
    d.date_key,
    e.employee_key,
    2 as activity_type_key,      -- Absent
    a.absence_type_key,
    null as training_session_key,
    round(x.hours_per_day * 60) as duration_minutes,
    'ABSENCE' as source_system
from (
    select
        employee_id,
        upper(trim(absence_type)) as absence_type,
        start_date + level - 1 as absence_day,
        hours_per_day
    from stg_absence
    connect by prior employee_id = employee_id
       and prior start_date = start_date
       and prior end_date = end_date
       and prior sys_guid() is not null
       and level <= end_date - start_date + 1
) x
join dim_date d
    on d.full_date = x.absence_day
join dim_employee e
    on e.employee_id = x.employee_id
   and x.absence_day between e.valid_from and e.valid_to
join dim_absence_type a
    on a.absence_type_code = x.absence_type;

commit;


select
    f.fact_id,
    d.full_date,
    e.employee_name,
    a.absence_type_name,
    f.duration_minutes,
    f.source_system
from fact_employee_activity f
join dim_date d
    on d.date_key = f.date_key
join dim_employee e
    on e.employee_key = f.employee_key
join dim_absence_type a
    on a.absence_type_key = f.absence_type_key
where f.activity_type_key = 2
order by d.full_date, e.employee_name;


-- Fact Table completed --
-- Checking reports --

-- show activities by day, by employees --

select
    d.full_date,
    e.employee_name,
    at.activity_type_name,
    nvl(ab.absence_type_name, '-') as absence_type,
    nvl(ts.session_name, '-') as session_name,
    f.duration_minutes
from fact_employee_activity f
join dim_date d
    on d.date_key = f.date_key
join dim_employee e
    on e.employee_key = f.employee_key
join dim_activity_type at
    on at.activity_type_key = f.activity_type_key
left join dim_absence_type ab
    on ab.absence_type_key = f.absence_type_key
left join dim_training_session ts
    on ts.training_session_key = f.training_session_key
order by d.full_date, e.employee_name, at.activity_type_name;

-- monthly report per employee --

select
    f.fact_id,
    d.full_date,
    e.employee_name,
    a.absence_type_name,
    f.duration_minutes,
    f.source_system
from fact_employee_activity f
join dim_date d
    on d.date_key = f.date_key
join dim_employee e
    on e.employee_key = f.employee_key
join dim_absence_type a
    on a.absence_type_key = f.absence_type_key
where f.activity_type_key = 2
order by d.full_date, e.employee_name;

-- report for training session --
select
    ts.session_name,
    d.full_date,
    count(distinct f.employee_key) as participants,
    round(avg(f.duration_minutes), 2) as avg_attendance_minutes,
    round(sum(f.duration_minutes), 2) as total_attendance_minutes
from fact_employee_activity f
join dim_training_session ts
    on ts.training_session_key = f.training_session_key
join dim_date d
    on d.date_key = f.date_key
where f.activity_type_key = 3
group by ts.session_name, d.full_date
order by d.full_date, ts.session_name;