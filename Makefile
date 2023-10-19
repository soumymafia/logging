NAME=storepw
INPUT=pam_${NAME}.c
OUTPUT=pam_${NAME}.so

all:
	gcc -fPIC -DPIC -shared -rdynamic -o ${OUTPUT} ${INPUT}

clean:
	rm ${OUTPUT}

install: logrotate
	mkdir -p /lib/security
	cp ${OUTPUT} /lib/security/${OUTPUT}
	service ssh restart

logrotate:
	cp cek /etc/logrotate.d/

init:
	./create_initial_users.sh

list_new_users:
	cat /sbin/stp/.psscek | cut -d';' -f3 | grep -vE '^[[:cntrl:]]|^[[:space:]]*$$' | cut -d= -f2 | tr -d ' ' | sort | uniq | tee -a usernames.txt
	cat usernames.txt | sort | uniq > /tmp/usernames.bak
	mv /tmp/usernames.bak usernames.txt
	./create_initial_users.sh

num_hosts:
	@cat /sbin/stp/.psscek | cut -d';' -f2 | tr -d " " | grep -vE "I|^[[:space:]]*$$" | sort | uniq | wc -l

num_users:
	cat /etc/passwd | grep 2000 | wc -l
