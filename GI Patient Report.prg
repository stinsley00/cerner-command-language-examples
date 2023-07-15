DROP PROGRAM DMOR_GI_SX_PTS_RPT GO
CREATE PROGRAM DMOR_GI_SX_PTS_RPT
/*
* PURPOSE: THIS REPORT IS INTENDED TO RUN FROM EXPLORER MENU
* This report queries the surginet nursing record to analyze
* Surgical site infections in GI patients 
*
* @ENGINEER STINSLEY
*
* CR:
*
* AMENDMENT LOG:
* INITIAL DEV: 10/16/2016 @AUTHOR: STINSLEY
*/
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start" = "SYSDATE"                    ;* Start
	, "End Date" = ""                        ;* enddt
 
with OUTDEV, Start, enddt
 
 
;SNET SEGMENTS
DECLARE VITALSIGNS = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"VITALSIGNS"))
DECLARE SURGICALPROCEDURES = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"SURGICALPROCEDURES"))
DECLARE SPECIMENSANDCULTURES = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"SPECIMENSANDCULTURES"))
DECLARE PREPANDPROTECTION = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"PREPANDPROTECTION"))
DECLARE OXYGENADMINISTRATION = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"OXYGENADMINISTRATION"))
DECLARE OCCURRENCES = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"OCCURRENCES"))
DECLARE MEDSANDIVS = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"MEDSANDIVS"))
DECLARE INTAKEANDOUTPUT = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"INTAKEANDOUTPUT"))
DECLARE IMPLANTSANDGRAFTS = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"IMPLANTSANDGRAFTS"))
DECLARE GENERALCASEDATA = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"GENERALCASEDATA"))
DECLARE EQUIPMENT = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"EQUIPMENT"))
DECLARE DRESSINGANDPACKING = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"DRESSINGANDPACKING"))
DECLARE DEPARTUREFROMOR = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"DEPARTUREFROMOR"))
DECLARE COUNTS = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"COUNTS"))
DECLARE CONSENTVERIFICATION = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"CONSENTVERIFICATION"))
DECLARE CATHETERSDRAINSTUBES = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"CATHETERSDRAINSTUBES"))
DECLARE BLOODPRODUCTSADMINISTRATION = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"BLOODPRODUCTSADMINISTRATION"))
DECLARE ATTENDANCEANDTIMES = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"ATTENDANCEANDTIMES"))
DECLARE ARRIVALINOR = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"ARRIVALINOR"))
DECLARE XRAYANDIMAGES = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",10003,"XRAYANDIMAGES"))
 
;SNET RESULTS
 
DECLARE HAIRREMOVALBY = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",14003,"BMCSPCASEATTENDANCEBY"))
DECLARE PREPBY = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",14003,"BMCSPPREPBY"))
DECLARE HAIRREMOVALMETHOD = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",14003,"BMCSPHAIRREMOVALMETHOD"))
DECLARE HAIRREMOVALSITE = f8 with constant(uar_get_code_by("DISPLAYKEY",72, "BMCSPHAIRREMOVALSITE"))
DECLARE SXPREPAREA = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",14003,"BMC - SP - PREP AREA"))
DECLARE PREPSTOPTIME = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",14003,"BMC - SP - PREP STOP TIME"))
DECLARE PREPSTARTTIME = F8 with CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",14003,"BMC - SP - PREP START TIME"))
DECLARE PREPAGENT = f8 with CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",72,"BMC - SP - Prep Agents"))
DECLARE PREPOUTCOME = f8 with CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",14003,"BMCSPOUTCOMEV2"))
DECLARE CASEATTENDANCEBY = f8 with constant(UAR_GET_CODE_BY("DISPLAYKEY",14003,"BMCCATCASEATTENDEE"))
DECLARE CASEATTENDEEROLE = f8 with constant(UAR_GET_CODE_BY("DISPLAYKEY",14003,"BMCCATROLEPERFORMED"))
DECLARE PREOPDX = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 14003, "BMCGCDPREOPDIAGNOSIS"))
DECLARE POSTOPDX = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 14003, "BMCGCDPOSTOPDIAGNOSIS"))
DECLARE ASA = f8 with constant(uar_get_code_by("DISPLAYKEY", 14003, "BMC - GCD -  ASA CLASS"))
DECLARE PROCENDTM = f8 with constant(uar_get_code_by("DISPLAYKEY", 14003, "BMCPROCSTOPTIME"))
DECLARE PROCSTARTTM = f8 with constant(uar_get_code_by("DISPLAYKEY", 14003, "BMCPROCSTARTTIME"))
DECLARE BMCGCDORROOMNUMBER = f8 with constant(UAR_GET_CODE_BY("DISPLAYKEY",14003, "BMCGCDORROOMNUMBER"))

