SET ANSI_NULLS ON

GO
USE [ProfilesRNS]

GO
SET QUOTED_IDENTIFIER ON

GO
CREATE SCHEMA [Profile.Stage] AUTHORIZATION [dbo]



GO 
CREATE TABLE [Profile.Stage].[DepartmentMapping] (
    [unit_id]            [int] not null,
    [unit_name]          [nvarchar](1000) not null,
    [unit_level]         [nvarchar](20) NULL,
    [parent_id]          [int] NULL
);


GO
CREATE TABLE [Profile.Stage].[Person] (
	[employee_number]     [nvarchar](1000) not null,
	[first_name]          [nvarchar](1000) not null,
	[middle_name]         [nvarchar](1000) NULL,
	[last_name]           [nvarchar](1000) not null,
	[suffix]              [nvarchar](1000) NULL,
	[building]            [nvarchar](1000) NULL,
	[room]                [nvarchar](1000) NULL,
	[phone]               [nvarchar](1000) NULL,
	[email_addr]          [nvarchar](1000) NULL
)


GO
CREATE TABLE [Profile.Stage].[PersonAffiliation] (
	[employee_number]     [nvarchar](1000) not null,
	[title]               [nvarchar](1000) NULL,
	[is_primary]          [bit] NULL,
	[affiliation_order]   [tinyint] NULL,
	[rc_id]               [nvarchar](10) NULL,
	[dept_id]             [nvarchar](10) NULL,
	[div_id]              [nvarchar](10) NULL,
	[faculty_rank]        [varchar](1000) NULL,
	[faculty_rank_order]  [tinyint] NULL
)


GO
CREATE TABLE [Profile.Stage].[User] (
	[employee_number]     [nvarchar](1000) not null,
	[first_name]          [nvarchar](1000) not null,
	[last_name]           [nvarchar](1000) not null,
	[rc_id]               [int] NULL,
	[dept_id]             [int] NULL,
	[can_be_proxy]        [bit] NULL
)


GO
CREATE TABLE [Profile.Stage].[Tester] (
	[employee_number]     [nvarchar](1000) not null,
	[first_name]          [nvarchar](1000) not null,
	[middle_name]         [nvarchar](1000) NULL,
	[last_name]           [nvarchar](1000) not null,
	[suffix]              [nvarchar](1000) NULL,
	[building]            [nvarchar](10) NULL,
	[room]                [nvarchar](1000) NULL,
	[phone]               [nvarchar](1000) NULL,
	[email_addr]          [nvarchar](1000) NULL,
	[title]               [nvarchar](1000) NULL,
	[rc_id]               [nvarchar](10) NULL,
	[dept_id]             [nvarchar](10) NULL,
	[div_id]              [nvarchar](10) NULL,
    [has_profile]         [bit] default 1 not null
)


GO
CREATE TABLE [Profile.Stage].[Building] (
    [building_id]         [nvarchar](10) NULL,
    [building_name]       [nvarchar](1000) NULL,
    [street]              [nvarchar](1000) NULL,
    [city]                [nvarchar](1000) NULL,
    [state]               [nvarchar](5) DEFAULT 'PA' NULL,
    [zip_code]            [nvarchar](10) NULL
);

GO


GO
CREATE TABLE [Profile.Data].[Person.HrData] (
    [PersonID]            [int] NOT NULL,
    [IsVisible]           [bit] default 1 NOT NULL,
    constraint EmailValidationCheck check (
       [EmailAddr] is null 
       or [EmailUpdatedOn] is not null
    ),
	[EmailAddr]           [nvarchar](255) NULL,
    [EmailUpdatedOn]      [datetime] NULL,
    constraint PhoneValidationCheck check (
       [Phone] is null  
       or [PhoneUpdatedOn] is not null
    ),
	[Phone]               [nvarchar](35) NULL,
    [PhoneUpdatedOn]      [datetime] NULL,
    constraint AddressValidationCheck check (
       ( [AddressLine1] is null and
         [AddressLine2] is null and
         [City] is null and
         [State] is null and
         [Zip] is null
       ) or [AddressUpdatedOn] is not null
    ),
	[AddressLine1]        [nvarchar](255) NULL,
	[AddressLine2]        [nvarchar](255) NULL,
	[City]                [nvarchar](55) NULL,
	[State]               [nvarchar](50) NULL,
	[Zip]                 [nvarchar](50) NULL,
    [AddressUpdatedOn]    [datetime] NULL,
);



