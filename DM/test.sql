(expand for query)
SELECT 
		detail_tour.ID
		,detail_tour.ORD_NUM
		,detail_tour.TICKET_CATE
		,detail_tour.CONFIRMATION_STATUS
		,detail_tour.ORD_ITEM_STATUS
		,CBL_TOUR_STATUS.CB_NAME AS TOUR_STATUS
		,detail_tour.TOUR_DATE
		,CASE 
			WHEN MIN(detail_tour.TOUR_START_TIME) IS NOT NULL 
			THEN SUBSTR('0' || FLOOR(MIN(detail_tour.TOUR_START_TIME)/60), -2, 2)
				|| ':' || 
				SUBSTR('0' || MOD(MIN(detail_tour.TOUR_START_TIME),60), -2, 2)
			ELSE NULL
			END AS TOUR_START_TIME
		,CASE 
			WHEN MAX(detail_tour.TOUR_END_TIME) IS NOT NULL 
			THEN SUBSTR('0' || FLOOR(MAX(detail_tour.TOUR_END_TIME)/60), -2, 2)
				|| ':' || 
				SUBSTR('0' || MOD(MAX(detail_tour.TOUR_END_TIME),60), -2, 2)
			ELSE NULL
			END AS TOUR_END_TIME
		,MAX(detail_tour.TOUR_DURATION) AS TOUR_DURATION_MINUTES_QTY
		,detail_tour.TICKET_PRICE_AMT
		,detail_tour.FEE
		,detail_tour.TAX
		,detail_tour.DISCNT
		,SUM(detail_tour.TOTAL_QTY) AS TOTAL_QTY
		,SUM(detail_tour.PRINTED_CNT) AS PRINTED_CNT
		,SUM(detail_tour.ADULT_13_OVER) AS ADULT_13_OVER
		,SUM(detail_tour.YOUTH) AS YOUTH
		,SUM(detail_tour.SIX_UP) AS SIX_UP
		,SUM(detail_tour.FIVE_UNDER) AS FIVE_UNDER
		,SUM(detail_tour.TWO_UNDER) AS TWO_UNDER
		,SUM(detail_tour.GA) AS GA
		,SUM(detail_tour.GAC) AS GAC
		,SUM(detail_tour.TOUR_GUIDE) AS TOUR_GUIDE
		,SUM(detail_tour.SELF_GUIDED_AUDIO) AS SELF_GUIDED_AUDIO
		,SUM(detail_tour.SELF_GUIDED_NON_AUDIO) AS SELF_GUIDED_NON_AUDIO
		,SUM(detail_tour.MOTORCOACH) AS MOTORCOACH
		,SUM(detail_tour.ALL_TYPES) AS ALL_TYPES
		,SUM(detail_tour.SENIOR) AS SENIOR
		,SUM(detail_tour.DVET) AS DVET
		,SUM(detail_tour.COMP) AS COMP
		,SUM(detail_tour.GENERAL_ADMISSION) AS GENERAL_ADMISSION
		,SUM(detail_tour.ADULT_PRE_PAID) AS ADULT_PRE_PAID
		,SUM(detail_tour.CHILD_12_UNDER) AS CHILD_12_UNDER
		,SUM(detail_tour.STUDENT_1_SITE) AS STUDENT_1_SITE
		,SUM(detail_tour.STUDENT_2_SITE) AS STUDENT_2_SITE
		,SUM(detail_tour.STUDENT_3_SITE) AS STUDENT_3_SITE
		,SUM(detail_tour.ADULT_W10_STUDENTS) AS ADULT_W10_STUDENTS
		,SUM(detail_tour.BUS_DRIVER) AS BUS_DRIVER
		,SUM(detail_tour.CHILDREN_0_5) AS CHILDREN_0_5
		,SUM(detail_tour.CHILDREN_6_15) AS CHILDREN_6_15
		,SUM(detail_tour.STUDENT) AS STUDENT
		,SUM(detail_tour.FAMILY) AS FAMILY
		,SUM(detail_tour.CHILD_0_4) AS CHILD_0_4
		,SUM(detail_tour.CHILD_5_12) AS CHILD_5_12
		,SUM(detail_tour.SCHOOL_GROUP) AS SCHOOL_GROUP
		,SUM(detail_tour.YOUTH_GROUP) AS YOUTH_GROUP
		,SUM(detail_tour.ACTIVE_RETIRED_MILITARY) AS ACTIVE_RETIRED_MILITARY
		,SUM(detail_tour.GROUP_ENTRY) AS GROUP_ENTRY
