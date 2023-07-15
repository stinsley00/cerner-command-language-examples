drop program 7_sn_field_level_audit:GROUP1 go
create program 7_sn_field_level_audit:GROUP1
 
prompt
	"Output to:" = "MINE"                                        ;* Enter or select the printer or file name to send this report t
	, "Scheduled From:" = CURDATE
	, "To:" = CURDATE
	, "Facility:" = 0                                            ;* Entity
	, "Surgical Area:" = VALUE(0                  )              ;* Surgical Area Service Resource
	, "Room / Suite:" = VALUE(0                        )         ;* Room.
	, "Specialty (Procedure Default):" = VALUE(0             )
	;<<hidden>>"Pre-Filter Personnel Groups:" = "*"
	, "Physician Group:" = VALUE(0)
	, "Surgeons:" = 0                                            ;* None selected = *ALL
 
with OUTDEV, dtBeg, dtEnd, dFac, dArea, dRm, dSpec, dPrGrp, dSurg
 
;-- Lib for prompts and utilities
 
%i cust_script:1_std_rpt_prompt.inc
%i cust_script:1_std_rpt_util.inc
 
;Get values from any and all parameters
Set rVar->ret_stat = getDpbValsIn( 0, 0 )
 
 
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

record dtas(
	1 cnt 				= i4
	1 list 				[*]
		2 cv			= f8
		2 description   = vc
) 
 
;-- Main data record
record rData(
  1 item[*]
    2 bKeep = i1
    2 dSCId = f8
    2 dSEId = f8
    2 dEId = f8
    2 dPId = f8
 
    2 sName = vc
    2 sFIN = vc
    2 sMRN = vc
    2 sDOB = c10
    2 sAge = vc
    2 sSex = vc
    2 sPatType = vc
    2 sFac = vc
    2 sArea = vc
    2 sRoom = vc
 
    2 dtSchedStart  = dq8
    2 dtSchedEnd    = dq8
 
    ;- Case Times
    2 dtSurgStart   = dq8
    2 dtSurgStop    = dq8
    2 dtInRoom      = dq8
    2 dtOutRoom     = dq8
 
    ;- Track Events
    2 dtSgnVst      = dq8 ;Surgeon Checkin SPA
    2 dtSgnStart    = dq8 ;Surgeon Start
    2 dtSgnStop     = dq8 ;Surgeon Stop
    2 dtAnsVst      = dq8 ;Anesthesia Checkin SPA
    2 dtAnsStart    = dq8 ;Anesthesiologist Start
    2 dtAnsStop     = dq8 ;Anesthesiologist Stop
    2 dtOrRnVst     = dq8 ;OR RN to SPA
    2 sSchedProc = vc
    2 sActualProc = vc
    2 dSrgSpec = f8
    2 sSrgSpec = vc
    2 dPrGrp = f8
    2 sPrGrp = vc
    2 dSurgeon1ID = f8
    2 sSurgeon1 = vc
    2 sSurgeon2ID = vc
    2 sSurgeon2 = vc
    2 sAnesth = vc
    2 sAnesType = vc ;Anesthesia Type (from pri proc of periop doc)
    2 sProcService = vc ;scheduled proc service
    2 sProcServCAS = vc ;nurse documented procedure service
    2 sSignedBy = vc
    2 sDocStatus = vc
    2 sCaseType = vc
    2 sPreOpDx = vc
    2 sWoundClass = vc
    2 sComm = vc
    2 sCancelReas = vc
 	2 sPatRoomNum = vc ; 008 added pat rm num
    2 sScrub = vc
    2 sCirculator = vc
    2 sCaseNum = vc
    2 sCaseLvlIn = vc
    2 sCaseLvlOut = vc
	;Audit results for display
	2 OVAVAILABILITYVERIFIEDIFAPPL			=vc
	2 OVCORRECTPROCEDURESITEVERIF            = vc
	2 OVDISCONTINUEREADONLYMSG               = vc
	2 OVOUTCOMEMETO                        = vc
	2 OVPATIENTIDENTITYVERIFIED              = vc
	2 OVRELEVANTIMAGESAVAILABLEAND           = vc
	2 PDADDCOMMENT                           = vc
	2 PDCATALOGNUMBER                        = vc
	2 PDCULTURED                      		 = vc
	2 PDDESCRIPTION                          = vc
	2 PDEXPIRATIONDATE                       = vc
	2 PDIMPLANTSITE                          = vc
	2 PDIMPLANTEDBY                   		 = vc
	2 PDLOTNUMBER                            = vc
	2 PDMANUFACTURER                         = vc
	2 PDOUTCOMEMETO30                        = vc
	2 PDQUANTITY                             = vc
	2 PDSERIALNUMBER		                 = vc
	2 PDSITE                                 = vc
	2 PDSIZE                                 = vc
	2 PDUDI                                  = vc
	2 TOCORRECTLATERALITYVISIBLESIT          = vc
	2 TOCORRECTPATIENT                       = vc
	2 TOCORRECTPOSITONANDSITE                = vc
	2 TOCORRECTPROCEDURE                     = vc
	2 TODISCONTINUEREADONLYMSG               = vc
	2 TOOUTCOMEMETO30                        = vc
	2 TOPROCEDURETIMEOUTCOMMENTS             = vc
	2 TORELEVANTIMAGESREVIEWEDANDD           = vc
	2 TOTIMEOUTDESCRIPTION                   = vc
	2 TOTIMEOUTTIME                          = vc
	2 PROCADDITIONALPROCEDUREDETAIL          = vc
	2 PROCMODIFIERS                          = vc
	2 PROCOUTCOMEMETO730                     = vc
	2 PROCPRIMARYPROCEDURE                   = vc
	2 PROCPROCEDURECODE                      = vc
	2 PROCSTARTTIME                          = vc
	2 PROCSTOPTIME                           = vc
	2 GCDOUTCOMEMETO320                      = vc
	2 GCDPREOPDIAGNOSIS                      = vc
	2 GCDWOUNDCLASSDESCRIPTION               = vc
	2 TIACQUISITIONDATE                      = vc
	2 TIANTIBIOTICDOSE                       = vc
	2 TIANTIBIOTICLOTNUMBER                  = vc
	2 TIANTIBIOTICSERIALNUMBER               = vc
	2 TICATALOGNUMBER                        = vc
	2 TIDESCRIPTION                          = vc
	2 TIEXPIRATIONDATE                       = vc
	2 TIIMPLANTCOMMENT                       = vc
	2 TIIMPLANTSITE                          = vc
	2 TIPREPARATIONCOMMENTS                  = vc
	2 TIPREPARATIONDATE                      = vc
	2 TIPREPARATIONMETHOD                    = vc
	2 TIPREPARATIONTIME                      = vc
	2 TIPREPAREDACCORDINGTOINSTRUCT          = vc
	2 TIPREPAREDBY                           = vc
	2 TIQUANTITY                             = vc
	2 TIRESPONSIBLESTAFF                     = vc
	2 TISOLUTION                             = vc
	2 TISOLUTIONEXPIRATIONDATE               = vc
	2 TISOLUTIONLOTNUMBER                    = vc
	2 TISOLUTIONVOLUME                       = vc
	2 TISTORAGELOCATION                      = vc
	2 TITISSUEANTIBIOTIC                     = vc
	2 TITISSUEEXPIRATIONDATE                 = vc
	2 TITISSUELOTNUMBER                      = vc
	2 TITISSUEREHYDRATIONTIME                = vc
	2 TITISSUESERIALNUMBER                   = vc
	2 TITISSUESIZE                           = vc
	2 TITISSUETYPE                           = vc
	2 TIUNIQUEID                             = vc
	)
 
 
