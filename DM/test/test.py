 ﻿IF exists (SELECT TOP 1 1 FROM SYSCOMMENTS WHERE ID = OBJECT_ID(N'a')) 
	print getdate() 

 IF exists (SELECT TOP 1 1 FROM SYSCOMMENTS WHERE ID = OBJECT_ID(N'a'))
	print getdate()  
 