GO

    create procedure [Edit.Module].[CustomEditEmail.Set] 
	    @NodeID BIGINT,
        @Email nvarchar(35)
    AS
        MERGE INTO [Profile.Data].[Person.HrData] hr
        USING (
            SELECT CAST(m.InternalID AS INT) as PersonID, @Email as EmailAddr 
	        FROM [RDF.Stage].[InternalNodeMap] m
            JOIN [RDF.].Node n on (m.ValueHash = n.ValueHash AND m.Status = 3)
	        WHERE  n.NodeID = @NodeID
        ) x
        ON ( 
            hr.PersonID = x.PersonID
        )
        WHEN MATCHED THEN 
            UPDATE
                SET hr.EmailAddr = x.EmailAddr
                  , hr.EmailUpdatedOn = GetDate()
        WHEN NOT MATCHED THEN 
            INSERT (PersonID, EmailAddr, EmailUpdatedOn)
            VALUES (x.PersonID, x.EmailAddr, GetDate())
        ;

GO

    create procedure [Edit.Module].[CustomEditEmail.Get] 
	    @NodeID BIGINT = NULL
    AS
        SELECT Coalesce(hr.emailaddr, p.EmailAddr, '') as EmailAddr
        FROM (
            SELECT CAST(m.InternalID AS INT) as personid
	        FROM [RDF.Stage].[InternalNodeMap] m
            JOIN [RDF.].Node n on (m.ValueHash = n.ValueHash AND m.Status = 3)
	        WHERE  n.NodeID = @NodeID
        ) x
        JOIN [Profile.Data].[Person] p on (x.personid = p.personid)
        LEFT OUTER JOIN [Profile.Data].[Person.HrData] hr on (hr.PersonID = p.personid)
    ;

GO

    create procedure [Edit.Module].[CustomEditPhone.Set] 
	    @NodeID BIGINT,
        @Phone nvarchar(35)
    AS
        MERGE INTO [Profile.Data].[Person.HrData] hr
        USING (
            SELECT CAST(m.InternalID AS INT) as PersonID, @Phone as Phone 
	        FROM [RDF.Stage].[InternalNodeMap] m
            JOIN [RDF.].Node n on (m.ValueHash = n.ValueHash AND m.Status = 3)
	        WHERE  n.NodeID = @NodeID
        ) x
        ON ( 
            hr.PersonID = x.PersonID
        )
        WHEN MATCHED THEN 
            UPDATE
                SET hr.Phone = x.Phone
                  , hr.PhoneUpdatedOn = GetDate()
        WHEN NOT MATCHED THEN 
            INSERT (PersonID, Phone, PhoneUpdatedOn)
            VALUES (x.PersonID, x.Phone, GetDate())
        ;

GO

    create procedure [Edit.Module].[CustomEditPhone.Get] 
	    @NodeID BIGINT = NULL
    AS
        SELECT Coalesce(hr.Phone, p.Phone, '') as Phone
        FROM (
            SELECT CAST(m.InternalID AS INT) as personid
	        FROM [RDF.Stage].[InternalNodeMap] m
            JOIN [RDF.].Node n on (m.ValueHash = n.ValueHash AND m.Status = 3)
	        WHERE  n.NodeID = @NodeID
        ) x
        JOIN [Profile.Data].[Person] p on (x.personid = p.personid)
        LEFT OUTER JOIN [Profile.Data].[Person.HrData] hr on (hr.PersonID = p.personid)
    ;

