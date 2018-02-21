<jsp:include page="partials/header.jsp" />
<%@page import="java.sql.*"%>
<%
    int O_QUANTITY = 1, C_ID = 0;
    double CAT_PRICE = 0, serviceFee = 0.07, O_SHIPPING = 0, O_FEE = 0, subTotal = 0, O_TOTAL = 0;
    String method = request.getMethod();
    
    // Get params from post method
    if (method.equalsIgnoreCase("POST")) {
        String C_FNAME = request.getParameter("C_FNAME");
        String C_LNAME = request.getParameter("C_LNAME");
        String C_EMAIL = request.getParameter("C_EMAIL");
        String C_ADDRESS = request.getParameter("C_ADDRESS");
        String C_CITY = request.getParameter("C_CITY");
        String C_STATE = request.getParameter("C_STATE"); // Will throw an error if not selected for now
        String C_ZIP = request.getParameter("C_ZIP");
        String O_CATNAME = request.getParameter("O_CATNAME");
        // Done for testing purposes
        if (request.getParameter("O_QUANTITY") != null) {
            O_QUANTITY = Integer.parseInt(request.getParameter("O_QUANTITY"));
        }
        String shipping = request.getParameter("shipping");

        // Cannot use a switch because Glassfish will throw a hissy fit
        if (O_CATNAME.equalsIgnoreCase("Category 1")) {
            CAT_PRICE = 50;
        } else if (O_CATNAME.equalsIgnoreCase("Category 2")) {
            CAT_PRICE = 40;
        } else {
            CAT_PRICE = 30;
        }
        
        // Calculate subtotal
        subTotal = CAT_PRICE * O_QUANTITY;
        
        // Calculate fee
        O_FEE = subTotal * serviceFee;

        // Calculate the total
        O_TOTAL = subTotal + O_FEE;
        
        // Add shipping if user selects this option
        if (shipping.equalsIgnoreCase("Ship to address ($5.95)")) {
            O_SHIPPING = 5.95;
            O_TOTAL += O_SHIPPING;
        }

        Connection conn = null;
        try {

            String driver = "org.apache.derby.jdbc.ClientDataSource";
            Class.forName(driver);

            // Setup the connection with the DB
            String url = "jdbc:derby://localhost:1527/Concert;user=app;password=password";
            conn = DriverManager.getConnection(url);
            conn.setAutoCommit(false);
            System.out.println("DB Connection successful");

            // Prepare to insert client info
            StringBuilder cBuilder = new StringBuilder();
            cBuilder.append("INSERT INTO CLIENTS(C_FNAME, C_LNAME, C_EMAIL, C_ADDRESS, C_ZIP, C_CITY, C_STATE)");
            cBuilder.append("VALUES (?, ?, ?, ?, ?, ?, ?)");
            String cPreparedQuery = cBuilder.toString();

            PreparedStatement cStatement = conn.prepareStatement(cPreparedQuery, Statement.RETURN_GENERATED_KEYS);
            cStatement.setString(1, C_FNAME);
            cStatement.setString(2, C_LNAME);
            cStatement.setString(3, C_EMAIL);
            cStatement.setString(4, C_ADDRESS);
            cStatement.setString(5, C_ZIP);
            cStatement.setString(6, C_CITY);
            cStatement.setString(7, C_STATE);

            cStatement.executeUpdate();
            
            // Get the auto generated key and store it for next orders table insertion
            ResultSet generateKey = cStatement.getGeneratedKeys();
    
            if (generateKey.next()) {
                C_ID = generateKey.getInt(1);
            }
            
            // Prepare to insert order info
            StringBuilder oBuilder = new StringBuilder();
            oBuilder.append("INSERT INTO ORDERS(O_QUANTITY, O_SHIPPING, O_FEE, O_TOTAL, O_CATNAME, C_ID)");
            oBuilder.append("VALUES (?, ?, ?, ?, ?, ?)");
            String oPreparedQuery = oBuilder.toString();

            PreparedStatement oStatement = conn.prepareStatement(oPreparedQuery);
            oStatement.setInt(1, O_QUANTITY);
            oStatement.setDouble(2, O_SHIPPING);
            oStatement.setDouble(3, O_FEE);
            oStatement.setDouble(4, O_TOTAL);
            oStatement.setString(5, O_CATNAME);
            oStatement.setInt(6, C_ID);

            oStatement.executeUpdate();

            // Prepare to update cat info
            StringBuilder catBuilder = new StringBuilder();
            catBuilder.append("UPDATE SEATS SET S_SOLD = S_SOLD + ?, S_TOTAL = S_TOTAL + ? WHERE S_CAT = ?");
            String catPreparedQuery = catBuilder.toString();

            PreparedStatement catStatement = conn.prepareStatement(catPreparedQuery);
            catStatement.setInt(1, O_QUANTITY);
            catStatement.setDouble(2, O_TOTAL);
            catStatement.setString(3, O_CATNAME);            
            
            catStatement.executeUpdate();

            conn.commit();
            System.out.println("All changes commited.");
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
        response.setStatus(response.SC_MOVED_TEMPORARILY);
        session.setAttribute("C_ID", C_ID);
        response.setHeader("Location", "order.jsp");           
    }
%> 

<main class="section">
    <div class="container">
        <h1>Reserve Seats</h1>
        <p class="lead">Enter your personal information below.</p>
        <form method="POST" action="tickets.jsp">
            <div class="form-row">
                <div class="form-group col-12 col-md-6">
                    <label for="C_FNAME">First Name</label>
                    <input type="text" class="form-control" name="C_FNAME" value="John" id="C_FNAME" required>
                </div>
                <div class="form-group col-12 col-md-6">
                    <label for="C_LNAME">Last Name</label>
                    <input type="text" class="form-control" name="C_LNAME" id="C_LNAME" value="Doe" required>
                </div>
            </div>
            <div class="form-group">
                <label for="C_EMAIL">Email</label>
                <input type="C_EMAIL" class="form-control" name="C_EMAIL" id="C_EMAIL"  value="example@email.com" required>
            </div>

            <div class="form-row">
                <div class="form-group col-12 col-md-5">
                    <label for="C_ADDRESS">Address</label>
                    <input type="text" class="form-control" name="C_ADDRESS" id="C_ADDRESS" value="1234 Main St"  required>
                </div>
                <div class="form-group col-12 col-md-3">
                    <label for="C_CITY">City</label>
                    <input type="C_CITY" class="form-control" name="C_CITY" id="C_CITY" required value="Beverly Hills">
                </div>
                <div class="form-group col-12 col-md-2">
                    <label for="C_STATE">State</label>
                    <select class="form-control" name="C_STATE" id="C_STATE" required value="NC">
                        <option selected>Choose...</option>
                        <option value="AL">Alabama</option>
                        <option value="AK">Alaska</option>
                        <option value="AZ">Arizona</option>
                        <option value="AR">Arkansas</option>
                        <option value="CA">California</option>
                        <option value="CO">Colorado</option>
                        <option value="CT">Connecticut</option>
                        <option value="DE">Delaware</option>
                        <option value="DC">District Of Columbia</option>
                        <option value="FL">Florida</option>
                        <option value="GA">Georgia</option>
                        <option value="HI">Hawaii</option>
                        <option value="ID">Idaho</option>
                        <option value="IL">Illinois</option>
                        <option value="IN">Indiana</option>
                        <option value="IA">Iowa</option>
                        <option value="KS">Kansas</option>
                        <option value="KY">Kentucky</option>
                        <option value="LA">Louisiana</option>
                        <option value="ME">Maine</option>
                        <option value="MD">Maryland</option>
                        <option value="MA">Massachusetts</option>
                        <option value="MI">Michigan</option>
                        <option value="MN">Minnesota</option>
                        <option value="MS">Mississippi</option>
                        <option value="MO">Missouri</option>
                        <option value="MT">Montana</option>
                        <option value="NE">Nebraska</option>
                        <option value="NV">Nevada</option>
                        <option value="NH">New Hampshire</option>
                        <option value="NJ">New Jersey</option>
                        <option value="NM">New Mexico</option>
                        <option value="NY">New York</option>
                        <option value="NC">North Carolina</option>
                        <option value="ND">North Dakota</option>
                        <option value="OH">Ohio</option>
                        <option value="OK">Oklahoma</option>
                        <option value="OR">Oregon</option>
                        <option value="PA">Pennsylvania</option>
                        <option value="RI">Rhode Island</option>
                        <option value="SC">South Carolina</option>
                        <option value="SD">South Dakota</option>
                        <option value="TN">Tennessee</option>
                        <option value="TX">Texas</option>
                        <option value="UT">Utah</option>
                        <option value="VT">Vermont</option>
                        <option value="VA">Virginia</option>
                        <option value="WA">Washington</option>
                        <option value="WV">West Virginia</option>
                        <option value="WI">Wisconsin</option>
                        <option value="WY">Wyoming</option>
                    </select>
                </div>
                <div class="form-group col-md-2">
                    <label for="C_ZIP">Zip</label>
                    <input type="text" class="form-control" name="C_ZIP" id="C_ZIP" required value="90210">
                </div>
            </div>
            <div class="form-row">
                <div class="form-group col-12 col-md-4">
                    <label for="O_CATNAME">Please select a category</label>
                    <select class="form-control" id="O_CATNAME" name="O_CATNAME" required>
                        <option>Category 1</option>
                        <option>Category 2</option>
                        <option>Category 3</option>
                    </select>
                </div>
                <div class="form-group col-12 col-md-4">
                    <label for="O_QUANTITY">How many tickets would you like to purchase?</label>
                    <input class="form-control" id="O_QUANTITY" name="O_QUANTITY" type="number" min="1" max="75" value="1" required>
                </div>
                <div class="form-group col-12 col-md-4">
                    <label for="shipping">How would you like to receive your tickets?</label>
                    <select class="form-control" id="shipping" name="shipping" required>
                        <option>Pick up at Box Office (Free)</option>
                        <option>Ship to address ($5.95)</option>
                        <option>Print online (free)</option>
                    </select>
                </div>
            </div>
            
            <input class="btn btn-success" type="submit" value="Place Order">
        </form>
    </div>
</main>

<jsp:include page="partials/footer.jsp" />