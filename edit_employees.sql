/********************************************************************* 
	Summary: Edit Bella Coola Employee information.

	Date            Author                  Notes
	-----------     --------------------    -------------------------
	25-Jun-2021     Jason Wong              Initial version
*********************************************************************/
use VCHA_DEV2
go

/*Create employee Su Salmon*/

update EMPLOYEES
set HOMEPHONE = '604-555-5555',
	WORKPHONE = '236-555-5555',
	CELLPHONE = '778-555-5555',
	BIRTHDATE = '1975-08-22 00:00:00.000',
	AREA = 'VB4C',
	CURR_ADDR1 = '2110 W 43rd Avenue',
	CURR_POST = 'V6M 2E1',
	PERMADDR_1 = '2110 W 43rd Avenue',
	PERM_POST = 'V6M 2E1',
	BIRTHDAY = '22',
	VOICEMAIL = 'Bus',
	EMAILADDR = 'vchprocurasupport@vch.ca',
	TITLEEMP = '5north'
where EMP_ID = 'TEST0000001'

update EMPREFNOS
set NUMVAL = ''
where EMP_ID = 'TEST0000001'
and NUMBER_ID = 'N0000000014'

update EMPREFNOS
set NUMVAL = '5555555'
where EMP_ID = 'TEST0000001'
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
	LASTNAME = 'VanTrain',
	FIRSTNAME = 'Jack',
	AUTHTYPE = 'P',
	AUTHWINUSER = null
where USER_ID = 'N0000000058'

