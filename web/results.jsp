<jsp:include page="partials/header.jsp" />
<%@page import="java.sql.*"%>

<%
    Connection conn = null;
    ResultSet rsOne = null;
    ResultSet rsTwo = null;
    ResultSet rsThree = null;
    ResultSet rsFour = null;
    boolean isResultSetEmpty = true;
    PreparedStatement preparedStatementOne = null;
    PreparedStatement preparedStatementTwo = null;
    PreparedStatement preparedStatementThree = null;
    PreparedStatement preparedStatementFour = null;
    String driver = "org.apache.derby.jdbc.ClientDataSource";
    String url = "jdbc:derby://localhost:1527/Concert;user=app;password=password";

    try {

        Class.forName(driver).newInstance();
        conn = DriverManager.getConnection(url);

        // First query
        String queryOne = "SELECT S_CAT, S_SOLD FROM SEATS";
        preparedStatementOne = conn.prepareStatement(queryOne);
        rsOne = preparedStatementOne.executeQuery();

        // Second query
        String queryTwo = "SELECT S_CAT, SUM(75 - S_SOLD) AS S_SOLD FROM SEATS GROUP BY S_CAT";
        preparedStatementTwo = conn.prepareStatement(queryTwo);
        rsTwo = preparedStatementTwo.executeQuery();
        
        // Third query
        String queryThree = "SELECT S_CAT, S_PRICE, S_SOLD FROM SEATS";
        preparedStatementThree = conn.prepareStatement(queryThree);
        rsThree  = preparedStatementThree.executeQuery();
        
        // Fourth and final query
        String queryFour = "SELECT SUM(S_TOTAL) AS S_TOTAL FROM SEATS";
        preparedStatementFour = conn.prepareStatement(queryFour);
        rsFour = preparedStatementFour.executeQuery();

%>

<main class="section">
    <div class="container">
        <h1>Results of the query</h1>
        <p class="lead">Tickets Sold Per Category</p>
        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Category</th>
                    <th>Amount</th>
                </tr>
            </thead>
            <tbody>
            <%     while (rsOne.next()) {
                    //If we enter to the while, the ResultSet wasn't empty
                    isResultSetEmpty = false;
            %>
                <tr>
                    <td><%=rsOne.getString("S_CAT")%></td>
                    <td><%=rsOne.getInt("S_SOLD")%></td>
                </tr>
            <% } %>
            </tbody>
        </table>
        <p class="lead">Tickets Available Per Category</p>
        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Category</th>
                    <th>Amount</th>
                </tr>
            </thead>
            <tbody>
            <%
                while (rsTwo.next()) {
                    //If we enter to the while, the ResultSet wasn't empty
                    isResultSetEmpty = false;
            %>
            <tr>
                <td><%=rsTwo.getString("S_CAT")%></td>
                <td><%=rsTwo.getInt("S_SOLD")%></td>
            </tr>
            
           <% } %>
           </tbody>
        </table>
        <p class="lead">Sales Report</p>
        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Category</th>
                    <th>Amount</th>
                </tr>
            </thead>
            <tbody>
            <%
                while (rsThree.next()) {
                    //If we enter to the while, the ResultSet wasn't empty
                    isResultSetEmpty = false;
                    
            %>
            
                <tr>
                    <td><%=rsThree.getString("S_CAT")%></td>
                    <td><%=String.format("$%,.2f", (rsThree.getDouble("S_PRICE")*rsThree.getDouble("S_SOLD")))%></td>
                </tr>
           <%
               }

               while(rsFour.next()) {
                    //If we enter to the while, the ResultSet wasn't empty
                    isResultSetEmpty = false;
                
               %>
                <tr>
                    <td><strong>Category Total</strong></td>
                    <td><strong><%=String.format("$%,.2f", rsFour.getDouble("S_TOTAL"))%></strong></td>
                </tr>		
           </tbody>	
        </table>
        <%
            }

            if (isResultSetEmpty) {
        %>
        <h2>The database is empty</h2>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
                try {
                    conn.rollback();
                } catch (Exception re) {
                    re.printStackTrace();
                }
            } finally {
                // try to close the connection...
                try {
                    // close the connection...
                    conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        %>
    </div>
</main>

<jsp:include page="partials/footer.jsp" />