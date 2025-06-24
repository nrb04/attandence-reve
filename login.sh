#!/bin/bash

# ─── Environment Setup for notify-send (Cron Compatibility) ──────────────
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# ─── Configurations ─────────────────────────────────────────────────────
USERNAME=""
PASSWORD=""
LOGIN_URL="https://Login.do"
STAMP="/home/badhon/daily_login/last_login_success.stamp"
RESPONSE="/home/badhon/daily_login/login_response.html"
LOGFILE="/home/badhon/daily_login/login.log"
TODAY=$(date +%Y-%m-%d)
NOW=$(date "+%Y-%m-%d %H:%M:%S")
COOKIE_JAR=$(mktemp)

# ─── Off Day Check ───────────────────────────────
DAY=$(date +%u)  # 1=Mon ... 7=Sun
if [ "$DAY" -eq 5 ] || [ "$DAY" -eq 6 ]; then
  echo "$NOW ❎ Skipped – Off day (Friday/Saturday)" >> "$LOGFILE"
  notify-send "❎ HajiraKhata" "Skipped – Friday/Saturday"
  exit 0
fi

# ─── Govt Holiday Check ──────────────────────────
HOLIDAY_FILE="/home/badhon/daily_login/govt_holidays.txt"
if [ -f "$HOLIDAY_FILE" ] && grep -Fxq "$TODAY" "$HOLIDAY_FILE"; then
  echo "$NOW 🏖 Skipped – Govt holiday" >> "$LOGFILE"
  notify-send "🏖 HajiraKhata" "Skipped – Govt holiday"
  exit 0
fi

# ─── Skip if Already Logged in Today ────────────────────────────────────
if [ -f "$STAMP" ] && grep -q "$TODAY" "$STAMP"; then
  echo "$NOW ⏭ Already logged in today" >> "$LOGFILE"
  exit 0
fi

# ─── Perform Login ──────────────────────────────────────────────────────
curl -k -s -L -c "$COOKIE_JAR" -b "$COOKIE_JAR" \
  -d "username=$USERNAME" \
  -d "password=$PASSWORD" \
  -d "changePassword=0" \
  "$LOGIN_URL" -o "$RESPONSE"

# ─── Check Login Success ────────────────────────────────────────────────
if grep -qi "Logout" "$RESPONSE" || grep -qi "Welcome" "$RESPONSE"; then
  echo "$TODAY" > "$STAMP"
  echo "$NOW ✅ Login successful" >> "$LOGFILE"
  notify-send "✅ HajiraKhata" "Login successful"
else
  echo "$NOW ❌ Login failed" >> "$LOGFILE"
  notify-send "❌ HajiraKhata" "Login failed"
fi
