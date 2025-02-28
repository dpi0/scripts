#!/bin/bash

# \e[: This is the escape sequence that starts an ANSI escape code. The \e is a shorthand for the escape character \033.
#
# 48;5;46m: This sets the background color to green.
#
#     48: Indicates that the following code is for the background color.
#
#     5: Indicates that the color is specified by a 256-color palette index.
#
#     46: The specific color index for green in the 256-color palette.
#
# \e[38;5;208m: This sets the foreground color to orange.
#
#     38: Indicates that the following code is for the foreground color.
#
#     5: Indicates that the color is specified by a 256-color palette index.
#
#     208: The specific color index for orange in the 256-color palette.
#
#
#     \e[0m: This resets all text attributes (including colors) back to their defaults.

# Define color variables
BG_GREEN="\e[48;5;46m"
BG_BLUE="\e[48;5;27m"
BG_YELLOW="\e[48;5;226m"
BG_PURPLE="\e[48;5;93m"
BG_CYAN="\e[48;5;51m"
BG_ORANGE="\e[48;5;208m"
BG_RED="\e[48;5;196m"

FG_BLACK="\e[38;5;0m"
FG_WHITE="\e[38;5;15m"
FG_RED="\e[38;5;196m"
FG_GREEN="\e[38;5;46m"
FG_BLUE="\e[38;5;27m"
FG_YELLOW="\e[38;5;226m"
FG_PURPLE="\e[38;5;93m"

RESET="\e[0m"

# Test echo statements
echo -e "${BG_GREEN}${FG_BLACK}GREEN BG, BLACK FG${RESET} this is good"
echo -e "${BG_BLUE}${FG_WHITE}BLUE BG, WHITE FG${RESET} this is good"
echo -e "${BG_YELLOW}${FG_RED}YELLOW BG, RED FG${RESET} this is good"
echo -e "${BG_PURPLE}${FG_GREEN}PURPLE BG, GREEN FG${RESET} this is good"
echo -e "${BG_CYAN}${FG_BLUE}CYAN BG, BLUE FG${RESET} this is good"
echo -e "${BG_ORANGE}${FG_YELLOW}ORANGE BG, YELLOW FG${RESET} this is good"
echo -e "${BG_GREEN}${FG_PURPLE}GREEN BG, PURPLE FG${RESET} this is good"
echo -e "${BG_BLUE}${FG_ORANGE}BLUE BG, ORANGE FG${RESET} this is good"
echo -e "${BG_YELLOW}${FG_WHITE}YELLOW BG, WHITE FG${RESET} this is good"
echo -e "${BG_PURPLE}${FG_BLACK}PURPLE BG, BLACK FG${RESET} this is good"
