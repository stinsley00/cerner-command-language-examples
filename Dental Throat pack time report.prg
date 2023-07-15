drop program MCH_DENTAL_THROATPACK go
create program MCH_DENTAL_THROATPACK

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Time" = "SYSDATE"               ;* Start time
	, "End Time" = "SYSDATE"                 ;* End date time 

with OUTDEV, starttm, endtm


select
p.person_id
,p.name_full_formatted
,e.encntr_id
,sc.surg_case_id
,age = cnvtage(p.birth_dt_tm)
,case_number = sc.surg_case_nbr_formatted
,Check_In_DtTm = sc.checkin_dt_tm
,PT_IN_RM_TM = ct1.case_time_dt_tm
,PT_OUT_RM_TM = ct.case_time_dt_tm
,Result_type = UAR_GET_CODE_DISPLAY(ce.event_cd)
,Result_date_tm = format(cnvtdatetime(cnvtdate2(substring(3,8,ce.result_val),"YYYYMMDD"),
cnvttime2(substring(11,4,ce.result_val),"HHMM")),";;q")
,Scheduled_provider = pp.name_full_formatted
from 
surgical_case sc
,encounter e
,person p
,case_times ct
,case_times ct1
,clinical_event ce
,prsnl pp
plan sc 
	where ;sc.surg_specialty_id in (643845.00) 
	 sc.surg_case_nbr_formatted = "MPS-*"
	and sc.active_ind = 1
	and sc.sched_start_dt_tm between cnvtdatetime($starttm) and cnvtdatetime($endtm)
	and sc.surg_area_cd in (4045770.00)
	;and sc.surgeon_prsnl_id in (3670982.00, 750028.00, 750034.00,749963.00, 836938.00)
join e where e.encntr_id = outerjoin(sc.encntr_id)
	and e.active_ind = 1
join p where p.person_id = e.person_id
	and p.active_ind = 1
join ct
	where ct.surg_case_id = sc.surg_case_id
	and ct.active_ind = 1
	and ct.task_assay_cd in (667193.00)
join ct1 
	where ct1.surg_case_id = sc.surg_case_id
	and ct1.active_ind = 1
	and ct1.task_assay_cd in (667192.00)
join ce
	where ce.encntr_id = outerjoin(sc.encntr_id)
	and ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
	and ce.performed_prsnl_id = 0.00
	and ce.accession_nbr = " "
	and ce.event_cd in (18920724.00, 18920728.00, 4154123.00)

join pp where pp.person_id = sc.surgeon_prsnl_id
order by sc.surg_case_nbr_formatted, ce.event_cd
with maxtime = 90,  format(date,";;q")


end
go
