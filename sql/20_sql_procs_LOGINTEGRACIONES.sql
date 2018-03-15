
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id (N'[compuertagp].[sp_LOGINTEGRACIONESInsUpdBase]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
	DROP PROCEDURE compuertagp.sp_LOGINTEGRACIONESInsUpdBase
GO

CREATE PROCEDURE compuertagp.sp_LOGINTEGRACIONESInsUpdBase
--	@ID int = NULL OUTPUT,
	@TIPODOCARN smallint,
	@NUMDOCARN varchar(20),
	@TIPODOCGP smallint = NULL,
	@NUMDOCGP varchar(20) = NULL,
	@DOCSTATUS VARCHAR(20),
	@USUARIO varchar(35),
	@MENSAJE varchar(150),
	@MENSAJELARGO varchar(MAX) = NULL

AS
	begin try

		IF EXISTS (SELECT 1 FROM compuertagp.LOGINTEGRACIONES 
					WHERE TIPODOCARN     = @TIPODOCARN
					and NUMDOCARN        = @NUMDOCARN
					and ESACTUAL         = 1)
		BEGIN
 
			UPDATE compuertagp.LOGINTEGRACIONES
			   SET 
				   TIPODOCGP        = @TIPODOCGP,
				   NUMDOCGP         = @NUMDOCGP,
				   DOCSTATUS        = @DOCSTATUS,
				   USUARIO          = @USUARIO,
				   FECHAHORA        = GETDATE(),
				   MENSAJE          = @MENSAJE,
				   MENSAJELARGO     = @MENSAJELARGO
			 WHERE TIPODOCARN     = @TIPODOCARN
				And NUMDOCARN        = @NUMDOCARN
				And ESACTUAL         = 1
 
 
		END
		ELSE
		BEGIN
 			INSERT INTO compuertagp.LOGINTEGRACIONES(TIPODOCARN,NUMDOCARN,TIPODOCGP,NUMDOCGP,DOCSTATUS,ESACTUAL,USUARIO,FECHAHORA,MENSAJE, MENSAJELARGO )
									SELECT @TIPODOCARN,@NUMDOCARN,@TIPODOCGP,@NUMDOCGP,@DOCSTATUS,1,@USUARIO,GETDATE(),@MENSAJE, @MENSAJELARGO 
 
		END
	end try
	begin catch
		print ERROR_NUMBER() + ' ' + ERROR_MESSAGE();  
		THROW;
	end catch;
 
GO

--|--------------------------------------------------------------------------------
--| [sp_LOGINTEGRACIONESInsert] - Insert Procedure Script for LOGINTEGRACIONES
--|--------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id (N'compuertagp.[sp_LOGINTEGRACIONESInsert]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) DROP PROCEDURE compuertagp.[sp_LOGINTEGRACIONESInsert]
GO

--------------------------------------------------------------------------
create PROCEDURE compuertagp.[sp_LOGINTEGRACIONESInsert]
(
	@ID int = NULL OUTPUT,
	@TIPODOCARN smallint,
	@NUMDOCARN varchar(20),
	@TIPODOCGP smallint = NULL,
	@NUMDOCGP varchar(20) = NULL,
	@TRANSICION VARCHAR(50),
	@USUARIO varchar(35),
	@MENSAJE varchar(150),
	@MSJPRECONDICIONES varchar(MAX) = NULL,
	@CUMPLEPRECONDICIONES smallint = 1
)
AS
	SET NOCOUNT ON

	begin try
		declare @transicionFactible smallint, @statusOrigen varchar(20), @statusDestino varchar(20), @MSJERR varchar(MAX), @MSJ varchar(150);
		set @MSJ = @MENSAJE;

		select  @transicionFactible = transicionFactible,
			@statusOrigen = statusOrigen,
			@statusDestino = statusDestino, 
			@MSJERR = mensaje
		from compuertagp.docGetSiguienteStatus(@TIPODOCARN, @NUMDOCARN, @TRANSICION);

		if (@transicionFactible = 1 and @CUMPLEPRECONDICIONES = 1)
		begin
			INSERT INTO compuertagp.[LOGINTEGRACIONES]
			(
				[TIPODOCARN],
				[NUMDOCARN],
				[TIPODOCGP],
				[NUMDOCGP],
				[DOCSTATUS],
				ESACTUAL,
				[USUARIO],
				[FECHAHORA],
				[MENSAJE],
				[MENSAJELARGO]
			)
			VALUES
			(
				@TIPODOCARN,
				@NUMDOCARN,
				@TIPODOCGP,
				@NUMDOCGP,
				@statusDestino,
				0,
				@USUARIO,
				GETDATE(),
				@MSJ,
				@MSJERR + ' ' + isnull(@MSJPRECONDICIONES, '')
			);
		end
		else 
		begin
			set @statusDestino = @statusOrigen;
			set @MSJ = 'No puede cambiar el estado. Intentó la transición ' + @TRANSICION;
			select @MSJERR = case when @transicionFactible = 0 then  @MSJERR else ' ' end +
							case when @CUMPLEPRECONDICIONES = 0 then  @MSJPRECONDICIONES else '' end;
		end

		exec compuertagp.sp_LOGINTEGRACIONESInsUpdBase @TIPODOCARN, @NUMDOCARN, @TIPODOCGP, @NUMDOCGP,
											@statusDestino, @USUARIO, @MSJ, @MSJERR;

		SELECT @ID = SCOPE_IDENTITY();
	end try
	begin catch
		print ERROR_NUMBER() + ' ' + ERROR_MESSAGE();  
		THROW;
	end catch;
GO

---------------------------------------------------------------------------------------------------------------


--|--------------------------------------------------------------------------------
--| [sp_LOGINTEGRACIONESUpdate] - Update Procedure Script for LOGINTEGRACIONES
--|--------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id (N'compuertagp.[sp_LOGINTEGRACIONESUpdate]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) DROP PROCEDURE compuertagp.[sp_LOGINTEGRACIONESUpdate]
GO

CREATE PROCEDURE compuertagp.[sp_LOGINTEGRACIONESUpdate]
(
	@ID int,
	@TIPODOCARN smallint,
	@NUMDOCARN varchar(20),
	@TIPODOCGP smallint = NULL,
	@NUMDOCGP varchar(20) = NULL,
	@DOCSTATUS varchar(20),
	@USUARIO varchar(35),
	@FECHAHORA datetime,
	@MENSAJE varchar(150),
	@MENSAJELARGO varchar(MAX) = NULL
)
AS
	SET NOCOUNT ON
	
	UPDATE compuertagp.[LOGINTEGRACIONES]
	SET
		[TIPODOCARN] = @TIPODOCARN,
		[NUMDOCARN] = @NUMDOCARN,
		[TIPODOCGP] = @TIPODOCGP,
		[NUMDOCGP] = @NUMDOCGP,
		[DOCSTATUS] = @DOCSTATUS,
		[USUARIO] = @USUARIO,
		[FECHAHORA] = @FECHAHORA,
		[MENSAJE] = @MENSAJE,
		[MENSAJELARGO] = @MENSAJELARGO
	WHERE 
		[ID] = @ID

	RETURN @@Error
GO

--|--------------------------------------------------------------------------------
--| [sp_LOGINTEGRACIONESDelete] - Update Procedure Script for LOGINTEGRACIONES
--|--------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id (N'compuertagp.[sp_LOGINTEGRACIONESDelete]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) DROP PROCEDURE compuertagp.[sp_LOGINTEGRACIONESDelete]
GO

CREATE PROCEDURE compuertagp.[sp_LOGINTEGRACIONESDelete]
(
	@ID int
)
AS
	SET NOCOUNT ON

	DELETE 
	FROM   compuertagp.[LOGINTEGRACIONES]
	WHERE  
		[ID] = @ID

	RETURN @@Error
GO

