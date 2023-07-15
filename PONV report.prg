/*****************************************************************************************************************
File Name       : PONV_RPT

******************************************************************************************************************
                       REVISION HISTORY
Mod Date       By      		CM#         Comment
--- ---------- ------- 		--------- -------------------------------------------------------------------------------
001 2016 Steve Tinsley   34082    	Initial Development \m/
 
 
******************************************************************************************************************/
 
drop program 7_SN_PONV_RPT go
create program 7_SN_PONV_RPT
 
prompt
	"Output to:" = "MINE"                             ;* Enter or select the printer or file name to send this report to.
	, "Scheduled From:" = "SYSDATE"
	, "To:" = "SYSDATE"
	, "Facility:" = 0                                 ;* Entity
	, "Surgical Area:" = VALUE(0                  )   ;* Surgical Area Service Resource
	, "Surgeon:" = 0                                  ;* None selected = *ALL
 
with OUTDEV, dtBeg, dtEnd, dFac, dArea, dSurg
/*
Date - proc date
Patient name
Age
Sex
Medical Record Number
FIN
DOB
BMI
Surgeon
Case type
PATIENT TYPE
Drugs
Drug from list/Nurse/time-specific meds	MAR
	Promethazne, Promethazine, Ondansetron, Metoclopramide
*/
 
 
 
 
 
;-- Lib for prompts and utilities
 
%i cust_script:1_std_rpt_prompt.inc
%i cust_script:1_std_rpt_util.inc
 
 
;Record structs
 
;-- To faciliate filtering by surgical area
free record rSA
record rSA(
    1 cnt               = i4
    1 arr               [ * ]
        2 num           = f8
        2 txt           = vc
        2 disp          = vc
        2 descr         = vc
)
;main output struct
record output(
1 list[*]
	;case nfo
	2 dSCId 		= f8
    2 dSEId 		= f8
    2 dEId 			= f8
    2 dPId 			= f8
    2 AnesType		= VC
    2 admitDate		= VC
    2 encntrType	= VC
    2 dSARID		= f8
    2 ANESTHESIOLOGIST = vc
    ;patient nfo
	2 sProcDate 	= vc
	2 sPatName    	= vc
	2 sPatAge     	= vc
	2 sPatSex     	= vc
	2 sPatMrn     	= vc
	2 sPatFin     	= vc
	2 sPatDob     	= vc
	2 sPatBmi     	= vc
	2 sPatSurgeon 	= vc
	2 sPatCaseTyp 	= vc
	2 sPatCaseAddOn = vc
	2 sPattyp	  	= vc
	;med nfo
	2 sMedsGiven  	= vc
	2 sMedDose		= vc
	2 sNurse	  	= vc
	2 sMedTimeGvn 	= vc
	2 origOrder 	= vc
	2 origOrderBy	= vc
	;times pacu for future use
	2 sPacuStart  	= vc
	2 sPacuStop	  	= vc
	2 sSurgStart  	= vc
	2 sSurgStop	  	= vc
	;rando troubleshooting data
	2  dsurga = f8
	2  dsurgo = f8
)
; set output->list[1].dsurga = $dArea
; set output->list[1].dsurgo = $dFac
;Var Decs
set rDpb->any_field = "0" ;set any to 0 not *
declare bAnyFac     = I1 with protect, constant( isDpbAny( Parameter2( $dFac )))
declare bAnySA      = I1 with protect, constant( isDpbAny( Parameter2( $dArea )))
declare bAnySurg    = I1 with protect
declare index = i4 with noconstant(0)
declare anes_attending = f8 with constant(uar_get_code_by("DISPLAYKEY",254571,"ATTENDINGANESTHESIOLOGIST"))
DECLARE FIN_CD = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",263,"FIN"))
DECLARE MRN_CD = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",4,"MRN"))
DECLARE AUTHVERIFIEDCD = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",8,"AUTHVERIFIED"))
DECLARE ACTIVECD = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",8,"ACTIVE"))
DECLARE MODIFIEDCD = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",8,"MODIFIED"))
DECLARE ACTIVE_STATUS = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",48,"ACTIVE"))
DECLARE DCP_FORM_COMP_CD = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",18189,"PRIMARYEVENTID"))
DECLARE DCP_FORM_REF_ID = F8 WITH CONSTANT(760864787.00);PACU OSA Stop Bang section/form for BMI(need to change for PROD!!!)
DECLARE dBMI = f8 with CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",14003,"BODYMASSINDEX"))
declare PrimarySurgeonCd = f8 with constant(uar_get_code_by("DISPLAYKEY",10170,"SURGEONPRIMARY"))
declare otherSurgeonCd = f8 with constant(uar_get_code_by("DISPLAYKEY",10170,"SURGEONOTHER"))
declare VisitingSurgeonCd = f8 with constant(uar_get_code_by("DISPLAYKEY",10170,"SURGEONVISITING"))
declare firstAssistCd = f8 with constant(uar_get_code_by("DISPLAYKEY",10170,"ASSISTANTFIRST"))
declare secondAssistCd = f8 with constant(uar_get_code_by("DISPLAYKEY",10170,"ASSISTANTSECOND"))
declare AssistantSurgeonCd = f8 with constant(uar_get_code_by("DISPLAYKEY",10170,"ASSISTANTSURGEON"))
declare dSurgArea = f8 with constant(uar_get_code_by("DisplayKey",223,"SURGICALAREA"))
declare bPaes       = i1 with protect, constant( 0 ) ;indicates Paes option, should be 0 for now
 ;Body Mass Index	from iview     task assay = 705278.00	     event cd = 705277.00
 
