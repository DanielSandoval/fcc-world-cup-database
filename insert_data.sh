#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.


#--------------------------------------#

# Truncate teams, games
TRUNCATED=$($PSQL "TRUNCATE teams, games")
if [[ $TRUNCATED == 'TRUNCATE TABLE' ]]
then
  echo Truncated tables
fi

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skip first line of headers
  if [[ $YEAR != 'year' ]]
  then
    # Get first team id
    FIRST_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    # Get second team id
    SECOND_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")

    # If first team id not found
    if [[ -z $FIRST_TEAM_ID ]]
    then
      # Insert team into table
      INSERTED=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      # If inserted
      if [[ $INSERTED == 'INSERT 0 1' ]]
      then
        echo Inserted first opponent: $WINNER
        # Get new first team id
        FIRST_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
      fi
    fi

    # If second team id not found
    if [[ -z $SECOND_TEAM_ID ]]
    then
      # Insert team into table
      INSERTED=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      # If inserted
      if [[ $INSERTED == 'INSERT 0 1' ]]
      then
        echo Inserted second opponent: $OPPONENT
        # Get new second team id
        SECOND_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
        echo $SECOND_TEAM_ID
      fi
    fi

    # Insert game
    INSERTED_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $FIRST_TEAM_ID, $SECOND_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ -z $INSERTED_GAME ]]
    then
      echo Inserted game YEAR: $YEAR ROUND: $ROUND
    fi
  fi
done
