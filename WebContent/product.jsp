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
// Get product name to search for
// TODO: Retrieve and display info for the product
String productId = request.getParameter("id");

try
{	// Load driver class
	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
}
catch (java.lang.ClassNotFoundException e)
{
	out.println("ClassNotFoundException: " +e);
}

// some connection information
String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";		
String uid = "sa";
String pw = "304#sa#pw";

// this is vulnerable to SQL injection attack, fix later
String sql = "SELECT * FROM product WHERE productId = " + productId;


try(Connection con = DriverManager.getConnection(url, uid, pw);
        PreparedStatement preparedStatement = con.prepareStatement(sql);)
    {
        ResultSet resultSet = preparedStatement.executeQuery();
        NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance();

        resultSet.next();
        String name = resultSet.getString("productName");
        int id = resultSet.getInt("productId");
        double productPrice = resultSet.getDouble("productPrice");
        String formattedProductPrice = currencyFormatter.format(productPrice);
        String imageURL = resultSet.getString("productImageURL");
        String image = String.format("<img style=padding:10; src =%s>", imageURL);

        String output = String.format("<h1>%s</h1>", name);
        out.println(output);
        if (imageURL != null) {
            out.println((image));
        }

        String table = String.format("<table border='2'> <tr> <th>Product ID</th> <th>Product Price</th> </tr> <tr> <td>%d</td> <td>%s</td> </table>", id, formattedProductPrice);
        out.println(table);

        out.println("</div> <div class='links'> <h3> <form>");

        String add_cart_link = String.format("addcart.jsp?id=%d&name=%s&price=%f", id, name, productPrice);
        String thing = (String.format("<button class='button-5' formaction=%s role='button'>Add to Cart</button>", add_cart_link));
        out.println(thing);

        
        
    }
        // try with resources closes itself
        catch (SQLException e)
        {
            out.println("SQLException: " + e);
        }


%>   
        </form>
        <form>
            <button class="button-5" formaction="listprod.jsp" role="button">Continue Shopping</button>
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