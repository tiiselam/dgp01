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
--Prop�sito. Obtiene el status destino correspondiente a la transicion del par�metro
--Precondiciones. Ejecute fnDocCumplePreCondiciones para saber si cumple los requisitos de la transici�n en la BD de la compa��a destino
--07/03/18 jcf Creaci�n
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
				case when isnull(efeg.sopnumbe, 'no_existe') = 'no_existe' then 'Correcto. La factura no est� en GP.'
				else 'Incorrecto. La factura existe en GP. Elim�nela en GP y vuelva a intentar'
				end
			else 'No se puede validar la transici�n ' + @TRANSICION
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

IF (@@Error = 0) PRINT 'Creaci�n exitosa de: comgp_fnDocStatusPreCondiciones'
ELSE PRINT 'Error en la creaci�n de: comgp_fnDocStatusPreCondiciones'
GO

