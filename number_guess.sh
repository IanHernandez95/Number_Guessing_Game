#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=games -t --no-align -c"

echo Enter your username:
read USERNAME
INPUT_LENGTH=${#USERNAME}

if [[ $INPUT_LENGTH -gt 22 ]]
then
  echo Username should be max 22 characters
else
  USERNAME_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  if [[ -z $USERNAME_ID ]]
  then
    echo Welcome, $USERNAME! It looks like this is your first time here.
    INSERT_RESULT=$($PSQL "INSERT INTO users(username,games_played,best_game) VALUES('$USERNAME',0,0)")
    USERNAME_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    GAME_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USERNAME_ID")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USERNAME_ID")
  else
    GAME_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USERNAME_ID")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USERNAME_ID")
    echo Welcome back, $USERNAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses.
  fi
fi

# Generate a random number between 
RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))

# prompt first guess
echo "Guess the secret number between 1 and 1000:"
read USER_GUESS

#varianble that count trys
GUEST_COUNT=0

#loop to guess number
until [[ $USER_GUESS == $RANDOM_NUMBER ]]
do 
   # check guess is valid/an integer
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    then
      # request valid guess
      echo -e "\nThat is not an integer, guess again:"
      read USER_GUESS
      # update guess count
      ((GUESS_COUNT++))
    
    # if its a valid guess
    else
      # check inequalities and give hint
      if [[ $USER_GUESS < $RANDOM_NUMBER ]]
        then
          echo "It's higher than that, guess again:"
          read USER_GUESS
          # update guess count
          ((GUESS_COUNT++))
        else 
          echo "It's lower than that, guess again:"
          read USER_GUESS
          #update guess count
          ((GUESS_COUNT++))
      fi  
  fi

done

# loop ends when guess is correct so, update guess
((GUESS_COUNT++))

#updates games played countt
NEW_GAMES_PLAYED=$((GAME_PLAYED + 1))
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED WHERE user_id=$USERNAME_ID")

#check it was best game played
if [[ $BEST_GAME -le 0 ]] || [[ $BEST_GAME -gt $GUESS_COUNT ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$GUESS_COUNT WHERE user_id=$USERNAME_ID")
fi

# winning message
echo You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job\!