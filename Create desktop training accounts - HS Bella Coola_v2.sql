/********************************************************************* 
	Workitem:	PRo071 - Training DB Refresh Process (227916)
	Summary:	Create training accounts for HS Bella Coola

	Date            Author                  Notes
	-----------     --------------------    -------------------------
	09-Apr-2021     Alex Hsu                Initial version
	06-Aug-2021		Jason Wong				UR revisions
	10-Aug-2021		Jason Wong				Added Visit Histories
	08-Sep-2021		Jason Wong				Updated general information
	14-Sep-2021		Jason Wong				Added Error Handling
	16-Sep-2021		Jason Wong				Updated Error Handling
*********************************************************************/
/** Variables **/
declare @empID varchar(14),
		@lastName varchar(30),
		@firstName varchar(20),
		@username varchar(10),
		@area varchar(5),
		@branchID varchar(1) = (select substring(branch_id, 1, 1) from system),
		@newID varchar(14),
		@nextSyskey varchar(14);
declare @trainingAccounts table (empID varchar(14), lastName varchar(30), firstName varchar(20), username varchar(10));

/** Set account values here **/
insert @trainingAccounts values
	('TEST0000061','BC Train','Anthony','ABCTrain'),
	('TEST0000062','BC Train','Brutus','BBCTrain'),
	('TEST0000063','BC Train','Chris','CBCTrain'),
	('TEST0000064','BC Train','Dawn','DBCTrain'),
	('TEST0000065','BC Train','Emanuelle','EBCTrain'),
	('TEST0000066','BC Train','Ferdinand','FBCTrain'),
	('TEST0000067','BC Train','Georgina','GBCTrain'),
	('TEST0000068','BC Train','Hannah','HBCTrain'),
	('TEST0000069','BC Train','Ivan','IBCTrain'),
	('TEST0000070','BC Train','Jamal','JBCTrain');
declare EMP_CURSOR cursor for 
	select *
	from @trainingAccounts

