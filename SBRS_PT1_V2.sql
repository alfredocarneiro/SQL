--PARTE 1
--Declarar nome da base
DECLARE @base sysname, @sql NVARCHAR(MAX)
SET @base = 'NomeBase'

IF @base = '' 
BEGIN
	select 'Nome da base a ser restaurada está vazio!'
END
ELSE
BEGIN
--Verifica a existencia da base BackupTabelas se existir dropa
	IF EXISTS ( SELECT name FROM sys.databases WHERE name = 'BackupTabelas' )
	DROP DATABASE BackupTabelas;

--Cria a base BackupTabelas
	CREATE DATABASE BackupTabelas;
	
--Inserir os dados das tabelas Sequencias, PesquisaProtocolo e PesquisaDocumentoBaixa das bases NomeBase para as tabelas BackupSequencia, BackupPsqProtocolo e BackupPsqDocBaixa da base BackupTabelas
	SET @sql = 'SELECT * INTO BackupTabelas.dbo.BackupSequencia FROM '+@base+'.dbo.sequencia;'
	EXEC (@sql);
	SET @sql2 = 'SELECT * INTO BackupTabelas.dbo.BackupPsqProtocolo FROM '+@base+'.dbo.PesquisaProtocolo;'
	EXEC (@sql2);
	SET @sql3 = 'SELECT * INTO BackupTabelas.dbo.BackupPsqDocBaixa FROM '+@base+'.dbo.PesquisaDocumentoBaixa;'
	EXEC (@sql3);

--Select para conferir se as sequencias e pesquisas foram copiadas
	select codigo, descricao, numero, formatacao from BackupTabelas.dbo.BackupSequencia
	select descricao from BackupTabelas.dbo.BackupPsqProtocolo
	select descricao from BackupTabelas.dbo.BackupPsqDocBaixa
END
GO
