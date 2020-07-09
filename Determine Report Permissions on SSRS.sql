    SELECT C.UserName
	     , D.RoleName
	     , D.Description
	     , E.Path
	     , E.Name
      FROM dbo.PolicyUserRole A
INNER JOIN dbo.Policies B
	    ON A.PolicyID = B.PolicyID
INNER JOIN dbo.Users C
	    ON A.UserID = C.UserID
INNER JOIN dbo.Roles D
	    ON A.RoleID = D.RoleID
INNER JOIN dbo.CATALOG E
	    ON A.PolicyID = E.PolicyID
  ORDER BY C.UserName;