GO

    create procedure [Edit.Module].[CustomEditAddress.Set] 
	    @NodeID BIGINT,
        @AddressLine1 nvarchar(255),
        @AddressLine2 nvarchar(255),
        @City nvarchar(55),
        @State nvarchar(50),
        @Zip nvarchar(50)
    AS
        MERGE INTO [Profile.Data].[Person.HrData] hr
        USING (
            SELECT CAST(m.InternalID AS INT) as PersonID
                 , @AddressLine1 as AddressLine1 
                 , @AddressLine2 as AddressLine2
                 , @City as City 
                 , @State as State 
                 , @Zip as Zip 
	        FROM [RDF.Stage].[InternalNodeMap] m
            JOIN [RDF.].Node n on (m.ValueHash = n.ValueHash AND m.Status = 3)
	        WHERE  n.NodeID = @NodeID
        ) x
        ON ( 
            hr.PersonID = x.PersonID
        )
        WHEN MATCHED THEN 
            UPDATE
                SET hr.AddressLine1 = x.AddressLine1
                  , hr.AddressLine2 = x.AddressLine2
                  , hr.City = x.City
                  , hr.State = x.State
                  , hr.Zip = x.Zip
                  , hr.AddressUpdatedOn = GetDate()
        WHEN NOT MATCHED THEN 
            INSERT (PersonID, AddressLine1, AddressLine2, City, State, Zip, AddressUpdatedOn)
            VALUES (x.PersonID, x.AddressLine1, x.AddressLine2, x.City, x.State, x.Zip, GetDate())
        ;

GO

    create procedure [Edit.Module].[CustomEditAddress.Get] 
	    @NodeID BIGINT = NULL
    AS
        SELECT case when hr.AddressUpdatedOn is not null then IsNull(hr.AddressLine1, '') else IsNull(p.AddressLine1, '') end as AddressLine1
             , case when hr.AddressUpdatedOn is not null then IsNull(hr.AddressLine2, '') else IsNull(p.AddressLine2, '') end as AddressLine2
             , case when hr.AddressUpdatedOn is not null then IsNull(hr.City, '') else IsNull(p.City, '') end as City
             , case when hr.AddressUpdatedOn is not null then IsNull(hr.State, '') else IsNull(p.State, '') end as State
             , case when hr.AddressUpdatedOn is not null then IsNull(hr.Zip, '') else IsNull(p.Zip, '') end as Zip
        FROM (
            SELECT CAST(m.InternalID AS INT) as personid
	        FROM [RDF.Stage].[InternalNodeMap] m
            JOIN [RDF.].Node n on (m.ValueHash = n.ValueHash AND m.Status = 3)
	        WHERE  n.NodeID = @NodeID
        ) x
        JOIN [Profile.Data].[Person] p on (x.personid = p.personid)
        LEFT OUTER JOIN [Profile.Data].[Person.HrData] hr on (hr.PersonID = p.personid)
    ;

GO

GRANT EXECUTE ON [Edit.Module].[CustomEditEmail.Set] TO PROFILES;
GRANT EXECUTE ON [Edit.Module].[CustomEditEmail.Get] TO PROFILES;
GRANT EXECUTE ON [Edit.Module].[CustomEditPhone.Set] TO PROFILES;
GRANT EXECUTE ON [Edit.Module].[CustomEditPhone.Get] TO PROFILES;
GRANT EXECUTE ON [Edit.Module].[CustomEditAddress.Set] TO PROFILES;
GRANT EXECUTE ON [Edit.Module].[CustomEditAddress.Get] TO PROFILES;



