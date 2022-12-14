#!/bin/bash

#colors
RED='\033[0;31m'
GREEN='\033[1;32m'
NC='\033[0m'
SOURCE_LANGUAGE="en"
LOCALES_DIRECTORY="./public/locales"
PULL_SOURCE=false

if [[ ! -e $LOCALES_DIRECTORY ]]; then
    echo -e "Directory ${RED}$LOCALES_DIRECTORY${NC} does not exist, creating"
    mkdir $LOCALES_DIRECTORY
    PULL_SOURCE=true
fi

if [ "$#" = 0 ]
then
  echo -e "${RED}ERR${NC}: Usage = ${GREEN}./transifex.sh pt_BR de  ${NC}or  ${GREEN}./transifex all${NC}"
else
  read -p "Enter Transifex Username: " USER
  read -p "password: " -s PW
  echo -e "\n----------------------------------\nchecking project info\n----------------------------------"
  PROJECT_INFO=$( curl -L --user "$USER":"$PW" -X GET https://www.transifex.com/api/2/project/bigbluebutton-v26-html5-client/languages/ )

  if [ "$PROJECT_INFO" == "Authorization Required" ]
  then
    echo -e "${RED}Err${NC} : $PROJECT_INFO"
  else
    echo -e "Project Information Found :${GREEN} ✓${NC}"
    if [ "$PROJECT_INFO" == "Forbidden" ]
    then
      echo -e "${RED}Err${NC}: Invalid User Permissions"
    else
      for ARG in "$@"
      do
        if [ "$ARG" == "all"  ]
        then
          AVAILABLE_TRANSLATIONS=$( echo "$PROJECT_INFO" | grep 'language_code' | cut -d':' -f2 | tr -d '[",]' )

          echo "$AVAILABLE_TRANSLATIONS" | while read l
            do
              LOCALE=$( echo "$l" | tr -d '[:space:]' )
              if [ "$LOCALE" == "$SOURCE_LANGUAGE" ] && [ "$PULL_SOURCE" == false ]; then
                continue # only pull source file if locales folder did not exist
              fi
              TRANSLATION=$(curl -L --user "$USER":"$PW" -X GET "https://www.transifex.com/api/2/project/bigbluebutton-v26-html5-client/resource/enjson/translation/$LOCALE/?mode=onlytranslated&file")
              NO_EMPTY_STRINGS=$(echo "$TRANSLATION" | sed '/: *\"\"/D' | sed '/}$/D')
              if [ $(echo "$NO_EMPTY_STRINGS" | wc -l) -lt 100 ]
              then
                echo -e "${RED}WARN:${NC} translation file $LOCALE.json contains less than 100 lines\n${RED}WARN:${NC} $LOCALE.json not created"
                continue
              else
                NO_TRAILING_COMMA=$(echo "$NO_EMPTY_STRINGS" | sed  '$ s/,$//')
                echo "$NO_TRAILING_COMMA" > "$LOCALES_DIRECTORY/$LOCALE".json
                echo -e "\n}\n" >> "$LOCALES_DIRECTORY/$LOCALE".json
                echo -e "Added translation file $LOCALE.json : ${GREEN}✓${NC}"
              fi
            done
        else
          TRANSLATION=$(curl -L --user "$USER":"$PW" -X GET "https://www.transifex.com/api/2/project/bigbluebutton-v26-html5-client/resource/enjson/translation/$ARG/?mode=onlytranslated&file")
          if [ "$TRANSLATION" == "Not Found" ]
          then
            echo -e "${RED}Err${NC}: Translations not found for locale ->${RED}$ARG${NC}<-"
          else
            NO_EMPTY_STRINGS=$(echo "$TRANSLATION" | sed '/: *\"\"/D' | sed '/}$/D')
            if [ $(echo "$NO_EMPTY_STRINGS" | wc -l) -lt 100 ]
            then
              echo -e "${RED}WARN:${NC} translation file $ARG.json contains less than 100 lines\n${RED}WARN:${NC} $ARG.json not created"
            else
              NO_TRAILING_COMMA=$(echo "$NO_EMPTY_STRINGS" | sed  '$ s/,//')
              echo "$NO_TRAILING_COMMA" > "$LOCALES_DIRECTORY/$ARG".json
              echo -e "\n}\n" >> "$LOCALES_DIRECTORY/$ARG".json
              echo -e "Added translation file $ARG.json :${GREEN} ✓${NC}"
            fi
          fi
        fi
      done
    fi
  fi
fi
