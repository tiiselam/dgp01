IF (OBJECT_ID ('compuertagp.vwIntegracionesVentas', 'V') IS NULL)
   exec('create view compuertagp.vwIntegracionesVentas as SELECT 1 as t');
go

ALTER VIEW compuertagp.vwIntegracionesVentas
--Propósito. Documentos integrados y no integrados
--28/02/18 JCF Creación
--
AS
select li.ID,
li.TIPODOCARN,
li.NUMDOCARN,
li.TIPODOCGP,
li.NUMDOCGP,
li.DOCSTATUS,
pfc.IDCLIENTE ,
pfc.FECHADOC ,
pfc.OBSERVACIONES,
pfc.DOCID_GP,
pfc.SOPTYPE_GP,
li.ESACTUAL,
li.USUARIO,
li.FECHAHORA,
li.MENSAJE,
li.MENSAJELARGO
from compuertagp.LOGINTEGRACIONES li
inner join compuertagp.PREFACTURACAB pfc
	on pfc.TIPODOC = li.tipodocarn
	and pfc.NUMERODOC = li.numdocarn
where ESACTUAL = 1

go
IF (@@Error = 0) PRINT 'Creación exitosa de: vwIntegracionesVentas'
ELSE PRINT 'Error en la creación de: vwIntegracionesVentas'
GO