if( reflect( parameter( 5, 0 )) in( "F8", "I4" ))
    if( cnvtreal( parameter( 5, 1 )) = 0.0 )
        set bAnySurg = 1
    endif
else
    set bAnySurg = 1
endif
 
declare sPFac   = vc with protect
declare sPArea  = vc with protect, noconstant( "Any (*)" )
declare sPSurg  = vc with protect, noconstant( "Any (*)" )
 
set sPFac = Replace( getCvDesc( Trim( getDpbList( Parameter2( $dFac ), ^^ ), 3 )), ",", " or", 2 )
if( not bAnySA ) set sPArea = Replace( getCvDisp( Trim( getDpbList( Parameter2( $dArea ), ^^ ), 3 )), ",", " or", 2 ) endif
if( not bAnySurg ) set sPSurg = Replace( getFullName( Trim( getDpbList( Parameter2( $dSurg ), ^^ ), 3 )), ",", " or", 2 ) endif
 
 
call echo (build2("Fac:", $dFac, " dAreacd: ", $dArea, " dsurgAreacd: ", dSurgArea, " sPArea: ", sPArea, " ", spFac))
 
;-- -------------------
;-- Supplemental Record Population ; Pre Main Query ;
;-- -------------------
;Populate records to facilitate index on main data retrieval
 
;----------------------------------
;-- Surgical Areas
;--
select  into "nl:"
from    location                    l
,       service_resource            sr
,       resource_group              rg
,       code_value                  cv
 
plan    l
where   l.location_cd               =   $dFac
 
join    sr
where   sr.organization_id          =   l.organization_id
and     sr.service_resource_type_cd =   dSurgArea
and     sr.active_ind               =   1
 
join    rg
where   rg.child_service_resource_cd=   sr.service_resource_cd
and     rg.active_ind               =   1
 
join    cv
where   cv.code_value               =   rg.child_service_resource_cd
and (   cv.code_value               =   $dArea
    or  bAnySA                      =   1
    )
and     cv.active_ind               =   1
and     cv.end_effective_dt_tm      >   SysDate
and     cv.begin_effective_dt_tm    <   SysDate
 
;and (   (   bPaes!= 0 and bPaes          !=   1 )
;    or  (   bPaes = 0 and cv.display_key !=   "*PAES*" )
;    or  (   bPaes = 1 and cv.display_key  =   "*PAES*" )
;    )
;
order   cv.description
 
head    report
        nCnt = 0
