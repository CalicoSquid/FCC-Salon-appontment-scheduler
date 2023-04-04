#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ Hair Today Dye Tomorrow Salon ~~~~~\n"
echo -e "\nWelcome to the Salon!"
echo -e "\nWe are HAIR Today, so don't DYE tomorrow hehe"

MAIN_MENU() {

  if [[ $1 ]]
  then
    echo -e $1
  fi

  echo -e "\nPlease select your service\n"
  # Find available services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  # Show available services
  echo -e "$SERVICES" | while read SERVICE_ID_SELECTED BAR NAME
    do
      echo "$SERVICE_ID_SELECTED $NAME" | sed 's/|/) /'
    done
   # get customer choice
  read CUSTOMER_SELECTION
  CUSTOMER_CHOICE=$($PSQL "SELECT name FROM services WHERE SERVICE_ID = $CUSTOMER_SELECTION")
  # If input is not a number
  if [[ ! $CUSTOMER_SELECTION =~ ^[0-9]+$ ]]
  then
    #Return to main menu
    MAIN_MENU "\nPlease enter a number to continue"
  else
    VALID_NUMBER=$($PSQL "SELECT service_id FROM services WHERE service_id = $CUSTOMER_SELECTION")  
    # If input is a number but not valid
    if [[ -z $VALID_NUMBER ]]
    then
      # Return to main menu
      MAIN_MENU "\nI could not find that service. What would you like today?"
    else
      #If input IS valid
      echo -e "\nThats great, we would be happy to give you a $CUSTOMER_CHOICE today!"
      echo -e "\n~~ To continue with this booking please enter a valid phone number ~~ \n"
      # Get phone number
      read CUSTOMER_PHONE   
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE' ")
      # If customer is not yet in database
      if [[ -z $CUSTOMER_NAME  ]]
      then        
        echo -e "\nLets add you into the system. Please enter your name."
        # Get customer name
        read CUSTOMER_NAME
        # Insert name and number into table
        CUSTOMER_INFO=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        echo -e "\nHello $CUSTOMER_NAME. What time would you like your appointment?"
        # Get requested appointment time
        read SERVICE_TIME
        # Find correct service_id
        SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $CUSTOMER_SELECTION")  
        # Find correct customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        # Enter appointment into table
        MAKE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID,'$SERVICE_TIME')")
        # Confirmation message
        echo -e "\nI have put you down for a $CUSTOMER_CHOICE at $SERVICE_TIME, $CUSTOMER_NAME."
      else
        echo -e "\nHello again $CUSTOMER_NAME. What time would you like your $($PSQL "SELECT name FROM services WHERE SERVICE_ID = $CUSTOMER_SELECTION")?" 
        # Get requested appointment time
        read SERVICE_TIME
        # Find correct customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        # Find correct service_id
        SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $CUSTOMER_SELECTION")  
        # Enter appointment into table
        MAKE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID, $SERVICE_ID,'$SERVICE_TIME')")
        # Confirmation message
        echo -e "\nI have put you down for a $CUSTOMER_CHOICE at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    fi
  fi

}
  
MAIN_MENU

