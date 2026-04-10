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