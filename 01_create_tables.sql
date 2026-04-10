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