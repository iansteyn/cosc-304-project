<%@ page import="java.sql.*,java.net.URLEncoder" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>

<head>
    <title>Rowan & Ian's Grocery</title>
</head>

<body>
    <h1>Search for the products you want to buy:</h1>

    <form method="get" action="listprod.jsp">
        <input type="text" name="productSearch" size="50">
        <!-- uhh... submit and reset buttons don't do anything?
        They don't even work properly on Ray's website?-->
        <input type="submit" value="Submit"><input type="reset" value="Reset"> (Leave blank for all products)
    </form>

    <%
        String searchTerm = request.getParameter("productSearch");
        String resultsHeading = (searchTerm == "" || searchTerm == null) ? ("All Products") : ("Products containing '" + searchTerm + "'");
    %>

    <h2>
        <%= resultsHeading %>
    </h2>

    <%
        //Ian: Is this really neccessary? Lecture 12 Slide 8 seems to say it isn't
        //Note: Forces loading of SQL Server driver
        try {
            // Load driver class
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        }
        catch (java.lang.ClassNotFoundException e) {
            out.println("ClassNotFoundException: " + e);
        }

        // Make the connection
        //TODO something must still be wrong here because no products are showing up
        String url = "jdbc:sqlserver://localhost;databaseName=orders;TrustServerCertificate=True";		
        String uid = "304#sa";
        String pw = "304#sa#pw";

        String query = "SELECT productId, productName, productPrice FROM product WHERE productName LIKE '%?%'";

        try(Connection con = DriverManager.getConnection(url, uid, pw);
            PreparedStatement preparedStatement = con.prepareStatement(query);
        ){
            //do the query
            preparedStatement.setString(1, searchTerm);
            ResultSet resultSet = preparedStatement.executeQuery();

            // Print out the ResultSet
            while(resultSet.next()) {
                int productId = resultSet.getInt("productId");
                String productName = resultSet.getString("productName");
                double productPrice = resultSet.getDouble("productPrice");

                // For each product create a link of the form
                // addcart.jsp?id=productId&name=productName&price=productPrice
                String link = String.format(
                    "<a href=\"addcart.jsp?id=%d&name=%s&price=%f\">Add to cart</a>",
                    productId,
                    productName,
                    productPrice
                );

                out.println(link + " " + productName + " " + productPrice);
            }
        }
        catch (SQLException e)
        {
            System.err.println("SQLException: " + e);
        }
        //Note: connection is closed implicitly by try-catch

        // Useful code for formatting currency values:
        // NumberFormat currFormat = NumberFormat.getCurrencyInstance();
        // out.println(currFormat.format(5.0);	// Prints $5.00
    %>

</body>
</html>