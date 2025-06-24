#!/bin/bash

# Fix notify-send for cron
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"


# Off days: Friday (5), Saturday (6)
DAY=$(date +%u)  # 1=Mon ... 7=Sun

# Exit if today is Friday (5) or Saturday (6)
if [ "$DAY" -eq 5 ] || [ "$DAY" -eq 6 ]; then
  echo "$(date): Skipping login – off day"
  exit 0
fi

# Prevent multiple logins – only run once per day
STAMP="/home/badhon/daily_login/last_login_success.stamp"
TODAY=$(date +%Y-%m-%d)

if [ -f "$STAMP" ] && grep -q "$TODAY" "$STAMP"; then
  echo "$(date): Already logged in today"
  exit 0
fi

# Your credentials
USERNAME="badhon"
PASSWORD="123456"
COOKIE_JAR=$(mktemp)

# Login
curl -k -s -L -c "$COOKIE_JAR" -b "$COOKIE_JAR" \
  -d "username=$USERNAME" \
  -d "password=$PASSWORD" \
  -d "changePassword=0" \
  "https://hajirakhata.revesoft.com/Login.do" \
  -o /home/badhon/daily_login/login_response.html

# Check login success
if grep -qi "Logout" /home/badhon/daily_login/login_response.html || grep -qi "Welcome" /home/badhon/daily_login/login_response.html; then
  echo "$TODAY" > "$STAMP"
  echo "$(date): ✅ Login successful"
  notify-send "✅ HajiraKhata" "Login successful"
else
  echo "$(date): ❌ Login failed"
  notify-send "❌ HajiraKhata" "Login failed"
fi
