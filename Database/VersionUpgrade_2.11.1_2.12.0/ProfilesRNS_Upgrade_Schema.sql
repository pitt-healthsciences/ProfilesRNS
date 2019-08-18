/*
Run this script on:

        Profiles 2.11.1   -  This database will be modified

to synchronize it with:

        Profiles 2.12.0

You are recommended to back up your database before running this script

Details of which objects have changed can be found in the release notes.
If you have made changes to existing tables or stored procedures in profiles, you may need to merge changes individually. 

*/

GO
PRINT N'Creating [Profile.Data].[Publication.Pubmed.Bibliometrics]...';


GO
CREATE TABLE [Profile.Data].[Publication.Pubmed.Bibliometrics] (
    [PMID]                     INT           NOT NULL,
    [PMCCitations]             INT           NOT NULL,
    [MedlineTA]                VARCHAR (255) NULL,
    [Fields]                   VARCHAR (MAX) NULL,
    [TranslationHumans]        INT           NULL,
    [TranslationAnimals]       INT           NULL,
    [TranslationCells]         INT           NULL,
    [TranslationPublicHealth]  INT           NULL,
    [TranslationClinicalTrial] INT           NULL,
    PRIMARY KEY CLUSTERED ([PMID] ASC)
);


GO
PRINT N'Creating [Profile.Data].[Publication.Pubmed.JournalHeading]...';


GO
CREATE TABLE [Profile.Data].[Publication.Pubmed.JournalHeading] (
    [MedlineTA]           VARCHAR (255) NOT NULL,
    [BroadJournalHeading] VARCHAR (100) NOT NULL,
    [Weight]              FLOAT (53)    NOT NULL,
    [DisplayName]         VARCHAR (100) NULL,
    [Abbreviation]        VARCHAR (50)  NULL,
    [Color]               VARCHAR (6)   NULL,
    [Angle]               FLOAT (53)    NULL,
    [Arc]                 FLOAT (53)    NULL,
    PRIMARY KEY CLUSTERED ([MedlineTA] ASC, [BroadJournalHeading] ASC)
);


GO
PRINT N'Creating [Profile.Import].[HMSWebservice.Log]...';


GO
CREATE TABLE [Profile.Import].[HMSWebservice.Log] (
    [LogID]            INT           IDENTITY (1, 1) NOT NULL,
    [Job]              VARCHAR (55)  NOT NULL,
    [BatchID]          VARCHAR (100) NULL,
    [RowID]            INT           NULL,
    [ServiceCallStart] DATETIME      NULL,
    [ServiceCallEnd]   DATETIME      NULL,
    [ProcessEnd]       DATETIME      NULL,
    [Success]          BIT           NULL,
    [ErrorText]        VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([LogID] ASC)
);


GO
PRINT N'Altering [Framework.].[LICENCE]...';


GO
ALTER PROCEDURE [Framework.].[LICENCE]
AS
BEGIN
PRINT 
'
Copyright (c) 2008-2014 by the President and Fellows of Harvard College. All rights reserved.  Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD., and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the National Center for Research Resources and Harvard University.
 
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
	* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
	* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
	* Neither the name "Harvard" nor the names of its contributors nor the name "Harvard Catalyst" may be used to endorse or promote products derived from this software without specific prior written permission.
 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER (PRESIDENT AND FELLOWS OF HARVARD COLLEGE) AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
'
END
GO
PRINT N'Altering [Ontology.].[AddProperty]...';


