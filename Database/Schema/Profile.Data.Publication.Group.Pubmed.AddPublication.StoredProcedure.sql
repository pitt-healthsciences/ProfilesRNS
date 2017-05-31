SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Profile.Data].[Publication.Group.Pubmed.AddPublication] 
	@GroupNodeID BIGINT=null,
	@pmid int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @GroupID INT

	SELECT @GroupID = CAST(m.InternalID AS INT)
		FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
		WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @GroupNodeID

	if exists (select * from [Profile.Data].[Publication.PubMed.AllXML] where pmid = @pmid)
	begin
 
		declare @ParseDate datetime
		set @ParseDate = (select coalesce(ParseDT,'1/1/1900') from [Profile.Data].[Publication.PubMed.AllXML] where pmid = @pmid)
		if (@ParseDate < '1/1/2000')
		begin
			exec [Profile.Data].[Publication.Pubmed.ParsePubMedXML] 
			 @pmid
		end
 BEGIN TRY 
		BEGIN TRANSACTION
 
			if not exists (select * from [Profile.Data].[Publication.Group.Include] where GroupID = @GroupID and pmid = @pmid)
			begin
 
				declare @pubid uniqueidentifier
				declare @mpid varchar(50)

				set @pubid = (select newid())
				set @mpid = null
 

				insert into [Profile.Data].[Publication.Group.Include](pubid,GroupID,pmid,mpid)
					values (@pubid,@GroupID,@pmid,@mpid)
 
 				DECLARE @Error BIT=NULL
				SELECT @Error = 0

				DECLARE @PubNodeID BIGINT
				select @PubNodeID = inm.NodeID from [Profile.Data].[vwPublication.Entity.InformationResource] ir
					join [RDF.Stage].InternalNodeMap inm
					on ir.EntityID = inm.InternalID
					and inm.InternalType = 'InformationResource'
					and PMID = @pmid

				EXEC [RDF.].GetStoreTriple	@SubjectID = @GroupNodeID,
							@PredicateURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#associatedInformationResource',
							@ObjectID = @PubNodeID,
							@ViewSecurityGroup = -1,
							@Weight = 1,
							@SessionID = null,
							@Error = @Error OUTPUT
				
			end
 
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK
 
		-- Raise an error with the details of the exception
		SELECT @ErrMsg =  ERROR_MESSAGE(),
					 @ErrSeverity = ERROR_SEVERITY()
 
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
			 
	END CATCH		
 
	END
 
END

GO
