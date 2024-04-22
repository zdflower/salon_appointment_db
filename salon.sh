#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MENU_SERVICES(){
    # leer los servicios de la base de datos
    SERVICES_OFFERED=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
    # mostrar los servicios
    echo "$SERVICES_OFFERED" | while read SERVICE_ID BAR SERVICE_NAME
        do
            echo "$SERVICE_ID) $SERVICE_NAME"
        done

    # leer el input
    read SERVICE_ID_SELECTED

    # buscar en la base de datos según el número seleccionado de servicio
    RETURN_SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    # si el servicio no existe
    if [[ -z $RETURN_SERVICE_SELECTED ]]
        then
        #   mostrar el menú 
        MENU_SERVICES "I could not find that service. What would you like today?"
    else
               #   pedir nº de teléfono
               echo -e "\nWhat's your phone number?"
               read CUSTOMER_PHONE
               # consultar la base de datos, guardar en una variable el id del cliente, y el nombre del cliente
               CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

               # si no existe en la base de datos
               if [[ -z $CUSTOMER_NAME ]]
                  then
                  #   pedir el nombre
                  echo -e "\nI don't have a record for that phone number, what's your name?"
                  read CUSTOMER_NAME
                  #   registrarlo en la base de datos de clientes.
                  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
               fi

               CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")"
               #   pedir la hora de la cita
               echo -e "\nWhat time would you like your $(echo $RETURN_SERVICE_SELECTED | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
               read SERVICE_TIME
               # registrar la cita en la tabla de appointments
               # usás el número de servicio que ingresó antes, y el id del cliente
               INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
               #  mostrar mensaje
               echo -e "\nI have put you down for a $(echo $RETURN_SERVICE_SELECTED | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
   fi
}

# mostrar el menu principal
MENU_SERVICES
