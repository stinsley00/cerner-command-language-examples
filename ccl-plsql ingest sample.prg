
  set current_domain = cnvtlower(curdomain)
 

 call echo(current_domain)
declare crlf = vc with NoConstant(build(char(10),char(13))),Public
 ;default max for a VC field is 1048576 but this limit can be extended in your script with the SET MODIFY MAXVARLEN command
set modify maxvarlen 25000000 ;set new max to 20 million
declare directory = vc with constant("/cerner/",current_domain,"/ftp/carec2/inbound/")
declare obDirectory  = vc with constant("/cerner/",current_domain,"/ftp/carec2/outbound/")
declare fText = vc with protect
declare filename = vc with noconstant(NOTRIM(fillstring(255," ")))
declare fileNameYouWantToRead = vc with noconstant(notrim(fillstring(255," ")))
declare pText = vc
DECLARE LMAXACTIONS = I4 WITH PUBLIC ,NOCONSTANT (0)
declare next = i4
declare last = i4
declare xx = i4 with noconstant(0)
declare temp = i4 with noconstant(0)
 set cnt = 0 
record fNames(
	1 list[*]
	2 Org_file = vc
	2 Prov_file = vc
	2 patient_file = vc
)
 
record FREC(
	1 FILE_DESC = I4
	1 FILE_OFFSET =I4
	1 FILE_DIR = I4
	1 FILE_NAME = VC
	1 FILE_BUF = VC
)
;record to hold the data that we are reading in
Record Facility(
	1 file_seq = vc
	1 filename = vc
)
 
Record Providers(
	1 file_seq = vc
 	1 filename = vc
)
 
record Patients(
	1 file_seq = vc
	1 fileName = vc ;from which file was the read
	1 list[*]
	2 MRN = VC
	2 FIN = VC
 
)
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  		OPS Logic 		      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if(not(validate(isopsjob)))
  declare isopsjob = i2 with noconstant(0), protect
  if(validate(request->batch_selection))
    set isopsjob = 1
  endif
endif
 
if(not(isopsjob))
  record request(
  1 batch_selection = vc
  1 output_dist = vc
  1 ops_date = dq8
  )
endif
 
if(not(validate(reply->status_data)))
  record reply(
  1 ops_event = vc
  1 status_data
    2 status = c1
    2 subeventstatus[1]
    3 operationname = c25
    3 operationstatus = c1
    3 targetobjectname = c25
    3 targetobjectvalue = vc
  )
endif
 

 
;get file names and cat them into a file for later processing
SET DCLCOM  =  build2("ls ", directory, " >filename.out;")
SET LEN = SIZE(TRIM(DCLCOM))
SET STATUS = -1
SET DCLSTAT = DCL ( DCLCOM,  LEN ,  STATUS )
 
 
set filename = concat("CCLUSERDIR:filename.out")
 
;CCLIO TO PROCESS THE FILE NAMES
if (findfile(filename) = 0)  ;if the file was not found
 
	call echo(build2(filename, " was not found"))
 
elseif(findfile(filename,4,0) =1) ;if file was found with write status && exact match
 
	call READ_FILE(filename)
	set stat = remove(filename)
endif
 
 
/*
* Request File ingest logic
* 1) need to determine the directory
* 2) read in file names and process them (below)
* 3) then feed the other programs the processed data
*/
 
call echorecord(fnames)
 
for(x = 1 to size(fnames->list,5))
	if(fNames->list[x].Org_file > "")
	set filename = concat(value(directory),fNames->list[x].Org_file)
	set obFileName = concat(value(obDirectory),fNames->list[x].Org_file)
 
 
 if(fNames->list[x].patient_file > "")
	SET FileName = concat(value(directory),fNames->list[x].patient_file)
	set obFileName = concat(value(obDirectory),fNames->list[x].patient_file)
	
		if (findfile(filename,4,1) = 0)  ;if the file was not found
		
			call echo(build2(filename, " was not found"))
		
		elseif(findfile(filename,4,1) =1 and not findfile(obFileName,4,1))
			SET Patients->file_seq =
			Replace(substring((findstring(char(95),fileName,1,1)+1),(findstring(char(46),fileName,1,1)-1),fileName),".txt","")
			set patients->fileName = fNames->list[x].patient_file
			call echo(build2("Importing patient File w/seq : ",patients->file_seq))
			Call echo(filename)
			call READ_FILE(filename)
		
		
			execute patient_script:dba 
		
		call rmFile(filename)
	endif
 
 endif
