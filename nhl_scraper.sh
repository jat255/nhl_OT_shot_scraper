#!/usr/bin/env bash

YEAR="${1}"
OUTFILE="/home/jat/tmp/nhl/${YEAR}output.csv"

printf "gameid,startTime,endTime,homeTeam,homeShots,awayTeam,awayShots\n" > ${OUTFILE}

for ((i=1;i<=1271;i++)); 
do 
    GAMENUM=${i}
    GAMESTR=$(printf "%04d" ${GAMENUM})
    GAMEID="${YEAR}02${GAMESTR}"

    DATA=$(curl -s https://statsapi.web.nhl.com/api/v1/game/${GAMEID}/feed/live)

    teams=$(jq '.liveData.linescore.teams' <<< "$DATA")
    overtime=$(jq '.liveData.linescore.periods[] | select(.periodType=="OVERTIME")' <<< "$DATA")

    if [ ${#overtime} -ge 1 ]; then 
        startTime=$(jq '.startTime' <<< "$overtime")
        endTime=$(jq '.endTime' <<< "$overtime")
        homeShots=$(jq '.home.shotsOnGoal' <<< "$overtime")
        awayShots=$(jq '.away.shotsOnGoal' <<< "$overtime")
        homeTeam=$(jq '.home.team.abbreviation' <<< "$teams")
        awayTeam=$(jq '.away.team.abbreviation' <<< "$teams")
        printf "${GAMEID},${startTime},${endTime},${homeTeam},${homeShots},${awayTeam},${awayShots}\n" >> ${OUTFILE}
    else 
        echo "Game ${GAMEID} did not go to overtime"
    fi

done

