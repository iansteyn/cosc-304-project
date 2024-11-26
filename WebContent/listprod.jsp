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
        <input type="submit" value="Submit">
        <input type="reset" value="Reset">
        (Leave blank for all products)
    </form>

    <%-- GET SEARCH TERM & SET TABLE HEADING --%>
    <%
        String searchTerm = request.getParameter("productSearch");

        if (searchTerm == null) {
            searchTerm = ""; //done so that all products are displayed by default
        }

        String tableHeading;

        if (searchTerm.equals("")) {
            tableHeading = "All Products";
        } else {
            tableHeading = String.format("Products containing '%s'", searchTerm);
        }
    %>

    <h2><%= tableHeading %></h2>

    <table>
        <tr>
            <th></th>
            <th>Product Name</th>
            <th>Price</th>
        </tr>

        <%-- QUERY DB & LIST PRODUCTS IN TABLE --%>
        <%
            // Load driver class
            try {
                Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            }
            catch (java.lang.ClassNotFoundException e) {
                out.println("ClassNotFoundException: " + e);
            }

            // Connection info
            String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";		
            String uid = "sa";
            String pw = "304#sa#pw";

            String query = "SELECT productId, productName, productPrice FROM product WHERE productName LIKE '%' + ? + '%'";

            // Make connection to DB
            try(Connection con = DriverManager.getConnection(url, uid, pw);
                PreparedStatement preparedStatement = con.prepareStatement(query);)
            {
                //do the query
                preparedStatement.setString(1, searchTerm);
                ResultSet resultSet = preparedStatement.executeQuery();

                NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance();

                // Process query results row by row
                while (resultSet.next())
                {
                    int productId = resultSet.getInt("productId");
                    String productName = resultSet.getString("productName");
                    double productPrice = resultSet.getDouble("productPrice");

                    String addToCartLink = String.format(
                        "<a href=\"addcart.jsp?id=%d&name=%s&price=%f\">Add to cart</a>",
                        productId,
                        productName,
                        productPrice
                    );

                    String productLink = String.format(
                        "<a href=\"product.jsp?id=%d\">%s</a>",
                        productId,
                        productName
                    );

                    String formattedPrice = currencyFormatter.format(productPrice);

                    String tableRow = String.format(
                        "<tr> <td>%s</td> <td>%s</td> <td>%s</td> </tr>",
                        addToCartLink,
                        productLink,
                        formattedPrice
                    );

                    out.println(tableRow);
                }
            }
            // Note: Connection is closed implicitly
            catch (SQLException e)
            {
                out.println("SQLException: " + e);
            }
        %>
    </table>

</body>
</html>