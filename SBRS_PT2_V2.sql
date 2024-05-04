--PROCESSO RESTAURAÇÃO
--(Após restaurar base da sede)

--PARTE 2
IF EXISTS ( SELECT name FROM sys.databases WHERE name = 'BackupTabelas' )
BEGIN
--Declarar nome da base
	DECLARE @base sysname, @sql1 NVARCHAR(MAX), @sql2 NVARCHAR(MAX), @sql3 NVARCHAR(MAX), @sqlselect NVARCHAR(MAX)
	SET @base = 'NomeBase'
	
	IF @base = '' 
	BEGIN
		select 'Nome da base a ser restaurada está vazio!'
	END
	ELSE
	BEGIN
--Inserir os dados que não existem na tabela de backup para tabela do sistema
       SET @sqlselect =
			'SELECT * FROM BackupTabelas.dbo.backupsequencia
			WHERE BackupTabelas.dbo.backupsequencia.codigo NOT IN 
			(SELECT codigo FROM '+@base+'.dbo.sequencia)'

		SET @sql1 = 'INSERT INTO '+@base+'.dbo.sequencia '+@sqlselect+
			'--Se houver dados a serem inseridos após a inserção é executado o generatorinitialization
			IF @@ROWCOUNT > 0
			begin
				use '+@base+'
				exec generatorinitialization
				use master
			end'
		EXEC (@sqlselect);
		EXEC (@sql1);

       SET @sqlselect2 =
			'SELECT * FROM BackupTabelas.dbo.BackupPsqProtocolo
			WHERE BackupTabelas.dbo.BackupPsqProtocolo.Descricao NOT IN 
			(SELECT Descricao FROM '+@base+'.dbo.PesquisaProtocolo)'

		SET @sql2 = 'INSERT INTO '+@base+'.dbo.PesquisaProtocolo '+@sqlselect+
			'--Se houver dados a serem inseridos após a inserção é executado o generatorinitialization
			IF @@ROWCOUNT > 0
			begin
				use '+@base+'
				exec generatorinitialization
				use master
			end'
		EXEC (@sqlselect2);
		EXEC (@sql2);
		
		SET @sqlselect3 =
			'SELECT * FROM BackupTabelas.dbo.BackupPsqDocBaixa
			WHERE BackupTabelas.dbo.BackupPsqDocBaixa.Descricao NOT IN 
			(SELECT Descricao FROM '+@base+'.dbo.PesquisaDocumentoBaixa)'

		SET @sql3 = 'INSERT INTO '+@base+'.dbo.PesquisaDocumentoBaixa '+@sqlselect+
			'--Se houver dados a serem inseridos após a inserção é executado o generatorinitialization
			IF @@ROWCOUNT > 0
			begin
				use '+@base+'
				exec generatorinitialization
				use master
			end'
		EXEC (@sqlselect3);
		EXEC (@sql3);
		
--Faz a comparação dos dados backupsequencia com a sequencia. 
--Os que houverem diferença de numero ou formatação onde o codigo e descricao forem iguais, os dados são atualizados com os anteriores.

        SET @sqlselect4 =
			+@base+'.dbo.sequencia as Inc_Seq
			inner join BackupTabelas.dbo.BackupSequencia bkp_seq on Inc_Seq.descricao = bkp_seq.descricao
			where Inc_Seq.codigo = bkp_seq.codigo and 
			Inc_Seq.descricao = bkp_seq.descricao and 
			Inc_Seq.numero != bkp_seq.numero or 
			Inc_Seq.Formatacao != bkp_seq.Formatacao;'

			SET @sql4 = 'update Inc_Seq
			set Inc_Seq.numero = bkp_seq.numero, 
			Inc_Seq.formatacao = bkp_seq.formatacao from '+@sqlselect4
			
		EXEC ('select Inc_Seq.codigo as Codigo, Inc_Seq.descricao as Descricao, Inc_Seq.numero as Numero_Anterior , bkp_seq.numero as Numero_Modificado, Inc_Seq.formatacao as Formatacao_Anterior, bkp_seq.formatacao as Formatacao_Modificada from '+@sqlselect4);
		EXEC (@sql4);