FROM (

		SELECT
			OIT.ID
			,ORD.ORD_NUM
			,CBL_TICKET_CATE.CB_NAME AS TICKET_CATE
			,CBL_ORD_CONF_STATUS.CB_NAME AS CONFIRMATION_STATUS
			,CBL_ORD_ITEM_STATUS.CB_NAME AS ORD_ITEM_STATUS
			,(SELECT MAX(TI.STATUS_ID) FROM O_TOUR_INSTANCE TI WHERE TI.ORD_ITEM_ID = OIT.ID) AS TOUR_STATUS
			,OIT.start_date AS TOUR_DATE
			,T_INV.START_TIME AS TOUR_START_TIME
			,
      CASE
      WHEN T_INV.END_TIME <> 0
        THEN T_INV.END_TIME
      ELSE NULL
      END AS TOUR_END_TIME
			,P.DURATION TOUR_DURATION
			,OIT.FEE + OIT.TAX - OIT.DISCNT AS TICKET_PRICE_AMT
			,OIT.FEE
			,OIT.TAX
			,OIT.DISCNT
			,(SELECT SUM(QTY) FROM O_TICKET_QUANTITY OTQ WHERE OTQ.TOUR_INSTANCE_ID = TI.ID) AS TOTAL_QTY
			,(SELECT COUNT(ID) FROM O_TICKET_PRNT TP WHERE TP.STATUS IN (1,3) AND TP.TOUR_INSTANCE_ID = TI.ID) AS PRINTED_CNT
			,TICKET_TYPE.Adult_13_OVER
			,TICKET_TYPE.Youth
			,TICKET_TYPE.six_up
			,TICKET_TYPE.five_under
			,TICKET_TYPE.two_under
			,TICKET_TYPE.GA
			,TICKET_TYPE.GAC
			,TICKET_TYPE.Tour_Guide
			,TICKET_TYPE.Self_Guided_Audio
			,TICKET_TYPE.Self_Guided_Non_Audio
			,TICKET_TYPE.Motorcoach
			,TICKET_TYPE.All_TYPES
			,TICKET_TYPE.Senior
			,TICKET_TYPE.DVET
			,TICKET_TYPE.COMP
			,TICKET_TYPE.General_Admission
			,TICKET_TYPE.Adult_Pre_Paid
			,TICKET_TYPE.Child_12_under
			,TICKET_TYPE.Student_1_site
			,TICKET_TYPE.Student_2_site
			,TICKET_TYPE.Student_3_site
			,TICKET_TYPE.Adult_w10_students
			,TICKET_TYPE.Bus_Driver
			,TICKET_TYPE.Children_0_5
			,TICKET_TYPE.Children_6_15
			,TICKET_TYPE.Student
			,TICKET_TYPE.Family
			,TICKET_TYPE.Child_0_4
			,TICKET_TYPE.Child_5_12
			,TICKET_TYPE.School_Group
			,TICKET_TYPE.Youth_Group
			,TICKET_TYPE.Active_Retired_Military
			,TICKET_TYPE.Group_Entry
		FROM O_ORDER ORD
		INNER JOIN O_ORD_ITEM OIT ON ORD.ID = OIT.ORD_ID
    INNER JOIN P_PRD P ON P.PRD_ID = OIT.PRD_ID
		LEFT JOIN O_TOUR_INSTANCE TI ON TI.ORD_ITEM_ID = OIT.ID
		LEFT JOIN O_TOUR_INSTANCE_INV TII ON TII.TOUR_INSTANCE_ID = TI.ID
		LEFT JOIN I_TOUR_INV T_INV ON T_INV.ID = TII.TOUR_INV_ID
		LEFT JOIN D_REF_CB_DICTIONARY CBL_TICKET_CATE ON CBL_TICKET_CATE.CB_ID = ORD.SALES_CAT_ID AND CBL_TICKET_CATE.CB_base_class = 'com.reserveamerica.system.product.configurable.SalesCategory'
		LEFT JOIN D_REF_CB_DICTIONARY CBL_ORD_CONF_STATUS ON CBL_ORD_CONF_STATUS.CB_ID = OIT.CONF_STATUS_ID AND CBL_ORD_CONF_STATUS.CB_base_class = 'com.reserveamerica.system.order.common.ConfirmationStatus'
		LEFT JOIN D_REF_CB_DICTIONARY CBL_ORD_ITEM_STATUS ON CBL_ORD_ITEM_STATUS.CB_ID = OIT.STATUS_ID AND CBL_ORD_ITEM_STATUS.CB_base_class = 'com.reserveamerica.system.order.common.OrderItemStatus'
		LEFT JOIN (SELECT TOUR_INSTANCE_ID, ADMISSION_TYPE_ID, QTY FROM O_TICKET_QUANTITY) 
		  PIVOT(MAX(QTY) FOR ADMISSION_TYPE_ID IN (
					 '1' AS Adult_13_OVER,
					 '2' AS Youth,
					 '3' AS six_up,
					 '4' AS five_under,
					 '5' AS two_under,
					 '6' AS GA,
					 '7' AS GAC,
					 '8' AS Tour_Guide,
					 '9' AS Self_Guided_Audio,
					 '10' AS Self_Guided_Non_Audio,
					 '11' AS Motorcoach,
					 '13' AS All_TYPES,
					 '14' AS Senior,
					 '15' AS DVET,
					 '16' AS COMP,
					 '17' AS General_Admission,
					 '28' AS Adult_Pre_Paid,
					 '18' AS Child_12_under,
					 '19' AS Student_1_site,
					 '20' AS Student_2_site,
					 '21' AS Student_3_site,
					 '22' AS Adult_w10_students,
					 '23' AS Bus_Driver,
					 '24' AS Children_0_5,
					 '25' AS Children_6_15,
					 '26' AS Student,
					 '27' AS Family,
					 '29' AS Child_0_4,
					 '30' AS Child_5_12,
					 '31' AS School_Group,
					 '32' AS Youth_Group,
					 '33' AS Active_Retired_Military,
					 '34' AS Group_Entry
								 )) TICKET_TYPE ON TI.ID = TICKET_TYPE.TOUR_INSTANCE_ID
		WHERE ORD.ORD_CAT_ID = 2 AND OIT.TYPE_ID = 2	
) detail_tour
LEFT JOIN D_REF_CB_DICTIONARY CBL_TOUR_STATUS ON CBL_TOUR_STATUS.CB_ID = detail_tour.TOUR_STATUS AND CBL_TOUR_STATUS.CB_base_class = 'com.reserveamerica.system.order.common.TourInstanceStatus'
GROUP BY 
		detail_tour.ID
		,detail_tour.ORD_NUM
		,detail_tour.TICKET_CATE
		,detail_tour.CONFIRMATION_STATUS
		,detail_tour.ORD_ITEM_STATUS
		,CBL_TOUR_STATUS.CB_NAME
		,detail_tour.TOUR_DATE
		,detail_tour.TICKET_PRICE_AMT
		,detail_tour.FEE
		,detail_tour.TAX
		,detail_tour.DISCNT