detail
        nCnt = nCnt + 1
        if( mod( nCnt, 10 ) = 1 )
            stat = alterlist( rSA->arr, nCnt + 9 )
        endif
 
        rSA->arr[ nCnt ].num    = cv.code_value
        rSA->arr[ nCnt ].disp   = cv.display
        rSA->arr[ nCnt ].descr  = cv.description
        if( cv.display != cv.description )
            rSA->arr[ nCnt ].txt= concat( cv.display, " (", cv.description, ")" )
        else
            rSA->arr[ nCnt ].txt= cv.display
        endif
 
foot    report
        stat = alterlist( rSA->arr, nCnt )
        rSA->cnt = nCnt
 
with    nocounter
;call echorecord( rSA )
 
set index = 0
;MAIN QUERY;
 
select ;into "NL:"
	if(size(rsa->arr,5)>0)
	into "NL:"
plan sc where sc.surg_start_dt_tm between cnvtdatetime($dtBeg) and cnvtdatetime($dtEnd)
	and EXPAND( index, 1, size(rSa->arr,5), sc.sched_surg_area_cd, rSA->arr[index].num )
	and (sc.surgeon_prsnl_id = $dSurg or bAnySurg = 1 )
	and sc.active_ind = 1
join p where p.person_id = sc.surgeon_prsnl_id ;primary scheduled
	and p.active_ind = 1
	and p.active_status_cd in (ACTIVE_STATUS)
join se where se.sch_event_id = sc.sch_event_id
join sar where sar.surgical_case_id = outerjoin(sc.surg_case_id)
	elseif(size(rsa->arr,5) = 0)
	into "NL:"
plan sc where sc.surg_start_dt_tm between cnvtdatetime($dtBeg) and cnvtdatetime($dtEnd)
	;and EXPAND( index, 1, size(rSa->arr,5), sc.sched_surg_area_cd, rSA->arr[index].num )
	and (sc.surgeon_prsnl_id = $dSurg or bAnySurg = 1 )
	and sc.active_ind = 1
join p where p.person_id = sc.surgeon_prsnl_id ;primary scheduled
	and p.active_ind = 1
	and p.active_status_cd in (ACTIVE_STATUS)
join se where se.sch_event_id = sc.sch_event_id
join sar where sar.surgical_case_id = outerjoin(sc.surg_case_id)
endif
 
	from
	surgical_case sc
	,prsnl p
	,sch_event se
	,sa_anesthesia_record sar
 
HEAD REPORT
	CNT = 0
	head sc.encntr_id
	CNT = CNT + 1
		IF(MOD(CNT,10) = 1)
			STAT = ALTERLIST(OUTPUT->LIST, CNT + 9)
		 ENDIF
	DETAIL
	output->list[cnt].dSEId = sc.sch_event_id
	output->list[cnt].dEId = sc.encntr_id
	output->list[cnt].dSCId =sc.surg_case_id
	output->list[cnt].dPId = sc.person_id
	output->list[cnt].dSARID = sar.sa_anesthesia_record_id
	output->list[cnt].sProcDate = if((sc.surg_start_dt_tm)>cnvtdatetime(0,0)) format(sc.surg_start_dt_tm, "DD-MMM-YYYY")
								  else format(sc.sched_start_dt_tm, "DD-MMM-YYYY") endif
	output->list[cnt].sPattyp = UAR_GET_CODE_DISPLAY(sc.pat_type_cd)
	output->list[cnt].sPatCaseTyp = uar_GET_CODE_DISPLAY(SC.case_level_cd)
	output->list[cnt].sPatCaseAddon = if(sc.add_on_ind > 0) "Add On Case" else "Not Add On Case" endif
	output->list[cnt].sSurgStart = format(sc.surg_start_dt_tm, ";;q")
	output->list[cnt].sSurgStop = format(sc.surg_stop_dt_tm, ";;q")
 	output->list[cnt].sPatSurgeon = trim(p.name_full_formatted)
 	output->list[cnt].AnesType = Trim(uar_get_code_display(sc.anesth_type_cd))
 
 
 	foot report
 		stat = ALTERLIST(OUTPUT->LIST, CNT)
 
with nocounter, expand =1
 
 

