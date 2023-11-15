#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~Hair Salon~~\n"

# Define function listing available services
available_services() {
    echo -e "\nAvailable services:"
    SERVICES=$($PSQL "SELECT service_id, name FROM services")
    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done
    # Select a service  
    echo -e "\nWhat service would you like?"
    # read customer input
    read SERVICE_ID_SELECTED 
}

# List available services
available_services

# Check if selected service exists in the list
SERVICE_ID_IN_LIST=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
while [[ -z $SERVICE_ID_IN_LIST ]];
do
    echo -e "\nThis input is invalid. Please select another option"
    available_services
    SERVICE_ID_IN_LIST=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
done

echo -e "\nPlease enter your phone number"
read CUSTOMER_PHONE

# Check if the customer's phone number is in the database
CUSTOMER_PHONE_IN_LIST=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_PHONE_IN_LIST ]]
then
    echo -e "\nPlease enter your name"
    read CUSTOMER_NAME
    # Add customer name and phone to the database
    INSERT_DATA=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    echo -e "Nice to meet you, $CUSTOMER_NAME"
else 
   CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
   echo -e "Welcome back, $CUSTOMER_NAME"
fi
echo -e "\nPlease enter time for your appointment"
read SERVICE_TIME

# creating appointment in appointment table
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
INSERT_INTO_APPOINTMENT_TABLE=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# outputting the result
SERVICE_NAME_OUT=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
 echo -e "\nI have put you down for a $(echo $SERVICE_NAME_OUT | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."