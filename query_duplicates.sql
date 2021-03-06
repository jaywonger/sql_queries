SELECT [HOSPNO]
		,[LASTNAME]
		,[FIRSTNAME]
		,FORMAT(getdate(), 'yyyyMMdd') AS DTRANS
		,'B' AS RTBFLAG
		,COUNT(*) as DUPLICATES
		--,[UPDATEDDATE]
		--,[UPDATEDTIME]
FROM [SHIREProd2020].[dbo].[PATIENT]
where [HOSPNO] is not null
	AND [DECEASED_DATE] is null
	AND [HOSPNO] like '[C][W][H][0-9]%'
	AND [CERNER_MRN] is  null
	AND LEN([SOCIAL_SECURITY]) = 10
GROUP BY [HOSPNO], LASTNAME, FIRSTNAME
HAVING ( COUNT(*) > 1 )

ORDER BY [HOSPNO] ASC