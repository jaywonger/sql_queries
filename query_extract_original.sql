SELECT 
      substring([HOSPNO],4,len([HOSPNO])) AS CWMRN
	  ,'VPP_CW' as MRNLOCID
	  ,[SOCIAL_SECURITY] AS PHN
      ,[LASTNAME]
      ,[FIRSTNAME]
      ,SUBSTRING([SEX],1,1) AS GENDER
      ,FORMAT([DOB],'yyyy-MM-dd') as DOB
	  ,'202201200900' AS DTRANS
	  ,'B' AS RTBFLAG

    
  FROM [SHIREPROD2020].[dbo].[PATIENT]
  where [HOSPNO] is not null
  AND [DECEASED_DATE] is null
  AND [HOSPNO] like '[C][W][H][0-9]%'
  AND [CERNER_MRN] is  null 
  AND LEN([SOCIAL_SECURITY]) = 10