<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>

<html>

<head>
    <title>Ray's Grocery - Product Information</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
</head>

<body>
    <%@ include file="header.jsp" %>

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
            // TODO: get image object directly from resultSet if it exists

            closeConnection();

            // do some formatting
            NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance();
            String formattedProductPrice = currencyFormatter.format(productPrice);

            String image;
            if (imageURL == null) {
                image = "";
            } else {
                image = String.format("<img style=padding:10; src=%s>", imageURL);
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
        <%= image %>

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
        <h3>
            <form>
                <button class="button-5" formaction="<%= addToCartLink %>" role="button">
                    Add to Cart
                </button>
            </form>

            <form>
                <button class="button-5" formaction="listprod.jsp" role="button">
                    Continue Shopping
                </button>
            </form>
        </h3>
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