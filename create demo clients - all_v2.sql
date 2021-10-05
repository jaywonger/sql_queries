/********************************************************************* 
	Workitem:	PRo071 - Training DB Refresh Process (227916)
	Summary:	Create client demo accounts for HS Vancouver

	Date            Author                  Notes
	-----------     --------------------    -------------------------
	19-May-2021     Alex Hsu                Initial version
	06-Aug-2021		Jason Wong				Updated from UR revision
	14-Sep-2021		Jason Wong				Added error handling 
	17-Sep-2021		Jason Wong				Updated error handling 
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
	('TESTCLT0010','BellaCoola','Anthony','B*','CGH792373270', 'CGH511562359'),	-- HS Bella Coola
	('TESTCLT0011','NorthShore','Brutus','N*','NSH123', 'NSH100012'),			-- HS North Shore
	('TESTCLT0012','PowellRiver','Chris','P*','PR123', 'PR164400'),				-- HS Powell River
	('TESTCLT0013','Richmond','Dawn','R*','N0000000020', ''),					-- HS Richmond
	('TESTCLT0014','STS','Emanuelle','S*','Coas868939024', 'Coas667087355'),	-- HS Sea to Sky
	('TESTCLT0015','Sunshine','Ferdinand','C*','S123', 'S512229273'),			-- HS Sunshine Coast
	('TESTCLT0016','VanNorth','Georgina','VN*','N0000000006', 'N0000000066'),	-- HS Vancouver (North)
	('TESTCLT0017','VanSouth','Hannah','VS*','N0000000006', 'N0000000066'),		-- HS Vancouver (South)
	('TESTCLT0018','VanWest','Ivan','VW*','N0000000006', 'N0000000066');		-- HS Vancouver (West)
declare CLT_CURSOR cursor for 
	select *
	from @trainingAccounts

/** Create each account **/
open CLT_CURSOR;
fetch next from CLT_CURSOR into @clientID,@lastName,@firstName,@area,@deptID,@funderID
while @@FETCH_STATUS = 0
begin
	/** Client Account Setup **/
	begin try
		insert into CLTVISITORS	
		select top 1 @clientID,null,'S'
		from CLTVISITORS
		where NOT EXISTS (select CLTVISITOR_ID
						  from CLTVISITORS 
						  where CLTVISITOR_ID = @clientID)

		insert into CLIENTS (CLIENT_ID,LASTNAME,FIRSTNAME,AREA,EMAILADDR,INTAKEUSER,INTAKEDATE,INTAKETIME,CHGDATE,CHGUSER,TZID)	 
		select top 1 @clientID,@lastName,@firstName,@area,@firstName+'.'+@lastName+'@vch.ca','ProcuraAdmin',GETDATE(),GETDATE(),GETDATE(),'ProcuraAdmin','America/Vancouver'
		from CLIENTS
		where NOT EXISTS (select CLIENT_ID
						  from CLIENTS 
						  where CLIENT_ID = @clientID)

		insert into CLTDEPT	(CLTVISITOR_ID,DEPT_ID,STATUS,CLTCONFIRM,STARTDATE,INTAKEDATE,INTAKEUSER,CHGDATE,CHGUSER, EXCLCALLME)  
		select top 1 @clientID,@deptID,'A','T',GETDATE(),GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin','F'
		from CLTDEPT
		where NOT EXISTS (select CLTVISITOR_ID
						  from CLTDEPT 
						  where CLTVISITOR_ID = @clientID)
	end try
	begin catch
		select ERROR_MESSAGE() AS ErrorMessage
	end catch
	
	
	--- General Information ---
	begin try
		exec pp_sys_get_next_id 'CL_REFNOS', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CL_REFNOS(REFNUM_ID,NUMBER_ID,CLIENT_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER)
		select top 1 @newID,'N0000000010',@clientID,'',GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN' -- AGA Support Form
		from CL_REFNOS
		where NOT EXISTS (select CLIENT_ID
						  from CL_REFNOS 
						  where CLIENT_ID = @clientID
						  and NUMBER_ID = 'N0000000010')

		exec pp_sys_get_next_id 'CL_REFNOS', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CL_REFNOS(REFNUM_ID,NUMBER_ID,CLIENT_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER)
		select top 1 @newID,'N0000000011',@clientID,'',GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN' -- Behaviour Care Plan
		from CL_REFNOS
		where NOT EXISTS (select CLIENT_ID
						  from CL_REFNOS 
						  where CLIENT_ID = @clientID
						  and NUMBER_ID = 'N0000000011')

		exec pp_sys_get_next_id 'CL_REFNOS', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CL_REFNOS(REFNUM_ID,NUMBER_ID,CLIENT_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER)
		select top 1 @newID,'N0000000019',@clientID,'',GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN' -- Consistency
		from CL_REFNOS
		where NOT EXISTS (select CLIENT_ID
						  from CL_REFNOS 
						  where CLIENT_ID = @clientID
						  and NUMBER_ID = 'N0000000019')

		exec pp_sys_get_next_id 'CL_REFNOS', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CL_REFNOS(REFNUM_ID,NUMBER_ID,CLIENT_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER)
		select top 1 @newID,'N0000000009',@clientID,'',GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN' -- No CPR Form
		from CL_REFNOS
		where NOT EXISTS (select CLIENT_ID
						from CL_REFNOS 
						where CLIENT_ID = @clientID
						and NUMBER_ID = 'N0000000009')
	
		exec pp_sys_get_next_id 'CL_REFNOS', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CL_REFNOS(REFNUM_ID,NUMBER_ID,CLIENT_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER)
		select top 1 @newID,'N0000000012',@clientID,'',GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN' -- Notification Expected Death
		from CL_REFNOS
		where NOT EXISTS (select CLIENT_ID
						  from CL_REFNOS 
						  where CLIENT_ID = @clientID
						  and NUMBER_ID = 'N0000000012')

		exec pp_sys_get_next_id 'CL_REFNOS', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CL_REFNOS(REFNUM_ID,NUMBER_ID,CLIENT_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER)
		select top 1 @newID,'N0000000003',@clientID,'55555',GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN' -- PARIS #
		from CL_REFNOS
		where NOT EXISTS (select CLIENT_ID
						  from CL_REFNOS 
						  where CLIENT_ID = @clientID
						  and NUMBER_ID = 'N0000000003')

		exec pp_sys_get_next_id 'CL_REFNOS', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CL_REFNOS (REFNUM_ID,NUMBER_ID,CLIENT_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER)
		select top 1 @newID,'NSH68567599',@clientID,'5555555555',GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN' -- PHN #
		from CL_REFNOS
		where NOT EXISTS (select CLIENT_ID
						  from CL_REFNOS 
						  where CLIENT_ID = @clientID
						  and NUMBER_ID = 'NSH68567599')
	
		exec pp_sys_get_next_id 'CL_REFNOS', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CL_REFNOS(REFNUM_ID,NUMBER_ID,CLIENT_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER)
		select top 1 @newID,'N0000000007',@clientID,'',GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN' -- Urgent Response 
		from CL_REFNOS
		where NOT EXISTS (select CLIENT_ID
						  from CL_REFNOS 
						  where CLIENT_ID = @clientID
						  and NUMBER_ID = 'N0000000007')
	end try
	begin catch
		select ERROR_MESSAGE() AS ErrorMessage
	end catch
	--- END of General Information ---

	-- Visit History (one by one adding) Bella Coola
	begin try 
		if not exists (select * from CLNTRESORC
					   where CLTVISITOR_ID = @clientID
					   AND DEPT_ID = @deptID
					   AND (RES_ID = 'N0000001058' OR RES_ID = 'CGH763890023' OR RES_ID = 'T0000000612' OR RES_ID = 'T0000000774' OR RES_ID = 'T0000000674'
					   OR RES_ID = 'N0000001853' OR RES_ID = 'T0000000658' OR RES_ID = 'T0000000055' OR RES_ID = 'T0000000732')) 
		begin
			insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER) values
			(@clientID, @deptID, 'N0000001058', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin'),
			(@clientID, @deptID, 'CGH763890023', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin'),
			(@clientID, @deptID, 'T0000000612', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin'),
			(@clientID, @deptID, 'T0000000774', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin'),
			(@clientID, @deptID, 'T0000000674', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin'),
			(@clientID, @deptID, 'N0000001853', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin'),
			(@clientID, @deptID, 'T0000000658', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin'),
			(@clientID, @deptID, 'T0000000055', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin'),
			(@clientID, @deptID, 'T0000000732', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin');
		end
	end try
	begin catch
		select ERROR_MESSAGE() AS ErrorMessage
	end catch

	/**
	-- Visit History (one by one adding) North Shore
	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'N0000001147', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'N0000000881', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'N0000000257', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'N0000002134', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'NSH2894', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'N0000000137', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000658', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'N0000001991', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000449', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	-- Visit History (one by one adding) Powell River
	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000858', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000348', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'CGH750935589', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000501', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'PR1163', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'CGH819708159', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000575', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'CGH792651509', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'N0000001015', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	-- Visit History (one by one adding) Richmond (needs to be updated)
	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000858', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000348', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'CGH750935589', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000501', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'PR1163', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'CGH819708159', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000575', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'CGH792651509', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'N0000001015', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	-- Visit History (one by one adding) Sea-to-Sky
	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'Coas691926477', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000758', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'Coas770670663', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000795', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'CGH824673749', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'N0000001055', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'N0000000981', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'CGH250461045', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000639', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	-- Visit History (one by one adding) Sunshine Coast (needs to be updated)
	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'Coas691926477', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000758', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'Coas770670663', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000795', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'CGH824673749', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'N0000001055', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'N0000000981', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'CGH250461045', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000639', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	-- Visit History (one by one adding) Vancouver N
	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'Coas691926477', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000758', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'Coas770670663', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000795', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'CGH824673749', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'N0000001055', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'N0000000981', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'CGH250461045', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000639', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

		-- Visit History (one by one adding) Vancouver S
	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'Coas691926477', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000758', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'Coas770670663', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000795', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'CGH824673749', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'N0000001055', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'N0000000981', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'CGH250461045', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000639', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

		-- Visit History (one by one adding) Vancouver W
	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'Coas691926477', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000758', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'Coas770670663', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000795', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'CGH824673749', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'N0000001055', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'N0000000981', 'Trained Client Speci', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'CGH250461045', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';

	insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
	select @clientID, @deptID, 'T0000000639', 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin';
	**/
	

	-- Careplan/Visit
	begin try
		exec pp_sys_get_next_id 'CLTACTC', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CLTACTC(CLTACTC_ID, ACTIVITY_ID, CLIENT_ID, DEPT_ID, CHANGED, FREQTYPE, DAYFREQ, ARCHIVED, INTAKE, INTAKEUSER, CHGDATE, CHGUSER)
		select top 1 @newID, 'N0000000269', @clientID, @deptID, 'F', 'D', 'O', 'F', GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin' -- Respiratory Screening Question N0000000269
		from CLTACTC
		where NOT EXISTS (select CLIENT_ID
						  from CLTACTC 
						  where CLIENT_ID = @clientID
						  and ACTIVITY_ID = 'N0000000269'
						  and DEPT_ID = @deptID)

		exec pp_sys_get_next_id 'CLTACTC', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CLTACTC(CLTACTC_ID, ACTIVITY_ID, CLIENT_ID, DEPT_ID, CHANGED, FREQTYPE, DAYFREQ, ARCHIVED, INTAKE, INTAKEUSER, CHGDATE, CHGUSER) 
		select top 1 @newID, 'T0000000192', @clientID, @deptID, 'F', 'D', 'O', 'F', GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin' -- Bathing Assignable T0000000192
		from CLTACTC
		where NOT EXISTS (select CLIENT_ID
						from CLTACTC 
						where CLIENT_ID = @clientID
						and ACTIVITY_ID = 'T0000000192')
	
		exec pp_sys_get_next_id 'CLTACTC', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CLTACTC(CLTACTC_ID, ACTIVITY_ID, CLIENT_ID, DEPT_ID, CHANGED, FREQTYPE, DAYFREQ, ARCHIVED, INTAKE, INTAKEUSER, CHGDATE, CHGUSER) 
		select top 1 @newID, 'T0000000196', @clientID, @deptID, 'F', 'D', 'O', 'F', GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin' -- Pericare Assignable T0000000196
		from CLTACTC
		where NOT EXISTS (select CLIENT_ID
						from CLTACTC 
						where CLIENT_ID = @clientID
						and ACTIVITY_ID = 'T0000000196')
	
		exec pp_sys_get_next_id 'CLTACTC', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CLTACTC(CLTACTC_ID, ACTIVITY_ID, CLIENT_ID, DEPT_ID, CHANGED, FREQTYPE, DAYFREQ, ARCHIVED, INTAKE, INTAKEUSER, CHGDATE, CHGUSER) 
		select top 1 @newID, 'T0000000200', @clientID, @deptID, 'F', 'D', 'O', 'F', GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin' -- Hair Care Assignable T0000000200
		from CLTACTC
		where NOT EXISTS (select CLIENT_ID
						from CLTACTC 
						where CLIENT_ID = @clientID
						and ACTIVITY_ID = 'T0000000200')
	
		exec pp_sys_get_next_id 'CLTACTC', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CLTACTC(CLTACTC_ID, ACTIVITY_ID, CLIENT_ID, DEPT_ID, CHANGED, FREQTYPE, DAYFREQ, ARCHIVED, INTAKE, INTAKEUSER, CHGDATE, CHGUSER) 
		select top 1 @newID, 'T0000000202', @clientID, @deptID, 'F', 'D', 'O', 'F', GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin' -- Facial Shaving Assignable T0000000202
		from CLTACTC
		where NOT EXISTS (select CLIENT_ID
						from CLTACTC 
						where CLIENT_ID = @clientID
						and ACTIVITY_ID = 'T0000000202')
	
		exec pp_sys_get_next_id 'CLTACTC', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CLTACTC(CLTACTC_ID, ACTIVITY_ID, CLIENT_ID, DEPT_ID, CHANGED, FREQTYPE, DAYFREQ, ARCHIVED, INTAKE, INTAKEUSER, CHGDATE, CHGUSER) 
		select top 1 @newID, 'T0000000204', @clientID, @deptID, 'F', 'D', 'O', 'F', GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin' -- Oral Care A T0000000204
		from CLTACTC
		where NOT EXISTS (select CLIENT_ID
						from CLTACTC 
						where CLIENT_ID = @clientID
						and ACTIVITY_ID = 'T0000000204')
	
		exec pp_sys_get_next_id 'CLTACTC', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CLTACTC(CLTACTC_ID, ACTIVITY_ID, CLIENT_ID, DEPT_ID, CHANGED, FREQTYPE, DAYFREQ, ARCHIVED, INTAKE, INTAKEUSER, CHGDATE, CHGUSER) 
		select top 1 @newID, 'T0000000209', @clientID, @deptID, 'F', 'D', 'O', 'F', GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin' -- Dressing A T0000000209
		from CLTACTC
		where NOT EXISTS (select CLIENT_ID
						from CLTACTC 
						where CLIENT_ID = @clientID
						and ACTIVITY_ID = 'T0000000209')
	
		exec pp_sys_get_next_id 'CLTACTC', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CLTACTC(CLTACTC_ID, ACTIVITY_ID, CLIENT_ID, DEPT_ID, CHANGED, FREQTYPE, DAYFREQ, ARCHIVED, INTAKE, INTAKEUSER, CHGDATE, CHGUSER) 
		select top 1 @newID, 'T0000000213', @clientID, @deptID, 'F', 'D', 'O', 'F', GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin' -- Bladder A T0000000213
		from CLTACTC
		where NOT EXISTS (select CLIENT_ID
						from CLTACTC 
						where CLIENT_ID = @clientID
						and ACTIVITY_ID = 'T0000000213')
	
		exec pp_sys_get_next_id 'CLTACTC', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CLTACTC(CLTACTC_ID, ACTIVITY_ID, CLIENT_ID, DEPT_ID, CHANGED, FREQTYPE, DAYFREQ, ARCHIVED, INTAKE, INTAKEUSER, CHGDATE, CHGUSER) 
		select top 1 @newID, 'T0000000214', @clientID, @deptID, 'F', 'D', 'O', 'F', GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin' -- Bladder D T0000000214
		from CLTACTC
		where NOT EXISTS (select CLIENT_ID
						from CLTACTC 
						where CLIENT_ID = @clientID
						and ACTIVITY_ID = 'T0000000214')
	
		exec pp_sys_get_next_id 'CLTACTC', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CLTACTC(CLTACTC_ID, ACTIVITY_ID, CLIENT_ID, DEPT_ID, CHANGED, FREQTYPE, DAYFREQ, ARCHIVED, INTAKE, INTAKEUSER, CHGDATE, CHGUSER) 
		select top 1 @newID, 'T0000000223', @clientID, @deptID, 'F', 'D', 'O', 'F', GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin' -- Transfers A T0000000223
		from CLTACTC
		where NOT EXISTS (select CLIENT_ID
						from CLTACTC 
						where CLIENT_ID = @clientID
						and ACTIVITY_ID = 'T0000000223')
	
		exec pp_sys_get_next_id 'CLTACTC', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CLTACTC(CLTACTC_ID, ACTIVITY_ID, CLIENT_ID, DEPT_ID, CHANGED, FREQTYPE, DAYFREQ, ARCHIVED, INTAKE, INTAKEUSER, CHGDATE, CHGUSER) 
		select top 1 @newID, 'T0000000227', @clientID, @deptID, 'F', 'D', 'O', 'F', GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin' -- Falls Prevention A T0000000227
		from CLTACTC
		where NOT EXISTS (select CLIENT_ID
						from CLTACTC 
						where CLIENT_ID = @clientID
						and ACTIVITY_ID = 'T0000000227')
	
		exec pp_sys_get_next_id 'CLTACTC', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CLTACTC(CLTACTC_ID, ACTIVITY_ID, CLIENT_ID, DEPT_ID, CHANGED, FREQTYPE, DAYFREQ, ARCHIVED, INTAKE, INTAKEUSER, CHGDATE, CHGUSER) 
		select top 1 @newID, 'T0000000231', @clientID, @deptID, 'F', 'D', 'O', 'F', GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin' -- Meal Setup T0000000231
		from CLTACTC
		where NOT EXISTS (select CLIENT_ID
						from CLTACTC 
						where CLIENT_ID = @clientID
						and ACTIVITY_ID = 'T0000000231')
	
		exec pp_sys_get_next_id 'CLTACTC', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CLTACTC(CLTACTC_ID, ACTIVITY_ID, CLIENT_ID, DEPT_ID, CHANGED, FREQTYPE, DAYFREQ, ARCHIVED, INTAKE, INTAKEUSER, CHGDATE, CHGUSER) 
		select top 1 @newID, 'T0000000243', @clientID, @deptID, 'F', 'D', 'O', 'F', GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin' -- Medication Assist T0000000243
		from CLTACTC
		where NOT EXISTS (select CLIENT_ID
						from CLTACTC 
						where CLIENT_ID = @clientID
						and ACTIVITY_ID = 'T0000000243')
	
		exec pp_sys_get_next_id 'CLTACTC', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CLTACTC(CLTACTC_ID, ACTIVITY_ID, CLIENT_ID, DEPT_ID, CHANGED, FREQTYPE, DAYFREQ, ARCHIVED, INTAKE, INTAKEUSER, CHGDATE, CHGUSER) 
		select top 1 @newID, 'T0000000247', @clientID, @deptID, 'F', 'D', 'O', 'F', GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin' -- Compression Stockings D T0000000247
		from CLTACTC
		where NOT EXISTS (select CLIENT_ID
						from CLTACTC 
						where CLIENT_ID = @clientID
						and ACTIVITY_ID = 'T0000000247')
	
		exec pp_sys_get_next_id 'CLTACTC', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CLTACTC(CLTACTC_ID, ACTIVITY_ID, CLIENT_ID, DEPT_ID, CHANGED, FREQTYPE, DAYFREQ, ARCHIVED, INTAKE, INTAKEUSER, CHGDATE, CHGUSER) 
		select top 1 @newID, 'T0000000267', @clientID, @deptID, 'F', 'D', 'O', 'F', GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin' -- Garbage & Recycling T0000000267
		from CLTACTC
		where NOT EXISTS (select CLIENT_ID
						from CLTACTC 
						where CLIENT_ID = @clientID
						and ACTIVITY_ID = 'T0000000267')
	
		exec pp_sys_get_next_id 'CLTACTC', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into CLTACTC(CLTACTC_ID, ACTIVITY_ID, CLIENT_ID, DEPT_ID, CHANGED, FREQTYPE, DAYFREQ, ARCHIVED, INTAKE, INTAKEUSER, CHGDATE, CHGUSER) 
		select top 1 @newID, 'T0000000275', @clientID, @deptID, 'F', 'D', 'O', 'F', GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin'  -- Respite Blocks T0000000275
		from CLTACTC
		where NOT EXISTS (select CLIENT_ID
						from CLTACTC 
						where CLIENT_ID = @clientID
						and ACTIVITY_ID = 'T0000000275')
	end try
	begin catch
		select ERROR_MESSAGE() AS ErrorMessage
	end catch

	
	-- DATED NOTES
	-- client notes DATEDNOTES
	begin try
		exec pp_sys_get_next_id 'CLNTNOTES', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into DATEDNOTES (NOTE_ID, NOTEDATE, DATE_IN, SUBJECT, CONTENTS, ENTRYBY, TIME_IN, CHGDATE, CHGUSER, UTCINTAKE, UTCCHGDATE) 
		select @newID, GETDATE(), GETDATE(), 'Testing', 'comments test', 'ProcuraAdmin', GETDATE(), GETDATE(), 'ProcuraAdmin', GETDATE(), GETDATE() 

		-- client notes CLNTNOTES
		insert into CLNTNOTES (CLIENT_ID, NOTE_ID, DEPT_ID, INTAKE, INTAKEUSER) 
		select @clientID, @newID, @deptID, GETDATE(), 'ProcuraAdmin'
	
		-- client notes SPCNTTYPE
		insert into SPCNTTYPE values
		(@newID, 'NSH100014', GETDATE(), 'ProcuraAdmin')
		end try
	begin catch
		select ERROR_MESSAGE() AS ErrorMessage
	end catch

	/**Update Client Information**/
	update CLIENTS
	set CURR_ADDR1 = '2209 Trafalgar Street',
		CURR_POST = 'V6K 3W5',
		PERMADDR_1 = '2209 Trafalgar Street',
		PERM_POST = 'V6K 3W5',
		HOME_PHONE = '604-555-5555',
		BIRTHDATE = '1932-12-21 00:00:00.000',
		PRIDOCTOR = 'N0000019396',
		REFERRAL = '',
		AREA = 'V6L',
		WORK_PHONE = '236-555-5555'
	where CLIENT_ID = @clientID 
	
	update CL_REFNOS
	set NUMVAL = '5555555555'
	where CLIENT_ID = @clientID 
	and NUMBER_ID = 'NSH68567599' -- PHN

	update CL_REFNOS
	set NUMVAL = '55555'
	where CLIENT_ID = @clientID 
	and NUMBER_ID = 'N0000000003' -- PARIS ID

	update FRMCONTACT
	set TYPE = 'Responsible Clinician',
		LASTNAME = 'Lilly',
		FIRSTNAME = 'Lillian',
		ADDRESS_1 = '1140 Hunter Pl',
		WORK_PHONE = '236-555-5555',
		HOME_PHONE = '604-555-5555',
		POSTAL = 'V5Z 4C2',
		EXT = '851',
		CELLPHONE = '778-555-5555',
		EMAILADDR = 'Lilian.lilly@vch.ca',
		CCONTACT_ID = 'N0000015108'
	where CLIENT_ID = @clientID 

	fetch next from CLT_CURSOR into @clientID,@lastName,@firstName,@area,@deptID,@funderID;
end;
close CLT_CURSOR;

deallocate CLT_CURSOR; 