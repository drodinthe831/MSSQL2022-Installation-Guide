/***************************************************************************************************
Procedure:          Create Mailbox
Create Date:        2024-02-29
Author:             Dave Rodriguez
Description:        Pull existing SQL Server Mail Settings
Call by:            [2.0 - Pull SQL Mail Param.sql]
Affected table(s):  1 of 3 Script to create Mail Box
Used By:            DCSIT DevOps
Parameter(s):       @param1 - description and usage
                    @param2 - description and usage
Usage:              EXEC dbo.sp_DoSomeStuff
                        @param1 = 1,
                        @param2 = 3,
                        @param3 = 2
                    Additional notes or caveats about this object, like where is can and cannot be run, or
                    gotchas to watch for when using it.
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
2024-02-29          Dave Rodriguez      upload to Gitlab.
***************************************************************************************************/


DECLARE @sqlserver varchar(20);

-- SET TO SQL SERVER you would like to pull settings from. 

SET @sqlserver = 'WIN22SRVSQL1';

use master 
go 
sp_configure 'show advanced options',1 
go 
reconfigure with override 
go 
	sp_configure 'Database Mail XPs',1 
	--go 
	--sp_configure 'SQL Mail XPs',0 
	go 
	reconfigure 
	go 
	 
	-------------------------------------------------------------------------------------------------- 
	-- BEGIN Mail Settings DBMAIL 
	-------------------------------------------------------------------------------------------------- 
	IF NOT EXISTS(SELECT * FROM msdb.dbo.sysmail_profile WHERE  name = 'DBMAIL')  
	  BEGIN 
	    --CREATE Profile [DBMAIL] 
	    EXECUTE msdb.dbo.sysmail_add_profile_sp 
	      @profile_name = 'DBMAIL', 
	      @description  = ''; 	  
	END --IF EXISTS profile 
	   
	  IF NOT EXISTS(SELECT * FROM msdb.dbo.sysmail_account WHERE  name = @sqlserver) 
	  BEGIN 
	    --CREATE Account [STAGCIO330DB154] 
	    EXECUTE msdb.dbo.sysmail_add_account_sp 
	    @account_name            = UCASE(SELECT @sqlserver), 
	    @email_address           = LCASE(SELECT @sqlserver + '@domain.com'), 
	    @display_name            = LCASE(SELECT @sqlserver + '@domain.com'), 
	    @replyto_address         = LCASE(SELECT @sqlserver + '@domain.com'), 
	    @description             = '', 
	    @mailserver_name         = 'MAIL.DOMAIN.COM', 
	    @mailserver_type         = 'SMTP', 
	    @port                    = '25', 
	    @username                =  NULL , 
	    @password                =  NULL ,  
	    @use_default_credentials =  1 , 
	    @enable_ssl              =  0 ; 
	  END --IF EXISTS  account 
	   
	IF NOT EXISTS(SELECT * 
	              FROM msdb.dbo.sysmail_profileaccount pa 
	                INNER JOIN msdb.dbo.sysmail_profile p ON pa.profile_id = p.profile_id 
	                INNER JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id   
	              WHERE p.name = 'DBMAIL' 
	                AND a.name = @sqlserver)  
	  BEGIN 
	    -- Associate Account [STAGCIO330DB154] to Profile [DBMAIL] 
	    EXECUTE msdb.dbo.sysmail_add_profileaccount_sp 
	      @profile_name = 'DBMAIL', 
		  @account_name = UCASE(SELECT @sqlserver), 
		@sequence_number = 1 ; 
	  END 


	--IF EXISTS associate accounts to profiles 
	--------------------------------------------------------------------------------------------------- 
	-- Drop Settings For DBMAIL 
	-------------------------------------------------------------------------------------------------- 
	/* 
	IF EXISTS(SELECT * 
	            FROM msdb.dbo.sysmail_profileaccount pa 
	              INNER JOIN msdb.dbo.sysmail_profile p ON pa.profile_id = p.profile_id 
	              INNER JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id   
	            WHERE p.name = 'DBMAIL' 
	              AND a.name = 'STAGCIO330DB154') 
	  BEGIN 
	    EXECUTE msdb.dbo.sysmail_delete_profileaccount_sp @profile_name = 'DBMAIL',@account_name = 'STAGCIO330DB154' 
	  END  
	IF EXISTS(SELECT * FROM msdb.dbo.sysmail_account WHERE  name = 'STAGCIO330DB154') 
	  BEGIN 
	    EXECUTE msdb.dbo.sysmail_delete_account_sp @account_name = 'STAGCIO330DB154' 
	  END 
	IF EXISTS(SELECT * FROM msdb.dbo.sysmail_profile WHERE  name = 'DBMAIL')  
	  BEGIN 
	    EXECUTE msdb.dbo.sysmail_delete_profile_sp @profile_name = 'DBMAIL' 
	  END 
	*/ 	  