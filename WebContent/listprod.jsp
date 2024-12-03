<%@ page import="java.sql.*,java.net.URLEncoder" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>
<!DOCTYPE html>
<html>

<head>
    <title>Rowan & Ian's Grocery</title>
</head>

<body>
    <h1>Search for the products you want to buy:</h1>

    <form method="get" action="listprod.jsp">
        <select size="1" name="categoryName">
            <option>All</option>
            <option>Beverages</option>
            <option>Condiments</option>
            <option>Confections</option>
            <option>Dairy Products</option>
            <option>Grains/Cereals</option>
            <option>Meat/Poultry</option>
            <option>Produce</option>
            <option>Seafood</option>       
        </select>
        <input type="text" name="productSearch" size="50">
        <input type="submit" value="Submit">
        <input type="reset" value="Reset">
        (Leave blank for all products)
    </form>

    <%-- GET FORM INPUTS & SET TABLE HEADING --%>
    <%
        String searchTerm = request.getParameter("productSearch");
        String tableHeading;
        if (searchTerm == null || searchTerm.equals("")) {
            searchTerm = "";
            tableHeading = "All Products";
        }
        else {
            tableHeading = String.format("Products containing '%s'", searchTerm);
        }

        String categoryName = request.getParameter("categoryName");
        if (categoryName == null) {
            categoryName = "All";
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
            try {
                // Make connection to DB
                getConnection();

                // Decide how to modify product query based on categoryName
                String productQueryModifier;

                if (categoryName.equals("All")) {
                    productQueryModifier = "";
                }
                else {
                    PreparedStatement category_pstmt = con.prepareStatement(
                        "SELECT categoryId FROM category WHERE categoryName = ?"
                    );
                    category_pstmt.setString(1, categoryName);

                    ResultSet category_rst = category_pstmt.executeQuery();
                    category_rst.next();
                    int categoryId = category_rst.getInt("categoryId");

                    productQueryModifier = String.format(" AND categoryId = %d", categoryId);
                }

                // Query product table
                PreparedStatement product_pstmt = con.prepareStatement(
                    "SELECT productId, productName, productPrice\n"
                         + "FROM product\n"
                         + "WHERE productName LIKE '%' + ? + '%'"
                         + productQueryModifier
                );
                product_pstmt.setString(1, searchTerm);
                ResultSet product_rst = product_pstmt.executeQuery();

                // prep formatter
                NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance();

                // Process query results row by row
                while (product_rst.next())
                {
                    int productId = product_rst.getInt("productId");
                    String productName = product_rst.getString("productName");
                    double productPrice = product_rst.getDouble("productPrice");

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
            catch (SQLException e)
            {
                out.println("SQLException: " + e);
            }
            finally {
                closeConnection();
            }
        %>
    </table>

</body>
</html>