endfor
;READ_FILE_Patient
SUBROUTINE READ_FILE(fileNameYouWantToRead)
/**********************************************************
*  Read File
***********************************************************/
	;free record frec
   SET FREC->FILE_NAME = (TRIM(fileNamed))

   SET FREC->FILE_BUF = "r" /* file_buf values are case sensitive so lowercase r is used */
   SET STAT = CCLIO("OPEN",FREC) ;open file
   ;Allocate buffer for desired read size
   SET FREC->FILE_BUF = NOTRIM(FILLSTRING(1000," ")) ;allow for a lot of space in each line

   set x = 0
   IF (FREC->FILE_DESC != 0)
       SET STAT = 1
       WHILE (STAT > 0)
       	set x = x + 1
       	set stat = alterlist(fnames->list, x)
  ;read the file one record at a time
          SET STAT = CCLIO("GETS",FREC)
          IF (STAT > 0)
              SET FTEXT = CONCAT(FTEXT,TRIM(FREC->FILE_BUF),";") ;unprocessed file concat) into a string
              if(FREC->FILE_NAME = "*filename.out")
              	set cnt   		= cnt + 1
                set pos   		= findstring(char(0), trim(frec->file_buf))
                set pos   		= evaluate(pos, 0, size(trim(frec->file_buf)), pos)
                set ltext 		= replace(substring(1, pos, trim(frec->file_buf)),";","")
               ; call echo(build2("ltxt: ", ltext))
                if(ltext 		= "*orgs*.txt")
 
         			SET fNames->list[x].Org_file = ltext
 
         		elseif(ltext 	= "*patients*.txt")
 
         			SET fNames->list[x].patient_file = ltext
 
         		endif
			call echorecord(fNames)
 
        	ENDIF
 
 
          ENDIF
       ENDWHILE
        ;Close the file
   SET STAT = CCLIO("CLOSE",FREC);commit changes and close file
   ENDIF

 
 IF(frec->FILE_NAME = "*patient*")
 
	SET FTEXT = TRIM(FTEXT,2)
	CALL ECHO(FTEXT)
	SET PIPECNT = 0
	SET CRLFCNT = 0
	SET STRLENGTH = 0
	;SET INITIAL POSITIONS
	SET POS = FINDSTRING("|",FTEXT,1,0)
	SET EOL = FINDSTRING(";",FTEXT,1,0)
	SET MRNPOS = 0
	SET STRLENGTH = EOL
	For(x = 1 to textlen(ftext))
		if(substring(x,1,ftext) = "|")
			set pipecnt = pipecnt + 1
			;parse logic
			set stat = alterlist(patients->list,pipecnt)
			set patients->list[pipecnt].FIN = cnvtstring(cnvtint(replace(substring(pos+1,((eol)-(pos)),ftext),";","")))
			set patients->list[pipecnt].MRN = cnvtstring(cnvtint(replace(substring(mrnpos,pos-mrnpos,ftext),"|","")))
			;set the next position
			call echo(build2(" pos: ", pos, " x: ", x , " MRNPOS: ", mrnpos))
			set pos = findstring("|",ftext,x+1,0)
			set eol = findstring(";",ftext,x+1,0)
		elseif(substring(x,1,ftext) = ";")
			set crlfcnt = crlfcnt + 1
			;set next endof line
			set mrnpos = (x+1)
			set pos = findstring("|",ftext,x+1,0)
			set eol = findstring(";",ftext,x+1,0)
		endif
 
		;end of parsing;
	endfor
  endif
 
 call echorecord(patients)
END
 
subroutine sftp(null)
 
set dclcom1 = concat(".\$cust_script:carec2.sftp.ksh")
SET LEN = SIZE((DCLCOM1))
SET STATUS = -1
SET DCLSTAT = DCL ( DCLCOM1,  LEN ,  STATUS )
 
call echo(dclcom1)
call echo(filename)
call echo(build('stat:', status))
 
end
 
subroutine rmFile(filename)
if(filename > "")
 
/*This command will remove the  file after processing*/
set dclcom1 = concat('rm -rf ',(filename))
SET LEN = SIZE((DCLCOM1))
SET STATUS = -1
SET DCLSTAT = DCL ( DCLCOM1,  LEN ,  STATUS )
 
call echo(dclcom1)
call echo(filename)
call echo(build('stat:', status))
 

set stat = remove(filename)
 
set reply->status_data.status = "S"
 
endif
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Reply for successful OPS Logic ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
set reply->status_data.status = "S"

 
end
go
