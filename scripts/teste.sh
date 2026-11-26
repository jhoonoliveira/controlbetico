#!/bin/bash
# Uso: teste.sh "texto do botão" arquivo.png  — acha o texto na tela, toca e tira foto
TXT="$1"; OUT="$2"
for i in 1 2 3 4 5; do
  adb shell uiautomator dump /sdcard/ui.xml >/dev/null 2>&1
  adb shell cat /sdcard/ui.xml > ui.xml 2>/dev/null
  B=$(python3 - "$TXT" <<'PY'
import re,sys
t=sys.argv[1];x=open('ui.xml',encoding='utf-8',errors='ignore').read()
for n in re.finditer(r'<node [^>]*>',x):
  s=n.group(0)
  m=re.search(r'(?:text|content-desc)="([^"]*)"',s)
  vals=re.findall(r'(?:text|content-desc)="([^"]*)"',s)
  if any(v.strip()==t or (len(t)>3 and v.strip().startswith(t)) or (len(t)>5 and t in v) for v in vals):
    b=re.search(r'bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"',s)
    if b:
      a=list(map(int,b.groups()));print((a[0]+a[2])//2,(a[1]+a[3])//2);break
PY
)
  if [ -n "$B" ]; then echo "tocando '$TXT' em $B"; adb shell input tap $B; break; fi
  echo "'$TXT' não achado (tentativa $i)"; [ $i -ge 2 ] && adb shell input swipe 540 1500 540 800 400; sleep 3
done
[ -z "$B" ] && echo "NAO_ACHOU: $TXT" >> passos.txt || echo "OK: $TXT" >> passos.txt
sleep ${3:-5}
adb exec-out screencap -p > "$OUT"
