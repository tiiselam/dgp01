
--|--------------------------------------------------------------------------------
--| [sp_PREFACTURACABInsert] - Insert Procedure Script for PREFACTURACAB
--|--------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id (N'compuertagp.[sp_PREFACTURACABInsert]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) DROP PROCEDURE compuertagp.[sp_PREFACTURACABInsert]
GO

--Propósito. Ingresa la cabecera de una pre factura
--01/03/18 jcf Creación
--
CREATE PROCEDURE compuertagp.[sp_PREFACTURACABInsert]
(
	@TIPODOC smallint,
	@NUMERODOC varchar(20),
	@IDCLIENTE varchar(15),
	@FECHADOC datetime,
	@OBSERVACIONES varchar(30),
	@USUARIO varchar(35)
)
AS
	SET NOCOUNT ON
	begin try

		INSERT INTO compuertagp.[PREFACTURACAB]
		(
			[TIPODOC],
			[NUMERODOC],
			[IDCLIENTE],
			[FECHADOC],
			[OBSERVACIONES],
			DOCID_GP,
			SOPTYPE_GP
		)
		VALUES
		(
			@TIPODOC,
			@NUMERODOC,
			@IDCLIENTE,
			@FECHADOC,
			@OBSERVACIONES,
			'FV A0001',
			3
		)

		DECLARE @idLog int;
		EXEC compuertagp.[sp_LOGINTEGRACIONESInsert] @idLog out, @TIPODOC, @NUMERODOC, null, null, 'GENERA_PREFACTURA', @USUARIO, 'Pendiente de ser integrado a GP.', null, 1; 

	end try
	begin catch
		print ERROR_NUMBER() + ' ' + ERROR_MESSAGE();  
		THROW;
	end catch;
go
--|--------------------------------------------------------------------------------
--| [sp_PREFACTURACABUpdate] - Update Procedure Script for PREFACTURACAB
--|--------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id (N'compuertagp.[sp_PREFACTURACABUpdate]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
	DROP PROCEDURE compuertagp.[sp_PREFACTURACABUpdate];
GO

CREATE PROCEDURE compuertagp.[sp_PREFACTURACABUpdate]
(
	@TIPODOC smallint,
	@NUMERODOC varchar(20),
	@IDCLIENTE varchar(15),
	@FECHADOC datetime,
	@OBSERVACIONES varchar(30)
)
AS
	SET NOCOUNT ON
	
	UPDATE compuertagp.[PREFACTURACAB]
	SET
		[TIPODOC] = @TIPODOC,
		[NUMERODOC] = @NUMERODOC,
		[IDCLIENTE] = @IDCLIENTE,
		[FECHADOC] = @FECHADOC,
		[OBSERVACIONES] = @OBSERVACIONES
	WHERE 
		[TIPODOC] = @TIPODOC AND
		[NUMERODOC] = @NUMERODOC

	RETURN @@Error
GO

--|--------------------------------------------------------------------------------
--| [sp_PREFACTURACABDelete] - Update Procedure Script for PREFACTURACAB
--|--------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id (N'compuertagp.[sp_PREFACTURACABDelete]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) DROP PROCEDURE compuertagp.[sp_PREFACTURACABDelete]
GO

CREATE PROCEDURE compuertagp.[sp_PREFACTURACABDelete]
(
	@TIPODOC smallint,
	@NUMERODOC varchar(20)
)
AS
	SET NOCOUNT ON

	DELETE 
	FROM   compuertagp.[PREFACTURACAB]
	WHERE  
		[TIPODOC] = @TIPODOC AND
		[NUMERODOC] = @NUMERODOC

	RETURN @@Error
GO