declare bNoData     = i1 with protect, noconstant( 1 )
declare bCont       = i1 with protect, noconstant( 0 )
declare dSurgArea   = f8 with protect, constant( uar_get_code_by("DISPLAYKEY", 223, "SURGICALAREA"))
declare bPaes       = i1 with protect, constant( 0 ) ;indicates Paes option, should be 0 for now
declare dInRoom     = f8 with protect, constant( uar_get_code_by("DISPLAYKEY", 14003, "SN - CTM - PATIENT - IN ROOM TIME"))
declare dOutRoom    = f8 with protect, constant( uar_get_code_by("MEANING", 14003, "CT-PATOUTRM"))
declare dSurgStart  = f8 with protect, constant( uar_get_code_by("DISPLAYKEY", 14003, "SNCTMSURGERYSTARTTIME"))
declare dSurgEnd    = f8 with protect, constant( uar_get_code_by("DISPLAYKEY", 14003, "SN - CTM - SURGERY - STOP TIME"))
declare nFinalCnt   = i4 with protect, noconstant( 0 )
declare nCnt        = i4 with protect, noconstant( 0 )
declare n           = i4 with protect, noconstant( 0 )
declare n2          = i4 with protect, noconstant( 0 )
declare dtBeg       = dq8 with protect, constant( cnvtdatetime(cnvtdate($dtBeg), 0))
declare dtEnd       = dq8 with protect, constant( cnvtdatetime(cnvtdate($dtEnd), 235959))
declare SNOVAVAILABILITYVERIFIEDIFAPPL = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNOVAVAILABILITYVERIFIEDIFAPPL"))
declare SNOVCORRECTPROCEDURESITEVERIF = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNOVCORRECTPROCEDURESITEVERIF"))
declare SNOVDISCONTINUEREADONLYMSG = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNOVDISCONTINUEREADONLYMSG"))
declare SNOVOUTCOMEMETO = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNOVOUTCOMEMETO30"))
declare SNOVPATIENTIDENTITYVERIFIED = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNOVPATIENTIDENTITYVERIFIED"))
declare SNOVRELEVANTIMAGESAVAILABLEAND = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNOVRELEVANTIMAGESAVAILABLEAND"))
declare SNPDADDCOMMENT = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNPDADDCOMMENT"))
declare SNPDCATALOGNUMBER = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNPDCATALOGNUMBER"))
declare SNPDCULTURED = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SN*PD*CULTURED"))
declare SNPDDESCRIPTION = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNPDDESCRIPTION"))
declare SNPDEXPIRATIONDATE = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNPDEXPIRATIONDATE"))
declare SNPDIMPLANTSITE = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNPDIMPLANTSITE"))
declare SNPDIMPLANTEDBY = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SN*PD*IMPLANTED*BY"))
declare SNPDLOTNUMBER = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNPDLOTNUMBER"))
declare SNPDMANUFACTURER = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNPDMANUFACTURER"))
declare SNPDOUTCOMEMETO30 = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNPDOUTCOMEMETO30"))
declare SNPDQUANTITY = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNPDQUANTITY"))
declare SNPDSERIALNUMBER = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SN*PD*SERIAL*NUMBER"))
declare SNPDSITE = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNPDSITE"))
declare SNPDSIZE = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNPDSIZE"))
declare SNPDUDI = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNPDUDI"))
declare SNTOCORRECTLATERALITYVISIBLESIT = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTOCORRECTLATERALITYVISIBLESIT"))
declare SNTOCORRECTPATIENT = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTOCORRECTPATIENT"))
declare SNTOCORRECTPOSITONANDSITE = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTOCORRECTPOSITONANDSITE"))
declare SNTOCORRECTPROCEDURE = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTOCORRECTPROCEDURE"))
declare SNTODISCONTINUEREADONLYMSG = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTODISCONTINUEREADONLYMSG"))
declare SNTOOUTCOMEMETO30 = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTOOUTCOMEMETO30"))
declare SNTOPROCEDURETIMEOUTCOMMENTS = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTOPROCEDURETIMEOUTCOMMENTS"))
declare SNTORELEVANTIMAGESREVIEWEDANDD = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTORELEVANTIMAGESREVIEWEDANDD"))
declare SNTOTIMEOUTDESCRIPTION = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTOTIMEOUTDESCRIPTION"))
declare SNTOTIMEOUTTIME = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTOTIMEOUTTIME"))
declare SNPROCADDITIONALPROCEDUREDETAIL = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNPROCADDITIONALPROCEDUREDETAIL"))
declare SNPROCMODIFIERS = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNPROCMODIFIERS"))
declare SNPROCOUTCOMEMETO730 = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNPROCOUTCOMEMETO730"))
declare SNPROCPRIMARYPROCEDURE = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNPROCPRIMARYPROCEDURE"))
declare SNPROCPROCEDURECODE = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNPROCPROCEDURECODE"))
declare SNPROCSTARTTIME = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNPROCSTARTTIME"))
declare SNPROCSTOPTIME = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNPROCSTOPTIME"))
declare SNGCDOUTCOMEMETO320 = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNGCDOUTCOMEMETO320"))
declare SNGCDPREOPDIAGNOSIS = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNGCDPREOPDIAGNOSIS"))
declare SNGCDWOUNDCLASSDESCRIPTION = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNGCDWOUNDCLASSDESCRIPTION"))
declare SNTIACQUISITIONDATE = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTIACQUISITIONDATE"))
declare SNTIANTIBIOTICDOSE = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTIANTIBIOTICDOSE"))
declare SNTIANTIBIOTICLOTNUMBER = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTIANTIBIOTICLOTNUMBER"))
declare SNTIANTIBIOTICSERIALNUMBER = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTIANTIBIOTICSERIALNUMBER"))
declare SNTICATALOGNUMBER = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTICATALOGNUMBER"))
declare SNTIDESCRIPTION = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTIDESCRIPTION"))
declare SNTIEXPIRATIONDATE = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTIEXPIRATIONDATE"))
declare SNTIIMPLANTCOMMENT = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTIIMPLANTCOMMENT"))
declare SNTIIMPLANTSITE = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTIIMPLANTSITE"))
declare SNTIPREPARATIONCOMMENTS = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTIPREPARATIONCOMMENTS"))
declare SNTIPREPARATIONDATE = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTIPREPARATIONDATE"))
declare SNTIPREPARATIONMETHOD = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTIPREPARATIONMETHOD"))
declare SNTIPREPARATIONTIME = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTIPREPARATIONTIME"))
declare SNTIPREPAREDACCORDINGTOINSTRUCT = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTIPREPAREDACCORDINGTOINSTRUCT"))
declare SNTIPREPAREDBY = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTIPREPAREDBY"))
declare SNTIQUANTITY = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTIQUANTITY"))
declare SNTIRESPONSIBLESTAFF = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTIRESPONSIBLESTAFF"))
declare SNTISOLUTION = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTISOLUTION"))
declare SNTISOLUTIONEXPIRATIONDATE = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTISOLUTIONEXPIRATIONDATE"))
declare SNTISOLUTIONLOTNUMBER = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTISOLUTIONLOTNUMBER"))
declare SNTISOLUTIONVOLUME = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTISOLUTIONVOLUME"))
declare SNTISTORAGELOCATION = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTISTORAGELOCATION"))
declare SNTITISSUEANTIBIOTIC = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTITISSUEANTIBIOTIC"))
declare SNTITISSUEEXPIRATIONDATE = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTITISSUEEXPIRATIONDATE"))
declare SNTITISSUELOTNUMBER = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTITISSUELOTNUMBER"))
declare SNTITISSUEREHYDRATIONTIME = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTITISSUEREHYDRATIONTIME"))
declare SNTITISSUESERIALNUMBER = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTITISSUESERIALNUMBER"))
declare SNTITISSUESIZE = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTITISSUESIZE"))
declare SNTITISSUETYPE = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTITISSUETYPE"))
declare SNTIUNIQUEID = f8 with constant(uar_get_code_by("DISPLAYKEY",14003,"SNTIUNIQUEID"))
 
