SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Profile.Data].[Publication.GetGroupMemberPublications]
	@GroupID INT=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  ;with pubs as (
  select distinct pmid, mpid from [Profile.Data].[Publication.Person.Include] a
  join [Profile.Data].Person p on a.PersonID = p.PersonID
  join [Profile.Data].[Group.Member] g on p.UserID = g.UserID
  and g.GroupID = @GroupID
  )
  select e.* from [Profile.Data].[vwPublication.Entity.InformationResource] e
  join pubs a on (a.PMID = e.PMID and e.MPID is null) OR (a.MPID = e.MPID and e.PMID is null)
END

GO