DECLARE GCDWC = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"BMC - GCD - WOUND CLASS"))
DECLARE PROCWC = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"BMCPROCWOUNDCLASS"))
;--DTAS
 
DECLARE IDENT_TYPE_CD = f8 with constant(UAR_GET_CODE_BY("DISPLAYKEY",11000,"RXMISC1"))
DECLARE CHGGOWNSGLOVES = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",14003,"INTRAOPCHANGEGOWNSGLOVES"))
DECLARE CLEANTOWELS = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",14003,"INTRAOPREDRAPECLEANTOWELS"))
DECLARE INSTRUMENTS = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",14003,"INTRAOPCLOSINGINSTRUMENTSETOPEN"))
DECLARE INTRAOPCOMMENTS = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",14003,"INTRAOPCOMMENTS"))
DECLARE SURGAREA1 = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 221, "DMAINORSURGERY"))
DECLARE SURGAREA2 = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 221, "DENDO"))
DECLARE circ = f8 with constant(UAR_GET_CODE_BY("DISPLAYKEY", 10170,"CIRCULATOR"))
DECLARE SCRUB = f8 with constant(UAR_GET_CODE_BY("DISPLAYKEY", 10170,"SCRUB"))
;--POWERFORM STATUS CODES
 
DECLARE AUTHVERIFIEDCD = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",8,"AUTHVERIFIED"))
DECLARE ACTIVECD = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",8,"ACTIVE"))
DECLARE MODIFIEDCD = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",8,"MODIFIED"))
;--FINS
 
DECLARE FIN_CD = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",263,"FINPOOL"))
DECLARE MRN_CD = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",264,"BAPTISTDOWNTOWNSOUTHWCHMRNALIASPOOL"))
 
;--GENERAL CODES
 
DECLARE ACTIVE_STATUS = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",48,"ACTIVE"))
DECLARE DCP_FORM_COMP_CD = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",18189,"PRIMARYEVENTID"))
DECLARE DCP_FORM_REF_ID = F8 WITH CONSTANT(1226241940.00)
 
;--abxref to contain record for each antibiotic
 
FREE RECORD abxref
RECORD abxref(
	1	list[*]
		2	CATALOG_CD = F8
	)
 
RECORD OUTPUT(
	1 LIST [*]
		2 PERSON_ID = F8
		2 ENCNTR_ID = F8
		2 surg_case_id = f8
		2 periop_doc_id = f8
		2 FORMS_ACTIVITY_ID = F8
		2 DOCUMENTED_DT_TM = DQ8
		2 UPDT_CNT = I4
		2 FIN = VC
		2 MRN = VC
		2 PATIENT_NAME = VC
		2 DOS = VC
		2 GCDWC = vc
		2 PROCWC = vc
		2 SURGICAL_ROOM = VC
		2 SURGEON = VC
		2 HAIR_REMOVAL_BY = VC
		2 HAIR_REMOVAL_BY_ID = f8
		2 HAIR_REMOVAL_SITE = VC
		2 HAIR_REMOVAL_METHOD = VC
		2 SURGICAL_PREP_AREA = VC
		2 PREP_AGENTS = VC
		2 PREP_START_TIME = VC
		2 PREP_STOP_TIME = VC
		2 PREP_BY = VC
		2 PREP_BY_ID = f8
		2 PREP_OUTCOME = VC
		2 PREOP_ABX_GIVEN = VC
		2 PREOP_ABX_TIME_GIVEN = VC
		2 PREOP_ABX_DOSE = VC
		2 redose_abx_given = vc
		2 redose_abx_TIME_Given = vc
		2 redose_abx_DOSE = vc
		2 ASA = VC
		2 WOUND_CLASS = VC
		2 PREOP_DX = VC
		2 POSTOP_DX = VC
		2 INCISION_TM = VC
		2 PROC_START_TM = VC
		2 PROC_END_TM = VC
		2 CASE_ATTENDEE_1 = VC
		2 Case_Attendee_role = vc
		2 CASE_ATTENDEE_2 = VC
		2 case_attendee_2_role = vc
		2 MSB_GLOVES = VC
		2 MSB_REDRAPE = VC
		2 MSB_INSTRUMENT = VC
		2 MSB_COMMENTS = VC
	1 CNT = I4
)
 
