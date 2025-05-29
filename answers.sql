--dedupe check switch tables against ID quick and dirty i could row hash...
select
	id,
	COUNT(*) as duplicate_count
from
	"Encounter" e
group by
	id
having
	COUNT(*) > 1;
--q1
select
	*
from
	"Patient" p
where
	active = true;
--q2
select
	P.*,
	E.status ,
	E.encounter_date
from
	"Patient" p
left join "Encounter" e 
on
	P.ID = E.patient_id
	--1:M
where
	E.patient_id = ''
	-- add THE PATIENT NAME HERE?  DOESNT SPECIFY WHAT THE filter SHOULD BE for PATIENT	
	-- Michelle Shaw and Diane Hughes DQ issue....
	--q3
select
	P.*,
	o."type" ,
	o.value,
	o.unit,
	o.recorded_at
from
	"Patient" p
left join "Observation" o  
on
	P.ID = o.patient_id ;
--1:M
where
o.patient_id = ''
--q4
with ranked_encounters as (
select
	e.patient_id,
	e.encounter_date,
	e.status,
	row_number() over (
            partition by e.patient_id
order by
	e.encounter_date desc
        ) as rn
from
	"Encounter" e
)
select
	patient_id,
	encounter_date,
	status
from
	ranked_encounters
where
	rn = 1;
--q5
select
	e.patient_id
from
	"Encounter" e
group by
	e.patient_id
having
	COUNT(distinct e.practitioner_id) > 1;
--q6
select
	medication_name,
	COUNT(*) as prescription_count
from
	"MedicationRequest"
group by
	medication_name
order by
	prescription_count desc
limit 3;

;
--q7
select
	p.id,
	p.name
from
	"Practitioner" p
left join "MedicationRequest" mr
    on
	p.id = mr.practitioner_id
where
	mr.practitioner_id is null;
--whos in prac table but not in med req
--q8
select
	ROUND(AVG(encounter_count)::numeric, 2) as average_encounters_per_patient
from
	(
	select
		p.id as patient_id,
		COUNT(e.id) as encounter_count
	from
		"Patient" p
	left join "Encounter" e on
		p.id = e.patient_id
	group by
		p.id
) sub;
--q9
select
	p.id as patient_id,
	COUNT(distinct mr.id) as medication_request_count,
	COUNT(distinct e.id) as encounter_count
from
	public."Patient" p
left join public."MedicationRequest" mr on
	p.id = mr.patient_id
left join public."Encounter" e on
	p.id = e.patient_id
group by
	p.id
having
	COUNT(distinct e.id) = 0
	and COUNT(distinct mr.id) > 0;
--q10
with first_encounter as (
select
	patient_id,
	MIN(encounter_date) as first_date
	--first date in system assumption
from
	"Encounter"
group by
	patient_id
),
encounters_with_cohort as (
select
	fe.patient_id,
	TO_CHAR(fe.first_date, 'YYYY-MM') as cohort_month,
	--conversion per req
	e.encounter_date
from
	first_encounter fe
join "Encounter" e 
      on
	fe.patient_id = e.patient_id
where
	e.encounter_date > fe.first_date
	--range for 6 month
	and e.encounter_date <= fe.first_date + interval '6 months'
),
retained_patients as (
select
	distinct patient_id,
	cohort_month
from
	encounters_with_cohort
)
select
	cohort_month,
	COUNT(distinct patient_id) as retained_patient_count
	--agg for final answer
from
	retained_patients
group by
	cohort_month
order by
	cohort_month;