declare PrimarySurgeonCd = f8 with constant(uar_get_code_by("DISPLAYKEY",10170,"SURGEONPRIMARY"))
declare otherSurgeonCd = f8 with constant(uar_get_code_by("DISPLAYKEY",10170,"SURGEONOTHER"))
declare VisitingSurgeonCd = f8 with constant(uar_get_code_by("DISPLAYKEY",10170,"SURGEONVISITING"))
declare firstAssistCd = f8 with constant(uar_get_code_by("DISPLAYKEY",10170,"ASSISTANTFIRST"))
declare secondAssistCd = f8 with constant(uar_get_code_by("DISPLAYKEY",10170,"ASSISTANTSECOND"))
declare AssistantSurgeonCd = f8 with constant(uar_get_code_by("DISPLAYKEY",10170,"ASSISTANTSURGEON"))
 
set rDpb->any_field = "0" ;set any to 0 not *
declare bAnyFac     = I1 with protect, constant( isDpbAny( Parameter2( $dFac )))
declare bAnySA      = I1 with protect, constant( isDpbAny( Parameter2( $dArea )))
declare bAnyRm      = I1 with protect, constant( isDpbAny( Parameter2( $dRm )))
declare bAnySpec    = I1 with protect, constant( isDpbAny( Parameter2( $dSpec )))
declare bAnyPrGrp   = I1 with protect, constant( isDpbAny( Parameter2( $dPrGrp )))
declare bAnySurg    = I1 with protect;, constant( evaluate( reflect( parameter( 11, 0 )), "F8", parameter( 11, 1 )
                                                                                       ;, "I4", parameter( 11, 1 ), 1 ))
