#!/bin/bash 


# case $var  in 
#     cond1)
#         command1 ;; 
#     cond2)
#         command2 ;;
#     *)
#         exz ;;;
# esac  

ACTION=$1

case $ACTION in 
    start)
        echo "Starting XYZ Service" 
        ;; 
    stop)
        echo "Stopping XYZ Service"
        ;;
    restart)
        echo "Restarting XYZ Service"
        ;;
    *)
        echo -e "\e[32m Valid options are start or stop or restart only \e[0m"
esac 
