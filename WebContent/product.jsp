<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>

<html>

<head>
    <title>Puzzle Place Product Information</title>
    <link rel="stylesheet" href="css/style.css">
</head>

<%@ include file="header.jsp" %>

<body>
    

    <div class="productTable">

        <%
            // query db for product info using the url parameter 'productId'
            getConnection();
            String query = "SELECT * FROM product WHERE productId = ?";
            PreparedStatement pstmt = con.prepareStatement(query);

            String productIdString = request.getParameter("id");
            int productId = Integer.parseInt(productIdString);
            pstmt.setInt(1, productId);

            ResultSet rst = pstmt.executeQuery();

            // extract product info from the result set
            rst.next();
            String productName = rst.getString("productName");
            double productPrice = rst.getDouble("productPrice");
            String imageURL = rst.getString("productImageURL");
            String productDescription = rst.getString("productDesc");
            String productImageString = rst.getString("productImage");

            closeConnection();

            // do some formatting
            NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance();
            String formattedProductPrice = currencyFormatter.format(productPrice);

            String URLImage;
            if (imageURL == null) {
                URLImage = "";
            } else {
                URLImage = String.format("<img style=padding:10; src=%s>", imageURL);
            }

            String productImage;
            if (productImageString == null || productImageString.isEmpty()) {
                productImage = "";
            }
            else {
                productImage = String.format("<img src=\"displayImage.jsp?id=%s\">", productId);
            }

            String addToCartLink = String.format(
                "addcart.jsp?id=%d&name=%s&price=%f",
                productId,
                productName,
                productPrice
            );
        %>

        <%-- Display product info --%>
        <h1><%= productName %></h1>
        <%= URLImage %>
        <%= productImage %><br>
        <%= productDescription %> <br>
        <%-- Prints a hexadecimal string of 2nd image for id = 1. Not sure how to convert to image --%>

        <table border='2'>
            <tr>
                <th>Product ID</th>
                <th>Product Price</th>
            </tr>
            <tr>
                <td><%= productId %></td>
                <td><%= formattedProductPrice %></td>
        </table>

    </div>
    
    <div class='links'>
        <p>
            <a href="<%= addToCartLink %>">
                <button class="button-5" role="button">
                    Add to Cart
                </button>
            </a>
        </p>
        <p>
            <a href="listprod.jsp">
                <button class="button-5" role="button">
                    Continue Shopping
                </button>
            </a>
        </p>
    </div>

</body>
</html>

<style>
table tr:hover {
    background-color: #CCCCCC;
}
.productTable {
    padding: 10;
    width: 100%;
    margin: auto;
    float: left;
}
div.links {
    margin: auto;
    padding: 10;
    justify-content: center;
}
.button-5 {
  align-items: center;
  background-clip: padding-box;
  background-color: #fa6400;
  border: 1px solid transparent;
  border-radius: .25rem;
  box-shadow: rgba(0, 0, 0, 0.02) 0 1px 3px 0;
  box-sizing: border-box;
  color: #fff;
  cursor: pointer;
  display: inline-flex;
  font-family: system-ui,-apple-system,system-ui,"Helvetica Neue",Helvetica,Arial,sans-serif;
  font-size: 16px;
  font-weight: 600;
  justify-content: center;
  line-height: 1.25;
  margin: 0;
  min-height: 3rem;
  padding: calc(.875rem - 1px) calc(1.5rem - 1px);
  position: relative;
  text-decoration: none;
  transition: all 250ms;
  user-select: none;
  -webkit-user-select: none;
  touch-action: manipulation;
  vertical-align: baseline;
  width: auto;
}

.button-5:hover,
.button-5:focus {
  background-color: #fb8332;
  box-shadow: rgba(0, 0, 0, 0.1) 0 4px 12px;
}

.button-5:hover {
  transform: translateY(-1px);
}

.button-5:active {
  background-color: #c85000;
  box-shadow: rgba(0, 0, 0, .06) 0 2px 4px;
  transform: translateY(0);
}
</style>