if( reflect( parameter( 11, 0 )) in( "F8", "I4" ))
    if( cnvtreal( parameter( 11, 1 )) = 0.0 )
        set bAnySurg = 1
    endif
else
    set bAnySurg = 1
endif
 
declare sPFac   = vc with protect
declare sPArea  = vc with protect, noconstant( "Any (*)" )
declare sPRoom  = vc with protect, noconstant( "Any (*)" )
declare sPSpec  = vc with protect, noconstant( "Any (*)" )
declare sPPrGrp = vc with protect, noconstant( "Any (*)" )
declare sPSurg  = vc with protect, noconstant( "Any (*)" )
 

set sPFac = Replace( getCvDesc( Trim( getDpbList( Parameter2( $dFac ), ^^ ), 3 )), ",", " or", 2 )
if( not bAnySA ) set sPArea = Replace( getCvDisp( Trim( getDpbList( Parameter2( $dArea ), ^^ ), 3 )), ",", " or", 2 ) endif
if( not bAnyRm ) set sPRoom = Replace( getCvDisp( Trim( getDpbList( Parameter2( $dRm ), ^^ ), 3 )), ",", " or", 2 ) endif
if( not bAnySpec ) set sPSpec = Replace( getCvDisp( Trim( getDpbList( Parameter2( $dSpec ), ^^ ), 3 )), ",", " or", 2 ) endif
if( not bAnyPrGrp ) set sPPrGrp = Replace( getPrGrp( Trim( getDpbList( Parameter2( $dPrGrp ), ^^ ), 3 )), ",", " or", 2 ) endif
if( not bAnySurg ) set sPSurg = Replace( getFullName( Trim( getDpbList( Parameter2( $dSurg ), ^^ ), 3 )), ",", " or", 2 ) endif

;grab all necessary DTAs for filtering later on
SELECT 
	CV1.CODE_VALUE
	,CV1.DISPLAY
	,CV1.CDF_MEANING
	,CV1.DESCRIPTION
	,CV1.DISPLAY_KEY
	,CV1.CKI
	,CV1.DEFINITION
 FROM CODE_VALUE CV1 

WHERE CV1.CODE_SET =  14003 
AND CV1.ACTIVE_IND = 1 
AND cv1.display_key in ("SNTI*", "SNGCD*","SNPROC*")
OR CV1.DISPLAY IN ("SN - TO*", "SN - PD*", "SN - OV*")
order cv1.display_key
head report
	 cnt = 0 
	 head cv1.display_key
	 cnt = cnt+ 1
	 if( mod( Cnt, 10 ) = 1 )
	 stat = alterlist(dtas->list, cnt + 9)
	 endif
detail
	 DTAS->LIST[CNT].CV = CV1.CODE_VALUE
	 DTAS->LIST[CNT].DESCRIPTION = CV1.DESCRIPTION
	
	FOOT REPORT
		STAT = ALTERLIST(DTAs->LIST, CNT)
WITH NOCOUNTER
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
 
