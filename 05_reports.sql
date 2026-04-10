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