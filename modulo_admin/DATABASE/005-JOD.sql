USE msdb;
GO

EXEC dbo.sp_add_job
    @job_name = N'EliminarCarpetasExpiradas', 
    @enabled = 1, 
    @description = N'Elimina carpetas marcadas como eliminadas con más de 30 días.';
GO

EXEC sp_add_jobstep
    @job_name = N'EliminarCarpetasExpiradas',
    @step_name = N'Ejecutar usp_EliminarCarpetasExpiradas',
    @subsystem = N'TSQL',
    @command = N'EXEC usp_EliminarCarpetasExpiradas;',
    @database_name = N'SISTEMA_DE_GESTION_DIDACTICA',
    @on_success_action = 1,
    @on_fail_action = 2;
GO

EXEC sp_add_schedule
    @schedule_name = N'EjecucionDiaria3AM',
    @enabled = 1,
    @freq_type = 4,
    @freq_interval = 1,
    @active_start_time = 030000;
GO

EXEC sp_attach_schedule
    @job_name = N'EliminarCarpetasExpiradas',
    @schedule_name = N'EjecucionDiaria3AM';
GO

EXEC sp_add_jobserver
    @job_name = N'EliminarCarpetasExpiradas',
    @server_name = N'(LOCAL)';
GO
