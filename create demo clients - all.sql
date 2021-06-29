/********************************************************************* 
	Workitem:	PRo071 - Training DB Refresh Process (227916)
	Summary:	Create client demo accounts for HS Vancouver

	Date            Author                  Notes
	-----------     --------------------    -------------------------
	19-May-2021     Alex Hsu                Initial version
*********************************************************************/
/** Variables **/
declare @clientID varchar(14),
		@lastName varchar(30),
		@firstName varchar(20),
		@area varchar(5),
		@deptID varchar(14),
		@branchID varchar(1) = (select substring(branch_id, 1, 1) from system),
		@newID varchar(14),
		@nextSyskey varchar(14),
		@comments varchar(max),
		@funderID varchar(14);
declare @trainingAccounts table (clientID varchar(14), lastName varchar(30), firstName varchar(20), area varchar(5), deptID varchar(14), funderID varchar(14));

/** Set account values here **/
insert @trainingAccounts values 
	('TESTCLT0001','VanTrain','Anthony','B*','CGH792373270', 'CGH511562359'),	-- HS Bella Coola
	('TESTCLT0002','VanTrain','Brutus','N*','NSH123', 'NSH100012'),				-- HS North Shore
	('TESTCLT0003','VanTrain','Chris','P*','PR123', 'PR164400'),				-- HS Powell River
	('TESTCLT0004','VanTrain','Dawn','R*','N0000000020', ''),					-- HS Richmond
	('TESTCLT0005','VanTrain','Emanuelle','S*','Coas868939024', 'Coas667087355'),-- HS Sea to Sky
	('TESTCLT0006','VanTrain','Ferdinand','C*','S123', 'S512229273'),			-- HS Sunshine Coast
	('TESTCLT0007','VanTrain','Georgina','VN*','N0000000006', 'N0000000066'),	-- HS Vancouver (North)
	('TESTCLT0008','VanTrain','Hannah','VS*','N0000000006', 'N0000000066'),		-- HS Vancouver (South)
	('TESTCLT0009','VanTrain','Ivan','VW*','N0000000006', 'N0000000066');		-- HS Vancouver (West)
declare CLT_CURSOR cursor for 
	select *
	from @trainingAccounts

/** Create each account **/
open CLT_CURSOR;
fetch next from CLT_CURSOR into @clientID,@lastName,@firstName,@area,@deptID,@funderID
while @@FETCH_STATUS = 0
begin
	/** Client Account Setup **/
	insert into CLTVISITORS
	values
	(@clientID,null,'S')

	insert into CLIENTS
	(CLIENT_ID,LASTNAME,FIRSTNAME,AREA,EMAILADDR,INTAKEUSER,INTAKEDATE,INTAKETIME,CHGDATE,CHGUSER,TZID)
	values 
	(@clientID,@lastName,@firstName,@area,@firstName+'.'+@lastName+'@vch.ca','ProcuraAdmin',GETDATE(),GETDATE(),GETDATE(),'ProcuraAdmin','America/Vancouver')

	insert into CLTDEPT 
	(CLTVISITOR_ID,DEPT_ID,STATUS,CLTCONFIRM,STARTDATE,INTAKEDATE,INTAKEUSER,CHGDATE,CHGUSER, EXCLCALLME)
	values 
	(@clientID,@deptID,'A','T',GETDATE(),GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin','F')

	-- PARIS #
	exec pp_sys_get_next_id 'CL_REFNOS', 1, @nextSyskey output
	set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
	insert into CL_REFNOS(REFNUM_ID,NUMBER_ID,CLIENT_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER)
	select @newID,'N0000000003',@clientID,'55555',GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN'

	-- PHN #
	exec pp_sys_get_next_id 'CL_REFNOS', 1, @nextSyskey output
	set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
	insert into CL_REFNOS (REFNUM_ID,NUMBER_ID,CLIENT_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER)
	select @newID,'NSH68567599',@clientID,'5555555555',GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN'
	
	-- client visit
	insert into ORDERS
	(ORDER_ID, DEPT_ID, FUNDER_ID, CLIENT_ID, COMMENTS, DESCR, STARTDATE, INTAKEUSER, CHGDATE, CHGUSER)
	values
	(@clientID, @deptID, @funderID, @clientID,'Comments^7','TEST TEST', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin')

	-- careplan/visit
	insert into CLTACTC
	(CLIENT_ID, DEPT_ID, CHGUSER, CLTACTC_ID, ACTIVITY_ID, INTAKE, INTAKEUSER, CHGDATE)
	values
	(@clientID, @deptID, 'ProcuraAdmin', @branchID + right('0000000000' + @nextSyskey, 10), 'T0000000125', GETDATE(), 'ProcuraAdmin', GETDATE())


	fetch next from CLT_CURSOR into @clientID,@lastName,@firstName,@area,@deptID,@funderID;
end;
close CLT_CURSOR;

deallocate CLT_CURSOR;