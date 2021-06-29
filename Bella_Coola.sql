/********************************************************************* 
	Summary: Add the additional information in User Readiness directory.

	Date            Author                  Notes
	-----------     --------------------    -------------------------
	14-Jun-2021     Jason Wong              Initial version
*********************************************************************/
use VCHA_DEV2
go

/*Create Bella Coola Client*/

update CLIENTS
set LASTNAME = 'Coola',
	FIRSTNAME = 'Bella',
	ALIAS = 'Bell',
	PERMADDR_1 = '1025 Elcho St',
	PERM_POST = 'V0T 1C0',
	HOME_PHONE = '604-555-5555',
	BIRTHDATE = '1950-12-31 00:00:00.000',
	PRIDOCTOR = 'N0000019396',
	REFERRAL = '',
	CURR_ADDR1 = '1025 Elcho St',
	CURR_POST = 'V0T 1C0',
	AREA = 'V0T'
where CLIENT_ID = 'C0000021843'

update CL_REFNOS
set NUMVAL = '5555555555'
where CLIENT_ID = 'C0000021843'
and NUMBER_ID = 'NSH68567599' -- PHN

update CL_REFNOS
set NUMVAL = '55555'
where CLIENT_ID = 'C0000021843'
and NUMBER_ID = 'N0000000003' -- PARIS ID

delete
from INFCONTACT
where CLIENT_ID = 'C0000021843'

update FRMCONTACT
set TYPE = 'Responsible Clinician',
	LASTNAME = 'Lilly',
	FIRSTNAME = 'Lillian',
	ADDRESS_1 = '1140 Hunter Pl',
	WORK_PHONE = '236-555-5555',
	POSTAL = 'V5Z 4C2',
	EXT = '851',
	CELLPHONE = '778-555-5555',
	EMAILADDR = 'Lilian.lilly@vch.ca',
	CCONTACT_ID = 'N0000015108'
where CLIENT_ID = 'C0000021843'

update ORDERS
set COMMENTS = 'Comments Comments Comments Comments Comments Comments Comments'
where CLIENT_ID = 'C0000021843'