GO
create procedure [Profile.Stage].Import 
as
    delete from [Profile.Import].[User];
    delete from [Profile.Import].PersonAffiliation;
    delete from [Profile.Import].Person;

    insert into [Profile.Import].Person(
        internalusername, 
        displayname,
        firstname, middlename, lastname, suffix,
        addressstring,
        addressline1, addressline2, city, [state], zip,
        building, room, phone, emailaddr, 
        isactive, isvisible
    )    
        select stage.internalusername
             , concat(
                stage.firstname, ' ',
                case when stage.middlename <> '' then concat(stage.middlename, ' ') else '' end,
                stage.lastname,
                case when stage.suffix <> '' then concat(', ', stage.suffix) else '' end
              ) as displayname
             , stage.firstname
             , stage.middlename
             , stage.lastname
             , stage.suffix
             , trim(concat(
                  case 
                      when hr.AddressUpdatedOn is not null and trim(isnull(hr.AddressLine1, '')) = '' then ''
                      when hr.AddressUpdatedOn is not null then concat(trim(hr.AddressLine1), char(10), char(13))
                      when trim(isnull(stage.addressline1, '')) = '' then ''
                      else concat(stage.addressline1, char(10), char(13))  
                  end,
                  case 
                      when hr.AddressUpdatedOn is not null and trim(isnull(hr.AddressLine2, '')) = '' then ''
                      when hr.AddressUpdatedOn is not null then concat(trim(hr.AddressLine2), char(10), char(13))
                      when trim(isnull(stage.addressline2, '')) = '' then ''
                      else concat(stage.addressline2, char(10), char(13))
                  end,
                  case 
                      when hr.AddressUpdatedOn is not null and trim(isnull(hr.City, '')) = '' then ''
                      when hr.AddressUpdatedOn is not null and trim(isnull(hr.State, '')) <> '' then concat(trim(hr.City), ', ')
                      when hr.AddressUpdatedOn is not null then concat(trim(hr.City), ' ')
                      when trim(isnull(stage.City, '')) <> '' and trim(isnull(stage.State, '')) <> '' then concat(stage.City, ', ')
                      when trim(isnull(stage.City, '')) <> '' then concat(stage.City, ' ')
                      else ''
                  end,
                  case
                      when hr.AddressUpdatedOn is not null and trim(isnull(hr.State, '')) = '' then ''
                      when hr.AddressUpdatedOn is not null then concat(trim(hr.State), ' ')
                      when trim(isnull(stage.State, '')) = '' then ''
                      else concat(stage.State, ' ')
                  end,
                  case
                      when hr.AddressUpdatedOn is not null and trim(isnull(hr.Zip, '')) = '' then ''
                      when hr.AddressUpdatedOn is not null then concat(trim(hr.Zip), ' ')
                      else trim(isnull(stage.Zip, ''))
                  end
               )) as addressstring
             , case when hr.AddressUpdatedOn is not null then hr.AddressLine1 else stage.addressline1 end as addressline1
             , case when hr.AddressUpdatedOn is not null then hr.AddressLine2 else stage.addressline2 end as addressline2
             , case when hr.AddressUpdatedOn is not null then hr.City else stage.City end as city
             , case when hr.AddressUpdatedOn is not null then hr.[State] else stage.[State] end as [state]
             , case when hr.AddressUpdatedOn is not null then hr.Zip else stage.Zip end as zip
             , stage.building
             , stage.room
             , case when hr.PhoneUpdatedOn is not null then hr.Phone else stage.Phone end as phone
             , case when hr.EmailUpdatedOn is not null then hr.EmailAddr else stage.emailaddr end as emailaddr
             , 1 as isactive
             , isnull(hr.isvisible, stage.isvisible) as isvisible
        from (
            select p.employee_number as internalusername
                 , 1 as isvisible
                 , p.first_name as firstname
                 , isnull(p.middle_name, '') as middlename
                 , p.last_name as lastname
                 , isnull(p.suffix, '') as suffix
                 , concat(
                     Coalesce(b.building_name, b.street, p.building),
                     case 
                       when p.room is null or p.room in ('', '0000') then ''
                       when p.room like 'suite%' or p.room like 'ste' then concat(', ', room) 
                       else concat(', Room ', p.room)
                     end
                   ) as addressline1
                 , case 
                     when b.building_id is not null and building_name is not null then b.street
                     else ''  
                   end as addressline2
                 , isnull(b.city, '') as city
                 , isnull(b.state, '') as state
                 , isnull(b.zip_code, '') as zip
                 , isnull(p.building, '') as building
                 , isnull(p.room, '') as room
                 , isnull(p.phone, '') as phone
                 , isnull(p.email_addr, '') as emailaddr
            from (
                select employee_number, first_name, middle_name, last_name, suffix, building, room, phone, email_addr from [Profile.Stage].Person
                union all
                select employee_number, first_name, middle_name, last_name, suffix, building, room, phone, email_addr from [Profile.Stage].Tester
                where has_profile = 1
                  and employee_number not in (select p.employee_number from [Profile.Stage].Person p)
            ) p
            left outer join [Profile.Stage].Building b on (b.building_id = p.building)  
        ) stage
        left outer join [Profile.Data].Person person on (person.internalusername = stage.internalusername)
        left outer join [Profile.Data].[Person.HrData] hr on (hr.PersonID = person.PersonID)
    ;
    
    insert into [Profile.Import].PersonAffiliation(
        internalusername, title, primaryaffiliation, affiliationorder, 
        institutionname, institutionabbreviation, departmentname, departmentvisible, facultyrank, facultyrankorder
    )   
      select employee_number as internalusername
           , title
           , is_primary as primaryaffiliation
           , affiliation_order as affiliationorder
           , rc.unit_name
           , rc_id as institutionabbreviation
           , dept.unit_name
           , 1 as departmentvisible
           , faculty_rank as facultyrank
           , faculty_rank_order as facultyrankorder
      from (
          select 
              employee_number, title, is_primary, affiliation_order, rc_id, dept_id, 
              faculty_rank, faculty_rank_order
          from [Profile.Stage].PersonAffiliation
          union all
          select 
              tester.employee_number, tester.title, 1, 1, tester.rc_id, tester.dept_id, 
              'Staff', (select [FacultyRankID] from [Profile.Data].[Person.FacultyRank] where [FacultyRank] = 'Staff')
          from [Profile.Stage].Tester
          where has_profile = 1
            and employee_number not in (select p.employee_number from [Profile.Stage].Person p)
      ) p
      left outer join [Profile.Stage].DepartmentMapping rc on (rc.unit_id = p.rc_id)
      left outer join [Profile.Stage].DepartmentMapping dept on (dept.unit_id = p.dept_id)
    ;

    insert into [Profile.Import].[User] (
        internalusername, 
        firstname, lastname, displayname, 
        institution, department, emailaddr, canbeproxy
    )
        select employee_number as internalusername
             , first_name as firstname
             , last_name as lastname
             , concat(first_name, ' ', last_name) as displayname
             , rc.unit_name as institution
             , dept.unit_name as department
             , email_addr as emailaddr
             , 1 as canbeproxy
        from (
            select employee_number, first_name, last_name, rc_id, dept_id, email_addr, can_be_proxy
            from [Profile.Stage].[User]
            where employee_number not in (select employee_number from [Profile.Stage].Person)
            union all
            select employee_number, first_name, last_name, rc_id, dept_id, email_addr, 1 as can_be_proxy
            from [Profile.Stage].Tester
            where has_profile = 0
              and employee_number not in (select internalusername from [Profile.Import].Person)
        ) p
      left outer join [Profile.Stage].DepartmentMapping rc on (rc.unit_id = p.rc_id)
      left outer join [Profile.Stage].DepartmentMapping dept on (dept.unit_id = p.dept_id)
    ;

GO

