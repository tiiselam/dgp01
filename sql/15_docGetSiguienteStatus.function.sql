IF OBJECT_ID ('compuertagp.docGetSiguienteStatus') IS NOT NULL
   DROP FUNCTION compuertagp.docGetSiguienteStatus
GO

--Status permitidos del documento
--LISTO. Indica que el documento (Ej. pre factura) ha sido ingresada por Ariane y está listo para ser integrado
--INTEGRADO. Indica que el documento (Ej. Factura) ha ingresado a GP y todavía es editable en GP.
--CONTABILIZADO. Indica que el documento (Ej. Factura) ha sido contabilizado en GP y ya no es editable.
--
--Transiciones permitidas:
--GENERA_PREFACTURA
--ENVIAR_A_GP
--ELIMINA_FACTURA_EN_GP
--CONTABILIZA_FACTURA_EN_GP
--ANULA_FACTURA_RM_EN_GP
--ANULA_FACTURA_SOP_EN_GP
--
go
create function compuertagp.docGetSiguienteStatus(	@TIPODOCARN smallint, @NUMDOCARN varchar(20), @TRANSICION VARCHAR(50))
returns table
--Propósito. Obtiene el status destino correspondiente a la transicion del parámetro
--Precondiciones. Ejecute fnDocCumplePreCondiciones para saber si cumple los requisitos de la transición en la BD de la compañía destino
-- Atención. Debe retornar un status
--1/3/18 jcf Creación
--
as
return(
	select case when @TRANSICION = 'GENERA_PREFACTURA' and isnull(li.DOCSTATUS, 'INICIO')= 'INICIO' THEN	1
				when @TRANSICION = 'ENVIAR_A_GP' and li.DOCSTATUS = 'LISTO' THEN							1
				when @TRANSICION = 'ELIMINA_FACTURA_EN_GP' and li.DOCSTATUS = 'INTEGRADO' THEN				1
				when @TRANSICION = 'CONTABILIZA_FACTURA_EN_GP' and li.DOCSTATUS = 'INTEGRADO' THEN			1
				when @TRANSICION = 'ANULA_FACTURA_RM_EN_GP' and li.DOCSTATUS = 'CONTABILIZADO' THEN			1
				when @TRANSICION = 'ANULA_FACTURA_SOP_EN_GP' and li.DOCSTATUS = 'INTEGRADO' THEN			1
			else 0
			end transicionFactible,

			li.DOCSTATUS statusOrigen,

			case when @TRANSICION = 'GENERA_PREFACTURA' and isnull(li.DOCSTATUS, 'INICIO')= 'INICIO' THEN	'LISTO'
				when @TRANSICION = 'ENVIAR_A_GP' and li.DOCSTATUS = 'LISTO' THEN							'INTEGRADO'
				when @TRANSICION = 'ELIMINA_FACTURA_EN_GP' and li.DOCSTATUS = 'INTEGRADO'  THEN				'LISTO'
				when @TRANSICION = 'CONTABILIZA_FACTURA_EN_GP' and li.DOCSTATUS = 'INTEGRADO' THEN			'CONTABILIZADO'
				when @TRANSICION = 'ANULA_FACTURA_RM_EN_GP' and li.DOCSTATUS = 'CONTABILIZADO' THEN			'LISTO'
				when @TRANSICION = 'ANULA_FACTURA_SOP_EN_GP' and li.DOCSTATUS = 'INTEGRADO' THEN			'LISTO'
			else isnull(li.DOCSTATUS, 'INICIO')
			end statusDestino,

			case when @TRANSICION = 'GENERA_PREFACTURA' and isnull(li.DOCSTATUS, 'INICIO')= 'INICIO' THEN	'INICIO->LISTO Transición OK. Puede integrar a GP.'
				when @TRANSICION = 'ENVIAR_A_GP'and li.DOCSTATUS = 'LISTO' THEN								'LISTO->INTEGRADO Transición OK.'
				when @TRANSICION = 'ELIMINA_FACTURA_EN_GP' and li.DOCSTATUS = 'INTEGRADO' THEN				'INTEGRADO->LISTO Transición OK. Puede re-integrar a GP.'
				when @TRANSICION = 'CONTABILIZA_FACTURA_EN_GP' and li.DOCSTATUS = 'INTEGRADO' THEN			'INTEGRADO->CONTABILIZADO en GP.'
				when @TRANSICION = 'ANULA_FACTURA_RM_EN_GP' and li.DOCSTATUS = 'CONTABILIZADO' THEN			'CONTABILIZADO->LISTO Transición OK. Puede re-integrar a GP.'
				when @TRANSICION = 'ANULA_FACTURA_SOP_EN_GP' and li.DOCSTATUS = 'INTEGRADO' THEN			'INTEGRADO->LISTO Transición OK. Puede re-integrar a GP.'
			else 'La transición '+@TRANSICION + ', no permite cambiar el status '+isnull(li.DOCSTATUS, 'INICIO')
			end mensaje

	from (select 1 predet) pd
	outer apply (
		select DOCSTATUS, isnull(TIPODOCGP, 0) TIPODOCGP, isnull(NUMDOCGP, '') NUMDOCGP
		FROM compuertagp.LOGINTEGRACIONES 
		WHERE TIPODOCARN     = @TIPODOCARN
		and NUMDOCARN        = @NUMDOCARN
		and ESACTUAL         = 1
	) li
)
go

IF (@@Error = 0) PRINT 'Creación exitosa de: docGetSiguienteStatus'
ELSE PRINT 'Error en la creación de: docGetSiguienteStatus'
GO
------------------------------------------------------------------------------



