<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>Rowan & Ian's Grocery Order List</title>
</head>
<body>

<h1>Order List</h1>

<%
//Note: Forces loading of SQL Server driver
try
{	// Load driver class
	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
}
catch (java.lang.ClassNotFoundException e)
{
	out.println("ClassNotFoundException: " +e);
}

// Useful code for formatting currency values:
// NumberFormat currFormat = NumberFormat.getCurrencyInstance();
// out.println(currFormat.format(5.0));  // Prints $5.00

// Make connection

// some connection information
String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";		
String uid = "sa";
String pw = "304#sa#pw";


String query = "SELECT * FROM order;";

<table>

// Make connection to DB
            try(Connection con = DriverManager.getConnection(url, uid, pw);
                PreparedStatement preparedStatement = con.prepareStatement(query);)
            {

                ResultSet resultSet = preparedStatement.executeQuery();

                
            }
            // try with resources closes itself
            catch (SQLException e)
            {
                out.println("SQLException: " + e);
            }

// Write query to retrieve all order summary records

// For each order in the ResultSet

	// Print out the order summary information
	// Write a query to retrieve the products in the order
	//   - Use a PreparedStatement as will repeat this query many times
	// For each product in the order
		// Write out product information 

// Close connection

</table>
%>

</body>
</html>

