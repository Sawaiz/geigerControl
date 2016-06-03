#Made for deploying application
appName=geigerControl

all: | deploy enable

enable: server.js
	sed -i -e '$$i /var/www/$(appName)/node_modules/forever/bin/forever start /var/www/$(appName)/server.js \n' /etc/rc.local
	service nginx restart
	/var/www/$(appName)/node_modules/forever/bin/forever start /var/www/$(appName)/server.js

deploy:$(appName)
	cp ./geigerControl /etc/nginx/sites-available/$<
	ln -sf /etc/nginx/sites-available/$< /etc/nginx/sites-enabled/$<
	rm -f /etc/nginx/sites-enabled/default
	mkdir -p /var/www/$</
	cd /var/www/$< &&\
	find . -maxdepth 1 ! -name 'node_modules' ! -name '.' ! -name '..' -exec rm -rf {} +
	cp -R ./* /var/www/$<
	cd /var/www/$< &&\
	npm install
	chmod -R 755 /var/www/$</*

$(appName):nginxTemplate
	sed -e 's/nginxTemplate/$@/g' $< > $@

database:

cleanAll: clean
	rm -rf /var/www/$(appName)

clean:
	rm $(appName)