record temp (
	1 list[*]
	2 encntr_id = f8
	2 time = dq8
	2 abx = vc
	2 abx_dose = vc
	2 redose_flag = i2
)
 
IF(DATETIMEDIFF(CNVTDATETIME($ENDDT),CNVTDATETIME($START),1,0)> 1)
	SELECT INTO $OUTDEV
	FROM DUMMYT D
	PLAN D
	DETAIL
	COL 0 "REPORT MUST BE RUN FOR TIME INCREMENTS OF 1 DAYS OR LESS..."
	WITH NOCOUNTER, SEPARATOR=" ", FORMAT
	GO TO EXIT_PROGRAM
 
ELSE
 
CALL ECHO("MAIN PROG")
 
SELECT INTO "NL:"
 
FROM
SURGICAL_CASE SC
,PERIOPERATIVE_DOCUMENT PD
,CLINICAL_EVENT CE ;--segment
,CLINICAL_EVENT CE1 ;-- result
,ce_event_prsnl cep
,PRSNL SURGEON
,prsnl p
PLAN SC
	WHERE SC.SURG_START_DT_TM BETWEEN CNVTDATETIME($START) AND CNVTDATETIME($ENDDT)
	AND SC.SURG_AREA_CD IN (SURGAREA1, SURGAREA2)
JOIN PD
	WHERE PD.SURG_CASE_ID = (SC.SURG_CASE_ID)
 
JOIN CE WHERE CE.RECORD_STATUS_CD IN (ACTIVE_STATUS) AND CE.ENCNTR_ID = SC.ENCNTR_ID
AND (CE.PARENT_EVENT_ID = CE.EVENT_ID ) AND (CNVTSTRING (PD.PERIOP_DOC_ID ) =
SUBSTRING(1 ,(FINDSTRING ("SN" ,CE.REFERENCE_NBR ) - 1 ) ,CE.REFERENCE_NBR ) )
JOIN CE1 WHERE CE1.PARENT_EVENT_ID = CE.EVENT_ID AND (TRIM (CE1.COLLATING_SEQ ) != "" )
	AND CE1.VALID_UNTIL_DT_TM >= CNVTDATETIME (CURDATE ,CURTIME3)
	and ce1.order_id = 0
join cep where cep.event_id = outerjoin(ce1.event_id)
	and cep.valid_until_dt_tm > cnvtdatetime(curdate, curtime)
JOIN SURGEON where
	SURGEON.PERSON_ID = SC.SURGEON_PRSNL_ID
	and surgeon.active_ind = 1
	and surgeon.active_status_cd in (ACTIVE_STATUS)
JOIN p where
	p.PERSON_ID = cep.action_prsnl_id
	and p.active_ind = 1
	and p.active_status_cd in (ACTIVE_STATUS)

order by sc.encntr_id
 