--SBstext RBrtm DtUltMod Filtro Dados SubConsultas		
		SET @sqlselect5 =
			+@base+'.dbo.PesquisaProtocolo as PsqPrt
			inner join BackupTabelas.dbo.BackupPsqProtocolo Bkp_PsqPrt on PsqPrt.descricao = Bkp_PsqPrt.descricao
			where PsqPrt.descricao = Bkp_PsqPrt.descricao and 
			PsqPrt.SBstext != Bkp_PsqPrt.SBstext or 
			PsqPrt.RBrtm != Bkp_PsqPrt.RBrtm or 
			PsqPrt.DtUltMod != Bkp_PsqPrt.DtUltMod or 
			PsqPrt.Filtro != Bkp_PsqPrt.Filtro or 
			PsqPrt.Dados != Bkp_PsqPrt.Dados or 
			PsqPrt.SubConsultas != Bkp_PsqPrt.SubConsultas;'

			SET @sql5 = 'update PsqPrt
			set PsqPrt.SBstext = Bkp_PsqPrt.SBstext, 
			PsqPrt.RBrtm = Bkp_PsqPrt.RBrtm,
			PsqPrt.DtUltMod = Bkp_PsqPrt.DtUltMod,
			PsqPrt.Filtro = Bkp_PsqPrt.Filtro,
			PsqPrt.Dados = Bkp_PsqPrt.Dados,
			PsqPrt.SubConsultas = Bkp_PsqPrt.SubConsultas,
			from '+@sqlselect5
			
		EXEC ('select PsqPrt.descricao as Descricao_Anterior, Bkp_PsqPrt.descricao as Descricao_Modificada, PsqPrt.SBstext as SBstext_Anterior , Bkp_PsqPrt.SBstext as SBstext_Modificado, PsqPrt.RBrtm as RBrtm_Anterior, Bkp_PsqPrt.RBrtm as RBrtm_Modificada, PsqPrt.DtUltMod as DtUltMod_Anterior, Bkp_PsqPrt.DtUltMod as DtUltMod_Modificada, PsqPrt.Filtro as Filtro_Anterior, Bkp_PsqPrt.Filtro as Filtro_Modificada, PsqPrt.Dados as Dados_Anterior, Bkp_PsqPrt.Dados as Dados_Modificada, PsqPrt.SubConsultas as SubConsultas_Anterior, Bkp_PsqPrt.SubConsultas as SubConsultas_Modificada from '+@sqlselect5);
		EXEC (@sql5);
		
		SET @sqlselect6 =
			+@base+'.dbo.PesquisaDocumentoBaixa as PsqDoc
			inner join BackupTabelas.dbo.BackupPsqProtocolo Bkp_PsqDoc on PsqDoc.descricao = Bkp_PsqDoc.descricao
			where PsqDoc.descricao = Bkp_PsqDoc.descricao and 
			PsqDoc.SBstext != Bkp_PsqDoc.SBstext or 
			PsqDoc.RBrtm != Bkp_PsqDoc.RBrtm or 
			PsqDoc.DtUltMod != Bkp_PsqDoc.DtUltMod or 
			PsqDoc.Filtro != Bkp_PsqDoc.Filtro or 
			PsqDoc.Dados != Bkp_PsqDoc.Dados or 
			PsqDoc.SubConsultas != Bkp_PsqDoc.SubConsultas;'

			SET @sql6 = 'update PsqDoc
			set PsqDoc.SBstext = Bkp_PsqDoc.SBstext, 
			PsqDoc.RBrtm = Bkp_PsqDoc.RBrtm,
			PsqDoc.DtUltMod = Bkp_PsqDoc.DtUltMod,
			PsqDoc.Filtro = Bkp_PsqDoc.Filtro,
			PsqDoc.Dados = Bkp_PsqDoc.Dados,
			PsqDoc.SubConsultas = Bkp_PsqDoc.SubConsultas,
			from '+@sqlselect6
			
		EXEC ('select PsqDoc.descricao as Descricao_Anterior, Bkp_PsqDoc.descricao as Descricao_Modificada, PsqDoc.SBstext as SBstext_Anterior , Bkp_PsqDoc.SBstext as SBstext_Modificado, PsqDoc.RBrtm as RBrtm_Anterior, Bkp_PsqDoc.RBrtm as RBrtm_Modificada, PsqDoc.DtUltMod as DtUltMod_Anterior, Bkp_PsqDoc.DtUltMod as DtUltMod_Modificada, PsqDoc.Filtro as Filtro_Anterior, Bkp_PsqDoc.Filtro as Filtro_Modificada, PsqDoc.Dados as Dados_Anterior, Bkp_PsqDoc.Dados as Dados_Modificada, PsqDoc.SubConsultas as SubConsultas_Anterior, Bkp_PsqDoc.SubConsultas as SubConsultas_Modificada from '+@sqlselect6);
		EXEC (@sql6);

	END
END
ELSE
	select 'Base de Backup não existe!'
GO
