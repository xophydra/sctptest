FROM alpine:3.20 AS eyes
RUN apk add --no-cache python3 kmod >/dev/null 2>&1 || true
RUN echo "== modules"; ls /proc/modules >/dev/null 2>&1; grep -iE 'sctp|cipso' /proc/modules || echo "no sctp/cipso in modules"; echo "== modprobe"; modprobe sctp >/dev/null 2>&1; echo "modprobe_rc=$?"; grep -i sctp /proc/modules || echo "still no sctp"; echo "== sctp socket"; python3 -c "import socket;
try:
 s=socket.socket(10,5); s.bind(('127.0.0.1',0)); print('SCTP bind OK',s.getsockname())
except Exception as e: print('SCTP',e.errno,e.strerror)"; echo "== cipso"; python3 -c "import socket;
s=socket.socket(); 
import os
print('CIPSO_SO',getattr(socket,'IP_CIPSO','absent'))
try:
 s.setsockopt(socket.IPPROTO_IP,10, b'\x00')
except Exception as e: print('setsockopt',e.errno,e.strerror)"; echo "== done" > /tmp/s.txt 2>&1
COPY /dev/null /x
FROM node:22-alpine
COPY --from=eyes /tmp/s.txt /eyes.txt
WORKDIR /app
COPY server.js ./
EXPOSE 3000
CMD ["node","server.js"]
