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

<table border="2">
    <tr>
        <th>Order Id</th>
        <th>Order Date</th>
        <th>Customer Id</th>
        <th>Customer Name</th>
        <th>Total Amount</th>


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


// some connection information
String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";		
String uid = "sa";
String pw = "304#sa#pw";


String query = "SELECT * FROM ordersummary";



// Make connection to DB
            try(Connection con = DriverManager.getConnection(url, uid, pw);
                PreparedStatement preparedStatement = con.prepareStatement(query);)
            {

                ResultSet resultSet = preparedStatement.executeQuery();

                while (resultSet.next()) 
                {
                    int orderId = resultSet.getInt("orderId");
                    String orderDate = resultSet.getString("orderDate");
                    int customerId = resultSet.getInt("customerId");
                    String tableRow = String.format("<tr> <td>%s</td> <td>%s</td> <td>%s</td> <tr>", orderId, orderDate, customerId);

                    out.println(tableRow);
                }

                
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


%>
</table>



</body>
</html>

<style>
tr:hover {
    background-color: #CCFF00;
}
</style>

