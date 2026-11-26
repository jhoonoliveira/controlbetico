#!/bin/bash
# Uso: teste.sh "texto do botão" arquivo.png [espera] [toques]  — acha o texto na tela (rolando se preciso), toca e tira foto
TXT="$1"; OUT="$2"
SZ=$(adb shell wm size | tail -1 | grep -o '[0-9]*x[0-9]*'); W=${SZ%x*}; H=${SZ#*x}; [ -z "$H" ] && { W=1080; H=1920; }; X=$((W/2)); echo "tela ${W}x${H}"
B=""; YANT=""
for i in 1 2 3 4 5 6; do
  adb shell uiautomator dump /sdcard/ui.xml >/dev/null 2>&1
  adb shell cat /sdcard/ui.xml > ui.xml 2>/dev/null
  B=$(python3 - "$TXT" <<'PY'
import re,sys
t=sys.argv[1];x=open('ui.xml',encoding='utf-8',errors='ignore').read()
for n in re.finditer(r'<node [^>]*>',x):
  s=n.group(0)
  vals=re.findall(r'(?:text|content-desc)="([^"]*)"',s)
  if any(v.strip()==t or (len(t)>3 and v.strip().startswith(t)) or (len(t)>5 and t in v) for v in vals):
    b=re.search(r'bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"',s)
    if b:
      a=list(map(int,b.groups()));print((a[0]+a[2])//2,(a[1]+a[3])//2);break
PY
)
  if [ -n "$B" ]; then
    Y=${B#* }
    if [ "$Y" -gt $((H*78/100)) ] && [ "$Y" != "$YANT" ]; then echo "'$TXT' muito embaixo ($B), rolando"; YANT=$Y; adb shell input swipe $X $((H*70/100)) $X $((H*35/100)) 500; sleep 4; B=""; continue; fi
    echo "tocando '$TXT' em $B (${4:-1}x)"; for k in $(seq 1 ${4:-1}); do adb shell input tap $B; sleep 0.3; done; break
  fi
  echo "'$TXT' não achado (tentativa $i)"; [ $i -ge 2 ] && adb shell input swipe $X $((H*70/100)) $X $((H*40/100)) 400; sleep 3
done
[ -z "$B" ] && echo "NAO_ACHOU: $TXT" >> passos.txt || echo "OK: $TXT" >> passos.txt
sleep ${3:-5}
adb exec-out screencap -p > "$OUT"
