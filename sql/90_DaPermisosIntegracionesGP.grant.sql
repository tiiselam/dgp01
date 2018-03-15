--Integraciones GP
--Prop�sito. Rol que da accesos a objetos de integraciones GP
--Requisitos. Ejecutar en la bd intermedia
--06/03/18 JCF Creaci�n
--
-----------------------------------------------------------------------------------
use	tst12	--pro12 --
go
IF DATABASE_PRINCIPAL_ID('rol_integracionesGP') IS NULL
	create role rol_integracionesGP;
grant select on dbo.comgp_fnDocStatusPreCondiciones to rol_integracionesGP;


use integra50	--integra10 -- 
go
IF DATABASE_PRINCIPAL_ID('rol_integracionesGP') IS NULL
	create role rol_integracionesGP;

grant select on compuertagp.vwIntegracionesVentas to rol_integracionesGP;
grant select on compuertagp.vwPreFacturas to rol_integracionesGP;
grant select on compuertagp.docGetSiguienteStatus to rol_integracionesGP;
grant execute on compuertagp.sp_LOGINTEGRACIONESInsert to rol_integracionesGP;

