
<div>
    <h1 align="center"><font face="sans-serif">
        <a href="index.jsp">PUZZLE PLACE</a></font>
    </h1>      
    <div class="centered-options">
        <p><a href="listprod.jsp">Begin Shopping</a></p>
        <p><a href="listorder.jsp">List All Orders</a></p>
        <p><a href="admin.jsp">Admin</a></p>
        <%
            if ((String) session.getAttribute("authenticatedUser") == null) {
                out.println("<p><a href=\"login.jsp\">Login</a></p>");
            }
            else {
                out.println(
                    "<p><a href=\"customer.jsp\">"
                    + "Current user: " + session.getAttribute("authenticatedUser")
                    + "</a></p>"
                    + "<p><a href=\"logout.jsp\">Log out</a></p>"
                );
            }
        %>
    </div>
</div>

<style>
    div {
        background-color: #c8cfff;
    }
    div.centered-options {
    display: flex;
    margin: auto;
    justify-content: space-evenly;
}
</style>
