<!DOCTYPE html>
<html>
<head>
    <title>Customer Page</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<%@ include file="auth.jsp"%>
<%@ page import="java.text.NumberFormat" %>
<%@ include file="jdbc.jsp" %>
<%@ include file="header.jsp" %>

<%
String userName = (String) session.getAttribute("authenticatedUser");
boolean loggedIn = (!(userName == null));

if (loggedIn) {
	getConnection();
	String sql = "SELECT * FROM Customer WHERE userId = ?";
	PreparedStatement pstmt = con.prepareStatement(sql);
	pstmt.setString(1, userName);

	ResultSet rst = pstmt.executeQuery();
	rst.next();
    String customerId = rst.getString("customerId");
	String firstName = rst.getString("firstName");
	String lastName = rst.getString("lastName");
	String email = rst.getString("email");
	String phonenum = rst.getString("phonenum");
	String address = rst.getString("address");
	String city = rst.getString("city");
	String province = rst.getString("state");
	String postalCode = rst.getString("postalCode");
	String country = rst.getString("country");

	closeConnection();
	%>

	<h1>Customer Information</h1>

	<table border='2'>
		<tr>
			<th>ID</th>
			<td> <%= customerId %> </td>
		</tr>
		<tr>
			<th>First Name</th>
			<td> <%= firstName %> </td>
		</tr>
		<tr>
			<th>Last Name</th>
			<td> <%= lastName %> </td>
		</tr>
		<tr>
			<th>Email</th>
			<td> <%= email %> </td>
		</tr>
		<tr>
			<th>Phone Number</th>
			<td> <%= phonenum %> </td>
		</tr>
		<tr>
			<th>Address</th>
			<td> <%= address %> </td>
		</tr>
		<tr>
			<th>City</th>
			<td> <%= city %> </td>
		</tr>
		<tr>
			<th> <% out.println(country.equals("Canada") ? "Province" : "State");%> </th>
			<td> <%= province %> </td>
		</tr>
		<tr>
			<th> <% out.println(country.equals("Canada") ? "Postal Code" : "Zip Code");%> </th>
			<td> <%= postalCode %> </td>
		</tr>
		<tr>
			<th>Country</th>
			<td> <%= country %> </td>
		</tr>
		<tr>
			<th>User ID</th>
			<td> <%= userName %> </td>
		</tr>
	</table>

    <h2><a href="index.jsp">Return to main page</a></h2>

<%
}
%>

</body>
</html>

