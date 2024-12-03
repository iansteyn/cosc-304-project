<div>
    <H1 align="center"><font face="cursive" color="#3399FF"><a href="index.jsp">Rowan & Ian's Grocery</a></font></H1>      
    <div class="centered-options">
        <p>test</p>
        <p>test 2 </p>
        <%
        if ((String) session.getAttribute("authenticatedUser") != null)
            out.println("<p>Welcome, " + session.getAttribute("authenticatedUser") + "</p>");
        %>
    </div>
</div>

<style>
    div {
        background-color: #dddddd;
    }
    div.centered-options {
    display: flex;
    margin: auto;
    padding: 10;
    justify-content: space-evenly;
}

</style>
