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