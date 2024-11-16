<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>
<!DOCTYPE html>
<html>

<head>
    <title>Rowan & Ian's Grocery Order Processing</title>
</head>

<body>
    <% 
        // Get customer id
        String customerId = request.getParameter("customerId");
        @SuppressWarnings({"unchecked"})
        HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

        // Determine if valid customer id was entered
        // Determine if there are products in the shopping cart
        // If either are not true, display an error message


        // Make connection
        getConnection(); //from jdbc.jsp?

        // Save order information to database
        String insertSQL = "INSERT INTO orderSummary(customerId, orderDate) VALUES(?, ?)";

        PreparedStatement pstmt = con.prepareStatement(insertSQL, Statement.RETURN_GENERATED_KEYS);			
        pstmt.setInt(1, customerId);
        pstmt.setTimestamp(2, new Timestamp(System.currentTimeMillis()));

        pstmt.executeUpdate();

        // Insert each item into OrderProduct table using OrderId from previous INSERT
        ResultSet keys = pstmt.getGeneratedKeys();
        keys.next();
        int orderId = keys.getInt(1);

        //String insertSQL =  

        // Update total amount for order record

        // Here is the code to traverse through a HashMap
        // Each entry in the HashMap is an ArrayList with item 0-id, 1-name, 2-quantity, 3-price

        /*
            Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator();
            while (iterator.hasNext())
            { 
                Map.Entry<String, ArrayList<Object>> entry = iterator.next();
                ArrayList<Object> product = (ArrayList<Object>) entry.getValue();
                String productId = (String) product.get(0);
                String price = (String) product.get(2);
                double pr = Double.parseDouble(price);
                int qty = ( (Integer)product.get(3)).intValue();
                    ...
            }
        */

        // Print out order summary

        // Clear cart if order placed successfully

        //close connection :)
        closeConnection();
    %>
</body>
</html>