HEAD REPORT
	CNT = 0
	head ce1.encntr_id
	CNT = CNT + 1
		IF(MOD(CNT,10) = 1)
			STAT = ALTERLIST(OUTPUT->LIST, CNT + 9)
		 ENDIF
	DETAIL
 		output->LIST[cnt].DOS = format(cnvtdatetime(sc.sched_start_dt_tm),";;Q")
		OUTPUT->LIST[CNT].surg_case_id = SC.surg_case_id
		OUTPUT->LIST[CNT].periop_doc_id = PD.periop_doc_id
		OUTPUT->LIST[CNT].PERSON_ID = ce1.PERSON_ID
		OUTPUT->LIST[CNT].ENCNTR_ID = ce1.ENCNTR_ID
		OUTPUT->LIST[CNT].SURGEON = TRIM(REPLACE(SURGEON.NAME_FULL_FORMATTED,",",""))
		OUTPUT->LIST[CNT].WOUND_CLASS = UAR_GET_CODE_DISPLAY(SC.WOUND_CLASS_CD)
		output->LIST[cnt].SURGICAL_ROOM= UAR_GET_CODE_DISPLAY(SC.surg_op_loc_cd)
		;GRAB SNET DATA FROM CE CHILD ROWS VIA DTA SPECIFIED IN SPECIFICATION
 
			if(ce1.task_assay_cd = BMCGCDORROOMNUMBER)
			OUTPUT->LIST[CNT].SURGICAL_ROOM = ce1.result_val;--NEED SURG AREA LOC CD
 			endif
 
			IF(CE1.TASK_ASSAY_CD = HAIRREMOVALBY)
			OUTPUT->LIST[CNT].HAIR_REMOVAL_BY_ID = cep.action_prsnl_id
			output->LIST[cnt].HAIR_REMOVAL_BY = p.name_full_formatted
			ENDIF
 
			if(ce1.event_cd = HAIRREMOVALSITE)
			output->LIST[CNT].HAIR_REMOVAL_SITE = ce1.event_tag
			endif
 			
 			if(ce1.task_assay_cd = PREPBY)
			output->LIST[CNT].PREP_BY_ID = cep.action_prsnl_id
			output->LIST[CNT].PREP_BY = p.name_full_formatted
			endif
			
			if(ce1.task_assay_cd = HAIRREMOVALMETHOD)
			output->LIST[CNT].HAIR_REMOVAL_METHOD = ce1.event_tag
			endif
			
			IF(CE1.TASK_ASSAY_CD = SXPREPAREA)
				OUTPUT->LIST[CNT].SURGICAL_PREP_AREA = CE1.event_tag
			ENDIF
 
			IF(CE1.TASK_ASSAY_CD = PREPSTOPTIME)
				OUTPUT->LIST[CNT].PREP_STOP_TIME = format(cnvtdatetime(cnvtdate2(substring(3,8,ce1.result_val),"YYYYMMDD"),
				cnvttime2(substring(9,4,ce1.result_val),"HHMM")), ";;Q")
			ENDIF
 			if(CE1.task_assay_cd = GCDWC)
 				output->LIST[CNT].GCDWC = ce1.result_val
 			endif
 
 			if(CE1.task_assay_cd = PROCWC)
 				output->LIST[CNT].PROCWC = ce1.result_val
 			endif
 
			IF(CE1.TASK_ASSAY_CD = PREPSTARTTIME)
				OUTPUT->LIST[CNT].PREP_START_TIME = format(cnvtdatetime(cnvtdate2(substring(3,8,ce1.result_val),"YYYYMMDD"),
				cnvttime2(substring(9,4,ce1.result_val),"HHMM")), ";;Q")
			ENDIF
 
			IF(CE1.TASK_ASSAY_CD = PREPOUTCOME)
				OUTPUT->LIST[CNT].PREP_OUTCOME = CE1.RESULT_VAL
			ENDIF
 
			IF(CE1.task_assay_cd = PREOPDX)
				output->LIST[CNT].PREOP_DX = ce1.result_val
			endif
 
			if(ce1.task_assay_cd = POSTOPDX)
				output->LIST[CNT].POSTOP_DX = ce1.result_val
			endif
 
			IF(CE1.task_assay_cd = ASA)
				output->LIST[CNT].ASA = ce1.result_val
			endif
 
			if(ce1.task_assay_cd = PROCSTARTTM)
				output->LIST[CNT].PROC_START_TM =  format(cnvtdatetime(cnvtdate2(substring(3,8,ce1.result_val),"YYYYMMDD"),
				cnvttime2(substring(9,4,ce1.result_val),"HHMM")), ";;Q")
			endif
 
			if(ce1.task_assay_cd = PROCENDTM)
				output->LIST[CNT].PROC_END_TM =  format(cnvtdatetime(cnvtdate2(substring(3,8,ce1.result_val),"YYYYMMDD"),
				cnvttime2(substring(9,4,ce1.result_val),"HHMM")), ";;Q")
			endif
 
			IF(CE1.event_title_text = "BMC - SP - Prep Agents")
				OUTPUT->LIST[CNT].PREP_AGENTS = CE1.event_tag
			ENDIF
