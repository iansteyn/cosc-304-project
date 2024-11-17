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
        else if (productList.isEmpty()) { //TODO: this line causes an error when shop page is loaded on its on
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

            // Prep - Get orderId generated from previous INSERT
            ResultSet keys = pstmt.getGeneratedKeys();
            keys.next();
            int orderId = keys.getInt(1);

            pstmt.close();
            keys.close();

            //Prep - prepare a new insert statement
            String insertSQL2 = "INSERT INTO OrderProduct(OrderId, ProductId, quantity, price) VALUES(?, ?, ?, ?)";
            PreparedStatement pstmt2 = con.prepareStatement(insertSQL2);
            pstmt2.setInt(1, orderId);

            //html prep - for some reason multiline strings are not a thing for JSP
            out.println(
                "<h1>Your Order Summary</h1>"
                +"<table>"
                +   "<tr>"
                +       "<th>Product Id</th>"
                +       "<th>Product Name</th>"
                +       "<th>Quantity</th>"
                +       "<th>Price</th>"
                +       "<th>Subtotal</th>"
                +   "</tr>"
            );
            
            //For each item in productList:
                // - insert it into OrderProduct table, using the orderId
                // - calculate its subtotal to the order total
                // - print out (or at least save) a summary line
                // Each entry in the HashMap is an ArrayList with item 0-id, 1-name, 2-quantity, 3-price
            Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator();
            while (iterator.hasNext())
            {
                //Get item info from productList hashmap
                Map.Entry<String, ArrayList<Object>> entry = iterator.next();
                ArrayList<Object> product = (ArrayList<Object>) entry.getValue();

                String productIdString = (String) product.get(0); 
                String priceString = (String) product.get(2); //TODO - I think price should be 3 and qty should be 2 based on the thing above... but I'm not sure
                
                int productId = Integer.parseInt(productIdString);
                double price = Double.parseDouble(priceString); //lol what why this way
                int quantity = ((Integer) product.get(3)).intValue(); 

                // Insert item record into OrderProduct table
                pstmt2.setInt(2, productId);
                pstmt2.setInt(3, quantity);
                pstmt2.setDouble(4, price);
                pstmt2.executeUpdate();

                //TODO - calculate subtotal

                //TODO - print row
            }

            pstmt2.close();

            // Update total amount for order record
            String updateSQLstart = "UPDATE orderSummary SET totalAmount = (";
            String updateSQLsubquery = "SELECT SUM(quantity * price) FROM orderProduct WHERE orderId = ?";
            String updateSQLend = ") WHERE orderId = ?"; //Okay wait I could calculate the orderTotal on this end

            String updateSQL = updateSQLstart + updateSQLsubquery + updateSQLend;

            PreparedStatement pstmt3 = con.prepareStatement(updateSQL);
            pstmt3.setInt(1, orderId);
            pstmt3.setInt(2, orderId);
            pstmt3.executeUpdate();
            pstmt3.close();

            // Print out order summary

            // Clear cart if order placed successfully

            out.println("</table>");
        }

        
        //close db connection
        closeConnection(); // from jdbc.jsp
    %>
</body>
</html>

