drop program CVICU go
create program CVICU
 
/*
* Purpose: This report is intended to run from ops or explorer menu to query monthly CVICU supporting charge documentation.
* This data saves from the CVICU Time Charges Powerform.
*
* @author stinsley
*
* CR:
*
* Amendment Log:
* Initial Dev: 5/16/2016 @author: STINSLEY
* 001 @stinsley - added more flexible date range logic and > 31 day logic
*/
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start" = "SYSDATE"
	, "End Date" = "SYSDATE" 

with OUTDEV, Start, Enddt
 
;DTAs
DECLARE LONG_STAY_REASON_FT = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"CVICUREASONFORLONGERRECOVERYSTAY"))
DECLARE LONG_STAY = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"CVICURECOVERYOTHERREASON"))
DECLARE PROC_PERF_FT = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"CVICUOTHERPROCEDUREPERFORMED"))
DECLARE PROC_PERFORMED = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"CVICUPROCEDUREPERFORMED"))
DECLARE CVICU_TOT_MINS = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"CVICUTIMECALCULATIONMINUTES"))
DECLARE CVICU_STOP_TM = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"CVICUSTOPTIME"))
DECLARE CVICU_START_TM  = f8 with Constant(uar_get_code_by("DISPLAYKEY",14003,"CVICUSTARTTIME"))
;powerform status codes
DECLARE AUTHVERIFIEDCD = f8 with constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED"))
DECLARE ACTIVECD = f8 with constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE"))
DECLARE MODIFIEDCD = f8 with constant(uar_get_code_by("DISPLAYKEY",8,"MODIFIED"))
;FINs
DECLARE FIN_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",263,"FINPOOL"))
;general codes
DECLARE ACTIVE_STATUS = f8 with constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
DECLARE DCP_FORM_COMP_CD = f8 with constant(uar_get_code_by("DISPLAYKEY",18189,"PRIMARYEVENTID"));9167.00
 
/*
********** change for PROD***********
*/
DECLARE ORG = f8 with constant(2.00);
DECLARE DCP_FORM_REF_ID = f8 with constant(1201225824.00)

 
RECORD output(
1 list[*]
  2 ENCNTR_ID= F8
  2 event_id = f8
  2 FORMS_ACTIVITY_ID =f8
  2 FIN = vc
  2 DOSIN = vc
  2 DOSOUT = vc
  2 DOS = vc
  2 total_MINS = vc
  2 proc_Performed = vc
  2 PROC_PERF_FT = vc
  2 long_Stay = vc
  2 long_Stay_Reason = vc
  2 documented_dt_tm = dq8
  2 Person_id = f8
  2 Location = vc
  2 updt_cnt = i4
1 list_cnt = i4
)
call echoout($start)
call echoout($enddt)
;001 @STINSLEY
if(datetimediff(cnvtdatetime($enddt),cnvtdatetime($start),1,0)> 31)
	SELECT INTO $OUTDEV
	FROM dummyt D
	PLAN D where 1=1
	detail
	col 0 "Report Must be Run for Time Increments of 31 Days or Less "
	WITH NOCOUNTER, SEPARATOR=" ", FORMAT
	GO TO EXIT_PROGRAM

else
/**************************************************************
; DVDev Start Coding
;**************************************************************/
 
	SELECT INTO "NL:"
	FROM
	ORGANIZATION O
	,encounter ee
	,ENCNTR_ALIAS EA
	,DCP_FORMS_ACTIVITY D
	PLAN O
	WHERE o.ORGANIZATION_ID = ORG
	JOIN EE WHERE EE.ORGANIZATION_ID = (O.ORGANIZATION_ID)
	    AND EE.ARRIVE_DT_TM BETWEEN cnvtdatetime($START) AND cnvtdatetime($ENDDT)
	JOIN EA
		WHERE EA.ENCNTR_ID = EE.ENCNTR_ID
		AND EA.ALIAS_POOL_CD IN (FIN_CD)
	JOIN D
		WHERE D.ENCNTR_ID = EE.ENCNTR_ID
		AND D.DCP_FORMS_REF_ID IN (DCP_FORM_REF_ID)
		AND D.ACTIVE_IND = 1
		AND D.FLAGS = 2
		ORDER BY  ea.ENCNTR_ID
	HEAD REPORT
			cnt = 0
		HEAD ea.ENCNTR_ID
			CNT = CNT + 1
		IF(MOD(CNT,10) = 1)
			STAT = ALTERLIST(OUTPUT->LIST, CNT + 9)
		 ENDIF
		detail
 
			OUTPUT->LIST[cnt].FIN = TRIM(EA.ALIAS)
			OUTPUT->LIST[cnt].PERSON_ID = Ee.PERSON_ID
			OUTPUT->list[CNT].ENCNTR_ID = EE.ENCNTR_ID
			OUTPUT->LIST[CNT].FORMS_ACTIVITY_ID = D.DCP_FORMS_ACTIVITY_ID
			OUTPUT->LIST[CNT].ENCNTR_ID = D.ENCNTR_ID
			OUTPUT->LIST[CNT].DOCUMENTED_DT_TM = D.VERSION_DT_TM
			OUTPUT->LIST[CNT].UPDT_CNT = d.updt_cnt
 
 	FOOT REPORT
		STAT = ALTERLIST(OUTPUT->LIST, CNT)
		OUTPUT->LIST_CNT = CNT
	WITH NOCOUNTER
 
 
if(size(output->list,5) >0)
set index = 0
 
SELECT INTO "NL:"
FROM
	DCP_FORMS_ACTIVITY_COMP DFA
	, CLINICAL_EVENT   CE
	, CLINICAL_EVENT   SECTION
	, CLINICAL_EVENT   DTA
 
