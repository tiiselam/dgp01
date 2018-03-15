--|--------------------------------------------------------------------------------
--| [sp_PREFACTURADETInsert] - Insert Procedure Script for PREFACTURADET
--|--------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id (N'compuertagp.[sp_PREFACTURADETInsert]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) DROP PROCEDURE compuertagp.[sp_PREFACTURADETInsert]
GO

CREATE PROCEDURE compuertagp.[sp_PREFACTURADETInsert]
(
	@NUMLINEA int = NULL OUTPUT,
	@PREFACTURACAB_NUMERODOC varchar(20),
	@PREFACTURACAB_TIPODOC smallint,
	@IDITEM varchar(30),
	@DESCRIPCION varchar(100),
	@UDM varchar(9),
	@CANTIDAD numeric(19,5),
	@PRECIO numeric(19,5)
)
AS
	SET NOCOUNT ON

	INSERT INTO compuertagp.[PREFACTURADET]
	(
		[PREFACTURACAB_NUMERODOC],
		[PREFACTURACAB_TIPODOC],
		[IDITEM],
		[DESCRIPCION],
		[UDM],
		[CANTIDAD],
		[PRECIO]
	)
	VALUES
	(
		@PREFACTURACAB_NUMERODOC,
		@PREFACTURACAB_TIPODOC,
		@IDITEM,
		@DESCRIPCION,
		@UDM,
		@CANTIDAD,
		@PRECIO
	)

	SELECT @NUMLINEA = SCOPE_IDENTITY();

	RETURN @@Error
GO

--|--------------------------------------------------------------------------------
--| [sp_PREFACTURADETUpdate] - Update Procedure Script for PREFACTURADET
--|--------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id (N'compuertagp.[sp_PREFACTURADETUpdate]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) DROP PROCEDURE compuertagp.[sp_PREFACTURADETUpdate]
GO

CREATE PROCEDURE compuertagp.[sp_PREFACTURADETUpdate]
(
	@NUMLINEA int,
	@PREFACTURACAB_NUMERODOC varchar(20),
	@PREFACTURACAB_TIPODOC smallint,
	@IDITEM varchar(30),
	@DESCRIPCION varchar(100),
	@UDM varchar(9),
	@CANTIDAD numeric(19,5),
	@PRECIO numeric(19,5)
)
AS
	SET NOCOUNT ON
	
	UPDATE compuertagp.[PREFACTURADET]
	SET
		[PREFACTURACAB_NUMERODOC] = @PREFACTURACAB_NUMERODOC,
		[PREFACTURACAB_TIPODOC] = @PREFACTURACAB_TIPODOC,
		[IDITEM] = @IDITEM,
		[DESCRIPCION] = @DESCRIPCION,
		[UDM] = @UDM,
		[CANTIDAD] = @CANTIDAD,
		[PRECIO] = @PRECIO
	WHERE 
		[NUMLINEA] = @NUMLINEA AND
		[PREFACTURACAB_NUMERODOC] = @PREFACTURACAB_NUMERODOC AND
		[PREFACTURACAB_TIPODOC] = @PREFACTURACAB_TIPODOC

	RETURN @@Error
GO

--|--------------------------------------------------------------------------------
--| [sp_PREFACTURADETDelete] - Update Procedure Script for PREFACTURADET
--|--------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id (N'compuertagp.[sp_PREFACTURADETDelete]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) DROP PROCEDURE compuertagp.[sp_PREFACTURADETDelete]
GO

CREATE PROCEDURE compuertagp.[sp_PREFACTURADETDelete]
(
	@NUMLINEA int,
	@PREFACTURACAB_NUMERODOC varchar(20),
	@PREFACTURACAB_TIPODOC smallint
)
AS
	SET NOCOUNT ON

	DELETE 
	FROM   compuertagp.[PREFACTURADET]
	WHERE  
		[NUMLINEA] = @NUMLINEA AND
		[PREFACTURACAB_NUMERODOC] = @PREFACTURACAB_NUMERODOC AND
		[PREFACTURACAB_TIPODOC] = @PREFACTURACAB_TIPODOC

	RETURN @@Error
GO

