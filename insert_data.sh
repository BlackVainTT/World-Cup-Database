#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

RESULT=$($PSQL "TRUNCATE TABLE games, teams;")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skip first line
  if [[ $YEAR == year ]]
  then  
    continue
  fi

  # Winner doesn't exists
  if [[ -z $($PSQL "SELECT * FROM teams WHERE name = '$WINNER';") ]]
  then
    # Add winner to teams
    RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER');")
    if [[ $RESULT = "INSERT 0 1" ]]
    then
      echo $WINNER added to teams
    fi
  fi
  # Get winner id
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")


  # Opponent doesn't exists
  if [[ -z $($PSQL "SELECT * FROM teams WHERE name = '$OPPONENT';") ]]
  then
    # Add opponent to teams
    RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT');")
    if [[ $RESULT = "INSERT 0 1" ]]
    then
      echo $OPPONENT added to teams
    fi
  fi
  # Get opponent id
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT';")


  # Add game
  RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)\
  VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")

  if [[ $RESULT = "INSERT 0 1" ]]
  then
    echo added $YEAR $ROUND to games
  fi

done
