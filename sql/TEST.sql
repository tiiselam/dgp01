use tst12
go
select *
from vwrmClientes
where custnmbr = '000708'

use integra50
go

select 
viv.*
from compuertagp.vwIntegracionesVentas viv



----------------------------------------------------------------------------------------------------------------------------
--Para reintegrar facturas que todavía están en lote en GP.
select *
from tst12.dbo.comgp_fnDocStatusPreCondiciones(3, 'FV A0088-T0000042', 'ELIMINA_FACTURA_EN_GP')

SELECT cumplePreCondiciones, msjPreCondiciones FROM tst12.dbo.comgp_fnDocStatusPreCondiciones(3, 'FV A0088-T00x00042', 'ELIMINA_FACTURA_EN_GP') 

-------------------------------------------------------------------------------------------------------------------
--Para reintegrar facturas que fueron contabilizads en GP
--1. cambiar el status de INTEGRADO a CONTABILIZADO
select pc.*, 
viv.*
from compuertagp.vwIntegracionesVentas viv
	CROSS apply pro12.dbo.comgp_fnDocStatusPreCondiciones(viv.tipodocgp, viv.numdocgp, 'CONTABILIZA_FACTURA_EN_GP') pc
where 
viv.docstatus = 'INTEGRADO'
and viv.numdocarn in ('15','16','17','18','19')

declare @r int; 
exec compuertagp.[sp_LOGINTEGRACIONESInsert] @r, 1, 15, 3, 'FV A0001-T0000016', 'CONTABILIZA_FACTURA_EN_GP', 'sa', 'Contabilizado en GP', 'Correcto. La factura está contabilizada en GP.', 1
exec compuertagp.[sp_LOGINTEGRACIONESInsert] @r, 1, 16, 3, 'FV A0001-T0000017', 'CONTABILIZA_FACTURA_EN_GP', 'sa', 'Contabilizado en GP', 'Correcto. La factura está contabilizada en GP.', 1
exec compuertagp.[sp_LOGINTEGRACIONESInsert] @r, 1, 17, 3, 'FV A0001-T0000018', 'CONTABILIZA_FACTURA_EN_GP', 'sa', 'Contabilizado en GP', 'Correcto. La factura está contabilizada en GP.', 1
exec compuertagp.[sp_LOGINTEGRACIONESInsert] @r, 1, 18, 3, 'FV A0001-T0000019', 'CONTABILIZA_FACTURA_EN_GP', 'sa', 'Contabilizado en GP', 'Correcto. La factura está contabilizada en GP.', 1
exec compuertagp.[sp_LOGINTEGRACIONESInsert] @r, 1, 19, 3, 'FV A0001-T0000020', 'CONTABILIZA_FACTURA_EN_GP', 'sa', 'Contabilizado en GP', 'Correcto. La factura está contabilizada en GP.', 1

--2. cambiar el status de CONTABILIZADO a LISTO
select pc.*, viv.*
from compuertagp.vwIntegracionesVentas viv
	outer apply pro12.dbo.comgp_fnDocStatusPreCondiciones(viv.tipodocgp, viv.numdocgp, 'ANULA_FACTURA_RM_EN_GP') pc
where viv.docstatus = 'CONTABILIZADO'

declare @r int; 
exec compuertagp.[sp_LOGINTEGRACIONESInsert] @r, 1, '15', NULL, NULL, 'ANULA_FACTURA_RM_EN_GP', 'sa', 'Habilitado para re-integrarse a GP', 'Correcto. La factura está anulada en GP.', 1
exec compuertagp.[sp_LOGINTEGRACIONESInsert] @r, 1, '16', NULL, NULL, 'ANULA_FACTURA_RM_EN_GP', 'sa', 'Habilitado para re-integrarse a GP', 'Correcto. La factura está anulada en GP.', 1
exec compuertagp.[sp_LOGINTEGRACIONESInsert] @r, 1, '17', NULL, NULL, 'ANULA_FACTURA_RM_EN_GP', 'sa', 'Habilitado para re-integrarse a GP', 'Correcto. La factura está anulada en GP.', 1
exec compuertagp.[sp_LOGINTEGRACIONESInsert] @r, 1, '18', NULL, NULL, 'ANULA_FACTURA_RM_EN_GP', 'sa', 'Habilitado para re-integrarse a GP', 'Correcto. La factura está anulada en GP.', 1
exec compuertagp.[sp_LOGINTEGRACIONESInsert] @r, 1, '19', NULL, NULL, 'ANULA_FACTURA_RM_EN_GP', 'sa', 'Habilitado para re-integrarse a GP', 'Correcto. La factura está anulada en GP.', 1


--------------------------------------------------------------------------------------------------------------------

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
where numdocarn = '15'
--and ESACTUAL = 1
order by tipodocarn, numdocarn, fechahora

select *
from tst12.dbo.vwSopFacturasCabezaTH
where sopnumbe like 'FV A0088-T000002%'

------------------------------------------------------------------------------
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
--update l set esactual = 1
from compuertagp.logintegraciones l
where numdocarn = '100'
--and id = 112
order by fechahora

select *
from tst12..sop30200
where sopnumbe = 'FV B0088-T0000003'

-- l.docstatus = 'INTEGRADO'

--insert into compuertagp.logintegraciones (tipodocarn, numdocarn, tipodocgp, numdocgp, docstatus,esactual, usuario, fechahora, mensaje)
SELECT tipodocarn, numdocarn, tipodocgp, numdocgp, docstatus,1, usuario, fechahora, mensaje
FROM compuertagp.logintegraciones
--where NUMDOCARN = '00000001'
----------------------------------------------------------------------------------------------------------------------------
