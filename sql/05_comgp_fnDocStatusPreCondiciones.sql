--Ejecutar en [company db]


IF OBJECT_ID ('dbo.comgp_fnDocStatusPreCondiciones') IS NOT NULL
   DROP FUNCTION dbo.comgp_fnDocStatusPreCondiciones
GO

--Transiciones permitidas:
--GENERA_PREFACTURA
--ENVIAR_A_GP
--ELIMINA_FACTURA_EN_GP
--ANULA_FACTURA_RM_EN_GP
--ANULA_FACTURA_SOP_EN_GP
--
create function dbo.comgp_fnDocStatusPreCondiciones(@TIPODOCGP smallint, @NUMDOCGP varchar(20), @TIPODOC SMALLINT, @NUMERODOC VARCHAR(20), @TRANSICION VARCHAR(50))
returns table
--Propósito. Obtiene el status destino correspondiente a la transicion del parámetro
--Precondiciones. Ejecute fnDocCumplePreCondiciones para saber si cumple los requisitos de la transición en la BD de la compañía destino
--07/03/18 jcf Creación
--19/03/18 jcf Agrega transiciones ANULA_FACTURA_SOP_EN_GP, ANULA_FACTURA_RM_EN_GP, CONTABILIZA_FACTURA_EN_GP
--23/04/18 jcf No se puede habilitar las transiciones ANULA_FACTURA_RM_EN_GP ni CONTABILIZA_FACTURA_EN_GP en tanto no se tenga la relación de números temporales T (sop10100) con números finales sopnumbe (sop30200)
--			Agrega la validación de la transición ENVIAR_A_GP
as
return(

	--DECLARE @TRANSICION VARCHAR(50), @TIPODOCGP smallint, @NUMDOCGP varchar(20) ;
	select case when doc.transicion = 'ELIMINA_FACTURA_EN_GP' then
					case when isnull(efeg.sopnumbe, 'no_existe') = 'no_existe' then 1 
					else 0 
					end
				when doc.transicion = 'ANULA_FACTURA_SOP_EN_GP' then
					case when isnull(efeg.voidstts, 0) >= 1 then 1 
					else 0 
					end
				when doc.transicion = 'ENVIAR_A_GP' then
					case when isnull(eagp.sopnumbe, '_no_existe') = '_no_existe' then 1 
					else 0 
					end
				--when doc.transicion = 'ANULA_FACTURA_RM_EN_GP' then
				--	case when isnull(fhi.voidstts, 0) >= 1 then 1 
				--	else 0 
				--	end
				--when doc.transicion = 'CONTABILIZA_FACTURA_EN_GP' then
				--	case when isnull(fhi.pstgstus, 0) = 2 then 1 
				--	else 0 
				--	end
			else 0
			end cumplePreCondiciones,

			case when doc.transicion = 'ELIMINA_FACTURA_EN_GP' then
					case when isnull(efeg.sopnumbe, 'no_existe') = 'no_existe' then 'Correcto. La factura no está en GP.'
					else 'Incorrecto. La factura existe en GP. Elimínela en GP y vuelva a intentar'
					end
				when doc.transicion = 'ANULA_FACTURA_SOP_EN_GP' then
					case when isnull(efeg.voidstts, 0) >= 1 then 'Correcto. La factura está anulada en GP.'
					else 'Incorrecto. La factura no está anulada. Anule la factura en GP y vuelva a intentar'
					end
				when doc.transicion = 'ENVIAR_A_GP' then
					case when isnull(eagp.sopnumbe, '_no_existe') = '_no_existe' then 'Correcto. No hay otra factura con la misma guía.' 
					else 'Incorrecto. Ya existe la factura ' +eagp.sopnumbe+ ' con el mismo número de guía. Puede cambiarlo y re-intentar.'
					end
				--when doc.transicion = 'ANULA_FACTURA_RM_EN_GP' then
				--	case when isnull(fhi.voidstts, 0) >= 1 then 'Correcto. La factura está anulada en GP.'
				--	else 'Incorrecto. La factura no está anulada. Anule la factura en GP y vuelva a intentar'
				--	end
				--when doc.transicion = 'CONTABILIZA_FACTURA_EN_GP' then
				--	case when isnull(fhi.pstgstus, 0) = 2 then 'Correcto. La factura está contabilizada en GP.'
				--	else 
				--		case when isnull(fhi.pstgstus, -1) = -1 then
				--			'Incorrecto. La factura no existe en GP'
				--		else 
				--			'La factura está en lote. Contabilice la factura y vuelva a intentar.'
				--		end
				--	end
			else 'No se puede validar la transición ' + @TRANSICION
			end msjPreCondiciones
    from (select @TRANSICION transicion) doc
     outer apply (
			select sopnumbe, voidstts, pstgstus
			from dbo.vwSopFacturasCabezaTH
			where sopnumbe = @NUMDOCGP 
			and soptype = @TIPODOCGP
			and @TRANSICION in ( 'ELIMINA_FACTURA_EN_GP', 'ANULA_FACTURA_SOP_EN_GP')
			) efeg
     outer apply (
			select top 1 sopnumbe, voidstts, pstgstus, cstponbr
			from dbo.vwSopFacturasCabezaTH
			where cstponbr = @NUMERODOC
			and soptype = @TIPODOCGP
			and voidstts = 0
			and @TIPODOC = 1	--guía de remisión
			and @TRANSICION = 'ENVIAR_A_GP'
			) eagp
   --  outer apply (
			--select sopnumbe, voidstts, pstgstus
			--from dbo.vwSopFacturasCabezaTH
			--where replace(sopnumbe, 'T', '0') = replace(@NUMDOCGP , 'T', '0')	--caso de factura electrónica de Arg el número sopnumbe de sop10100 puedes ser totalmente diferente a sop30200
			--and soptype = @TIPODOCGP
			--and @TRANSICION in ( 'ANULA_FACTURA_RM_EN_GP', 'CONTABILIZA_FACTURA_EN_GP')
			--) fhi
)
go

IF (@@Error = 0) PRINT 'Creación exitosa de: comgp_fnDocStatusPreCondiciones'
ELSE PRINT 'Error en la creación de: comgp_fnDocStatusPreCondiciones'
GO