set index = 0
select into "NL:"
from
orders o
,clinical_event ce
,ce_med_result cmr
, prsnl p
, prsnl p1
plan o
where expand(index,1,size(output->list,5),o.encntr_id,output->list[index].dEId) ;grab all orders on the encounter
and o.catalog_cd in (2767590.00, 2765642.00, 2763400.00);specific meds.
join ce where ce.order_id = o.order_id
join cmr where cmr.event_id = ce.event_id
	and cmr.infused_volume > 0 
join p where p.person_id = ce.performed_prsnl_id
join p1 where p1.person_id = o.active_status_prsnl_id
order by o.encntr_id
HEAD REPORT
			CNT = 0
			POS = 0
			INDEX = 0
		HEAD ce.event_id
		POS = LOCATEVAL(INDEX, 1, SIZE(OUTPUT->LIST,5),o.ENCNTR_ID, OUTPUT->LIST[INDEX].dEId)
		DETAIL
 		WHILE(POS > 0)
 			;maybe do substring() logic for med dosages find the decimal and trunk to the hundredths?
 			;then figure out wth is up the the units...
 			output->list[pos].sMedDose = build2(output->list[pos].sMedDose,^;^,cnvtstring(cmr.infused_volume),^ ^,
 			uar_get_code_display(cmr.infused_volume_unit_cd))
			OUTPUT->LIST[POS].sMedsGiven = build2(OUTPUT->LIST[POS].sMedsGiven,^;^,uar_get_code_display(ce.catalog_cd))
			OUTPUT->LIST[POS].sMedTimeGvn =
			build2(OUTPUT->LIST[POS].sMedTimeGvn,^;^,format(cmr.admin_start_dt_tm,"DD-MMM-YYYY HH:MM"))
 			output->list[pos].sNurse = trim(p.name_full_formatted)
 			output->list[pos].origOrder = trim(o.clinical_display_line)
 			output->list[pos].origOrderBy = (p1.name_full_formatted)
		POS = LOCATEVAL(INDEX, POS+1, SIZE(OUTPUT->LIST,5),o.ENCNTR_ID, OUTPUT->LIST[INDEX].dEId)
		ENDWHILE
WITH NOCOUNTER, EXPAND = 1


	/*get rid of the first ^;^ */
 	for(xx=1 to size(output->list,5))
 		set output->list[xx].sMedDose = trim(trim(replace(OUTPUT->LIST[xx].sMedDose, ";", " ", 1), 3), 10)
 		set output->list[xx].sMedsGiven = trim(replace(OUTPUT->LIST[xx].sMedsGiven, ";", " ", 1), 3)
 		set OUTPUT->LIST[xx].sMedTimeGvn =  trim(replace(OUTPUT->LIST[xx].sMedTimeGvn, ";", " ", 1), 3)
 	endfor
 	
 	
 	
 	
/*GET DTA RESPONSES FROM POWERFORM*/
 SET INDEX = 0
;SX ENCNTRS WITH FORMS
SELECT INTO "NL:"
	FROM
	 DCP_FORMS_ACTIVITY D
	, DCP_FORMS_ACTIVITY_COMP DFA
	, CLINICAL_EVENT   CE
	, CLINICAL_EVENT   SECTION
	, CLINICAL_EVENT   DTA
 
Plan D where EXPAND(INDEX,1,SIZE(OUTPUT->LIST,5),D.ENCNTR_ID, OUTPUT->LIST[INDEX].dEId)
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
		POS = LOCATEVAL(INDEX, 1, SIZE(OUTPUT->LIST,5),D.ENCNTR_ID, OUTPUT->LIST[INDEX].dEId)
		DETAIL
 		WHILE(POS > 0)
 
			;--DTAS FROM THE POWERFORM
			IF(DTA.TASK_ASSAY_CD = dBMI)
			OUTPUT->LIST[POS].sPatBmi = Trim(build2(DTA.RESULT_VAL, " ",UAR_GET_CODE_DISPLAY(DTA.result_units_cd)), 10)
			ENDIF
 
 
			POS = LOCATEVAL(INDEX, POS+1, SIZE(OUTPUT->LIST,5),D.ENCNTR_ID, OUTPUT->LIST[INDEX].dEId)
			ENDWHILE
