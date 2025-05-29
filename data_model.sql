-- star schema to track tasks over date dimension
-- im choosing a DDM given this is data engineering and assuming a denormalized exercise. i would do this in dbt core
-- Dimension: Tasks
CREATE TABLE DimTask (
    task_key UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- i would key off BK 
    task_name VARCHAR(255) NOT NULL,
    recurrence_type NOT NULL DEFAULT 'None',
    recurrence_count INT,           -- NULL means unlimited
    start_date DATE NOT NULL,
    end_date DATE                   -- optional
);

-- Dimension: People
CREATE TABLE DimPerson (
    person_key UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    person_name VARCHAR(255) NOT NULL --max this data type
);

-- Dimension: Dates (Date spine gen)
CREATE TABLE DimDate (
    date_key DATE PRIMARY KEY,
    year INT NOT NULL,
    month INT NOT NULL,
    day INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    day_of_week VARCHAR(20) NOT NULL
);

-- Dimension: Statuses
CREATE TABLE DimStatus (
    status_key UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status task_status NOT NULL
);

-- Fact table: Task occurrences
CREATE TABLE FactTaskOccurrence (
    fact_task_occurrence_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), --agg on for counts etc
    task_key UUID NOT NULL REFERENCES DimTask(task_key),
    person_key UUID REFERENCES DimPerson(person_key),
    occurrence_date_key DATE NOT NULL REFERENCES DimDate(date_key),
    status_key INT NOT NULL REFERENCES DimStatus(status_key) --basically a flag
);
