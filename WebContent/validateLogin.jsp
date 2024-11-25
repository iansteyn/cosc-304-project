<%@ page language="java" import="java.io.*,java.sql.*"%>
<%@ include file="jdbc.jsp" %>
<%
	String authenticatedUser = null;
	session = request.getSession(true);

    System.out.println(session);
	try {
		authenticatedUser = validateLogin(out,request,session);
	}
	catch(IOException e) {
        System.err.println(e);
    }

	if (authenticatedUser != null)
		response.sendRedirect("index.jsp");		// Successful login
	else {
		response.sendRedirect("login.jsp");		// Failed login - redirect back to login page with a message 
    }
%>


<%!
	String validateLogin(JspWriter out, HttpServletRequest request, HttpSession session) throws IOException
	{
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		String retStr = null;

		if(username == null || password == null)
				return null;
		if((username.length() == 0) || (password.length() == 0))
				return null;

        // Check if userId and password match some customer account.
        // If so, set retStr to be the username.
		try 
		{
			getConnection();

            String query = "SELECT userid\n"
                         + "FROM Customer\n"
                         + "WHERE userid = ? AND password = ?";

            PreparedStatement pstmt = con.prepareStatement(query);
            pstmt.setString(1, username);
            pstmt.setString(2, password);

            ResultSet rst = pstmt.executeQuery();
            rst.next();

            retStr = rst.getString("userid");
		} 
		catch (SQLException ex) {
			out.println(ex);
		}
		finally {
			closeConnection();
		}	
		
		if(retStr != null) {
            session.removeAttribute("loginMessage");
			session.setAttribute("authenticatedUser",username);
		}
		else {
			session.setAttribute("loginMessage","Could not connect to the system using that username/password.");
        }

		return retStr;
	}
%>

