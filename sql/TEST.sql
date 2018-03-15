-------------------
--sp_columns LOGINTEGRACIONES
select *
from compuertagp.vwIntegracionesVentas



select resp_type
from ARN_Customers

--update compuertagp.PREFACTURACAB set docid_gp = 'FV A0088'

select *
from compuertagp.PREFACTURAdet

----------------------------------------------------------------
--delete from l
select *
from compuertagp.logintegraciones l
where l.docstatus = 'INTEGRADO'

--insert into compuertagp.logintegraciones (tipodocarn, numdocarn, tipodocgp, numdocgp, docstatus,esactual, usuario, fechahora, mensaje)
SELECT tipodocarn, numdocarn, tipodocgp, numdocgp, docstatus,1, usuario, fechahora, mensaje
FROM compuertagp.logintegraciones
--where NUMDOCARN = '00000001'
----------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------
--Para reintegrar facturas
select *
from tst12.dbo.comgp_fnDocStatusPreCondiciones(3, 'FV A0088-T0000042', 'ELIMINA_FACTURA_EN_GP')

SELECT cumplePreCondiciones, msjPreCondiciones FROM tst12.dbo.comgp_fnDocStatusPreCondiciones(3, 'FV A0088-T00x00042', 'ELIMINA_FACTURA_EN_GP') 

declare @idLog int;
EXEC compuertagp.[sp_LOGINTEGRACIONESInsert] @idLog out, 1, '00000001', null, null,'ELIMINA_FACTURA_EN_GP', 'jcf', 'Se puede reintegrar a GP', 'OK. La factura no existe en GP.' , 1
EXEC compuertagp.[sp_LOGINTEGRACIONESInsert] @idLog out, 1, '00000002', null, null,'ELIMINA_FACTURA_EN_GP', 'jcf', 'Se puede reintegrar a GP', 'OK. La factura no existe en GP.' , 1
EXEC compuertagp.[sp_LOGINTEGRACIONESInsert] @idLog out, 1, '00000003', null, null,'ELIMINA_FACTURA_EN_GP', 'jcf', 'Se puede reintegrar a GP', 'OK. La factura no existe en GP.' , 1
EXEC compuertagp.[sp_LOGINTEGRACIONESInsert] @idLog out, 1, '11', null, null,'ELIMINA_FACTURA_EN_GP', 'jcf', 'Se puede reintegrar a GP', 'OK. La factura no existe en GP.' , 1
EXEC compuertagp.[sp_LOGINTEGRACIONESInsert] @idLog out, 1, '12', null, null,'ELIMINA_FACTURA_EN_GP', 'jcf', 'Se puede reintegrar a GP', 'OK. La factura no existe en GP.' , 1

	--@ID int = NULL OUTPUT,
	--@TIPODOCARN smallint,
	--@NUMDOCARN varchar(20),
	--@TIPODOCGP smallint = NULL,
	--@NUMDOCGP varchar(20) = NULL,
	--@TRANSICION VARCHAR(50),
	--@USUARIO varchar(35),
	--@MENSAJE varchar(150),
	--@MSJPRECONDICIONES varchar(MAX) = NULL,
	--@CUMPLEPRECONDICIONES smallint = 1

select *
--UPDATE p set docid_gp = 'FV A0001'
from compuertagp.PREFACTURACAB p
order by 2

select *
from compuertagp.vwIntegracionesVentas

select *
--update l set DOCSTATUS = 'INTEGRADO'
from compuertagp.logintegraciones l
where numdocarn = '8'
--and ESACTUAL = 1
order by tipodocarn, numdocarn, fechahora

select *
from tst12.dbo.vwSopFacturasCabezaTH
where sopnumbe like 'FV A0088-T000002%'

------------------------------------------------------------------------------
--Datos de prueba
exec compuertagp.sp_PREFACTURACABInsert 1, '00000001', '000001', '1/1/18', 'guía 1', 'jcf';
declare @numlinea int;
exec compuertagp.sp_PREFACTURADETInsert @numlinea out, '00000001', 1, 'WP621020', 'item1', 'UND', 3, 0;
exec compuertagp.sp_PREFACTURADETInsert @numlinea out, '00000001', 1, 'WP621020-T', 'item2', 'UND', 1, 0;


exec compuertagp.sp_PREFACTURACABInsert 1, '00000002', '000001', '2/1/18', 'guía 2', 'jcf';
declare @numlinea int;
exec compuertagp.sp_PREFACTURADETInsert @numlinea out, '00000002', 1, 'WP621020', 'item1', 'UND', 1, 0;
exec compuertagp.sp_PREFACTURADETInsert @numlinea out , '00000002', 1, 'WP621020-T', 'item2', 'UND', 2, 0;

exec compuertagp.sp_PREFACTURACABInsert 1, '00000003', '000001', '2/3/18', 'guía de remisión 3', 'jcf';
declare @numlinea int;
exec compuertagp.sp_PREFACTURADETInsert @numlinea out, '00000003', 1, 'WP621020', 'item1', 'UND', 3, 0;
exec compuertagp.sp_PREFACTURADETInsert @numlinea out , '00000003', 1, 'WP621020-T', 'item2', 'UND', 3, 0;


--@NUMLINEA int = NULL OUTPUT,
--	@PREFACTURACAB_NUMERODOC varchar(20),
--	@PREFACTURACAB_TIPODOC smallint,
--	@IDITEM varchar(30),
--	@DESCRIPCION varchar(100),
--	@UDM varchar(9),
--	@CANTIDAD numeric(19,5),
--	@PRECIO numeric(19,5)
----------------------------------------------------------------------------------


