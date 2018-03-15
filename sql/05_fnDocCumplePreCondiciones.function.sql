--Ejecutar en [company db]


IF OBJECT_ID ('dbo.comgp_fnDocStatusPreCondiciones') IS NOT NULL
   DROP FUNCTION dbo.comgp_fnDocStatusPreCondiciones
GO

--Transiciones permitidas:
--GENERA_PREFACTURA
--ENVIAR_A_GP
--ELIMINA_FACTURA_EN_GP
--
CREATE function dbo.comgp_fnDocStatusPreCondiciones(@TIPODOCGP smallint, @NUMDOCGP varchar(20) , @TRANSICION VARCHAR(50))
returns table
--Propósito. Obtiene el status destino correspondiente a la transicion del parámetro
--Precondiciones. Ejecute fnDocCumplePreCondiciones para saber si cumple los requisitos de la transición en la BD de la compañía destino
--07/03/18 jcf Creación
--
as
return(

	--DECLARE @TRANSICION VARCHAR(50), @TIPODOCGP smallint, @NUMDOCGP varchar(20) ;
	select case when doc.transicion = 'ELIMINA_FACTURA_EN_GP' then
				case when isnull(efeg.sopnumbe, 'no_existe') = 'no_existe' then 1 
				else 0 
				end
			else 0
			end cumplePreCondiciones,

			case when doc.transicion = 'ELIMINA_FACTURA_EN_GP' then
				case when isnull(efeg.sopnumbe, 'no_existe') = 'no_existe' then 'Correcto. La factura no está en GP.'
				else 'Incorrecto. La factura existe en GP. Elimínela en GP y vuelva a intentar'
				end
			else 'No se puede validar la transición ' + @TRANSICION
			end msjPreCondiciones
    from (select @TRANSICION transicion) doc
     outer apply (
			select sopnumbe
			from dbo.vwSopFacturasCabezaTH
			where sopnumbe = @NUMDOCGP 
			and soptype = @TIPODOCGP
			and @TRANSICION = 'ELIMINA_FACTURA_EN_GP'
			) efeg
)
go

IF (@@Error = 0) PRINT 'Creación exitosa de: comgp_fnDocStatusPreCondiciones'
ELSE PRINT 'Error en la creación de: comgp_fnDocStatusPreCondiciones'
GO