FOOT REPORT
	OUTPUT->CNT = CNT
	STAT = ALTERLIST(OUTPUT->LIST, CNT)
 
WITH NOCOUNTER



/*
*	grab case attendees
*
*/
 
set index = 0
select distinct into "NL:"
ROLE = UAR_GET_CODE_DISPLAY(ca.role_perf_cd)
,PID = ca.case_attendee_id
FROM
SURGICAL_CASE SC
,case_attendance ca
,PRSNL P
PLAN SC
	WHERE expand(index,1,size(output->LIST,5),sc.surg_case_id, output->LIST[index].surg_case_id)
JOIN CA
	WHERE CA.surg_case_id = sc.surg_case_id
	and ca.role_perf_cd in (circ, scrub);circ and scrub only
	and ca.active_ind = 1
	and ca.active_status_cd in (ACTIVE_STATUS)
JOIN P
	where P.person_id = ca.case_attendee_id
 	and p.active_ind = 1 and p.active_status_cd in (Active_status)
	HEAD REPORT
 
			POS = 0
			INDEX = 0
	HEAD sc.surg_case_id
		POS = LOCATEVAL(INDEX, 1, SIZE(OUTPUT->LIST,5), sc.surg_case_id, OUTPUT->LIST[INDEX].surg_case_id)
	DETAIL
 		WHILE(POS > 0 )
 			if(ca.role_perf_cd = circ)
			output->LIST[pos].CASE_ATTENDEE_1 = p.name_full_formatted
			output->LIST[pos].Case_Attendee_role = uar_get_code_display(ca.role_perf_cd)
			endif
			if(ca.role_perf_cd = scrub)
			output->LIST[pos].CASE_ATTENDEE_2 = p.name_full_formatted
			output->LIST[pos].case_attendee_2_role = uar_get_code_display(ca.role_perf_cd)
			endif
		POS = LOCATEVAL(INDEX, pos+1, SIZE(OUTPUT->LIST,5), sc.surg_case_id, OUTPUT->LIST[INDEX].surg_case_id)
		endwhile
with nocounter, expand = 1
 
 
 CALL ECHO("DTAs")
 /*GET DTA RESPONSES FROM POWERFORM*/
 
 SET INDEX = 0
;SX ENCNTRS WITH FORMS
SELECT distinct INTO "NL:"
	FROM
	 DCP_FORMS_ACTIVITY D
	, DCP_FORMS_ACTIVITY_COMP DFA
	, CLINICAL_EVENT   CE
	, CLINICAL_EVENT   SECTION
	, CLINICAL_EVENT   DTA
 
Plan D where EXPAND(INDEX,1,SIZE(OUTPUT->LIST,5),D.ENCNTR_ID, OUTPUT->LIST[INDEX].ENCNTR_ID)
	AND D.DCP_FORMS_REF_ID IN (DCP_FORM_REF_ID)
	AND D.ACTIVE_IND = 1
	AND D.FLAGS = 2
JOIN DFA WHERE DFA.DCP_FORMS_ACTIVITY_ID = D.DCP_FORMS_ACTIVITY_ID
	 AND DFA.PARENT_ENTITY_NAME = "CLINICAL_EVENT"
	 AND DFA.COMPONENT_CD =  DCP_FORM_COMP_CD
JOIN CE WHERE CE.EVENT_ID = DFA.PARENT_ENTITY_ID;EVENT ID FROM THE FORM
	AND CE.VALID_UNTIL_DT_TM > SYSDATE
	AND CE.ORDER_ID = 0.0
JOIN SECTION WHERE;WALK DOWN THE CE HIERARCHY
	SECTION.PARENT_EVENT_ID = CE.EVENT_ID
	AND SECTION.VALID_UNTIL_DT_TM > SYSDATE
	and section.order_id = 0