GO
ALTER PROCEDURE [Ontology.].[AddProperty]
	@OWL nvarchar(100),
	@PropertyURI varchar(400),
	@PropertyName varchar(max),
	@ObjectType bit,
	@PropertyGroupURI varchar(400) = null,
	@SortOrder int = null,
	@ClassURI varchar(400) = null,
	@NetworkPropertyURI varchar(400) = null,
	@IsDetail bit = null,
	@Limit int = null,
	@IncludeDescription bit = null,
	@IncludeNetwork bit = null,
	@SearchWeight float = null,
	@CustomDisplay bit = null,
	@CustomEdit bit = null,
	@ViewSecurityGroup bigint = null,
	@EditSecurityGroup bigint = null,
	@EditPermissionsSecurityGroup bigint = null,
	@EditExistingSecurityGroup bigint = null,
	@EditAddNewSecurityGroup bigint = null,
	@EditAddExistingSecurityGroup bigint = null,
	@EditDeleteSecurityGroup bigint = null,
	@MinCardinality int = null,
	@MaxCardinality int = null,
	@CustomEditModule xml = null,
	@ReSortClassProperty bit = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	---------------------------------------------------
	-- [Ontology.Import].[Triple]
	---------------------------------------------------

	DECLARE @LoadRDF BIT
	SELECT @LoadRDF = 0

	-- Get Graph
	DECLARE @Graph BIGINT
	SELECT @Graph = (SELECT Graph FROM [Ontology.Import].[OWL] WHERE Name = @OWL)

	-- Insert Type record
	IF NOT EXISTS (SELECT *
					FROM [Ontology.Import].[Triple]
					WHERE OWL = @OWL and Subject = @PropertyURI and Predicate = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type')
	BEGIN
		INSERT INTO [Ontology.Import].[Triple] (OWL, Graph, Subject, Predicate, Object)
			SELECT @OWL, @Graph, @PropertyURI,
				'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
				(CASE WHEN @ObjectType = 1 THEN 'http://www.w3.org/2002/07/owl#DatatypeProperty'
						ELSE 'http://www.w3.org/2002/07/owl#ObjectProperty' END)
		SELECT @LoadRDF = 1
	END
	
	-- Insert Label record
	IF NOT EXISTS (SELECT *
					FROM [Ontology.Import].[Triple]
					WHERE OWL = @OWL and Subject = @PropertyURI and Predicate = 'http://www.w3.org/2000/01/rdf-schema#label')
	BEGIN
		INSERT INTO [Ontology.Import].[Triple] (OWL, Graph, Subject, Predicate, Object)
			SELECT @OWL, @Graph, @PropertyURI,
				'http://www.w3.org/2000/01/rdf-schema#label',
				@PropertyName
		SELECT @LoadRDF = 1
	END

	-- Load RDF
	IF @LoadRDF = 1
	BEGIN
		EXEC [RDF.Stage].[LoadTriplesFromOntology] @OWL = @OWL, @Truncate = 1
		EXEC [RDF.Stage].[ProcessTriples]
	END
	
	---------------------------------------------------
	-- [Ontology.].[PropertyGroupProperty]
	---------------------------------------------------

	IF NOT EXISTS (SELECT * FROM [Ontology.].PropertyGroupProperty WHERE PropertyURI = @PropertyURI)
	BEGIN
	
		-- Validate the PropertyGroupURI
		SELECT @PropertyGroupURI = IsNull((SELECT TOP 1 PropertyGroupURI 
											FROM [Ontology.].PropertyGroup
											WHERE PropertyGroupURI = @PropertyGroupURI
												AND @PropertyGroupURI IS NOT NULL
											),'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupOverview')
		
		-- Validate the SortOrder
		DECLARE @MaxSortOrder INT
		SELECT @MaxSortOrder = IsNull((SELECT MAX(SortOrder)
										FROM [Ontology.].PropertyGroupProperty
										WHERE PropertyGroupURI = @PropertyGroupURI),0)
		SELECT @SortOrder = (CASE WHEN @SortOrder IS NULL THEN @MaxSortOrder+1
									WHEN @SortOrder > @MaxSortOrder THEN @MaxSortOrder+1
									ELSE @SortOrder END)

		-- Shift SortOrder of existing records
		UPDATE [Ontology.].PropertyGroupProperty
			SET SortOrder = SortOrder + 1
			WHERE PropertyGroupURI = @PropertyGroupURI AND SortOrder >= @SortOrder
		
		-- Insert new property
		INSERT INTO [Ontology.].PropertyGroupProperty (PropertyGroupURI, PropertyURI, SortOrder, _NumberOfNodes)
			SELECT @PropertyGroupURI, @PropertyURI, @SortOrder, 0

	END

	---------------------------------------------------
	-- [Ontology.].[ClassProperty]
	---------------------------------------------------

	IF (@ClassURI IS NOT NULL) AND NOT EXISTS (
		SELECT *
		FROM [Ontology.].[ClassProperty]
		WHERE Class = @ClassURI AND Property = @PropertyURI
			AND ( (NetworkProperty IS NULL AND @NetworkPropertyURI IS NULL) OR (NetworkProperty = @NetworkPropertyURI) )
	)
	BEGIN

		-- Get the ClassPropertyID	
		DECLARE @ClassPropertyID INT
		SELECT @ClassPropertyID = IsNull((SELECT MAX(ClassPropertyID)
											FROM [Ontology.].ClassProperty),0)+1
		-- Insert the new property
		INSERT INTO [Ontology.].[ClassProperty] (
				ClassPropertyID,
				Class, NetworkProperty, Property,
				IsDetail, Limit, IncludeDescription, IncludeNetwork, SearchWeight,
				CustomDisplay, CustomEdit, ViewSecurityGroup,
				EditSecurityGroup, EditPermissionsSecurityGroup, EditExistingSecurityGroup, EditAddNewSecurityGroup, EditAddExistingSecurityGroup, EditDeleteSecurityGroup,
				MinCardinality, MaxCardinality, CustomEditModule,
				_NumberOfNodes, _NumberOfTriples		
			)
			SELECT	@ClassPropertyID,
					@ClassURI, @NetworkPropertyURI, @PropertyURI,
					IsNull(@IsDetail,1), @Limit, IsNull(@IncludeDescription,0), IsNull(@IncludeNetwork,0),
					IsNull(@SearchWeight,(CASE WHEN @ObjectType = 0 THEN 0 ELSE 0.5 END)),
					IsNull(@CustomDisplay,0), IsNull(@CustomEdit,0), IsNull(@ViewSecurityGroup,-1),
					IsNull(@EditSecurityGroup,-40),
					Coalesce(@EditPermissionsSecurityGroup,@EditSecurityGroup,-40),
					Coalesce(@EditExistingSecurityGroup,@EditSecurityGroup,-40),
					Coalesce(@EditAddNewSecurityGroup,@EditSecurityGroup,-40),
					Coalesce(@EditAddExistingSecurityGroup,@EditSecurityGroup,-40),
					Coalesce(@EditDeleteSecurityGroup,@EditSecurityGroup,-40),
					IsNull(@MinCardinality,0),
					@MaxCardinality,
					@CustomEditModule,
					0, 0

		-- Re-sort the table
		IF @ReSortClassProperty = 1
		BEGIN
			update x
				set x.ClassPropertyID = y.k
				from [Ontology.].ClassProperty x, (
					select *, row_number() over (order by (case when NetworkProperty is null then 0 else 1 end), Class, NetworkProperty, IsDetail, IncludeNetwork, Property) k
						from [Ontology.].ClassProperty
				) y
				where x.Class = y.Class and x.Property = y.Property
					and ((x.NetworkProperty is null and y.NetworkProperty is null) or (x.NetworkProperty = y.NetworkProperty))

					
			update x 
				set x._ClassPropertyID = b.ClassPropertyID 
				from [Ontology.].ClassPropertyCustom x join [Ontology.].ClassProperty b
					on x.Class=b.Class and x.Property=b.Property
					and ((x.NetworkProperty is null and b.NetworkProperty is null) or (x.NetworkProperty = b.NetworkProperty))
		END
	END

	---------------------------------------------------
	-- Update Derived Fields
	---------------------------------------------------

	EXEC [Ontology.].UpdateDerivedFields
	
	
	/*
	
	-- Example
	exec [Ontology.].AddProperty
		@OWL = 'PRNS_1.0',
		@PropertyURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#emailEncrypted',
		@PropertyName = 'email encrypted',
		@ObjectType = 1,
		@PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupAddress',
		@SortOrder = 20,
		@ClassURI = 'http://xmlns.com/foaf/0.1/Person',
		@NetworkPropertyURI = null,
		@IsDetail = 0,
		@SearchWeight = 0,
		@CustomDisplay = 1,
		@CustomEdit = 1

	*/
	
END
GO
PRINT N'Altering [Profile.Module].[CustomViewAuthorInAuthorship.GetGroupList]...';


GO
ALTER PROCEDURE [Profile.Module].[CustomViewAuthorInAuthorship.GetGroupList]
	@NodeID bigint = NULL,
	@SessionID uniqueidentifier = NULL
AS
BEGIN

	DECLARE @SecurityGroupID BIGINT, @HasSpecialViewAccess BIT
	EXEC [RDF.Security].GetSessionSecurityGroup @SessionID, @SecurityGroupID OUTPUT, @HasSpecialViewAccess OUTPUT
	CREATE TABLE #SecurityGroupNodes (SecurityGroupNode BIGINT PRIMARY KEY)
	INSERT INTO #SecurityGroupNodes (SecurityGroupNode) EXEC [RDF.Security].GetSessionSecurityGroupNodes @SessionID, @NodeID


	declare @AssociatedInformationResource bigint
	select @AssociatedInformationResource = [RDF.].fnURI2NodeID('http://profiles.catalyst.harvard.edu/ontology/prns#associatedInformationResource') 


	select i.NodeID, p.EntityID, i.Value rdf_about, p.EntityName rdfs_label, 
		p.Reference prns_informationResourceReference, p.EntityDate prns_publicationDate,
		year(p.EntityDate) prns_year, p.pmid bibo_pmid, p.pmcid vivo_pmcid, p.mpid prns_mpid, p.URL vivo_webpage,
		isnull(b.PMCCitations, -1) as PMCCitations, isnull(Fields, '') as Fields, isnull(TranslationHumans , 0) as TranslationHumans, isnull(TranslationAnimals , 0) as TranslationAnimals, 
		isnull(TranslationCells , 0) as TranslationCells, isnull(TranslationPublicHealth , 0) as TranslationPublicHealth, isnull(TranslationClinicalTrial , 0) as TranslationClinicalTrial
	from [RDF.].[Triple] t
		inner join [RDF.].[Node] a
			on t.subject = @NodeID and t.predicate = @AssociatedInformationResource
				and t.object = a.NodeID
				and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
				and ((a.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (a.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (a.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.].[Node] i
			on t.object = i.NodeID
				and ((i.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (i.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (i.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.Stage].[InternalNodeMap] m
			on i.NodeID = m.NodeID
		inner join [Profile.Data].[Publication.Entity.InformationResource] p
			on m.InternalID = p.EntityID
		left join [Profile.Data].[Publication.Pubmed.Bibliometrics] b on p.PMID = b.PMID
	order by p.EntityDate desc
END
GO
PRINT N'Altering [Profile.Module].[CustomViewAuthorInAuthorship.GetList]...';


GO
ALTER PROCEDURE [Profile.Module].[CustomViewAuthorInAuthorship.GetList]
	@NodeID bigint = NULL,
	@SessionID uniqueidentifier = NULL
AS
BEGIN

	DECLARE @SecurityGroupID BIGINT, @HasSpecialViewAccess BIT
	EXEC [RDF.Security].GetSessionSecurityGroup @SessionID, @SecurityGroupID OUTPUT, @HasSpecialViewAccess OUTPUT
	CREATE TABLE #SecurityGroupNodes (SecurityGroupNode BIGINT PRIMARY KEY)
	INSERT INTO #SecurityGroupNodes (SecurityGroupNode) EXEC [RDF.Security].GetSessionSecurityGroupNodes @SessionID, @NodeID


	declare @AuthorInAuthorship bigint
	select @AuthorInAuthorship = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#authorInAuthorship') 
	declare @LinkedInformationResource bigint
	select @LinkedInformationResource = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#linkedInformationResource') 


	select i.NodeID, p.EntityID, i.Value rdf_about, p.EntityName rdfs_label, 
		p.Reference prns_informationResourceReference, p.EntityDate prns_publicationDate,
		year(p.EntityDate) prns_year, p.pmid bibo_pmid, p.pmcid vivo_pmcid, p.mpid prns_mpid, p.URL vivo_webpage, 
		isnull(b.PMCCitations, -1) as PMCCitations, isnull(Fields, '') as Fields, isnull(TranslationHumans , 0) as TranslationHumans, isnull(TranslationAnimals , 0) as TranslationAnimals, 
		isnull(TranslationCells , 0) as TranslationCells, isnull(TranslationPublicHealth , 0) as TranslationPublicHealth, isnull(TranslationClinicalTrial , 0) as TranslationClinicalTrial
	from [RDF.].[Triple] t
		inner join [RDF.].[Node] a
			on t.subject = @NodeID and t.predicate = @AuthorInAuthorship
				and t.object = a.NodeID
				and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
				and ((a.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (a.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (a.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.].[Node] i
			on t.object = i.NodeID
				and ((i.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (i.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (i.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.Stage].[InternalNodeMap] m
			on i.NodeID = m.NodeID
		inner join [Profile.Data].[Publication.Entity.Authorship] e
			on m.InternalID = e.EntityID
		inner join [Profile.Data].[Publication.Entity.InformationResource] p
			on e.InformationResourceID = p.EntityID
		left join [Profile.Data].[Publication.Pubmed.Bibliometrics] b on p.PMID = b.PMID
	order by p.EntityDate desc

END
GO
PRINT N'Altering [User.Account].[Proxy.Search]...';


GO
ALTER PROCEDURE [User.Account].[Proxy.Search]
	@LastName nvarchar(100) = NULL,
	@FirstName nvarchar(100) = NULL,
	@Institution nvarchar(500) = NULL,
	@Department nvarchar(500) = NULL,
	@Division nvarchar(500) = NULL,
	@offset INT = 0,
	@limit INT = 20
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET nocount  ON;

	SELECT @offset = IsNull(@offset,0), @limit = IsNull(@limit,1000)
	SELECT @limit = 1000 WHERE @limit > 1000
	
	SELECT	@LastName = (CASE WHEN @LastName = '' THEN NULL ELSE @LastName END),
			@FirstName = (CASE WHEN @FirstName = '' THEN NULL ELSE @FirstName END),
			@Institution = (CASE WHEN @Institution = '' THEN NULL ELSE @Institution END),
			@Department = (CASE WHEN @Department = '' THEN NULL ELSE @Department END),
			@Division = (CASE WHEN @Division = '' THEN NULL ELSE @Division END)

	DECLARE @sql NVARCHAR(MAX)
	
	SELECT @sql = '
		SELECT UserID, DisplayName, Institution, Department, EmailAddr
			FROM (
				SELECT UserID, DisplayName, Institution, Department, EmailAddr, 
					row_number() over (order by LastName, FirstName, UserID) k
				FROM [User.Account].[User]
				WHERE IsActive = 1
					AND CanBeProxy = 1
					' + IsNull('AND FirstName LIKE '''+replace(@FirstName,'''','''''')+'%''','') + '
					' + IsNull('AND LastName LIKE '''+replace(@LastName,'''','''''')+'%''','') + '
					' + IsNull('AND Institution = '''+replace(@Institution,'''','''''')+'''','') + '
					' + IsNull('AND Department = '''+replace(@Department,'''','''''')+'''','') + '
					' + IsNull('AND Division = '''+replace(@Division,'''','''''')+'''','') + '
			) t
			WHERE (k >= ' + cast(@offset+1 as varchar(50)) + ') AND (k < ' + cast(@offset+@limit+1 as varchar(50)) + ')
			ORDER BY k
		'

	EXEC sp_executesql @sql

END
GO
PRINT N'Creating [Profile.Data].[Publication.Pubmed.GetPMIDsforBibliometrics]...';


GO
CREATE PROCEDURE [Profile.Data].[Publication.Pubmed.GetPMIDsforBibliometrics]
	@BatchSize int = 10000
AS
BEGIN
	Create table #tmp(pmid int primary key)
	insert into #tmp
	SELECT pmid
		FROM [Profile.Data].[Publication.PubMed.Disambiguation]
		WHERE pmid IS NOT NULL 
		UNION   
	SELECT pmid
		FROM [Profile.Data].[Publication.Person.Include]
		WHERE pmid IS NOT NULL 

	declare @c int
	select @c = count(1) from #tmp
	declare @batchID varchar(100)
	select @batchID = NEWID()
	select @batchID batchID, n, (
	select pmid "PMID" FROM #tmp order by pmid offset n * @BatchSize ROWS FETCH NEXT @BatchSize ROWS ONLY FOR XML path(''), ELEMENTS, ROOT('PMIDS')) x
	from [Utility.Math].N where n <= @c / @BatchSize
END
GO
PRINT N'Creating [Profile.Data].[Publication.Pubmed.ParseBibliometricResults]...';


GO
CREATE PROCEDURE [Profile.Data].[Publication.Pubmed.ParseBibliometricResults]
	@Data xml
AS
BEGIN
	create table #tmp(
		pmid int primary key,
		PMCCitations int,
		MedlineTA varchar(255),
		TranslationAnimals int,
		TranslationCells int,
		TranslationHumans int,
		TranslationPublicHealth int,
		TranslationClinicalTrial int
	)

	CREATE TABLE #tmpJournalHeading(
		[MedlineTA] [varchar](255) NOT NULL,
		[BroadJournalHeading] [varchar](100) NOT NULL,
		[Weight] [float] NULL,
		[DisplayName] [varchar](100) NULL,
		[Abbreviation] [varchar](50) NULL,
		[Color] [varchar](6) NULL,
		[Angle] [float] NULL,
		[Arc] [float] NULL,
	PRIMARY KEY CLUSTERED 
	(
		[MedlineTA] ASC,
		[BroadJournalHeading] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	)


	insert into #tmp
	select t.x.value('PMID[1]', 'int') as PMID,
	t.x.value('PMCCitations[1]', 'int') as PMCCitations,
	t.x.value('MedlineTA[1]', 'varchar(255)') as MedlineTA,
	t.x.value('TranslationAnimals[1]', 'int') as TranslationAnimals,
	t.x.value('TranslationCells[1]', 'int') as TranslationCells,
	t.x.value('TranslationHumans[1]', 'int') as TranslationHumans,
	t.x.value('TranslationPublicHealth[1]', 'int') as TranslationPublicHealth,
	t.x.value('TranslationClinicalTrial[1]', 'int') as TranslationClinicalTrial
	from @data.nodes('/Bibliometrics/ArticleSummary') t(x)

	insert into #tmpJournalHeading (MedlineTA, BroadJournalHeading, DisplayName, Abbreviation, Color, Angle, Arc)
		select 
		t.x.value('MedlineTA[1]', 'varchar(255)') as MedlineTA,
		t.x.value('BroadJournalHeading[1]', 'varchar(100)') as BroadJournalHeading,
	--	t.x.value('Weight[1]', 'float') as Weight,
		t.x.value('DisplayName[1]', 'varchar(100)') as DisplayName,
		t.x.value('Abbreviation[1]', 'varchar(50)') as Abbreviation,
		t.x.value('Color[1]', 'varchar(6)') as Color,
		t.x.value('Angle[1]', 'float') as Angle,
		t.x.value('Arc[1]', 'float') as Arc
		from @data.nodes('/Bibliometrics/JournalHeading') t(x)

	;with counts as (
		select MedlineTA, count(*) c from #tmpJournalHeading
		Group by MedlineTA
	)
	update a set a.weight = 1.0 / c from #tmpJournalHeading a join counts b on a.MedlineTA = b.MedlineTA

	delete from [Profile.Data].[Publication.Pubmed.JournalHeading] where MedlineTA in (select MedlineTA from #tmpJournalHeading)
	insert into [Profile.Data].[Publication.Pubmed.JournalHeading] select * from #tmpJournalHeading

	delete from [Profile.Data].[Publication.Pubmed.Bibliometrics] where PMID in (select pmid from #tmp)

	;
	with abbs as (
		SELECT t2.MedlineTA, weight, STUFF((SELECT '|' + CAST([Abbreviation] AS varchar) + ',' + CAST([Color] as varchar) +  ',' + CAST(DisplayName as varchar)  FROM [Profile.Data].[Publication.Pubmed.JournalHeading] t1  where t1.MedlineTA =t2.MedlineTA FOR XML PATH('')), 1 ,1, '') AS ValueList
		FROM #tmpJournalHeading t2
		GROUP BY t2.MedlineTA, t2.Weight
	)
	insert into [Profile.Data].[Publication.Pubmed.Bibliometrics] 
		(PMID, PMCCitations, MedlineTA, Fields, TranslationHumans, TranslationAnimals, TranslationCells, TranslationPublicHealth, TranslationClinicalTrial)
	select PMID, PMCCitations, a.MedlineTA, ValueList , TranslationHumans, TranslationAnimals, TranslationCells, TranslationPublicHealth, TranslationClinicalTrial
		from #tmp a join abbs b on a.MedlineTA = b.MedlineTA

END
GO
PRINT N'Creating [Profile.Import].[HMSWebservice.AddLog]...';


GO
CREATE PROCEDURE [Profile.Import].[HMSWebservice.AddLog]
	@logID BIGINT = -1,
	@batchID varchar(100) = null,
	@rowID int = -1,
	@Job varchar(55),
	@action VARCHAR(200),
	@actionText varchar(max) = null,
	@newLogID BIGINT OUTPUT
AS
BEGIN
	IF @action='StartService'
		BEGIN
			DECLARE @LogIDTable TABLE (logID BIGINT)
			INSERT INTO [Profile.Import].[HMSWebservice.Log] (Job, BatchID, RowID, ServiceCallStart)
			OUTPUT Inserted.LogID INTO @LogIDTable
			VALUES (@job, @batchID, @rowID, GETDATE())
			select @logID = LogID from @LogIDTable
		END
	IF @action='EndService'
		BEGIN
			UPDATE [Profile.Import].[HMSWebservice.Log]
			   SET ServiceCallEnd = GETDATE()
			 WHERE LogID = @logID
		END
	IF @action='RowComplete'
		BEGIN
			UPDATE [Profile.Import].[HMSWebservice.Log]
			   SET ProcessEnd  =GETDATE(),
				   Success= 1
			 WHERE LogID = @logID
		END
	IF @action='Error'
		BEGIN
			UPDATE [Profile.Import].[HMSWebservice.Log]
			   SET ErrorText = @actionText,
				   ProcessEnd  =GETDATE(),
				   Success=0
			 WHERE LogID = @logID
		END

	Select @newLogID = @logID
END
GO
PRINT N'Creating [Profile.Import].[HMSWebservice.GetPostData]...';


GO
CREATE PROCEDURE [Profile.Import].[HMSWebservice.GetPostData]
	@Job varchar(55),
	@BatchSize int = 0
AS
BEGIN
	if @Job = 'Bibliometrics'
	begin
		select @BatchSize = case when @BatchSize = 0 then 10000 else @BatchSize end
		exec [Profile.Data].[Publication.Pubmed.GetPMIDsforBibliometrics] @BatchSize=@BatchSize
	end
/*	if @Job = 'GetPubMedXML'
	begin
		select @BatchSize = case when @BatchSize = 0 then 20 else @BatchSize end
		exec [Profile.Data].[Publication.Pubmed.GetAllPMIDsBatch] @BatchSize=@BatchSize
	end
	*/
END
GO
PRINT N'Creating [Profile.Import].[HMSWebservice.ImportData]...';


GO

CREATE PROCEDURE [Profile.Import].[HMSWebservice.ImportData]
	@Job varchar(55),
	@Data xml
AS
BEGIN
	if @Job = 'Bibliometrics'
	begin
		exec [Profile.Data].[Publication.Pubmed.ParseBibliometricResults] @data=@data
	end
/*	if @Job = 'GetPubMedXML'
	begin
		exec [Profile.Data].[Publication.Pubmed.AddPubMedXMLBatch] @data=@data
	end
*/
END
GO
PRINT N'Creating [Profile.Module].[CustomViewAuthorInAuthorship.GetJournalHeadings]...';


GO
CREATE PROCEDURE [Profile.Module].[CustomViewAuthorInAuthorship.GetJournalHeadings]
	@NodeID bigint = NULL,
	@SessionID uniqueidentifier = NULL
AS
BEGIN
	DECLARE @SecurityGroupID BIGINT, @HasSpecialViewAccess BIT
	EXEC [RDF.Security].GetSessionSecurityGroup @SessionID, @SecurityGroupID OUTPUT, @HasSpecialViewAccess OUTPUT
	CREATE TABLE #SecurityGroupNodes (SecurityGroupNode BIGINT PRIMARY KEY)
	INSERT INTO #SecurityGroupNodes (SecurityGroupNode) EXEC [RDF.Security].GetSessionSecurityGroupNodes @SessionID, @NodeID

	declare @class nvarchar(400)
	select @class = class from [RDF.Stage].InternalNodeMap where nodeid=@NodeID 

	create table #tmp(
		[Order] int,
		BroadJournalHeading varchar(100),
		[Weight] float,
		[Count] int,
		Color varchar(6)
	)

	if @class = 'http://xmlns.com/foaf/0.1/Person'
	BEGIN
		declare @AuthorInAuthorship bigint
		select @AuthorInAuthorship = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#authorInAuthorship') 
		declare @LinkedInformationResource bigint
		select @LinkedInformationResource = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#linkedInformationResource') 

		insert into #tmp
		select /*top 10*/ ROW_NUMBER() OVER (ORDER BY CASE isnull(h.BroadJournalHeading, 'Unknown') WHEN 'Unknown' THEN 1 ELSE 0 END, SUM(isnull(h.Weight, 1)) desc, count(*) desc) as [Order],
		 isnull(h.DisplayName, 'Unknown') BroadJournalHeading, SUM(isnull(h.Weight, 1)) as [Weight], count(*) as [Count], Color--, count(*) * 100.0 / sum (count(*)) over() as Percentage, Sum(isnull(h.Weight, 1))over() as Total
		from [RDF.].[Triple] t
			inner join [RDF.].[Node] a
				on t.subject = @NodeID and t.predicate = @AuthorInAuthorship
					and t.object = a.NodeID
					and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
					and ((a.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (a.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (a.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
			inner join [RDF.].[Node] i
				on t.object = i.NodeID
					and ((i.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (i.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (i.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
			inner join [RDF.Stage].[InternalNodeMap] m
				on i.NodeID = m.NodeID
			inner join [Profile.Data].[Publication.Entity.Authorship] e
				on m.InternalID = e.EntityID
			inner join [Profile.Data].[Publication.Entity.InformationResource] p
				on e.InformationResourceID = p.EntityID
			left join [Profile.Data].[Publication.Pubmed.Bibliometrics] b on p.PMID = b.PMID
			left join [Profile.Data].[Publication.Pubmed.JournalHeading] h on b.MedlineTA = H.MedlineTA
		--order by p.EntityDate desc
		GROUP BY isnull(h.BroadJournalHeading, 'Unknown'), DisplayName, Color
		ORDER BY CASE isnull(h.BroadJournalHeading, 'Unknown') WHEN 'Unknown' THEN 1 ELSE 0 END, SUM(isnull(h.Weight, 1)) desc, count(*) desc
	END
	ELSE if @class = 'http://xmlns.com/foaf/0.1/Group'
	BEGIN

		declare @AssociatedInformationResource bigint
		select @AssociatedInformationResource = [RDF.].fnURI2NodeID('http://profiles.catalyst.harvard.edu/ontology/prns#associatedInformationResource') 

		insert into #tmp
		select /*top 10*/ ROW_NUMBER() OVER (ORDER BY CASE isnull(h.BroadJournalHeading, 'Unknown') WHEN 'Unknown' THEN 1 ELSE 0 END, SUM(isnull(h.Weight, 1)) desc, count(*) desc) as [Order],
		 isnull(h.DisplayName, 'Unknown') BroadJournalHeading, SUM(isnull(h.Weight, 1)) as [Weight], count(*) as [Count], Color--, count(*) * 100.0 / sum (count(*)) over() as Percentage, Sum(isnull(h.Weight, 1))over() as Total
		from [RDF.].[Triple] t
			inner join [RDF.].[Node] a
				on t.subject = @NodeID and t.predicate = @AssociatedInformationResource
					and t.object = a.NodeID
					and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
					and ((a.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (a.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (a.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
			inner join [RDF.].[Node] i
				on t.object = i.NodeID
					and ((i.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (i.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (i.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
			inner join [RDF.Stage].[InternalNodeMap] m
				on i.NodeID = m.NodeID
			inner join [Profile.Data].[Publication.Entity.InformationResource] p
				on m.InternalID = p.EntityID
			left join [Profile.Data].[Publication.Pubmed.Bibliometrics] b on p.PMID = b.PMID
			left join [Profile.Data].[Publication.Pubmed.JournalHeading] h on b.MedlineTA = H.MedlineTA
		--order by p.EntityDate desc
		GROUP BY isnull(h.BroadJournalHeading, 'Unknown'), DisplayName, Color
		ORDER BY CASE isnull(h.BroadJournalHeading, 'Unknown') WHEN 'Unknown' THEN 1 ELSE 0 END, SUM(isnull(h.Weight, 1)) desc, count(*) desc
	END
	--select * from #tmp ORDER BY [Weight] desc, [count]desc
	
	DECLARE @totalWeight float
	DECLARE @totalCount int
	SELECT @totalWeight = SUM(Weight), @totalCount = SUM(Count) from #tmp

	DELETE FROM #tmp WHERE BroadJournalHeading = 'Unknown' OR [Order] > 9

	INSERT INTO #tmp ([Order], BroadJournalHeading, [Weight], [Count], Color) 
	SELECT top 1 10, 'Other' as BroadJournalHeading, @totalWeight - (Select top 1 sum ([Weight]) over () from #tmp) AS [Weight], @totalCount - (Select top 1 sum ([Count]) over () from #tmp) AS [Count], 'BAB0AC' from #tmp

	UPDATE #tmp set color = '4E79A7' where [Order] = 1
	UPDATE #tmp set color = 'F28E2B' where [Order] = 2
	UPDATE #tmp set color = 'E15759' where [Order] = 3
	UPDATE #tmp set color = '76B7B2' where [Order] = 4
	UPDATE #tmp set color = '59A14F' where [Order] = 5
	UPDATE #tmp set color = 'EDC948' where [Order] = 6
	UPDATE #tmp set color = 'B07AA1' where [Order] = 7
	UPDATE #tmp set color = 'FF9DA7' where [Order] = 8
	UPDATE #tmp set color = '9C755F' where [Order] = 9
	UPDATE #tmp SET [Weight] = [Weight] / @totalWeight;

	select BroadJournalHeading, [Count], Weight, Color from #tmp
	ORDER BY [Order]
END
GO
PRINT N'Refreshing [ORNG.].[AddAppToOntology]...';


GO
EXECUTE sp_refreshsqlmodule N'[ORNG.].[AddAppToOntology]';


GO
PRINT N'Update complete.';


GO
