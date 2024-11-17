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
        // PREPARATION
        // -----------
        // Get customer id and product list
        String customerIdString = request.getParameter("customerId");
        int customerId = Integer.parseInt(customerIdString);

        @SuppressWarnings({"unchecked"})
        HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

        // Make connection
        getConnection(); //from jdbc.jsp

        // VALIDATION
        // ----------
        // find boolean customerIdIsValid
        String queryForCustomerId = "SELECT customerId FROM customer WHERE customerId = ?";
        PreparedStatement pstmt1 = con.prepareStatement(queryForCustomerId);
        pstmt1.setInt(1, customerId);
        ResultSet resultSet = pstmt1.executeQuery();

        boolean customerIdIsValid = resultSet.isBeforeFirst();

        // Determine if customer id is valid
        if (!customerIdIsValid) {
            out.println("<h1>Invalid customer id.<h1>");
            out.println("<h2><a href=\"checkout.jsp\">Try again.</a></h2>");
        }
        // Determine if there are products in the shopping cart
        else if (productList.isEmpty()) {
            out.println("<h1>Shopping cart is empty!<h1>");
            out.println("<h2><a href=\"listprod.jsp\">Return to shopping.</a></h2>");
        }
        // SAVE ORDER TO DB & PRINT SUMMARY
        // --------------------------------
        else {
            // Save customerid and orderdate information to database
            String insertSQL = "INSERT INTO orderSummary(customerId, orderDate) VALUES(?, ?)";

            PreparedStatement pstmt = con.prepareStatement(insertSQL, Statement.RETURN_GENERATED_KEYS);			
            pstmt.setInt(1, customerId);
            pstmt.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            pstmt.executeUpdate();

            // Get orderId generated from previous INSERT
            ResultSet keys = pstmt.getGeneratedKeys();
            keys.next();
            int orderId = keys.getInt(1);

            pstmt.close();
            keys.close();

            //prepare a new insert statement
            String insertSQL2 = "INSERT INTO OrderProduct(OrderId, ProductId, quantity, price) VALUES(?, ?, ?, ?)";
            PreparedStatement pstmt2 = con.prepareStatement(insertSQL2);
            pstmt2.setInt(1, orderId);

            //Insert each item from productList into OrderProduct table, using this orderId
                // Each entry in the HashMap is an ArrayList with item 0-id, 1-name, 2-quantity, 3-price
            Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator();
            while (iterator.hasNext())
            {
                Map.Entry<String, ArrayList<Object>> entry = iterator.next();
                ArrayList<Object> product = (ArrayList<Object>) entry.getValue();

                String productId = (String) product.get(0);
                String priceString = (String) product.get(2); //TODO - I think price should be 3 and qty should be 2 based on the thing above... but I'm not sure
                double price = Double.parseDouble(priceString);
                int quantity = ((Integer) product.get(3)).intValue(); //lol what why this way

                pstmt2.setInt(2, productId);
                pstmt2.setInt(3, quantity);
                pstmt2.setDouble(4, price);
                pstmt2.executeUpdate();
            }

            pstmt2.close();

            // Update total amount for order record

            

            // Print out order summary

            // Clear cart if order placed successfully
        }

        //close db connection
        closeConnection();
    %>
</body>
</html>

