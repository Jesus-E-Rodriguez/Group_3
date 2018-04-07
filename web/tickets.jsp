<%-- 
    Document   : tickets
    Created on : Mar 18, 2018, 6:03:02 PM
    Author     : Jesus
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@ page language="java" import="java.util.*" errorPage="" %>
<html>
    <head>
        <!-- Required meta tags -->
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

        <!-- Title -->
        <title>Jazz Concert</title>

        <!-- Custom icons -->
        <link rel="stylesheet" href="css/font-awesome.css" />

        <!-- Custom CSS -->
        <link rel="stylesheet" href="css/styles.css" />
    </head>
    <body>
        <header class="background--dark">
            <!-- Navigation -->
            <nav class="wrapper--unpadded">
                <div class="navbar__content">
                    <a class="navbar__content__brand--dark" href="index.jsp"><img src="img/jazz_grasp_logo.png" alt="Jazz Grasp Logo"></a>
                    <ul class="navigation">
                        <li class="navigation__item">
                            <a class="navigation__item__link--dark" href="index.jsp">Home</a>
                        </li>
                        <li class="navigation__item">
                            <a class="navigation__item__link--dark" href="tickets.jsp">Order Tickets</a>
                        </li>
                        <li class="navigation__item">
                            <a class="navigation__item__link--dark" href="results.jsp">Results</a>
                        </li>
                    </ul>
                </div>
            </nav>
        </header>

        <%@page import="java.sql.*"%>
        <%@page import="java.util.regex.Pattern"%>
        <%
            // Declare revelant variables
            Connection conn = null;
            PreparedStatement preparedStatement = null;
            ResultSet query = null;
            // Establish the driver needed to communicate with the database
            String driver = "org.apache.derby.jdbc.ClientDataSource";
            // Setup the connection with the DB
            String url = "jdbc:derby://localhost:1527/Concert;user=app;password=password";

            // First check the amount of seats that are avaiable in the database
            try {
                Class.forName(driver).newInstance();
                conn = DriverManager.getConnection(url);
                conn.setAutoCommit(false);

                // First query
                String queryStr = "SELECT S_CAT, S_SOLD FROM SEATS";
                preparedStatement = conn.prepareStatement(queryStr);
                query = preparedStatement.executeQuery();

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

            // Main variables
            String method = request.getMethod(); // To get the request
            boolean error = false; // To determine if there is an error
            String message = ""; // To display messages to the user

            // Get params from post method
            if (method.equalsIgnoreCase("POST")) {

                // Delcare relevant variables
                int O_QUANTITY = 1, C_ID = 0;
                final double CATEGORY_ONE = 50, CATEGORY_TWO = 40, CATEGORY_THREE = 30; // Constants 
                double CAT_PRICE = 0, serviceFee = 0.07, O_SHIPPING = 0, O_FEE = 0, subTotal = 0, O_TOTAL = 0;
                Pattern strPattern = Pattern.compile("(^[a-zA-Z][\\']?[a-zA-Z\\s]+$)");
                Pattern addressPattern = Pattern.compile("([0-9]*\\)*\\(*\\s*)+");
                Pattern emailPattern = Pattern.compile("^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,6}$", Pattern.CASE_INSENSITIVE);
                Pattern numPattern = Pattern.compile("(^[0-9]+$)");
                final int NAME_LENGTH = 40, EMAIL_LENGTH = 50, ADDRESS_LENGTH = 50, ZIP_LENGTH = 5, CITY_LENGTH = 50, STATE_LENGTH = 2, QUANTITY_MIN_SIZE = 1, QUANTITY_MAX_SIZE = 75;

                // Validate input for strings
                if (strPattern.matcher(request.getParameter("C_FNAME")).find() && strPattern.matcher(request.getParameter("C_LNAME")).find()
                        && emailPattern.matcher(request.getParameter("C_EMAIL")).find() && addressPattern.matcher(request.getParameter("C_ADDRESS")).find()
                        && strPattern.matcher(request.getParameter("C_CITY")).find() && strPattern.matcher(request.getParameter("C_STATE")).find()
                        && numPattern.matcher(request.getParameter("C_ZIP")).find() && numPattern.matcher(request.getParameter("O_QUANTITY")).find()) {

                    // Validate input for form lengths that are less than or equal to the required lengths in the database
                    if (request.getParameter("C_FNAME").length() <= NAME_LENGTH && request.getParameter("C_LNAME").length() <= NAME_LENGTH
                            && request.getParameter("C_EMAIL").length() <= EMAIL_LENGTH && request.getParameter("C_ADDRESS").length() <= ADDRESS_LENGTH
                            && request.getParameter("C_CITY").length() <= CITY_LENGTH && request.getParameter("C_ZIP").length() == ZIP_LENGTH
                            && request.getParameter("C_STATE").length() == STATE_LENGTH && (Integer.parseInt(request.getParameter("O_QUANTITY")) >= QUANTITY_MIN_SIZE)
                            && (Integer.parseInt(request.getParameter("O_QUANTITY")) <= QUANTITY_MAX_SIZE)) {

                        // Check to see if there are any quantities to sell 
                        while (query.next()) {
                            if (query.getString("S_CAT").equalsIgnoreCase(request.getParameter("O_CATNAME"))) {
                                if (75 - query.getInt("S_SOLD") == 0) {
                                    error = true;
                                    message = "All seats have been sold out in that category!";
                                } else if (75 - query.getInt("S_SOLD") < Integer.parseInt(request.getParameter("O_QUANTITY"))) {
                                    error = true;
                                    message = "Your order cannot exceed the available seats in that category!";
                                }
                            }
                        }

                        if (!error) {
                            // Collect all of the fields from the request
                            String C_FNAME = request.getParameter("C_FNAME");
                            String C_LNAME = request.getParameter("C_LNAME");
                            String C_EMAIL = request.getParameter("C_EMAIL");
                            String C_ADDRESS = request.getParameter("C_ADDRESS");
                            String C_CITY = request.getParameter("C_CITY");
                            String C_STATE = request.getParameter("C_STATE");
                            String C_ZIP = request.getParameter("C_ZIP");
                            String O_CATNAME = request.getParameter("O_CATNAME");
                            O_QUANTITY = Integer.parseInt(request.getParameter("O_QUANTITY"));
                            String shipping = request.getParameter("shipping");

                            // Check to see the category name and then assign the category price based on that
                            if (O_CATNAME.equalsIgnoreCase("Category 1")) {
                                CAT_PRICE = CATEGORY_ONE;
                            } else if (O_CATNAME.equalsIgnoreCase("Category 2")) {
                                CAT_PRICE = CATEGORY_TWO;
                            } else {
                                CAT_PRICE = CATEGORY_THREE;
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
                            try {
                                conn = null;
                                Class.forName(driver);
                                conn = DriverManager.getConnection(url);
                                conn.setAutoCommit(false);
                                System.out.println("DB Connection successful");

                                // Prepare to insert client info
                                StringBuilder cBuilder = new StringBuilder();
                                cBuilder.append("INSERT INTO CLIENTS(C_FNAME, C_LNAME, C_EMAIL, C_ADDRESS, C_ZIP, C_CITY, C_STATE)");
                                cBuilder.append("VALUES (?, ?, ?, ?, ?, ?, ?)");
                                String cPreparedQuery = cBuilder.toString();

                                /* Declare the prepared statement and once it executes, recieve back the auto generated key that was used
                        as the primary key for the client */
                                PreparedStatement cStatement = conn.prepareStatement(cPreparedQuery, Statement.RETURN_GENERATED_KEYS);
                                cStatement.setString(1, C_FNAME);
                                cStatement.setString(2, C_LNAME);
                                cStatement.setString(3, C_EMAIL);
                                cStatement.setString(4, C_ADDRESS);
                                cStatement.setString(5, C_ZIP);
                                cStatement.setString(6, C_CITY);
                                cStatement.setString(7, C_STATE);

                                // Execute the statment
                                cStatement.executeUpdate();

                                // Get the auto generated key and store it for next orders table insertion
                                ResultSet generateKey = cStatement.getGeneratedKeys();

                                // If there is a result store it in a variable
                                if (generateKey.next()) {
                                    C_ID = generateKey.getInt(1);
                                }

                                // Prepare to insert order info into the Orders table
                                StringBuilder oBuilder = new StringBuilder();
                                oBuilder.append("INSERT INTO ORDERS(O_QUANTITY, O_SHIPPING, O_FEE, O_TOTAL, O_CATNAME, C_ID)");
                                oBuilder.append("VALUES (?, ?, ?, ?, ?, ?)");
                                String oPreparedQuery = oBuilder.toString();

                                // Set the prepared statement
                                PreparedStatement oStatement = conn.prepareStatement(oPreparedQuery);
                                oStatement.setInt(1, O_QUANTITY);
                                oStatement.setDouble(2, O_SHIPPING);
                                oStatement.setDouble(3, O_FEE);
                                oStatement.setDouble(4, O_TOTAL);
                                oStatement.setString(5, O_CATNAME);
                                oStatement.setInt(6, C_ID);

                                // Execute the statement
                                oStatement.executeUpdate();

                                // Prepare to update cat info
                                StringBuilder catBuilder = new StringBuilder();
                                catBuilder.append("UPDATE SEATS SET S_SOLD = S_SOLD + ?, S_TOTAL = S_TOTAL + ? WHERE S_CAT = ?");
                                String catPreparedQuery = catBuilder.toString();

                                // Set the prepared statment
                                PreparedStatement catStatement = conn.prepareStatement(catPreparedQuery);
                                catStatement.setInt(1, O_QUANTITY);
                                catStatement.setDouble(2, O_TOTAL);
                                catStatement.setString(3, O_CATNAME);

                                // Execute the statement
                                catStatement.executeUpdate();

                                // Commit all changes to the database
                                conn.commit();

                                // Print message to ensure that all changes have been commited
                                System.out.println("All changes commited.");

                                // Catch exceptions
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

                            /* If everything is sucessful, then move the user to the order page
                            where they can review their order. Also set a temporary session 
                            attribute in order to retrive the user from the database on the next
                            page */
                            response.setStatus(response.SC_MOVED_TEMPORARILY);
                            session.setAttribute("C_ID", C_ID);
                            response.setHeader("Location", "order.jsp");
                        }
                    } else {
                        error = true;
                        message = "The length of the fields you entered does not match what is allowable in the database. Please fill the form out correctly.";
                    }

                    // If there are any errors in the inpput, then send the message to the user.
                } else {
                    error = true;
                    message = "Please fill out the form correctly.";
                }
            }

            // A query specifically to display the amount of seats that are available to the user
            try {
                Class.forName(driver).newInstance();
                conn = DriverManager.getConnection(url);
                conn.setAutoCommit(false);

                // First query
                String queryStr = "SELECT S_CAT, S_SOLD, S_PRICE FROM SEATS";
                preparedStatement = conn.prepareStatement(queryStr);
                query = preparedStatement.executeQuery();
        %> 

        <% if (error) {%>
        <div class="error-warning"><p><%=message%></p></div>
                <% }%>

        <div class="showcase--medium-screen-plus background background2">
            <div class="wrapper text--light">
                <div class="grid--half">
                    <div class="grid--half__item">
                        <h1>Reserve Seats</h1>
                        <p class="text--emphasize">Enter your personal information below. <br>A 7% service fee will be added to all online purchases. Tickets are non-refundable.</p>
                    </div>
                    <div class="grid--half__item">
                        <!-- <div class="box">
                                                <h3>Ticket Prices</h3>
                                            <p>Category 1: Rows A-C - $50<br>Category 2: Rows D-F - $40<br>Category 3: Rows G-I - $30</p>
                            </div>-->
                        <div class="box">
                            <h3>Available Tickets and Prices</h3>	
                            <script>
                                var ticketsAvailable = [0];
                                var rowsInCat = [0, "Rows A-C", "Rows D-F", "Rows G-I"];
                            </script>
                            <% int CAT_ID = 1; %>
                            <% while (query.next()) {%>
                            <span id="info_cat<%= CAT_ID%>"><em><strong><%=query.getString("S_CAT")%>:</strong> <%=(75 - query.getInt("S_SOLD"))%> tickets available</em></span><br>
                            <script>
                                ticketsAvailable.push(<% out.print(75 - query.getInt("S_SOLD"));%>);
                            </script>
                            <%

                                        CAT_ID++;
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
                                }%>
                            <script>
                                var info_cat1 = document.getElementById("info_cat1");
                                info_cat1.innerHTML = info_cat1.innerHTML + " <em>- Rows A-C - $50</em>";
                                var info_cat2 = document.getElementById("info_cat2");
                                info_cat2.innerHTML = info_cat2.innerHTML + " <em>- Rows D-F - $40</em>";
                                var info_cat3 = document.getElementById("info_cat3");
                                info_cat3.innerHTML = info_cat3.innerHTML + " <em>- Rows G-I - $30</em>";
                                function changeMaxField(input) {
                                    document.getElementById('O_QUANTITY').setAttribute('max', ticketsAvailable[input.value.slice(-1)]);
                                    document.getElementById('O_QUANTITY_label').innerHTML = "How many tickets? (1MIN - " + ticketsAvailable[input.value.slice(-1)] + "MAX)";
                                }
                            </script>
                        </div>
                    </div>
                </div>
                <form method="POST" action="tickets.jsp">
                    <div class="grid--thirds">
                        <div class="grid--thirds__item">
                            <div class="form--row">
                                <div class="form--group">
                                    <label for="C_FNAME">First Name</label>
                                    <input type="text" class="form--control" name="C_FNAME" id="C_FNAME" required>
                                </div>
                                <div class="form--group">
                                    <label for="C_LNAME">Last Name</label>
                                    <input type="text" class="form--control" name="C_LNAME" id="C_LNAME" required>
                                </div>
                            </div>
                            <div class="form--group">
                                <label for="C_EMAIL">Email</label>
                                <input type="email" class="form--control" name="C_EMAIL" id="C_EMAIL" required>
                            </div>

                            <div class="form--row">
                                <div class="form--group">
                                    <label for="C_ADDRESS">Address</label>
                                    <input type="text" class="form--control" name="C_ADDRESS" id="C_ADDRESS" required>
                                </div>                    </div>
                        </div>
                        <div class="grid--thirds__item">
                            <div class="form--group">
                                <label for="C_CITY">City</label>
                                <input type="text" class="form--control" name="C_CITY" id="C_CITY" required>
                            </div>
                            <div class="form--group">
                                <label for="C_STATE">State</label>
                                <select class="form--control" name="C_STATE" id="C_STATE" required>
                                    <option value="">Choose a state...</option>
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
                            <div class="form--group">
                                <label for="C_ZIP">Zip</label>
                                <input type="text" class="form--control" name="C_ZIP" id="C_ZIP" required>
                            </div>
                        </div>

                        <div class="grid--thirds__item">
                            <div class="form--row">
                                <div class="form--group">
                                    <label for="O_CATNAME">Please select a category</label>
                                    <select class="form--control" id="O_CATNAME" name="O_CATNAME" onchange="changeMaxField(this);" required>
                                        <option value="">Choose a category...</option>
                                        <option>Category 1</option>
                                        <option>Category 2</option>
                                        <option>Category 3</option>
                                    </select>
                                </div>
                                <div class="form--group">
                                    <label for="O_QUANTITY" id="O_QUANTITY_label">How many tickets? (1MIN - 75 MAX)</label>
                                    <input class="form--control" id="O_QUANTITY" name="O_QUANTITY" type="number" min="1" max="75" required>
                                </div>
                                <div class="form--group">
                                    <label for="shipping">How would you like to receive your tickets?</label>
                                    <select class="form--control" id="shipping" name="shipping" required>
                                        <option value="">Choose an option...</option>
                                        <option>Pick up at Box Office (Free)</option>
                                        <option>Ship to address ($5.95)</option>
                                        <option>Print online (free)</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>
                    <input class="button button--primary-color" type="submit" value="Place Order">
                    <input class="button button--light" type="reset" value="Reset Order"/>
                </form>
            </div>
        </div>

        <footer class="background--dark">
            <div class="wrapper--unpadded">
                <div class="grid--thirds">
                    <div class="grid--thirds__item">
                        <small>&copy; 2018 Jazz Grasp</small>
                    </div>
                    <div class="grid--thirds__item text--center">
                        <a href="http://validator.w3.org/check?uri=referer">HTML</a> | <a href="http://jigsaw.w3.org/css-validator/check/referer">CSS</a>
                    </div>
                    <div class="grid--thirds__item text--right">
                        <ul class="social__icons">
                            <li class="social__icons__item"><a class="social__icons--dark" href="#"><i class="fa fa-facebook-official" aria-hidden="true"></i></a></li>
                            <li class="social__icons__item"><a class="social__icons--dark" href="#"><i class="fa fa-twitter" aria-hidden="true"></i></a></li>
                            <li class="social__icons__item"><a class="social__icons--dark" href="#"><i class="fa fa-instagram" aria-hidden="true"></i></a></li>
                        </ul>
                    </div>
                </div>
            </div>
        </footer>  
    </body>
</html>
