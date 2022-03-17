SELECT DISTINCT substring([HOSPNO],4,len([HOSPNO])) AS CWMRN
      ,'VPP_CW' as MRNLOCID
	  ,[SOCIAL_SECURITY] AS PHN
      ,[LASTNAME]
      ,[FIRSTNAME]
      ,SUBSTRING([SEX],1,1) AS GENDER
      ,FORMAT([DOB],'yyyyMMdd') as DOB
	  ,FORMAT(getdate(), 'yyyyMMddHHmm') AS DTRANS -- convert transaction time to text
	  ,'B' AS RTBFLAG
	  ,FORMAT([UPDATEDDATE], 'yyyyMMdd') AS UPDATEDATE
      ,FORMAT([UPDATEDTIME], 'yyyyMMddHHmmss') AS UPDATETIME
    
  FROM [SHIREPROD2020].[dbo].[PATIENT]
  where [HOSPNO] is not null
  AND [DECEASED_DATE] is null
  AND [HOSPNO] like '[C][W][H][0-9]%'
  AND [CERNER_MRN] is  null
  AND LEN([SOCIAL_SECURITY]) = 10

  ORDER BY CWMRN ASC