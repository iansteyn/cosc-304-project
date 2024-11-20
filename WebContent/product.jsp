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

        while (resultSet.next()) {
            String name = resultSet.getString("productName");
            int id = resultSet.getInt("productId");
            double productPrice = resultSet.getDouble("productPrice");
            String formattedProductPrice = currencyFormatter.format(productPrice);
            String imageURL = resultSet.getString("productImageURL");
            String image = String.format("<img src =%s>", imageURL);

            // String tablerow = String.format("<tr> <td>%s</td>  <td>%d</td> <td>%s</td> <td>%s</td></tr>", image, id, name, formattedProductPrice);

            String output = String.format("<h1>%s</h1>", name);
            out.println(output);
            if (imageURL != null) {
                out.println((image));
            }

            String table = String.format("<table border='2'> <tr> <th>Product ID</th> <th>Product Price</th> </tr> <tr> <td>%d</td> <td>%s</td> </table>", id, formattedProductPrice);
            out.println(table);

            
        }
    }
        // try with resources closes itself
        catch (SQLException e)
        {
            out.println("SQLException: " + e);
        }

// TODO: If there is a productImageURL, display using IMG tag
		
// TODO: Retrieve any image stored directly in database. Note: Call displayImage.jsp with product id as parameter.
		
// TODO: Add links to Add to Cart and Continue Shopping
%>

</body>
</html>

<style>
table tr:hover {
    background-color: #CCCCCC;
}
</style>