PLAN DFA
where expand(index, 1, output->list_cnt, dfa.dcp_forms_activity_id, output->list[index].FORMS_ACTIVITY_ID)
	 AND DFA.PARENT_ENTITY_NAME = "CLINICAL_EVENT"
	 AND DFA.component_cd =  DCP_FORM_COMP_CD
JOIN CE WHERE ce.event_id = dfa.parent_entity_id;event ID from the form
	AND CE.VALID_UNTIL_DT_TM > SYSDATE
	AND ce.order_id = 0.0
JOIN SECTION WHERE;walk down the CE hierarchy
	SECTION.PARENT_EVENT_ID = CE.EVENT_ID
	AND SECTION.VALID_UNTIL_DT_TM > SYSDATE
JOIN DTA WHERE	DTA.PARENT_EVENT_ID = SECTION.EVENT_ID
	AND DTA.VALID_UNTIL_DT_TM > SYSDATE
	AND DTA.RESULT_STATUS_CD = AUTHVERIFIEDCD
	HEAD REPORT
	 	POS = 0
		INDEX = 0
		HEAD DTA.event_id
		POS = LOCATEVAL(INDEX, 1, OUTPUT->LIST_CNT,dfa.dcp_forms_activity_id, OUTPUT->LIST[INDEX].FORMS_ACTIVITY_ID)
	DETAIL
	if(DTA.event_id > 0)
	WHILE(POS > 0)
		; MATCH DTAS AND DISPLAY RESULTS
		OUTPUT->LIST[POS].EVENT_ID = DTA.CLINICAL_EVENT_ID
		call echoout(build2("POS: ", POS, "INDEX: ", INDEX))
 
		IF (DTA.TASK_ASSAY_CD = CVICU_START_TM)
		 	OUTPUT->LIST[POS].DOSIN = FORMAT(CNVTDATETIME(CNVTDATE2(SUBSTRING(3,10,DTA.RESULT_VAL),"YYYYMMDD"),
		 	CNVTTIME2(SUBSTRING(11,15,DTA.RESULT_VAL),"HHMM")), ";;Q")
			OUTPUT->LIST[POS].DOS = FORMAT(CNVTDATE2(SUBSTRING(3,10,DTA.RESULT_VAL),"YYYYMMDD"),"DD-MMM-YYYY;;D")
		ELSEIF (DTA.TASK_ASSAY_CD = CVICU_STOP_TM)
		 	OUTPUT->LIST[POS].DOSOUT = FORMAT(CNVTDATETIME(CNVTDATE2(SUBSTRING(3,10,DTA.RESULT_VAL),"YYYYMMDD"),
		 	CNVTTIME2(SUBSTRING(11,15,DTA.RESULT_VAL),"HHMM")), ";;Q")
		ELSEIF (DTA.TASK_ASSAY_CD = CVICU_TOT_MINS)
			 OUTPUT->LIST[POS].TOTAL_MINS = DTA.RESULT_VAL
		ELSEIF (DTA.TASK_ASSAY_CD = PROC_PERFORMED)
			 OUTPUT->LIST[POS].PROC_PERFORMED = substring(0,255,DTA.RESULT_VAL)
		ELSEIF(DTA.TASK_ASSAY_CD = PROC_PERF_FT)
	         OUTPUT->LIST[POS].PROC_PERF_FT = substring(0,255,DTA.RESULT_VAL)
		ELSEIF(DTA.TASK_ASSAY_CD = LONG_STAY)
			 OUTPUT->LIST[POS].LONG_STAY = substring(0,255,DTA.RESULT_VAL)
		ELSEIF(DTA.TASK_ASSAY_CD = 	LONG_STAY_REASON_FT)
			 OUTPUT->LIST[POS].LONG_STAY_REASON = substring(0,255,DTA.RESULT_VAL)
		ENDIF
		;pos++
		pos = locateval(index, pos+1,output->list_cnt , DFA.dcp_forms_activity_id, OUTPUT->LIST[INDEX].FORMS_ACTIVITY_ID)
	Endwhile
	endif
		WITH NOCOUNTER, EXPAND = 1
 
 
endif
 
	SELECT into $outdev
	 
	    FIN = OUTPUT->list[D1.SEQ].FIN
		, DOSIN = OUTPUT->list[D1.SEQ].DOSIN
		, DOSOUT = OUTPUT->list[D1.SEQ].DOSOUT
		, DOS = OUTPUT->list[D1.SEQ].DOS
		, TOTAL_MINS = OUTPUT->list[D1.SEQ].total_MINS
		, PROC_PERFORMED = substring(0,255,OUTPUT->list[D1.SEQ].proc_Performed)
		, PROC_PERF_FT = substring(0,255,OUTPUT->list[D1.SEQ].PROC_PERF_FT)
		, LONG_STAY_REASON = substring(0,255,OUTPUT->list[D1.SEQ].long_Stay_Reason)
		, LONG_STAY_FT = substring(0,255,OUTPUT->list[D1.SEQ].long_Stay)
	 
	FROM
		(DUMMYT   D1  WITH SEQ = VALUE(SIZE(OUTPUT->list, 5)))
	 
	PLAN D1
	order by PROC_PERFORMED, DOS
	WITH NOCOUNTER, SEPARATOR=" ", FORMAT
endif ;end of date constraint

/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
SUBROUTINE EchoOut(echo_str)
 
  call echo(concat(echo_str,"  @",format(cnvtdatetime(curdate,curtime3),"MM/DD/YYYY HH:MM:SS;;D")))
 
END ;EchoOut
#EXIT_PROGRAM ;001
SET LAST_MOD = "@STINSLEY - VERSION 1.1  - 06/07/16"
 
CALL ECHO (LAST_MOD)
 
end
go
 