and (   (   bPaes!= 0 and bPaes          !=   1 )
    or  (   bPaes = 0 and cv.display_key !=   "*PAES*" )
    or  (   bPaes = 1 and cv.display_key  =   "*PAES*" )
    )
 
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
;;call echorecord( rSA )
 
;Check for results
if (rSA->cnt = 0)
  go to POST_PROCESSING
endif
 
; *************************************************
; ************** MAIN QUAL ************************
; *************************************************
set nCnt = 0
select into "nl:"
  dttm = cnvtdatetime(sc.sched_start_dt_tm)
from
  surgical_case sc,
  code_value cv,
  encounter e,
  person p,
  encntr_alias ea,
  prsnl_group pgs ;surgeon specialty (as scheduled)
 
plan    sc
where   sc.sched_start_dt_tm between cnvtdatetime(dtBeg) and cnvtdatetime(dtEnd)
and     EXPAND( n, 1, rSA->cnt, sc.sched_surg_area_cd, rSA->arr[n].num )
and   ( sc.surg_op_loc_cd                   = $dRm   or bAnyRm   = 1 )
and   ( sc.surgeon_prsnl_id                 = $dSurg or bAnySurg = 1 )
and     sc.active_ind = 1
and (   bAnyPrGrp = 1
    or  (   bAnyPrGrp = 0
        and EXISTS
          ( select (1)
            from    prsnl_group_reltn       gr
            ,       prsnl_group             g
 
            where   g.prsnl_group_id        = $dPrGrp
            and     g.active_ind            = 1
            and     cnvtdatetime( curdate, curtime ) between g.beg_effective_dt_tm and g.end_effective_dt_tm
 
            and     gr.prsnl_group_id       = g.prsnl_group_id
            and     gr.person_id            = sc.surgeon_prsnl_id
            and     gr.active_ind           = 1
            and     cnvtdatetime( curdate, curtime ) between gr.beg_effective_dt_tm and gr.end_effective_dt_tm
          )
        )
    )
join cv where
  cv.code_value = sc.sched_surg_area_cd and
  cv.display != "*PAES*"
join e where
  e.encntr_id = sc.encntr_id ;and (bAnyFac = 1 or e.loc_facility_cd = $dFac)
join p where
  p.person_id = e.person_id
join ea where
  ea.encntr_id = e.encntr_id and
  ea.encntr_alias_type_cd in(1077.0, 1079.0) and ; FIN, MRN
  ea.active_ind = 1 and
  ea.end_effective_dt_tm > sysdate
 
join    pgs
where   pgs.prsnl_group_id                  =   outerjoin( sc.surg_specialty_id )
and     pgs.active_ind                      =   outerjoin( 1 )
and     pgs.end_effective_dt_tm             >   outerjoin( sysdate )
 
order sc.surg_case_id, ea.encntr_alias_type_cd
 
head sc.surg_case_id
  nCnt = nCnt + 1
  if(mod(nCnt, 200) = 1)
    stat = alterlist(rData->item, nCnt + 199)
  endif
  sRet = concat(trim(cnvtstring(sc.sched_dur), 3), ",MIN")
  rData->item[nCnt].dEId = sc.encntr_id
  rData->item[nCnt].dPId = sc.person_id
  rData->item[nCnt].dSCId = sc.surg_case_id
  rData->item[nCnt].dSEId = sc.sch_event_id
  rData->item[nCnt].sCaseNum = trim(sc.surg_case_nbr_formatted)
  rData->item[nCnt].sCaseLvlOut = trim(uar_get_code_display(sc.case_level_cd))
  rData->item[nCnt].sFac = trim(uar_get_code_display(sc.inst_cd))
  rData->item[nCnt].dtSchedStart = dttm
  rData->item[nCnt].dtSchedEnd = cnvtlookahead(sRet, dttm)
  rData->item[nCnt].sAge = trim(cnvtage(p.birth_dt_tm, dttm, 0), 3)
  rData->item[nCnt].sArea = trim(uar_get_code_display(sc.sched_surg_area_cd))
  rData->item[nCnt].sRoom = trim(uar_get_code_display(sc.sched_op_loc_cd))
  rData->item[nCnt].sCancelReas = trim(uar_get_code_display(sc.cancel_reason_cd))
  rData->item[nCnt].sDOB = format(p.birth_dt_tm, "mm/dd/yyyy;;D")
  rData->item[nCnt].sName = trim(p.name_full_formatted)
  rData->item[nCnt].sSex = trim(uar_get_code_display(p.sex_cd))
  rData->item[nCnt].sPatType = trim(uar_get_code_display(e.encntr_type_cd))
  rData->item[nCnt].sCaseType = trim(uar_get_code_display(sc.sched_type_cd))
  rData->item[nCnt].dSrgSpec = sc.sched_surg_specialty_id
  rData->item[nCnt].sSrgSpec = pgs.prsnl_group_name
  rData->item[nCnt].bKeep = bAnySpec
 
head ea.encntr_alias_type_cd
  if(ea.encntr_alias_type_cd = 1077.0) ; FIN
    rData->item[nCnt].sFIN = trim(ea.alias)
  else
    rData->item[nCnt].sMRN = trim(ea.alias)
  endif
