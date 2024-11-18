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
        // Get session variables
        String customerIdString = request.getParameter("customerId");
        @SuppressWarnings({"unchecked"})
        HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

        // VALIDATION STUFF
        // ----------------
        // Create error messages
        String emptyCartMessage = "<h1>Shopping cart is empty!<h1>"
                                + "<h2><a href=\"listprod.jsp\">Return to shopping.</a></h2>";

        String invalidIdMessage = "<h1>Invalid customer id.<h1>"
                                + "<h2><a href=\"checkout.jsp\">Try again.</a></h2>";

        // Validate shopping cart
        if (productList == null || productList.isEmpty()) {
            out.println(emptyCartMessage);
            return; //END jsp execution early
        }

        // Validate customer id (PT 1)
        boolean customerIdIsNumber = customerIdString.matches("^[0-9]+$");

        if (! customerIdIsNumber) {
            out.println(invalidIdMessage);
            return; //END jsp execution early
        }

        // Connect to DB and validate customer id (PT 2)
            // Note: this resultset is later used to print customer name
        getConnection(); // from jdbc.jsp
        PreparedStatement customer_pstmt = con.prepareStatement(
            "SELECT firstName, lastName FROM customer WHERE customerId = ?"
        );
        
        int customerId = Integer.parseInt(customerIdString);
        customer_pstmt.setInt(1, customerId); 

        ResultSet customerResultSet = customer_pstmt.executeQuery();
        boolean customerIdIsInDB = customerResultSet.isBeforeFirst();

        if (! customerIdIsInDB) {
            out.println(invalidIdMessage);
            closeConnection();
            return; //end jsp execution early
        }

        // ORDERSUMMARY STUFF
        // ------------------
        // Save customerid and orderdate info to database
        PreparedStatement orderSummary_pstmt = con.prepareStatement(
            "INSERT INTO orderSummary(customerId, orderDate) VALUES(?, ?)",
            Statement.RETURN_GENERATED_KEYS
        );
        orderSummary_pstmt.setInt(1, customerId);
        orderSummary_pstmt.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
        orderSummary_pstmt.executeUpdate();

        // Get orderId generated from the INSERT
        ResultSet keys = orderSummary_pstmt.getGeneratedKeys();
        keys.next();
        int orderId = keys.getInt(1);

        // PREPARE FOR ORDERPRODUCT STUFF
        // ------------------------------
        //set up html table - for some reason multiline strings are not a thing for JSP
        out.println(
            "<h1>Your Order Summary</h1>"
            +"<table style='text-align: center'>"
            +   "<tr>"
            +       "<th>Product Id</th>"
            +       "<th>Product Name</th>"
            +       "<th>Quantity</th>"
            +       "<th>Price</th>"
            +       "<th>Subtotal</th>"
            +   "</tr>"
        );

        //Initialize fields needed in the iterator loop
        double orderTotal = 0;
        NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance();

        PreparedStatement orderProduct_pstmt = con.prepareStatement(
            "INSERT INTO OrderProduct(OrderId, ProductId, quantity, price) VALUES(?, ?, ?, ?)"
        );
        orderProduct_pstmt.setInt(1, orderId);

        // ORDERPRODUCT STUFF
        // ------------------
            // Each entry in the HashMap is an ArrayList with item 0-id, 1-name, 2-price, 3-quantity
        Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator();

        while (iterator.hasNext()) {

            //Get item info from productList hashmap
            Map.Entry<String, ArrayList<Object>> entry = iterator.next();
            ArrayList<Object> product = (ArrayList<Object>) entry.getValue();

            String productIdString = (String) product.get(0); 
            String productName = (String) product.get(1);
            String priceString = (String) product.get(2);
            int quantity = ((Integer) product.get(3)).intValue(); 

            int productId = Integer.parseInt(productIdString);
            double price = Double.parseDouble(priceString);

            // Insert item record into OrderProduct table
            orderProduct_pstmt.setInt(2, productId);
            orderProduct_pstmt.setInt(3, quantity);
            orderProduct_pstmt.setDouble(4, price);
            orderProduct_pstmt.executeUpdate();

            //Calculate item subtotal
            double subtotal = quantity * price;
            orderTotal += subtotal;

            //Print item as row in html table
            String tableRow = String.format(
                "<tr> <td>%d</td> <td>%s</td> <td>%d</td> <td>%s</td> <td>%s</td> </tr>",
                productId,
                productName,
                quantity,
                currencyFormatter.format(price),
                currencyFormatter.format(subtotal)
            );

            out.println(tableRow);
        }

        // ORDER TOTAL STUFF
        // -----------------
        //print orderTotal
        String finalRow = String.format(
            "<tr> <td></td> <td></td> <td></td> <th>Order Total</th> <td>%s</tr>",
            currencyFormatter.format(orderTotal)
        );
        out.println(finalRow);
        out.println("</table>");

        //Update total amount for orderSummary record
        PreparedStatement orderSummary_pstmt2 = con.prepareStatement(
            "UPDATE orderSummary SET totalAmount = ? WHERE orderId = ?"
        );
        orderSummary_pstmt2.setDouble(1, orderTotal);
        orderSummary_pstmt2.setInt(2, orderId);
        orderSummary_pstmt2.executeUpdate();

        // SUCCESS STUFF
        // --------------
        // get customer name
        customerResultSet.next();
        String customerName = customerResultSet.getString("firstName") + " " + customerResultSet.getString("lastName");

        // print success message
        String successMessage = String.format(
            "<h1>Order Completed. Will be shipped soon...</h1>"
            +"<h2>Your order reference number is: %d</h2>"
            +"<h2>Shipping to customer: %d. Name: %s.",
            orderId,
            customerId,
            customerName
        );

        out.println(successMessage);
        out.println("<h2><a href=\"shop.html\">Return to home page.</a></h2>");

        // Clear shopping cart
        session.setAttribute("productList", null);

        //close db connection
        closeConnection(); // from jdbc.jsp
    %>

</body>
</html>