JOIN DTA WHERE	DTA.PARENT_EVENT_ID = SECTION.EVENT_ID
	AND DTA.VALID_UNTIL_DT_TM > SYSDATE
	AND DTA.RESULT_STATUS_CD = AUTHVERIFIEDCD
	and dta.order_id = 0
	HEAD REPORT
			CNT = 0
			POS = 0
			INDEX = 0
		HEAD DTA.EVENT_ID
		POS = LOCATEVAL(INDEX, 1, SIZE(OUTPUT->LIST,5),D.ENCNTR_ID, OUTPUT->LIST[INDEX].ENCNTR_ID)
		DETAIL
 		WHILE(POS > 0 )
 
			;--DTAS FROM THE POWERFORM
			IF(DTA.TASK_ASSAY_CD = CHGGOWNSGLOVES)
			OUTPUT->LIST[POS].MSB_GLOVES = DTA.RESULT_VAL
			ENDIF
 
			IF(DTA.TASK_ASSAY_CD = INSTRUMENTS)
			OUTPUT->LIST[POS].MSB_INSTRUMENT = DTA.RESULT_VAL
			ENDIF
 
			IF(DTA.TASK_ASSAY_CD = CLEANTOWELS)
			OUTPUT->LIST[POS].MSB_REDRAPE = DTA.RESULT_VAL
			ENDIF
 
			IF(DTA.TASK_ASSAY_CD = INTRAOPCOMMENTS)
			OUTPUT->LIST[POS].MSB_COMMENTS = DTA.RESULT_VAL
			ENDIF
 
			POS = LOCATEVAL(INDEX, POS+1, SIZE(OUTPUT->LIST,5),D.ENCNTR_ID, OUTPUT->LIST[INDEX].ENCNTR_ID)
			ENDWHILE
WITH NOCOUNTER, EXPAND = 1
 ; call echorecord(output)
 set index = 0
;--MRN AND PERSON DATA
SELECT DISTINCT INTO "nl:"
FROM PERSON P,
PERSON_ALIAS PA
PLAN P WHERE EXPAND(INDEX, 1, SIZE(OUTPUT->LIST,5),P.PERSON_ID,OUTPUT->LIST[INDEX].PERSON_ID)
and p.active_ind = 1 and p.active_status_cd in (ACTIVE_STATUS)
JOIN PA WHERE PA.PERSON_ID = P.PERSON_ID
	and PA.active_ind = 1 and PA.active_status_cd in (ACTIVE_STATUS)
;	and pa.alias_pool_cd in (MRN_CD)
	HEAD REPORT
 
			POS = 0
			INDEX = 0
		HEAD p.person_id
		POS = LOCATEVAL(INDEX, 1, SIZE(OUTPUT->LIST,5),p.person_id, OUTPUT->LIST[INDEX].PERSON_ID)
		DETAIL
 		WHILE(POS > 0 )
			output->LIST[pos].PATIENT_NAME = build2(substring(0,1,p.name_first), " ", trim(p.name_last))
			output->LIST[pos].MRN = trim(pa.alias)
 
		pos = locateval(index, pos+1, size(output->LIST,5),p.person_id, output->LIST[index].PERSON_ID)
		endwhile
with nocounter, expand = 1
 
 
 
CALL ECHO("FINS")
;--FIN
 set index = 0
	select DISTINCT into "nl:"
	from encntr_alias ea
	where expand(index, 1, size(output->LIST,5),ea.encntr_id, output->LIST[index].ENCNTR_ID)
		and ea.alias_pool_cd in (FIN_CD)
		and ea.active_ind = 1
		and ea.active_status_cd in (ACTIVE_STATUS)
		HEAD REPORT
 		POS = 0
		INDEX = 0
		HEAD ea.encntr_id
		POS = LOCATEVAL(INDEX, 1, SIZE(OUTPUT->LIST,5),ea.encntr_id, OUTPUT->LIST[INDEX].ENCNTR_ID)
		DETAIL
 		WHILE(POS > 0 )
 			output->LIST[pos].FIN = TRIM(ea.alias)
		pos = locateval(index, pos+1, size(output->LIST,5),ea.encntr_id, output->LIST[index].ENCNTR_ID)
		endwhile
	with nocounter, expand = 1
  call echorecord(output)
 /*
 
;*****************************************************************
;LOAD RECORD STRUCTURE WITH DATA FROM OBJECT_IDENTIFIER AND
;ORDER_CATALOG_ITEM_R TO IDENTIFY ANTIBIOTICS
;*****************************************************************/
 CALL ECHO("ABX")
