#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Delete rows before adding new ones
echo $($PSQL "TRUNCATE games, teams;")

# Insert Data
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINGOALS OPPGOALS
do
  if [[ $WINNER != winner ]]
  then
    # get team_id
    WINTEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    OPPTEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

    # if ID for winner not found
    if [[ -z $WINTEAM_ID ]]
    then
      # insert name
      INSERT_WINTEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      if [[ $INSERT_WINTEAM == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi

      # get new team_id
      WINTEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")

    fi

    # if ID for opponent not found  
    if [[ -z $OPPTEAM_ID ]]
    then
      # insert name
      INSERT_OPPTEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
      if [[ $INSERT_OPPTEAM == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi

      # get new team_id
      OPPTEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

    fi
    
    # insert winner_id and opponent_id
    INSERT_WIN_OPP_ID=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINTEAM_ID, $OPPTEAM_ID, $WINGOALS, $OPPGOALS);")
    if [[ $INSERT_WIN_OPP_ID == "INSERT 0 1" ]]
      then
        echo Inserted into games, $YEAR : $ROUND : $WINTEAM_ID : $OPPTEAM_ID : $WINGOALS : $OPPGOALS
      fi

  fi
done

