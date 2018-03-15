IF (OBJECT_ID ('compuertagp.vwPreFacturas', 'V') IS NULL)
   exec('create view compuertagp.vwPreFacturas as SELECT 1 as t');
go

ALTER VIEW compuertagp.vwPreFacturas
--Propósito. Obtiene pre facturas
--02/03/18 JCF Creación
--
AS
select 
  pfc.TIPODOC,
  pfc.NUMERODOC,
  pfc.IDCLIENTE ,
  pfc.FECHADOC ,
  pfc.OBSERVACIONES,
  pfd.NUMLINEA ,
  pfd.IDITEM ,
  pfd.DESCRIPCION ,
  pfd.UDM ,
  pfd.CANTIDAD ,
  pfd.PRECIO
from compuertagp.PREFACTURACAB pfc
inner join compuertagp.PREFACTURADET pfd
	on pfc.NUMERODOC = pfd.PREFACTURACAB_NUMERODOC
	and pfc.TIPODOC = pfd.PREFACTURACAB_TIPODOC

go
IF (@@Error = 0) PRINT 'Creación exitosa de: vwPreFacturas'
ELSE PRINT 'Error en la creación de: vwPreFacturas'
GO


