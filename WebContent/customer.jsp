<!DOCTYPE html>
<html>
<head>
<title>Customer Page</title>
</head>
<body>

<%@ include file="auth.jsp"%>
<%@ page import="java.text.NumberFormat" %>
<%@ include file="jdbc.jsp" %>

<%
	String userName = (String) session.getAttribute("authenticatedUser");
%>

<%


getConnection();
String sql = "SELECT * FROM CUSTOMER WHERE customerId = ?";
PreparedStatement pstmt = con.prepareStatement(sql);

int customerId = Integer.parseInt(userName);
pstmt.setInt(1, customerId);

ResultSet rst = pstmt.executeQuery();
rst.next();
String firstName = rst.getString("firstName");
String lastName = rst.getString("lastName");
String email = rst.getString("email");
String phonenum = rst.getString("phonenum");
String address = rst.getString("address");
String city = rst.getString("city");
String province = rst.getString("state");
String postalCode = rst.getString("postalCode");
String country = rst.getString("country");
String userid = rst.getString("userid");



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
		<th>email</th>
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
		<td> <%= userid %> </td>
	</tr>
</table>

</body>
</html>

