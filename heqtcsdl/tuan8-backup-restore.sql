--bt backup - restore

--12/5/2021

use master
go

exec sp_addumpdevice 'disk', 'adv2008back', 'D:\backup-12-5-2021\adv2008back.bak'

--set db adventurework recovery full
alter database [AdventureWorks2008R2]
set recovery full

backup database [AdventureWorks2008R2]--file 1
to adv2008back
--to disk 'D:\backup-12-5-2021\adv2008back.bak'
with description = 'AdventureWorks2008R2 Full Backup'
go

--productid=749 listprice = 3578.27

--trans giam 15$

backup database [AdventureWorks2008R2]--file 2
to adv2008back
--to disk 'D:\backup-12-5-2021\adv2008back.bak'
with differential, description = 'AdventureWorks2008R2 Different Backup lan 1'
go

backup log [AdventureWorks2008R2]--file 3
to adv2008back
--to disk 'D:\backup-12-5-2021\adv2008back.bak'
with description = 'AdventureWorks2008R2 Log Backup lan 1'
go

--delete person.email

backup log [AdventureWorks2008R2]--file 4
to adv2008back
--to disk 'D:\backup-12-5-2021\adv2008back.bak'
with description = 'AdventureWorks2008R2 Log Backup lan 2'
go

--insert person.personphone


backup database [AdventureWorks2008R2]--file 5
to adv2008back
--to disk 'D:\backup-12-5-2021\adv2008back.bak'
with differential, description = 'AdventureWorks2008R2 Different Backup lan 2'
go


--delete table sales.shoppingcaritem

--xoa db adventure work
use master
--drop database AdventureWorks2008R2


restore headeronly --xem toan bo thong tin backup
from disk = 'D:\backup-12-5-2021\adv2008back.bak'

restore database [AdventureWorks2008R2]
from adv2008back
with file = 1, recovery

use master
--drop database AdventureWorks2008R2


restore database [AdventureWorks2008R2]
from adv2008back
with file = 1, norecovery

restore database [AdventureWorks2008R2]
from adv2008back
with file = 2, norecovery

restore database [AdventureWorks2008R2]
from adv2008back
with file = 3


use master
--drop database AdventureWorks2008R2

restore database [AdventureWorks2008R2]
from adv2008back
with file = 1, norecovery

restore database [AdventureWorks2008R2]
from adv2008back
with file = 5