/** Create each account **/
open EMP_CURSOR;
fetch next from EMP_CURSOR into @empID, @lastName, @firstName, @username
while @@FETCH_STATUS = 0
begin
	/** Employee Account Setup **/
	begin try
		insert into RESVIS  
		select top 1 @empID,NULL,'S','F'
		from RESVIS
		where NOT EXISTS (select RESVIS_ID
						  from RESVIS 
						  where RESVIS_ID = @empID)

		insert into RESOURCES  
		select top 1 @empID,'E'
		from RESOURCES
		where NOT EXISTS (select RES_ID
						  from RESOURCES 
						  where RES_ID = @empID)

		-- Create employee account
		insert into EMPLOYEES (EMP_ID,LASTNAME,FIRSTNAME,AREA,IS_USER,INTAKEUSER,INTAKEDATE,INTAKETIME,CHGDATE,CHGUSER,TZID)
		select top 1 @empID,@lastName,@firstName,'U*','T','ProcuraAdmin',GETDATE(),GETDATE(),GETDATE(),'ProcuraAdmin','America/Vancouver'
		from EMPLOYEES
		where NOT EXISTS (select EMP_ID
						  from EMPLOYEES 
						  where EMP_ID = @empID)
	end try
	begin catch
		select ERROR_MESSAGE() AS ErrorMessage
	end catch

	-- Add employee departments
	begin try
		if not exists (select * from EMPLDEPT
					   where EMP_ID = @empID
					   and (DEPT_ID = 'CGH792373270'
					   OR DEPT_ID = 'N0000000011'))
		begin 
			insert into EMPLDEPT (EMP_ID,DEPT_ID,STATUS,STARTDATE,DATE_IN,TIME_IN,USER_IN,SENSTART,INTAKEDATE,INTAKEUSER,CHGDATE,CHGUSER) values
			(@empID,'CGH792373270','A',GETDATE(),GETDATE(),GETDATE(),'ProcuraAdmin',GETDATE(),GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin'),	-- HS Bella Coola
			(@empID,'N0000000011','A',GETDATE(),GETDATE(),GETDATE(),'ProcuraAdmin',GETDATE(),GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin');	-- Users Bella Coola
		end
	end try
	begin catch
		select ERROR_MESSAGE() AS ErrorMessage
	end catch

	
	begin try
		exec pp_sys_get_next_id 'EMPREFNOS', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into EMPREFNOS (REFNUM_ID,NUMBER_ID,EMP_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER) 
		select top 1 @newID,'N0000000011',@empID,'VCH\'+@username,GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN'	-- Domain/LAN ID
		from EMPREFNOS
		where not exists (select NUMBER_ID
						  from EMPREFNOS
						  where NUMBER_ID = 'N0000000011'
						  and EMP_ID = @empID)

		exec pp_sys_get_next_id 'EMPREFNOS', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into EMPREFNOS (REFNUM_ID,NUMBER_ID,EMP_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER) 
		select top 1 @newID,'NSH513035684',@empID,'######',GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN'			-- PS Payroll #
		from EMPREFNOS
		where not exists (select NUMBER_ID
						  from EMPREFNOS
						  where NUMBER_ID = 'NSH513035684'
						  and EMP_ID = @empID)

		exec pp_sys_get_next_id 'EMPREFNOS', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into EMPREFNOS (REFNUM_ID,NUMBER_ID,EMP_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER) 
		select top 1 @newID,'N0000000015',@empID,'Yes',GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN'			 -- Pay Mileage
		from EMPREFNOS
		where not exists (select NUMBER_ID
						  from EMPREFNOS
						  where NUMBER_ID = 'N0000000015'
						  and EMP_ID = @empID)

		exec pp_sys_get_next_id 'EMPREFNOS', 1, @nextSyskey output
		set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
		insert into EMPREFNOS (REFNUM_ID,NUMBER_ID,EMP_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER) 
		select top 1 @newID,'S368252009',@empID,1.0,GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN'					-- FTE
		from EMPREFNOS
		where not exists (select NUMBER_ID
						  from EMPREFNOS
						  where NUMBER_ID = 'S368252009'
						  and EMP_ID = @empID)
	end try
	begin catch
		select ERROR_MESSAGE() AS ErrorMessage
	end catch

	-- Add as a supervisor
	begin try
		if not exists (select * from SUPERVISORS
					   where SUPER_ID = @empID)
		begin
			insert into SUPERVISORS values (@empID)
		end
	end try
	begin catch
		select ERROR_MESSAGE() AS ErrorMessage
	end catch

	-- Create user account
	-- Password: Procura2019
	begin try
		if not exists (select * from USERS
					   where USER_ID = @empID)
		begin
			insert into USERS
			(USER_ID,USERNAME,PASSWRD,ACTIVE,PROMPTDEPT,INTAKE,INTAKEUSER,CHGPASS,PASSNOEXPIRE,SYNCAUTOACCEPT,SYNCAUTOSYNC,TZID)
			select @empID,@username,
			0x313138313135313031303831303034313335313238313435313139313530313837313630323336303537000050697B2230B8E6063C90E606F8A27B220000000000000000000000006C18F9062051CB1600000000D0639D1E90FABC170000000000000000,
			'T','F',GETDATE(),'ProcuraAdmin','F','T','F','F','America/Vancouver'
		end
	end try
	begin catch
		select ERROR_MESSAGE() AS ErrorMessage
	end catch

	-- Add user to report folders
	begin try
		if not exists (select * from RPTUSERFOLD
					   where USER_ID = @empID
					   and (RFOLDER_ID = 1 OR RFOLDER_ID = 2 OR RFOLDER_ID = 3 OR RFOLDER_ID = 4 OR RFOLDER_ID = 5 OR RFOLDER_ID = 6 OR RFOLDER_ID = 7 OR RFOLDER_ID = 8
					    OR RFOLDER_ID = 13))
		begin
			insert into RPTUSERFOLD values
			(@empID,1,'F',GETDATE(),'ProcuraAdmin'),	-- Scheduling
			(@empID,2,'F',GETDATE(),'ProcuraAdmin'),	-- Employee
			(@empID,3,'F',GETDATE(),'ProcuraAdmin'),	-- Client
			(@empID,4,'F',GETDATE(),'ProcuraAdmin'),	-- Statistics
			(@empID,5,'F',GETDATE(),'ProcuraAdmin'),	-- Timekeeping
			(@empID,6,'F',GETDATE(),'ProcuraAdmin'),	-- Audits
			(@empID,7,'F',GETDATE(),'ProcuraAdmin'),	-- Biling
			(@empID,8,'F',GETDATE(),'ProcuraAdmin'),	-- PARIS IR checks
			(@empID,13,'F',GETDATE(),'ProcuraAdmin');	-- Mobile
		end
	end try
	begin catch
		select ERROR_MESSAGE() AS ErrorMessage
	end catch

	-- Add user to department(s)
	begin try
		if not exists (select * from USERDEPT
					   where USER_ID = @empID
					   and (DEPT_ID = 'CGH792373270'
					   OR DEPT_ID = 'N0000000011'))
		begin
			insert into USERDEPT values
			(@empID,'CGH792373270',GETDATE(),'ProcuraAdmin'),	-- HS Bella Coola
			(@empID,'N0000000011',GETDATE(),'ProcuraAdmin');	-- Users Bella Coola
		end
	end try
	begin catch
		select ERROR_MESSAGE() AS ErrorMessage
	end catch

	-- Add user to access group(s)
	begin try
		if not exists (select * from USERGROUPS
					   where USER_ID = @empID
					   and GROUP_ID = 'N0000000013')
		begin
			insert into USERGROUPS values
		(@empID,'N0000000013',GETDATE(),'ProcuraAdmin')	-- _Scheduler+TK / Mobile
		end
	end try
	begin catch 
		select ERROR_MESSAGE() AS ErrorMessage
	end catch

	-- Add access to department dated notes
	begin try
		if not exists (select * from USERNOTES
					   where USER_ID = @empID
					   and DEPT_ID = 'CGH792373270'
					   and (TYPE_ID = 'N0000000018' OR TYPE_ID = 'N0000000017' OR TYPE_ID = 'N0000000016' OR TYPE_ID = 'N0000000003'
					   OR TYPE_ID = 'N0000000019' OR TYPE_ID = 'N0000000010' OR TYPE_ID = 'N0000000012' OR TYPE_ID = 'N0000000014'
					   OR TYPE_ID = 'N0000000005' OR TYPE_ID = 'Coas928962299' OR TYPE_ID = 'N0000000015' OR TYPE_ID = 'N0000000008'
					   OR TYPE_ID = 'S860153481' OR TYPE_ID = 'NSH100015' OR TYPE_ID = 'N0000000020' OR TYPE_ID = 'S455526658'
					   OR TYPE_ID = 'NSH100020' OR TYPE_ID = 'INV0001' OR TYPE_ID = 'N0000000009' OR TYPE_ID = 'S615050533'
					   OR TYPE_ID = 'T0000000001' OR TYPE_ID = 'NSH100014' OR TYPE_ID = 'NSH100017' OR TYPE_ID = 'N0000000007'))
		begin
			insert into USERNOTES values
			(@empID, 'CGH792373270', 'N0000000018', GETDATE(), 'ProcuraAdmin'),		-- Backup Plan
			(@empID, 'CGH792373270', 'N0000000017', GETDATE(), 'ProcuraAdmin'),		-- CHW Attendance
			(@empID, 'CGH792373270', 'N0000000016', GETDATE(), 'ProcuraAdmin'),		-- CHW Incident
			(@empID, 'CGH792373270', 'N0000000003', GETDATE(), 'ProcuraAdmin'),		-- CHW Supervisory Notes*
			(@empID, 'CGH792373270', 'N0000000019', GETDATE(), 'ProcuraAdmin'),		-- CHW Training	
			(@empID, 'CGH792373270', 'N0000000010', GETDATE(), 'ProcuraAdmin'),		-- Client Complaint
			(@empID, 'CGH792373270', 'N0000000012', GETDATE(), 'ProcuraAdmin'),		-- Client Observations
			(@empID, 'CGH792373270', 'N0000000014', GETDATE(), 'ProcuraAdmin'),		-- Client Update
			(@empID, 'CGH792373270', 'N0000000005', GETDATE(), 'ProcuraAdmin'),		-- Do Not Send - Client/CHW*
			(@empID, 'CGH792373270', 'Coas928962299', GETDATE(), 'ProcuraAdmin'),	-- DOT - Delegation of Task
			(@empID, 'CGH792373270', 'N0000000015', GETDATE(), 'ProcuraAdmin'),		-- DOT - Pending Review
			(@empID, 'CGH792373270', 'N0000000008', GETDATE(), 'ProcuraAdmin'),		-- Falls
			(@empID, 'CGH792373270', 'S860153481', GETDATE(), 'ProcuraAdmin'),		-- Feedback about CHW
			(@empID, 'CGH792373270', 'NSH100015', GETDATE(), 'ProcuraAdmin'),		-- Financial Notes
			(@empID, 'CGH792373270', 'N0000000020', GETDATE(), 'ProcuraAdmin'),		-- Hazard/Risk Investigation
			(@empID, 'CGH792373270', 'S455526658', GETDATE(), 'ProcuraAdmin'),		-- Hospital Updates
			(@empID, 'CGH792373270', 'NSH100020', GETDATE(), 'ProcuraAdmin'),		-- Initial Visit
			(@empID, 'CGH792373270', 'INV0001', GETDATE(), 'ProcuraAdmin'),			-- Invoice Change Log
			(@empID, 'CGH792373270', 'N0000000009', GETDATE(), 'ProcuraAdmin'),		-- Med Incident
			(@empID, 'CGH792373270', 'S615050533', GETDATE(), 'ProcuraAdmin'),		-- New Referral
			(@empID, 'CGH792373270', 'T0000000001', GETDATE(), 'ProcuraAdmin'),		-- Position Changes
			(@empID, 'CGH792373270', 'NSH100014', GETDATE(), 'ProcuraAdmin'),		-- Progress Notes
			(@empID, 'CGH792373270', 'NSH100017', GETDATE(), 'ProcuraAdmin'),		-- Referred Agency
			(@empID, 'CGH792373270', 'N0000000007', GETDATE(), 'ProcuraAdmin');		-- Schedule Changes
		end
	end try
	begin catch
		select ERROR_MESSAGE() AS ErrorMessage
	end catch

	-- Add access to department planners
	begin try
		if not exists (select * from USERPLANS
					   where USER_ID = @empID
					   and DEPT_ID = 'CGH792373270'
					   and PLANNER_ID = 'N0000000087' OR PLANNER_ID = 'N0000000088' OR PLANNER_ID = 'N0000000089' OR PLANNER_ID = 'N0000000090' OR PLANNER_ID = 'N0000000091')
		begin
			insert into USERPLANS (USER_ID, DEPT_ID, PLANNER_ID, INTAKE, INTAKEUSER) values
			(@empID, 'CGH792373270', 'N0000000087', GETDATE(), 'ProcuraAdmin'),	-- BC - RN
			(@empID, 'CGH792373270', 'N0000000088', GETDATE(), 'ProcuraAdmin'),	-- BC - Non Stat
			(@empID, 'CGH792373270', 'N0000000089', GETDATE(), 'ProcuraAdmin'),	-- BC - Mobile Alerts
			(@empID, 'CGH792373270', 'N0000000090', GETDATE(), 'ProcuraAdmin'),	-- BC - Observation Notes
			(@empID, 'CGH792373270', 'N0000000091', GETDATE(), 'ProcuraAdmin');	-- BC - PPE Documents
		end
	end try
	begin catch
		select ERROR_MESSAGE() AS ErrorMessage
	end catch
	
	-- Core Competencies
	begin try
	exec pp_sys_get_next_id 'EMPSERVS', 1, @nextSyskey output
	set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
	insert into EMPSERVS (REQ_ID, EMP_ID, DEPT_ID, SERV_ID, ATTACHDATE, ISSUEDATE) 
	select top 1 @newID, @empID, 'CGH792373270', 'N0000010236', GETDATE(), GETDATE() -- Medication Management
	from EMPSERVS
	where not exists (select SERV_ID
					  from EMPSERVS
					  where SERV_ID = 'N0000010236'
					  and EMP_ID = @empID
					  and DEPT_ID = 'CGH792373270')
	

	exec pp_sys_get_next_id 'EMPSERVS', 1, @nextSyskey output
	set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
	insert into EMPSERVS (REQ_ID, EMP_ID, DEPT_ID, SERV_ID, ATTACHDATE, ISSUEDATE) 
	select top 1 @newID, @empID, 'CGH792373270', 'N0000010237', GETDATE(), GETDATE() -- Dementia Care
	from EMPSERVS
	where not exists (select SERV_ID
					  from EMPSERVS
					  where SERV_ID = 'N0000010237'
					  and EMP_ID = @empID
					  and DEPT_ID = 'CGH792373270')

	exec pp_sys_get_next_id 'EMPSERVS', 1, @nextSyskey output
	set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
	insert into EMPSERVS (REQ_ID, EMP_ID, DEPT_ID, SERV_ID, ATTACHDATE, ISSUEDATE) 
	select top 1 @newID, @empID, 'CGH792373270', 'N0000010238', GETDATE(), GETDATE() -- Falls Prevention
	from EMPSERVS
	where not exists (select SERV_ID
					  from EMPSERVS
					  where SERV_ID = 'N0000010238'
					  and EMP_ID = @empID
					  and DEPT_ID = 'CGH792373270')

	exec pp_sys_get_next_id 'EMPSERVS', 1, @nextSyskey output
	set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
	insert into EMPSERVS (REQ_ID, EMP_ID, DEPT_ID, SERV_ID, ATTACHDATE, ISSUEDATE) 
	select top 1 @newID, @empID, 'CGH792373270', 'N0000010239', GETDATE(), GETDATE() -- Palliative Care
	from EMPSERVS
	where not exists (select SERV_ID
					  from EMPSERVS
					  where SERV_ID = 'N0000010239'
					  and EMP_ID = @empID
					  and DEPT_ID = 'CGH792373270')
	end try
	begin catch
		select ERROR_MESSAGE() AS ErrorMessage
	end catch
	

	-- Visit History (one by one adding) specific BC clients
	begin try
		if not exists (select * from CLNTRESORC
					   where RES_ID = @empID
					   and DEPT_ID = 'CGH792373270'
					   and (CLTVISITOR_ID = 'N0000013738' OR CLTVISITOR_ID = 'N0000013916' OR CLTVISITOR_ID = 'N0000012259' OR CLTVISITOR_ID = 'N0000009690'
					   OR CLTVISITOR_ID = 'CGH192324907' OR CLTVISITOR_ID = 'N0000012894' OR CLTVISITOR_ID = 'N0000014798' OR CLTVISITOR_ID = 'T0000005476'
					   OR CLTVISITOR_ID = 'T0000004894'))
		begin
			insert into CLNTRESORC (CLTVISITOR_ID, DEPT_ID, RES_ID, CODE, INTAKE, INTAKEUSER, CHGDATE, CHGUSER) values
			('N0000013738', 'CGH792373270', @empID, 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin'),
			('N0000013916', 'CGH792373270', @empID, 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin'),
			('N0000012259', 'CGH792373270', @empID, 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin'),
			('N0000009690', 'CGH792373270', @empID, 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin'),
			('CGH192324907', 'CGH792373270', @empID, 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin'),
			('N0000012894', 'CGH792373270', @empID, 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin'),
			('N0000014798', 'CGH792373270', @empID, 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin'),
			('T0000005476', 'CGH792373270', @empID, 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin'),
			('T0000004894', 'CGH792373270', @empID, 'Required', GETDATE(), 'ProcuraAdmin', GETDATE(), 'ProcuraAdmin');
		end
	end try
	begin catch
	select ERROR_MESSAGE() AS ErrorMessage
	end catch
	 
	-- Additional Information
	begin try
	if not exists (select * from EMPSUBCATS
				   where RES_ID = @empID
				   and SUBCAT_ID = 'N0000000038'	 -- BC Driver's License
				   and DEPT_ID = 'CGH792373270')
	begin
		insert into EMPSUBCATS (RES_ID, SUBCAT_ID, DEPT_ID)
		values (@empID, 'N0000000038', 'CGH792373270')
		end
	end try
	begin catch
	select ERROR_MESSAGE() AS ErrorMessage
	end catch

	begin try
	if not exists (select * from EMPSUBCATS
				   where RES_ID = @empID
				   and SUBCAT_ID = 'N0000000037'	-- Physical Description
				   and DEPT_ID = 'CGH792373270')
	begin
		insert into EMPSUBCATS (RES_ID, SUBCAT_ID, DEPT_ID)
		values (@empID, 'N0000000037', 'CGH792373270')
		end
	end try
	begin catch
	select ERROR_MESSAGE() AS ErrorMessage
	end catch

	begin try
	if not exists (select * from EMPSUBCATS
				   where RES_ID = @empID
				   and SUBCAT_ID = 'NSH825409883'	-- Vehicle Details
				   and DEPT_ID = 'CGH792373270')
	begin
		insert into EMPSUBCATS (RES_ID, SUBCAT_ID, DEPT_ID)
		values (@empID, 'NSH825409883', 'CGH792373270')
		end
	end try
	begin catch
	select ERROR_MESSAGE() AS ErrorMessage
	end catch

	/*Update Employee General Information*/
	update EMPLOYEES
	set HOMEPHONE = '604-555-5555',
		WORKPHONE = '236-555-5555',
		CELLPHONE = '778-555-5555',
		BIRTHDATE = '1975-08-22 00:00:00.000',
		CURR_ADDR1 = '1025 Elcho St',
		CURR_POST = 'V0T 1C0',
		PERMADDR_1 = '1025 Elcho St',
		PERM_POST = 'V0T 1C0',
		BIRTHDAY = '22',
		VOICEMAIL = 'Bus',
		EMAILADDR = 'vchprocurasupport@vch.ca',
		TITLEEMP = '1bella'
	where EMP_ID = @empID

	update EMPREFNOS
	set NUMVAL = ''
	where EMP_ID = @empID
	and NUMBER_ID = 'N0000000014'

	update EMPREFNOS
	set NUMVAL = '5555555'
	where EMP_ID = @empID
	and NUMBER_ID = 'NSH513035684'

	update EMPCONTACTS
	set TYPE = 'Alternate',
		LASTNAME = 'Carp',
		FIRSTNAME = 'Candice',
		WORK_PHONE = '236-555-5555',
		CELLPHONE = '778-555-5555'
	where CONTACT_ID = 'N0000000181'

	update EMPCONTACTS
	set TYPE = 'Primary',
		LASTNAME = 'Carp',
		FIRSTNAME = 'Carly',
		HOME_PHONE = '604-555-5555'
	where CONTACT_ID = 'P0000000064'

	update PORTALUSERS
	set USERNAME = 'AVTrain',
		EMAIL = 'vchprocurasupport@vch.ca',
		PASSWORD = 'vZjZpfYxDrFwzlPPBG3SS1LE/sE=',
		APPROVED = 'T',
		AUTHTYPE = 'P',
		AUTHWINUSER = null
	where USER_ID = @empID

	fetch next from EMP_CURSOR into @empID, @lastName, @firstName, @username;
end;
close EMP_CURSOR;

deallocate EMP_CURSOR;