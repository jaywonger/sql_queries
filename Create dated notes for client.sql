/********************************************************************* 
	Workitem:	PRo071 - Training DB Refresh Process (227916)
	Summary:	Create client dated notes

	Date            Author                  Notes
	-----------     --------------------    -------------------------
	17-June-2021     Jason Wong              Initial version
*********************************************************************/
/** Variables **/
declare @clientID varchar(14),
		@noteID varchar(14),
		@deptID varchar(14),
		@intake datetime,
		@intakeuser varchar(10);
declare @datedNotes table (clientID varchar(14), noteID varchar(14),deptID varchar(14), intake datetime, intakeuser varchar(10));

/** Set dated notes values here **/
insert @datedNotes values 
	('TESTCLT0001','TESTNOT0001','CGH792373270', GETDATE(), 'PAdmin'),	-- HS Bella Coola
	('TESTCLT0002','TESTNOT0002','NSH123', GETDATE(), 'PAdmin'),		-- HS North Shore
	('TESTCLT0003','TESTNOT0003','PR123', GETDATE(), 'PAdmin'),			-- HS Powell River
	('TESTCLT0004','TESTNOT0004','N0000000020', GETDATE(), 'PAdmin'),	-- HS Richmond
	('TESTCLT0005','TESTNOT0005','Coas868939024',GETDATE(), 'PAdmin'),	-- HS Sea to Sky
	('TESTCLT0006','TESTNOT0006','S123',GETDATE(), 'PAdmin'),			-- HS Sunshine Coast
	('TESTCLT0007','TESTNOT0007','N0000000006',GETDATE(), 'PAdmin'),	-- HS Vancouver (North)
	('TESTCLT0008','TESTNOT0008','N0000000006',GETDATE(), 'PAdmin'),	-- HS Vancouver (South)
	('TESTCLT0009','TESTNOT0009','N0000000006',GETDATE(), 'PAdmin');	-- HS Vancouver (West)
declare CLT_CURSOR cursor for 
	select *
	from @datedNotes

/** Create each dated note **/
open CLT_CURSOR;
fetch next from CLT_CURSOR into @clientID,@noteID,@deptID,@intake,@intakeuser
while @@FETCH_STATUS = 0
begin
	/** Dated Notes Setup **/

	--dated notes creation
	insert into DATEDNOTES
	(NOTE_ID, NOTEDATE, DATE_IN, SUBJECT, CONTENTS, ENTRYBY, TIME_IN, CHGDATE, CHGUSER)
	values
	(@noteID, GETDATE(), GETDATE(), 'TEST', 'TEST', 'ProcuraAdmin', GETDATE(), GETDATE(), 'ProcuraAdmin')
	
	fetch next from CLT_CURSOR into @clientID,@noteID,@deptID,@intake,@intakeuser;
end;
close CLT_CURSOR;

deallocate CLT_CURSOR;