with nocounter
 
 
;******************************
;*get results and resulted IDs*
;******************************
set index = 0
select into "NL;"
  Segment = uar_get_code_display(sh.input_form_cd)
  , Documenter = p.name_full_formatted
  , Time_Documented = format(cep.action_dt_tm, "@SHORTDATETIME")
  , Result_documented = ce2.result_val
  , ce2.event_tag
  , ce2.event_title_text
from
  surgical_case@cmrpt sc,
  perioperative_document@CMRPT pd,
  segment_header@CMRPT sh,
  input_form_reference@CMRPT ifr,
  clinical_event@CMRPT ce,
  clinical_event@CMRPT ce2,
  ce_event_prsnl@cmrpt cep,
  prsnl@cmrpt	p
 
plan sc where 
  expand(index, 0, size(rdata->item,5),sc.surg_case_id,rData->item[index].dSCId) 
join pd where
	pd.surg_case_id = sc.surg_case_id and
  pd.doc_term_by_id = 0.0
join sh where
  sh.periop_doc_id = pd.periop_doc_id
join ifr where
  ifr.input_form_cd = sh.input_form_cd and
  ifr.active_ind = 1
join ce where
  ce.person_id = sc.person_id and
  ce.encntr_id = sc.encntr_id and
  ce.event_cd = ifr.event_cd and
  findstring(concat(trim(cnvtstring(sh.periop_doc_id), 3), "SN"), ce.reference_nbr) > 0 and
  ce.valid_until_dt_tm > sysdate  
  
join ce2 where
  ce2.parent_event_id = ce.event_id and
  ce2.view_level = 1 and
  ce2.valid_until_dt_tm > sysdate and
  EXPAND(INDEX, 0, SIZE(rDATA->item,5), CE2.TASK_ASSAY_CD, DTAS->LIST[INDEX].CV)
join cep where
  cep.event_id = ce2.event_id and
  cep.action_status_cd =  653.00 and ; complete status
  cep.action_type_cd   =  95.00 and ;documenter
  cep.valid_until_dt_tm > sysdate
join p where
  p.person_id = cep.action_prsnl_id ;who done it--the results
order  pd.surg_case_id, ce.event_id, CEP.EVENT_ID
HEAD REPORT
    POS = 0
    INDEX = 0
DETAIL
	POS = LOCATEVAL(INDEX, 1, SIZE(rDATA->item,5),sc.surg_case_id, rdata->item[INDEX].dSCId)
	
case (ce.task_assay_cd)
of SNOVAVAILABILITYVERIFIEDIFAPPL :
	rData->item[pos].OVAVAILABILITYVERIFIEDIFAPPL = ce.result_val
of SNOVCORRECTPROCEDURESITEVERIF :
 rData->item[pos].OVCORRECTPROCEDURESITEVERIF   = ce.result_val
of SNOVDISCONTINUEREADONLYMSG :
 rData->item[pos].OVDISCONTINUEREADONLYMSG      = ce.result_val
of SNOVOUTCOMEMETO :
 rData->item[pos].OVOUTCOMEMETO 				= ce.result_val
of SNOVPATIENTIDENTITYVERIFIED :
 rData->item[pos].OVPATIENTIDENTITYVERIFIED     = ce.result_val
of SNOVRELEVANTIMAGESAVAILABLEAND :
 rData->item[pos].OVRELEVANTIMAGESAVAILABLEAND  = ce.result_val
of SNPDADDCOMMENT :
 rData->item[pos].PDADDCOMMENT                  = ce.result_val
of SNPDCATALOGNUMBER :
 rData->item[pos].PDCATALOGNUMBER               = ce.result_val
of SNPDCULTURED :
 rData->item[pos].PDCULTURED                    = ce.result_val
of SNPDDESCRIPTION :
 rData->item[pos].PDDESCRIPTION                 = ce.result_val
of SNPDEXPIRATIONDATE :
 rData->item[pos].PDEXPIRATIONDATE              = ce.result_val
of SNPDIMPLANTSITE :
 rData->item[pos].PDIMPLANTSITE                 = ce.result_val
of SNPDIMPLANTEDBY :
 rData->item[pos].PDIMPLANTEDBY                 = ce.result_val
of SNPDLOTNUMBER :
 rData->item[pos].PDLOTNUMBER                   = ce.result_val
of SNPDMANUFACTURER :
 rData->item[pos].PDMANUFACTURER                = ce.result_val
of SNPDOUTCOMEMETO30 :
 rData->item[pos].PDOUTCOMEMETO30               = ce.result_val
of SNPDQUANTITY :
 rData->item[pos].PDQUANTITY                    = ce.result_val
of SNPDSERIALNUMBER :
 rData->item[pos].PDSERIALNUMBER 				= ce.result_val
of SNPDSITE :
 rData->item[pos].PDSITE                        = ce.result_val
of SNPDSIZE :
 rData->item[pos].PDSIZE                        = ce.result_val
of SNPDUDI :
 rData->item[pos].PDUDI                         = ce.result_val
