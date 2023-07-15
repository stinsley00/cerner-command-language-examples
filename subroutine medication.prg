subroutine medication(NULL)
 call echo("get of meds")
 
	select into "NL:"
	�
	from (dummyt d1 with seq = value(size(pat_tmp->patient,5))),
			orders o,
			order_ingredient oi,
			frequency_schedule fs,
			order_detail od,
			order_action oa,
			prsnl pers,
			order_catalog_synonym ocs,
			alt_sel_list al,
			alt_sel_cat ac
 
	plan d1
 
	join o
		where o.encntr_id = pat_tmp->patient[d1.seq].encntr_id
		and o.catalog_type_cd = PHARM;2516
		and o.orig_ord_as_flag in(0,1) ;Regular Med order or RX
		and o.order_status_cd not in(VOIDED, CANCELED);(2542,2544,2545)
 
	join oi where oi.order_id = o.order_id
 
	join fs where fs.frequency_id = outerjoin(o.frequency_id)
 
	join od where od.order_id = outerjoin(o.order_id)
		and od.oe_field_meaning = outerjoin("RXROUTE")
 
	join oa where oa.order_id = o.order_id
		and oa.action_type_cd = ORDERED; 2534
 
	join pers where pers.person_id = oa.order_provider_id
 
	join ocs where ocs.synonym_id = o.synonym_id
		and ocs.catalog_type_cd = PHARM;2516
		and ocs.active_ind = 1
 
	join al where al.synonym_id = ocs.synonym_id
 
	join ac where ac.alt_sel_category_id = al.alt_sel_category_id
		and ac.alt_sel_category_id > 0 and ac.ahfs_ind+0 = 1
		and child_cat_ind = 1
order by o.encntr_id, o.order_id, od.oe_field_meaning
 
		head report
			index = 0
			nCnt = 0�
			x = 0
		HEAD o.encntr_id
 
		  	x = LOCATEVAL(index,1,size(pat_tmp->patient,5),o.encntr_id,pat_tmp->patient[index].encntr_id)
 
		head o.order_id
			nCnt = nCnt + 1
			stat = alterlist(pat_tmp->patient[x]->medication_ord, nCnt + 9)
		    Pat_tmp->patient[x].medication_ord[nCnt].medication							= "MEDICATION"
		    Pat_tmp->patient[x].medication_ord[nCnt].medication_order_id					= cnvtstring(o.order_id)
		    Pat_tmp->patient[x].medication_ord[nCnt].medication_code 						= trim(o.cki)
		    Pat_tmp->patient[x].medication_ord[nCnt].medication_description 				= uar_get_code_description(o.catalog_cd)
		   	Pat_tmp->patient[x].medication_ord[nCnt].med_ordering_resource_cd				= cnvtstring(oa.order_provider_id)
		    Pat_tmp->patient[x].medication_ord[nCnt].med_ordering_resource_firstname		= pers.name_first
		    Pat_tmp->patient[x].medication_ord[nCnt].med_ordering_resource_lastname			= pers.name_last
		    Pat_tmp->patient[x].medication_ord[nCnt].med_ordering_resource_middlename		= "%"
		    Pat_tmp->patient[x].medication_ord[nCnt].medication_therapeutic_class			= ac.long_description
		    Pat_tmp->patient[x].medication_ord[nCnt].medication_order_date
		    	= format(o.orig_order_dt_tm,"YYYYmmddHHmmss;;d")
 
		    if(o.orig_ord_as_flag = 0)
		    	Pat_tmp->patient[x].medication_ord[nCnt].medication_order_status				;order status
		    		= uar_get_code_description(o.order_status_cd)
		    else
		    	Pat_tmp->patient[x].medication_ord[nCnt].medication_order_status 			= "Rx"
		    endif
		    Pat_tmp->patient[x].medication_ord[nCnt].medication_instructions				;clinical display line
		    		= substring(1,250,o.clinical_display_line)
		    Pat_tmp->patient[x].medication_ord[nCnt].medication_start_date					;current start dt/tm
		    	= format(o.current_start_dt_tm,"YYYYmmddHHmmss;;d")
		    if(o.projected_stop_dt_tm > NULL)
		    	Pat_tmp->patient[x].medication_ord[nCnt].medication_stop_date				;projected stop dt/tm
		    		= format(o.projected_stop_dt_tm,"YYYYmmddHHmmss;;d")
		    else
		    	Pat_tmp->patient[x].medication_ord[nCnt].medication_stop_date				= "%"
		    endif
 
		    if(oi.strength > 0 and oi.volume > 0 OR oi.strength > 0 and oi.volume = 0); if both strength and volume are present,
		    																			 ; display strength and units
		    																			 ; or just display strength
		    	Pat_tmp->patient[x].medication_ord[nCnt].medication_dose_quantity 			= cnvtstring(oi.strength)
		    	Pat_tmp->patient[x].medication_ord[nCnt].medication_dose_unit
		    		= uar_get_code_description(oi.strength_unit)
		    elseif(oi.strength = 0 and oi.volume > 0) ;strength is NULL, but volume is present
		    	Pat_tmp->patient[x].medication_ord[nCnt].medication_dose_quantity			= cnvtstring(oi.volume)
		    	Pat_tmp->patient[x].medication_ord[nCnt].medication_dose_unit
		    		= uar_get_code_description(oi.volume_unit)
		    else									  ;no strength or volume
		    	Pat_tmp->patient[x].medication_ord[nCnt].medication_dose_quantity 			= "%"
		    	Pat_tmp->patient[x].medication_ord[nCnt].medication_dose_unit				= "%"
		    endif
 
		    if(od.oe_field_display_value > " ")
				Pat_tmp->patient[x].medication_ord[nCnt].medication_route			= od.oe_field_display_value
			else
				Pat_tmp->patient[x].medication_ord[nCnt].medication_route			= "%"
			endif
 
		foot o.order_id
		stat = alterlist(pat_tmp->patient[x]->medication_ord, ncnt)
		with nocounter, outerjoin = d
  call echo("meds finished")
end