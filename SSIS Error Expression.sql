----------------------------------------------------------------------------------------------------------
-- General Data
----------------------------------------------------------------------------------------------------------
-- Author          : Hidequel Puga
-- Email           : codefivestar@gmail.com
-- Date            : 2019-05-30 10:00 a.m.
-- Description     : Get error using Event handler and send mail
-- Reference       : https://www.mssqltips.com/sqlservertip/5679/capturing-sql-server-integration-services-package-errors-using-onerror-event-handlers/
-- Used For        : SSIS >> Event handler > Send Mail Task On Error
----------------------------------------------------------------------------------------------------------

/*
 
"\n" + "Falla en la tarea programada ! " + "\n\n\n" + 
"Detalle Error : " + "\n\n\n" + 
"Servidor : " + @[System::MachineName] + "\n\n" + 
"Paquete : " + @[System::PackageName] + ".dtsx" + "\n\n" + 
"Tarea (Fuente) : " + @[System::SourceName] + "\n\n" + 
"Tipo (SSIS Componente) : " + @[System::SourceDescription] + "\n\n" + 
"Descripción Error : " + @[System::ErrorDescription] + "\n\n" + 
"Código Error : " + (DT_WSTR, 12) @[System::ErrorCode]
 
 */