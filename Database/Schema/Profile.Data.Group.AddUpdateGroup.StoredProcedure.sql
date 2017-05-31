SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Profile.Data].[Group.AddUpdateGroup]
	@ExistingGroupID INT=NULL, 
	@ExistingGroupNodeID BIGINT=NULL,
	@ExistingGroupURI VARCHAR(400)=NULL,
	@GroupName VARCHAR(MAX)=NULL,
	@EndDate DATETIME=NULL,
	@ViewSecurityGroup BIGINT=NULL,
	@SessionID UNIQUEIDENTIFIER=NULL, 
	@Error BIT=NULL OUTPUT, 
	@NodeID BIGINT=NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/*
	
	This stored procedure either creates or updates a Group.
	Groups can be specified either by GroupID, NodeID or URI.
	
	*/
	
	SELECT @Error = 0

	-------------------------------------------------
	-- Validate and prepare variables
	-------------------------------------------------
	
	-- Convert URIs and NodeIDs to GroupID
 	IF (@ExistingGroupNodeID IS NULL) AND (@ExistingGroupURI IS NOT NULL)
		SELECT @ExistingGroupNodeID = [RDF.].fnURI2NodeID(@ExistingGroupURI)
 	IF (@ExistingGroupID IS NULL) AND (@ExistingGroupNodeID IS NOT NULL)
		SELECT @ExistingGroupID = CAST(m.InternalID AS INT)
			FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
			WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @ExistingGroupNodeID

	-------------------------------------------------
	-- Create a new group if needed
	-------------------------------------------------

	IF @ExistingGroupID IS NULL
	BEGIN
		-- Create the GroupID
		INSERT INTO [Profile.Data].[Group.General] (GroupName, ViewSecurityGroup, CreateDate, EndDate)
			SELECT ISNULL(NULLIF(@GroupName,''),'New Group'), ISNULL(@ViewSecurityGroup,0), GetDate(), ISNULL(@EndDate,DATEADD(yy,10,CAST(GetDate() AS DATE)))
		SELECT @ExistingGroupID = @@IDENTITY
		-- Create the NodeID (hidden by default)
		EXEC [RDF.].GetStoreNode @Class = 'http://xmlns.com/foaf/0.1/Group', @InternalType = 'Group', @InternalID = @ExistingGroupID,
			@ViewSecurityGroup = 0, @EditSecurityGroup = -40,
			@SessionID = @SessionID, @Error = @Error OUTPUT, @NodeID = @NodeID OUTPUT
		UPDATE [RDF.].[Node] SET EditSecurityGroup = @NodeID WHERE NodeID = @NodeID
		-- Add the class types
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
									@ObjectURI = 'http://xmlns.com/foaf/0.1/Agent',
									@ViewSecurityGroup = -1,
									@Weight = 1,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
									@ObjectURI = 'http://xmlns.com/foaf/0.1/Group',
									@ViewSecurityGroup = -1,
									@Weight = 1,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		-- Add a hasGroupOptions property
		DECLARE @BooleanTrueNodeID BIGINT
		EXEC [RDF.].GetStoreNode	@Value = 'true', 
									@Language = NULL,
									@DataType = 'http://www.w3.org/2001/XMLSchema#boolean',
									@SessionID = @SessionID, 
									@Error = @Error OUTPUT, 
									@NodeID = @BooleanTrueNodeID OUTPUT
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#hasGroupOptions',
									@ObjectID = @BooleanTrueNodeID,
									@ViewSecurityGroup = -1,
									@Weight = 1,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		-- Set the ViewSecurityGroup to the NodeID to make it private by default
		SELECT @ViewSecurityGroup = ISNULL(@ViewSecurityGroup,@NodeID)
		-- Make sure the group has a valid name
		SELECT @GroupName = ISNULL(NULLIF(@GroupName,''),'New Group '+CAST(@ExistingGroupID AS VARCHAR(50)))
		-- Give all admins access to the group
		EXEC [Profile.Data].[Group.UpdateSecurityMembership]
	END

	-------------------------------------------------
	-- Update an existing group
	-------------------------------------------------

	-- Get the group's NodeID
	IF @NodeID IS NULL
		SELECT @NodeID = NodeID
			FROM [RDF.Stage].InternalNodeMap
			WHERE Class = 'http://xmlns.com/foaf/0.1/Group' AND InternalType = 'Group' AND InternalID = CAST(@ExistingGroupID AS VARCHAR(50))

	-- Update the ViewSecurityGroup
	IF @ViewSecurityGroup IS NOT NULL
	BEGIN
		UPDATE [Profile.Data].[Group.General] 
			SET ViewSecurityGroup = @ViewSecurityGroup 
			WHERE GroupID = @ExistingGroupID
		UPDATE [RDF.].[Node] 
			SET ViewSecurityGroup = @ViewSecurityGroup 
			WHERE NodeID = @NodeID
	END

	-- Update the EndDate
	IF @EndDate IS NOT NULL
	BEGIN
		UPDATE [Profile.Data].[Group.General] 
			SET EndDate = @EndDate 
			WHERE GroupID = @ExistingGroupID
	END

	-- Update the label
	IF NULLIF(@GroupName,'')<>''
	BEGIN
		-- Update the General table
		UPDATE [Profile.Data].[Group.General] 
			SET GroupName = @GroupName 
			WHERE GroupID = @ExistingGroupID
		-- Get the NodeID for the label
		DECLARE @labelNodeID BIGINT
		EXEC [RDF.].GetStoreNode	@Value = @GroupName, 
									@Language = NULL,
									@DataType = NULL,
									@SessionID = @SessionID, 
									@Error = @Error OUTPUT, 
									@NodeID = @labelNodeID OUTPUT
		-- Check if a label already exists
		DECLARE @ExistingTripleID BIGINT
		SELECT @ExistingTripleID = TripleID
			FROM [RDF.].[Triple]
			WHERE Subject = @NodeID AND Predicate = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')
		IF @ExistingTripleID IS NOT NULL
		BEGIN
			-- Update an existing label
			UPDATE [RDF.].[Triple]
				SET Object = @labelNodeID
				WHERE TripleID = @ExistingTripleID
		END
		ELSE
		BEGIN
			-- Create a new label
			EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
										@PredicateURI = 'http://www.w3.org/2000/01/rdf-schema#label',
										@ObjectID = @labelNodeID,
										@SessionID = @SessionID,
										@Error = @Error OUTPUT
		END
	END

END


GO