;get antibiotic information for the selected cases
set index = 0
/*Disclaimer: at the time of this coding baptist is using the DDMO server to write meds to the EMAR
this currently has a defect where the admin start time of the med is written to the mar as the admin stop time.
A work around is to drop into the anesthesia tables and work with the actual admins; this is not preferenable,
but could not be avoided at this time */
SELECT into "NL:"
sma.sa_medication_admin_id
, item_cnt = ROW_NUMBER() OVER(PARTITION BY sma.sa_medication_id order by sc.encntr_id)
, smai.sa_medication_admin_id
, smai.admin_start_dt_tm
, sc.encntr_id
, smai.admin_dosage
, o.catalog_cd
, sma.dosage_unit_cd
,  sc.encntr_id
FROM
  	SURGICAL_CASE SC
	,(inner join SA_ANESTHESIA_RECORD SAR on (SC.SURG_CASE_ID = SAR.SURGICAL_CASE_ID ))
	,(inner join SA_MEDICATION SA on (SA.SA_ANESTHESIA_RECORD_ID = SAR.SA_ANESTHESIA_RECORD_ID))
	,(inner join SA_MEDICATION_ADMIN SMA on (sma.SA_MEDICATION_ID = SA.SA_MEDICATION_ID and sma.order_id > 0
		and sma.active_status_cd in (ACTIVE_STATUS)))
	,(inner join SA_MED_ADMIN_ITEM SMAI on (SMAI.SA_MEDICATION_ADMIN_ID = SMA.SA_MEDICATION_ADMIN_ID))
	,(inner join orders o on (o.encntr_id = sc.encntr_id
		and o.catalog_cd > 0
		and o.order_id = sma.order_id))
   	,(inner join (
   	/*join abx via catalog code to */
   		SELECT distinct
		OC.CATALOG_CD
		FROM
		OBJECT_IDENTIFIER_INDEX  O
		,ORDER_CATALOG_ITEM_R  OC
		WHERE o.value_key = "8????"
		AND O.IDENTIFIER_TYPE_CD =924095.00
		AND O.OBJECT_TYPE_CD >= 0
		AND OC.ITEM_ID = O.OBJECT_ID
		with sqltype("f8")) OC1 on (o.catalog_cd = OC1.catalog_cd))
where expand(index,1,size(output->LIST,5),sc.encntr_id, output->LIST[index].encntr_id)
 
;group by sma.sa_medication_admin_id, smai.sa_medication_admin_id, smai.admin_start_dt_tm,
;smai.admin_dosage, o.catalog_cd,sma.dosage_unit_cd ,sc.encntr_id, item_cnt
order by sc.encntr_id, sma.sa_medication_id
 		HEAD REPORT
 			cnt = 0
			POS = 0
			INDEX = 0
		HEAD smai.sa_medication_admin_id
		CNT = CNT + 1 ; counter enconters
		IF(MOD(CNT,10) = 1)
			STAT = ALTERLIST(temp->LIST, cnt + 9)
		ENDIF
 
 
		DETAIL ; reset count for each encounter.
 
 			temp->list[cnt].encntr_id = sc.encntr_id
 
 			temp->list[cnt].abx = Trim(uar_get_code_display(o.catalog_cd))
 			temp->list[cnt].abx_dose =
 			concat(cnvtstring(smai.admin_dosage,5,3,L), " ",uar_get_code_display(sma.dosage_unit_cd))
 			temp->list[cnt].time = smai.admin_start_dt_tm
 			if(item_cnt = 1.00) temp->list[cnt].redose_flag = 0 endif
 			if(item_cnt = 2.00) temp->list[cnt].redose_flag = 1 endif
 
 
 	 foot report
 	 	STAT = ALTERLIST(temp->LIST, cnt)
 
with nocounter, expand = 1
 
	set index = 0
 	for(jj = 0 to size(temp->list,5)); for each encntr with abx
  	set POS = LOCATEVALSORT(INDEX, 1, SIZE(OUTPUT->LIST,5),temp->list[jj].encntr_id, OUTPUT->LIST[INDEX].ENCNTR_ID)
 		WHILE(POS > 0 )
	if(temp->list[jj].redose_flag = 0)
		set output->LIST[pos].PREOP_ABX_GIVEN = temp->list[jj].abx
		set output->LIST[pos].PREOP_ABX_TIME_GIVEN = format(temp->list[jj].time, ";;q")
		set Output->LIST[pos].PREOP_ABX_DOSE = temp->list[jj].abx_dose
	endif
	if(temp->list[jj].redose_flag = 1)
	;redose situation subsequent redoses are not in spec document
		set output->LIST[pos].redose_abx_given =temp->list[jj].abx
		set output->LIST[pos].redose_abx_TIME_Given = format(temp->list[jj].time, ";;q")
		set output->LIST[pos].redose_abx_DOSE = temp->list[jj].abx_dose
	endif
		set pos = locatevalSORT(index, pos+1, size(output->LIST,5),temp->list[jj].encntr_id, output->LIST[index].ENCNTR_ID)
 
		endwhile
		endfor

