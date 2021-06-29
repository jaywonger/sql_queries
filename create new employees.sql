/********************************************************************* 
	Workitem:	PRo071 - Training DB Refresh Process (227916)
	Summary:	Create CHWs training accounts for all sites

	Date            Author                  Notes
	-----------     --------------------    -------------------------
	13-May-2021     Alex Hsu                Initial version
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
declare @trainingAccounts table (empID varchar(14), lastName varchar(30), firstName varchar(20), username varchar(10), area varchar(5));

/** Set account values here **/
insert @trainingAccounts values 
	('TEST0000001','VanTrain','Jack','AVTrain','B*'),		-- HS Bella Coola
	('TEST0000002','VanTrain','Klem','BVTrain','N*'),		-- HS North Shore
	('TEST0000003','VanTrain','Laney','CVTrain','P*'),		-- HS Powell River
	('TEST0000004','VanTrain','Mike','DVTrain','R*'),		-- HS Richmond
	('TEST0000005','VanTrain','Nicole','EVTrain','S*'),		-- HS Sea to Sky
	('TEST0000006','VanTrain','Oscar','FVTrain','C*'),		-- HS Sunshine Coast
	('TEST0000007','VanTrain','Peter','GVTrain','VN*'),		-- HS Van North
	('TEST0000008','VanTrain','Quinton','HVTrain','VS*'),	-- HS Van South
	('TEST0000009','VanTrain','Rick','IVTrain','VW*');		-- HS Van West
declare EMP_CURSOR cursor for 
	select *
	from @trainingAccounts

/** Create each account **/
open EMP_CURSOR;
fetch next from EMP_CURSOR into @empID, @lastName, @firstName, @username, @area
while @@FETCH_STATUS = 0
begin
	/** Employee Account Setup **/
	insert into RESVIS values 
	(@empID,NULL,'S','F')

	insert into RESOURCES values
	(@empID,'E')

	insert into EMPLOYEES 
	(EMP_ID,LASTNAME,FIRSTNAME,AREA,IS_USER,VOICEMAIL,EMAILADDR,INTAKEUSER,INTAKEDATE,INTAKETIME,TITLEEMP,CHGDATE,CHGUSER,TZID)
	values 
	(@empID,@lastName,@firstName,@area,'T','Car',@firstName+'.'+@lastName+'@vch.ca','ProcuraAdmin',GETDATE(),GETDATE(),'CHW',GETDATE(),'ProcuraAdmin','America/Vancouver')

	-- AGREE_ID: N0000000019 = BCGEU - VAN WEST COM, N0000000021 = BCGEU - VAN NORTH COM, N0000000022 = BCGEU - VAN SOUTH COM
	insert into EMPLDEPT 
	(EMP_ID,DEPT_ID,PAYLEVEL_ID,DEFPAYREC, AGREE_ID,STATUS,STARTDATE,DATE_IN,TIME_IN,USER_IN,SENSTART,INTAKEDATE,INTAKEUSER,CHGDATE,CHGUSER)
	values 
	(@empID,'N0000000006','N0000000188','N0000003995','N0000000019','A',GETDATE(),GETDATE(),GETDATE(),'ProcuraAdmin',GETDATE(),GETDATE(),'ProcuraAdmin',GETDATE(),'ProcuraAdmin') -- HS Vancouver
	
	-- Domain/LAN ID
	exec pp_sys_get_next_id 'EMPREFNOS', 1, @nextSyskey output
	set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
	insert into EMPREFNOS (REFNUM_ID,NUMBER_ID,EMP_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER)
	select @newID,'N0000000014',@empID,'VCH\'+@username,GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN'

	-- PS Payroll #
	exec pp_sys_get_next_id 'EMPREFNOS', 1, @nextSyskey output
	set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
	insert into EMPREFNOS (REFNUM_ID,NUMBER_ID,EMP_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER)
	select @newID,'NSH513035684',@empID,'######',GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN'

	-- Pay Mileage
	exec pp_sys_get_next_id 'EMPREFNOS', 1, @nextSyskey output
	set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
	insert into EMPREFNOS (REFNUM_ID,NUMBER_ID,EMP_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER)
	select @newID,'N0000000015',@empID,'Yes',GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN'

	-- FTE
	exec pp_sys_get_next_id 'EMPREFNOS', 1, @nextSyskey output
	set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
	insert into EMPREFNOS (REFNUM_ID,NUMBER_ID,EMP_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER)
	select @newID,'S368252009',@empID,1.0,GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN'

	-- PS Emp Record # VN, VS, VW
	exec pp_sys_get_next_id 'EMPREFNOS', 1, @nextSyskey output
	set @newID = @branchID + right('0000000000' + @nextSyskey, 10)
	if @area like 'VN%' 
		insert into EMPREFNOS (REFNUM_ID,NUMBER_ID,EMP_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER) select @newID,'N0000000020',@empID,0,GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN'
	else if @area like 'VS%'
		insert into EMPREFNOS (REFNUM_ID,NUMBER_ID,EMP_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER) select @newID,'N0000000022',@empID,0,GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN'
	else if @area like 'VW%'
		insert into EMPREFNOS (REFNUM_ID,NUMBER_ID,EMP_ID,NUMVAL,INTAKE,INTAKEUSER,CHGDATE,CHGUSER) select @newID,'N0000000013',@empID,0,GETDATE(),'VCHA_ADMIN',GETDATE(),'VCHA_ADMIN'
	
	-- need to add in the remaining site users

	-- Setup mobile account
	insert into PORTALUSERS
	(USER_ID, USERNAME, EMAIL,PASSWORD,APPROVED,LASTNAME,FIRSTNAME,PREFS,PASSNOEXPIRE,AUTHTYPE)
	values
	(@empID,@username, @firstName+'.'+@lastName+'@vch.ca','vZjZpfYxDrFwzlPPBG3SS1LE/sE=','T',@lastName,@firstName,'<PropBag><Prop Name="MobileDeviceId" Value=""/></PropBag>','F','P')
	
	insert into PORTALUSERROLES
	(USER_ID,ROLETYPE,ROLEAUX_ID,INTAKE,INTAKEUSER)
	values
	(@empID,'E',@empID,GETDATE(),'ProcuraAdmin')

	insert into PORTALUSERDEPTS
	(USER_ID,DEPT_ID,INTAKEUSER,INTAKE)
	values
	(@empID,'N0000000006','ProcuraAdmin',GETDATE())
	
	insert into PORTALUSERGROUPS
	(USER_ID,GROUP_ID,INTAKEUSER,INTAKE)
	values
	(@empID,'N0000000002','ProcuraAdmin',GETDATE())

	fetch next from EMP_CURSOR into @empID, @lastName, @firstName, @username, @area;
end;
close EMP_CURSOR;

deallocate EMP_CURSOR;