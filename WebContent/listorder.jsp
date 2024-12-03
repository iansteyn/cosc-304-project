<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>Rowan & Ian's Grocery Order List</title>
</head>
<body>

<%@ include file="header.jsp" %>

<h1>Order List</h1>

<table class="outer" border="2">
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


String query = "SELECT * FROM ordersummary JOIN customer ON ordersummary.customerId = customer.customerId";




// Make connection to DB
            try(Connection con = DriverManager.getConnection(url, uid, pw);
                PreparedStatement preparedStatement = con.prepareStatement(query);)
            {

                ResultSet resultSet = preparedStatement.executeQuery();
                NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance();

                while (resultSet.next()) 
                {
                    int orderId = resultSet.getInt("orderId");
                    String orderDate = resultSet.getString("orderDate");
                    int customerId = resultSet.getInt("customerId");
                    String firstName = resultSet.getString("firstName");
                    String lastName = resultSet.getString("lastName");
                    String customerName = firstName + " " + lastName;
                    double totalAmount = resultSet.getDouble("totalAmount");
                    String formattedTotalAmount = currencyFormatter.format(totalAmount);

                    String tableRow = String.format("<tr> <td>%s</td> <td>%s</td> <td>%s</td> <td>%s</td> <td>%s</td> <tr>", orderId, orderDate, customerId, customerName, formattedTotalAmount);

                    out.println(tableRow);

                    String query2 = "SELECT productId, quantity, price FROM orderproduct WHERE orderId = " + orderId;
                    PreparedStatement preparedStatement2 = con.prepareStatement(query2);
                    ResultSet resultSet2 = preparedStatement2.executeQuery();

                    out.println(String.format("<tr align='right'> <td colspan='5'> <table class='inner' border='2'> <tr> <th>Product Id</th> <th>Quantity</th> <th>Price</th> </tr>"));

                    while (resultSet2.next())
                    {
                        int productId = resultSet2.getInt("productId");
                        int quantity = resultSet2.getInt("quantity");
                        double price = resultSet2.getDouble("price");
                        String formattedPrice = currencyFormatter.format(price);

                        out.println(String.format("<tr> <td>%s</td> <td>%s</td> <td>%s</td> </tr>", productId, quantity, formattedPrice));
                    }
                    out.println(String.format("</table> </td> </tr>"));
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
.outer tr:hover {
    background-color: #CCFF00;
}
.inner tr:hover {
    background-color: #33DDBB;
}
</style>