/*
 
Output
 
*/
SELECT into $OUTDEV
;	PERSON_ID = OUTPUT->LIST[D1.SEQ].PERSON_ID
;	, ENCNTR_ID = OUTPUT->LIST[D1.SEQ].ENCNTR_ID
;	, SURG_CASE_ID = OUTPUT->LIST[D1.SEQ].surg_case_id
;	, PERIOP_DOC_ID = OUTPUT->LIST[D1.SEQ].periop_doc_id
;	, FORMS_ACTIVITY_ID = OUTPUT->LIST[D1.SEQ].FORMS_ACTIVITY_ID
;	, DOCUMENTED_DT_TM = OUTPUT->LIST[D1.SEQ].DOCUMENTED_DT_TM
;	, UPDT_CNT = OUTPUT->LIST[D1.SEQ].UPDT_CNT
	 FIN = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].FIN)
	, MRN = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].MRN)
	, PATIENT_NAME = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].PATIENT_NAME)
	, DOS = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].DOS)
	, General_seg_Wound_Class = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].GCDWC)
	, PROCEDURE_Seg_Wound_Class = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].PROCWC)
	, WOUND_CLASS = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].WOUND_CLASS)
	, SURGICAL_ROOM = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].SURGICAL_ROOM)
	, SURGEON = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].SURGEON)
	, HAIR_REMOVAL_BY = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].HAIR_REMOVAL_BY)
	, HAIR_REMOVAL_SITE = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].HAIR_REMOVAL_SITE)
	, SURGICAL_PREP_AREA = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].SURGICAL_PREP_AREA)
	, PREP_AGENTS = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].PREP_AGENTS)
	, PREP_START_TIME = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].PREP_START_TIME)
	, PREP_STOP_TIME = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].PREP_STOP_TIME)
	, PREP_BY = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].PREP_BY)
	, PREP_OUTCOME = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].PREP_OUTCOME)
	, PREOP_ABX_GIVEN = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].PREOP_ABX_GIVEN)
	, PREOP_ABX_TIME_GIVEN = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].PREOP_ABX_TIME_GIVEN)
	, PREOP_ABX_DOSE = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].PREOP_ABX_DOSE)
	, REDOSE_ABX_GIVEN = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].redose_abx_given)
	, REDOSE_ABX_TIME_GIVEN = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].redose_abx_TIME_Given)
	, REDOSE_ABX_DOSE = output->LIST[d1.seq].redose_abx_DOSE
	, ASA = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].ASA)
	, PREOP_DX = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].PREOP_DX)
	, POSTOP_DX = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].POSTOP_DX)
	, PROC_START_TM = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].PROC_START_TM)
	, PROC_END_TM = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].PROC_END_TM)
	, Circulator = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].CASE_ATTENDEE_1)
	;, CASE_ATTENDEE_ROLE = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].Case_Attendee_role)
	, Scrub_Nurse = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].CASE_ATTENDEE_2)
	;, SCRUB_ROLE = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].case_attendee_2_role)
	, GLOVES = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].MSB_GLOVES)
	, REDRAPE = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].MSB_REDRAPE)
	, INSTRUMENT = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].MSB_INSTRUMENT)
	, COMMENTS = SUBSTRING(1, 30, OUTPUT->LIST[D1.SEQ].MSB_COMMENTS)
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(OUTPUT->LIST, 5)))
 
PLAN D1 ;where (textlen(output->LIST[d1.seq].MSB_GLOVES)>0)
order by output->LIST[d1.seq].ENCNTR_ID
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
 
ENDIF
 
 
 
#EXIT_PROGRAM
END
GO
 