of SNTOCORRECTLATERALITYVISIBLESIT :
 rData->item[pos].TOCORRECTLATERALITYVISIBLESIT = ce.result_val
of SNTOCORRECTPATIENT :
 rData->item[pos].TOCORRECTPATIENT              = ce.result_val
of SNTOCORRECTPOSITONANDSITE :
 rData->item[pos].TOCORRECTPOSITONANDSITE       = ce.result_val
of SNTOCORRECTPROCEDURE :
 rData->item[pos].TOCORRECTPROCEDURE            = ce.result_val
of SNTODISCONTINUEREADONLYMSG :
 rData->item[pos].TODISCONTINUEREADONLYMSG      = ce.result_val
of SNTOOUTCOMEMETO30 :
 rData->item[pos].TOOUTCOMEMETO30               = ce.result_val
of SNTOPROCEDURETIMEOUTCOMMENTS :
 rData->item[pos].TOPROCEDURETIMEOUTCOMMENTS    = ce.result_val
of SNTORELEVANTIMAGESREVIEWEDANDD :
 rData->item[pos].TORELEVANTIMAGESREVIEWEDANDD  = ce.result_val
of SNTOTIMEOUTDESCRIPTION :
 rData->item[pos].TOTIMEOUTDESCRIPTION          = ce.result_val
of SNTOTIMEOUTTIME :
 rData->item[pos].TOTIMEOUTTIME                 = ce.result_val
of SNPROCADDITIONALPROCEDUREDETAIL :
 rData->item[pos].PROCADDITIONALPROCEDUREDETAIL = ce.result_val
of SNPROCMODIFIERS :
 rData->item[pos].PROCMODIFIERS                 = ce.result_val
of SNPROCOUTCOMEMETO730 :
 rData->item[pos].PROCOUTCOMEMETO730            = ce.result_val
of SNPROCPRIMARYPROCEDURE :
 rData->item[pos].PROCPRIMARYPROCEDURE          = ce.result_val
of SNPROCPROCEDURECODE :
 rData->item[pos].PROCPROCEDURECODE             = ce.result_val
of SNPROCSTARTTIME :
 rData->item[pos].PROCSTARTTIME                 = ce.result_val
of SNPROCSTOPTIME :
 rData->item[pos].PROCSTOPTIME                  = ce.result_val
of SNGCDOUTCOMEMETO320 :
 rData->item[pos].GCDOUTCOMEMETO320             = ce.result_val
of SNGCDPREOPDIAGNOSIS :
 rData->item[pos].GCDPREOPDIAGNOSIS             = ce.result_val
of SNGCDWOUNDCLASSDESCRIPTION :
 rData->item[pos].GCDWOUNDCLASSDESCRIPTION      = ce.result_val
of SNTIACQUISITIONDATE :
 rData->item[pos].TIACQUISITIONDATE             = ce.result_val
of SNTIANTIBIOTICDOSE :
 rData->item[pos].TIANTIBIOTICDOSE              = ce.result_val
of SNTIANTIBIOTICLOTNUMBER :
 rData->item[pos].TIANTIBIOTICLOTNUMBER         = ce.result_val
of SNTIANTIBIOTICSERIALNUMBER :
 rData->item[pos].TIANTIBIOTICSERIALNUMBER      = ce.result_val
of SNTICATALOGNUMBER :
 rData->item[pos].TICATALOGNUMBER               = ce.result_val
of SNTIDESCRIPTION :
 rData->item[pos].TIDESCRIPTION                 = ce.result_val
of SNTIEXPIRATIONDATE :
 rData->item[pos].TIEXPIRATIONDATE              = ce.result_val
of SNTIIMPLANTCOMMENT :
 rData->item[pos].TIIMPLANTCOMMENT              = ce.result_val
of SNTIIMPLANTSITE :
 rData->item[pos].TIIMPLANTSITE                 = ce.result_val
of SNTIPREPARATIONCOMMENTS :
 rData->item[pos].TIPREPARATIONCOMMENTS         = ce.result_val
of SNTIPREPARATIONDATE :
 rData->item[pos].TIPREPARATIONDATE             = ce.result_val
of SNTIPREPARATIONMETHOD :
 rData->item[pos].TIPREPARATIONMETHOD           = ce.result_val
of SNTIPREPARATIONTIME :
 rData->item[pos].TIPREPARATIONTIME             = ce.result_val
of SNTIPREPAREDACCORDINGTOINSTRUCT :
 rData->item[pos].TIPREPAREDACCORDINGTOINSTRUCT = ce.result_val
of SNTIPREPAREDBY :
 rData->item[pos].TIPREPAREDBY                  = ce.result_val
of SNTIQUANTITY :
 rData->item[pos].TIQUANTITY                    = ce.result_val
of SNTIRESPONSIBLESTAFF :
 rData->item[pos].TIRESPONSIBLESTAFF            = ce.result_val
of SNTISOLUTION :
 rData->item[pos].TISOLUTION                    = ce.result_val
of SNTISOLUTIONEXPIRATIONDATE :
 rData->item[pos].TISOLUTIONEXPIRATIONDATE      = ce.result_val
