<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html>

<head>
    <title>Administrator Page</title>
</head>

<body>

    <%@ include file="jdbc.jsp" %>
    <%-- <%@ include file="auth.jsp" %> --%>

    <h1>Administrator Sales Report by Day<h1>

    <table>
        <tr>
            <th>Order Date<th>
            <th>Total Order Amount<th>
        <tr>

        <%

            String sql = "SELECT orderDate, SUM(totalAmount) AS summedTotalAmount"
                    + "FROM OrderSummary"
                    + "GROUP BY orderDate";

            getConnection();
            Statement stmt = con.createStatement();
            ResultSet rst = stmt.executeQuery(sql);

            NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance();
            DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd LLLL yyyy"); //eg 03 January 2024

            while(rst.next()) {
                Timestamp orderDateTime = rst.getTimestamp("orderDate");
                double summedTotalAmount = rst.getDouble("summedTotalAmount");

                LocalDate orderDate = orderDateTime.toLocalDateTime().toLocalDate();
                String formattedDate = dateFormatter.format(orderDate);
                String formattedAmount = currencyFormatter.format(summedTotalAmount);

                String tableRow = String.format(
                    "<tr> <td>%s</td> <td>%s</td> <tr>",
                    formattedDate,
                    formattedAmount
                );

                out.println(tableRow);
            }

            closeConnection();

        %>

    </table>

</body>
</html>

