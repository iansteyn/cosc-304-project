<%@ page import="java.sql.*,java.net.URLEncoder" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>

<head>
    <title>Cube Shop BC</title>
</head>

<body>
    <h1>Search for the products you want to buy:</h1>

    <form method="get" action="listprod.jsp">
        <input type="text" name="productName" size="50">
        <input type="submit" value="Submit"><input type="reset" value="Reset"> (Leave blank for all products)
    </form>

    <%
        // Get product name to search for
        String productName = request.getParameter("productName");

        //Ian: Is this really neccessary? Lecture 12 Slide 8 seems to say it isn't
        //Note: Forces loading of SQL Server driver
        try { // Load driver class
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        }
        catch (java.lang.ClassNotFoundException e) {
            out.println("ClassNotFoundException: " + e);
        }

        // Variable name now contains the search string the user entered
        // Use it to build a query and print out the resultset.  Make sure to use PreparedStatement!

        // Make the connection
        String url = "jdbc:mysql://localhost/orders";
        String uid = "user"; // TODO - is this correct?
        String pw = "testpw";//TODO - is this correct?

        String query = """
            SELECT *
            FROM product
            WHERE productName LIKE '%?%'
        """;

        try (Connection con = DriverManager.getConnection(url, uid, pw);
             PreparedStatement preparedStatement = con.prepareStatement(query);)
        {
            preparedStatement.setString(1,productName);
            ResultSet resultSet = preparedStatement.executeQuery();
        }
        catch (SQLException e) {
            System.out.println(e);
        }

        // Print out the ResultSet
        

        // For each product create a link of the form
        // addcart.jsp?id=productId&name=productName&price=productPrice

        // Close connection - should already be done by the try catch; we shall see
        // con.close();

        // Useful code for formatting currency values:
        // NumberFormat currFormat = NumberFormat.getCurrencyInstance();
        // out.println(currFormat.format(5.0);	// Prints $5.00
    %>

</body>
</html>