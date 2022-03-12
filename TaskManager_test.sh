#!/bin/bash 

IFS=$'\n'
MOD=0
USER_SEL=0
PS_SEL=-1

DrawLogo()
{
        echo '______                     _    _             '
        echo '| ___ \                   | |  (_)            '
        echo '| |_/ / _ __   __ _   ___ | |_  _   ___   ___ '
        echo '|  __/ |  __| / _  | / __|| __|| | / __| / _ \'
        echo '| |    | |   | (_| || (__ | |_ | || (__ |  __/'
        echo '\_|    |_|    \__,_| \___| \__||_| \___| \___|'
        echo '                                              '
        echo '(_)       | |    (_)                          '
        echo ' _  _ __  | |     _  _ __   _   _ __  __      '
        echo '| ||  _ \ | |    | ||  _ \ | | | |\ \/ /      '
        echo '| || | | || |___ | || | | || |_| | >  <       '
        echo '|_||_| |_|\_____/|_||_| |_| \__,_|/_/\_\      '
        echo '                                              '
}

PrintPsTable()
{
echo '-NAME------------------CMD-------------------PID-----STIME-----'



for i in $(seq 0 19)
do
	
	printf '|'
        if [ $i -eq $USER_SEL ]; then

                printf '\e[41m'

        fi

                printf '%20s\e[0m|' ${USER[$i]:0:20}


        if [ $i -eq $PS_SEL ]; then

                printf '\e[42m'
        fi

                IDX=$RMOD+$i

		printf '%-2s' ${BF[$IDX]:0:2}
                printf '%-20s|' ${CMD[$IDX]:0:20}
                printf '%7s|' ${PID[$IDX]:0:7}
                printf '%9s\e[0m|\n' ${STIME[$IDX]:0:9}
done


echo '---------------------------------------------------------------'

}

while :
do

USER=(`ps aux | awk '{print $1}'| sed -nE '2,$p' | sort -u`)
ARRAY=`ps aux --sort=-pid | grep ^${USER[$USER_SEL]}`
CMD=(`awk '{print $11}' <<< ${ARRAY}`)
PID=(`awk '{print $2}' <<< ${ARRAY}`)
STIME=(`awk '{print $9}' <<< ${ARRAY}`)
BF=(`awk '{print $8}' <<< ${ARRAY} | sed $'/+$/cF\nt;cB'`)
MY=`whoami`

clear
DrawLogo
PrintPsTable

echo "If you want to exit, please type 'q' or 'Q'"

if  read -n 3  -t 3  KEY; then 
	if [ $MOD = 1 ]; then
 		if [[ ${KEY} == $'\0A' ]]; then
			if [[ ${USER[$USER_SEL]} == ${MY} ]]; then
				kill -9 ${PID[$PS_SEL]}
			else
				echo 'NO PERMISSION'
				read -n 1 -s	
			fi
		fi
	fi
fi

if [ "${KEY}" = 'q' -o "${KEY}" = 'Q' ]; then
	exit

elif [ ${MOD} = 0 ]; then
	if [[ ${KEY} == $'\e[C' ]]; then
		MOD=1
		PS_SEL=0
	elif [[ ${KEY} == $'\e[A' ]]; then
		if [ $USER_SEL -gt 0 ]; then 
                	USER_SEL=$(($USER_SEL - 1))
			RMOD=0
            	fi        
	elif [[ ${KEY} == $'\e[B' ]]; then
		if [ $USER_SEL -lt 19 -a $USER_SEL -lt $((${#USER[@]}-1)) ]; then
                       	USER_SEL=$(($USER_SEL + 1))
			RMOD=0
		fi
fi
	
	

elif [ ${MOD} = 1 ]; then
	if [[ ${KEY} == $'\e[D' ]]; then
		MOD=0
		PS_SEL=-1
	elif [[ ${KEY} == $'\e[A' ]]; then
		if [ $PS_SEL -gt 0 ]; then
                       	PS_SEL=$(($PS_SEL - 1))
		elif [ $RMOD -gt 0 ]; then
			RMOD=$(($RMOD - 1))
		fi
	elif [[ ${KEY} == $'\e[B' ]]; then
		if [ $PS_SEL -lt 19 -a $PS_SEL -lt $((${#PID[@]}-1)) ]; then
                       	PS_SEL=$(($PS_SEL + 1))
		else
		if [ $RMOD -lt $((${#PID[@]}-20)) ]; then
			RMOD=$(($RMOD + 1))	
		fi
	fi
fi
fi

done