WITH NOCOUNTER, EXPAND = 1
 
select into "NL:"
from
clinical_event ce
where EXPAND(INDEX,1,SIZE(OUTPUT->LIST,5),ce.ENCNTR_ID, OUTPUT->LIST[INDEX].dEId)
	and ce.event_cd in (705277.00) ; iview calculated BMI
 	HEAD REPORT
			CNT = 0
			POS = 0
			INDEX = 0
		HEAD ce.encntr_id
		POS = LOCATEVAL(INDEX, 1, SIZE(OUTPUT->LIST,5),ce.ENCNTR_ID, OUTPUT->LIST[INDEX].dEId)
		DETAIL
 		WHILE(POS > 0)
 
			;--DTAS FROM THE POWERFORM
 
			OUTPUT->LIST[POS].sPatBmi = Trim(build2(ce.RESULT_VAL, " ",UAR_GET_CODE_DISPLAY(ce.result_units_cd)), 10)
 
		POS = LOCATEVAL(INDEX, POS+1, SIZE(OUTPUT->LIST,5),ce.ENCNTR_ID, OUTPUT->LIST[INDEX].dEId)
		ENDWHILE
WITH NOCOUNTER, EXPAND = 1
/*
*
* FETCH MRN AND PERSON DATA
*
*/
 
SET INDEX = 0
;--MRN
SELECT INTO "NL:"
FROM PERSON P,
PERSON_ALIAS PA
PLAN P WHERE EXPAND(INDEX, 1, SIZE(OUTPUT->LIST,5),P.PERSON_ID,OUTPUT->LIST[INDEX].DPID)
AND P.ACTIVE_IND = 1 AND P.ACTIVE_STATUS_CD IN (ACTIVE_STATUS)
JOIN PA WHERE PA.PERSON_ID = P.PERSON_ID
	AND PA.ACTIVE_IND = 1 AND PA.ACTIVE_STATUS_CD IN (ACTIVE_STATUS)
	AND PA.person_alias_type_cd IN (MRN_CD)
	HEAD REPORT
 
			POS = 0
			INDEX = 0
		HEAD P.PERSON_ID
		POS = LOCATEVAL(INDEX, 1, SIZE(OUTPUT->LIST,5),P.PERSON_ID, OUTPUT->LIST[INDEX].DPID)
		DETAIL
 		WHILE(POS > 0 )
			OUTPUT->LIST[POS].SPATNAME = TRIM(P.NAME_FULL_FORMATTED)
			OUTPUT->LIST[POS].SPATMRN = TRIM(PA.ALIAS)
			OUTPUT->LIST[POS].SPATAGE = CNVTAGE(P.BIRTH_DT_TM)
			OUTPUT->LIST[POS].SPATSEX = UAR_GET_CODE_DISPLAY(P.SEX_CD)
 			output->list[pos].sPatDob = format(p.birth_dt_tm, "DD-MMM-YYYY")
		POS = LOCATEVAL(INDEX, POS+1, SIZE(OUTPUT->LIST,5),P.PERSON_ID, OUTPUT->LIST[INDEX].DPID)
		ENDWHILE
WITH NOCOUNTER, EXPAND = 1
 
 
/*GET FIN*/
SET INDEX= 0
SELECT INTO "NL:"
FROM
	ENCNTR_ALIAS EA
PLAN EA WHERE EXPAND(INDEX, 1, SIZE(OUTPUT->LIST,5),EA.ENCNTR_ID,OUTPUT->LIST[INDEX].DEID)
AND EA.ALIAS_POOL_CD IN (FIN_CD)
HEAD REPORT
	POS = 0
	II = 0
HEAD EA.ENCNTR_ID
POS = LOCATEVAL(II, 1, SIZE(OUTPUT->LIST,5), EA.ENCNTR_ID, OUTPUT->LIST[II].DEID)
DETAIL
	WHILE(POS > 0)
 
		OUTPUT->LIST[POS].SPATFIN = TRIM(EA.ALIAS)
 
		POS = LOCATEVAL(II, POS+1, SIZE(OUTPUT->LIST,5), EA.ENCNTR_ID, OUTPUT->LIST[II].DEID)
	ENDWHILE