of SNTISOLUTIONLOTNUMBER :
 rData->item[pos].TISOLUTIONLOTNUMBER           = ce.result_val
of SNTISOLUTIONVOLUME :
 rData->item[pos].TISOLUTIONVOLUME              = ce.result_val
of SNTISTORAGELOCATION :
 rData->item[pos].TISTORAGELOCATION             = ce.result_val
of SNTITISSUEANTIBIOTIC :
 rData->item[pos].TITISSUEANTIBIOTIC            = ce.result_val
of SNTITISSUEEXPIRATIONDATE :
 rData->item[pos].TITISSUEEXPIRATIONDATE        = ce.result_val
of SNTITISSUELOTNUMBER :
 rData->item[pos].TITISSUELOTNUMBER             = ce.result_val
of SNTITISSUEREHYDRATIONTIME :
 rData->item[pos].TITISSUEREHYDRATIONTIME       = ce.result_val
of SNTITISSUESERIALNUMBER :
 rData->item[pos].TITISSUESERIALNUMBER          = ce.result_val
of SNTITISSUESIZE :
 rData->item[pos].TITISSUESIZE                  = ce.result_val
of SNTITISSUETYPE :
 rData->item[pos].TITISSUETYPE                  = ce.result_val
of SNTIUNIQUEID :
 rData->item[pos].TIUNIQUEID                    = ce.result_val
endcase 




with time = 60


call echorecord(rdata)







 
SELECT
	ITEM_SNAME = SUBSTRING(1, 30, RDATA->item[D1.SEQ].sName)
	, ITEM_SFIN = SUBSTRING(1, 30, RDATA->item[D1.SEQ].sFIN)
	, ITEM_SMRN = SUBSTRING(1, 30, RDATA->item[D1.SEQ].sMRN)
	, ITEM_SDOB = RDATA->item[D1.SEQ].sDOB
	, ITEM_SAGE = SUBSTRING(1, 30, RDATA->item[D1.SEQ].sAge)
	, ITEM_SSEX = SUBSTRING(1, 30, RDATA->item[D1.SEQ].sSex)
	, ITEM_SPATTYPE = SUBSTRING(1, 30, RDATA->item[D1.SEQ].sPatType)
	, ITEM_SFAC = SUBSTRING(1, 30, RDATA->item[D1.SEQ].sFac)
	, ITEM_SAREA = SUBSTRING(1, 30, RDATA->item[D1.SEQ].sArea)
	, ITEM_DTSCHEDSTART = RDATA->item[D1.SEQ].dtSchedStart
	, ITEM_DTSCHEDEND = RDATA->item[D1.SEQ].dtSchedEnd
	, ITEM_DTSURGSTART = RDATA->item[D1.SEQ].dtSurgStart
	, ITEM_DTSURGSTOP = RDATA->item[D1.SEQ].dtSurgStop
	, ITEM_DTINROOM = RDATA->item[D1.SEQ].dtInRoom
	, ITEM_DTOUTROOM = RDATA->item[D1.SEQ].dtOutRoom
	, ITEM_DTSGNVST = RDATA->item[D1.SEQ].dtSgnVst
	, ITEM_DTSGNSTART = RDATA->item[D1.SEQ].dtSgnStart
	, ITEM_DTSGNSTOP = RDATA->item[D1.SEQ].dtSgnStop
	, ITEM_DTANSVST = RDATA->item[D1.SEQ].dtAnsVst
	, ITEM_DTANSSTART = RDATA->item[D1.SEQ].dtAnsStart
	, ITEM_DTANSSTOP = RDATA->item[D1.SEQ].dtAnsStop
	, ITEM_DTORRNVST = RDATA->item[D1.SEQ].dtOrRnVst
	, ITEM_SSCHEDPROC = SUBSTRING(1, 30, RDATA->item[D1.SEQ].sSchedProc)
	, ITEM_SACTUALPROC = SUBSTRING(1, 30, RDATA->item[D1.SEQ].sActualProc)
	, ITEM_DSRGSPEC = RDATA->item[D1.SEQ].dSrgSpec
	, ITEM_SSRGSPEC = SUBSTRING(1, 30, RDATA->item[D1.SEQ].sSrgSpec)
	, ITEM_DPRGRP = RDATA->item[D1.SEQ].dPrGrp
	, ITEM_SPRGRP = SUBSTRING(1, 30, RDATA->item[D1.SEQ].sPrGrp)
	, ITEM_DSURGEON1ID = RDATA->item[D1.SEQ].dSurgeon1ID
	, ITEM_SSURGEON1 = SUBSTRING(1, 30, RDATA->item[D1.SEQ].sSurgeon1)
	, ITEM_SSURGEON2ID = SUBSTRING(1, 30, RDATA->item[D1.SEQ].sSurgeon2ID)
	, ITEM_SSURGEON2 = SUBSTRING(1, 30, RDATA->item[D1.SEQ].sSurgeon2)
	, ITEM_SSIGNEDBY = SUBSTRING(1, 30, RDATA->item[D1.SEQ].sSignedBy)
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(RDATA->item, 5)))
 
PLAN D1
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
 
#POST_PROCESSING
end
go