WITH NOCOUNTER, EXPAND = 1

    /*
	*
	* Get Anes PRSNL times and names from the Anes record if there is one and replace the existing from
	* case attendance
	* logic to get the last attending on the case
	*
	*/
	set index = 0
 
		SELECT into "NL:"
		FROM
		sa_prsnl_activity spa
		,(
		(select
		max(spat.start_dt_tm), sp.prsnl_id,
		sp.sa_anesthesia_record_id, sp.sa_prsnl_activity_id,
		p.name_first, p.name_last
		from
		sa_prsnl_activity sp
		,sa_prsnl_activity_time spat
		,prsnl p
		where EXPAND(INDEX,1,SIZE(output->list,5),sp.SA_ANESTHESIA_RECORD_ID, output->list[index].dSARID)
		and sp.prsnl_activity_type_cd in (ANES_ATTENDING)
		and sp.active_ind =1 and sp.active_status_cd = (active_status)
		and spat.sa_prsnl_activity_id = spat.sa_prsnl_activity_id
		and spat.active_ind =1
		and spat.active_status_cd in (active_status)
		and p.person_id = sp.prsnl_id
		group by p.person_id, sp.prsnl_id, sp.sa_anesthesia_record_id, sp.sa_prsnl_activity_id,p.name_first, p.name_last
		with sqltype("dq8", "F8", "F8", "F8", "c30", "c30")) spa1
		)
		where spa.sa_anesthesia_record_id = spa1.sa_anesthesia_record_id
		and spa.sa_prsnl_activity_id = spa1.sa_prsnl_activity_id
		and spa.prsnl_id = spa1.prsnl_id
		HEAD REPORT
		    POS = 0
		    INDEX = 0
		head spa.sa_anesthesia_record_id
		POS = LOCATEVAL(INDEX, 1, SIZE(output->list,5), spa.SA_ANESTHESIA_RECORD_ID ,output->list[index].dSARID)
		DETAIL
		WHILE(POS > 0)
			output->list[pos].ANESTHESIOLOGIST = TRIM(BUILD2(SUBSTRING(1,1,spa1.NAME_FIRST)," ",SUBSTRING(1,9,spa1.NAME_LAST)),1)
		 POS = LOCATEVAL(INDEX, POS+1,SIZE(output->list,5), spa.SA_ANESTHESIA_RECORD_ID , output->list[index].dSARID)
		ENDWHILE
 		with nocounter, expand = 1



 call echorecord(output)
 
if(size(output->list,5)>0)
SELECT into $Outdev
;		output->list[1].dsurgo
;	  ,output->list[1].dsurga,
	  PROCDATE = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].sProcDate)
	, PATNAME = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].sPatName)
	, PATAGE = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].sPatAge)
	, PATSEX = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].sPatSex)
	, PATMRN = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].sPatMrn)
	, PATFIN = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].sPatFin)
	, PATDOB = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].sPatDob)
	, PATBMI = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].sPatBmi)
	, PATSURGEON = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].sPatSurgeon)
	, PATCASETYP = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].sPatCaseTyp)
	, PATCASEADDON = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].sPatCaseAddOn)
	, PATTYP = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].sPattyp)
	, MEDSGIVEN = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].sMedsGiven)
	, MEDTIMEGVN = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].sMedTimeGvn)
	, AdminDose = output->list[d1.seq].sMedDose
	, AdminNurse = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].sNurse)
	, OrderSentence = SUBSTRING(1, 255,trim(output->list[d1.seq].origOrder,3))
	, OrigOrderBy = SUBSTRING(1, 30,output->list[d1.seq].origOrderBy)
	, AnesProv = SUBSTRING(1, 30,output->list[d1.seq].ANESTHESIOLOGIST)
	;, PACUSTART = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].sPacuStart)
	;, PACUSTOP = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].sPacuStop)
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(OUTPUT->list, 5)))
PLAN D1
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 else
;#EXIT_SCRIPT
;
	Select into $OUTDEV
	from
	dummyt dt
	detail
		col 0 "No Data Retrieved for specified Criteria"
		row +1
endif
end
go
 