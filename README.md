# README #

### tasks ###

rake update:hosts updates the server list  
rake update:seats updates seat information
rake cleanup:hosts removes old hosts from the database  
rake cleanup:pins removes pins from unreachable hosts

### Here are the quick and dirty instructions to get this up and running: ###

install git
> sudo apt-get install git

clone this repo. in this example i have it cloned in ~/Development/byoc.ninja

> git clone https://github.com/wdeasy/byoc.ninja.git ~/Development/byoc.ninja

install ruby on rails  
> \curl -sSL https://get.rvm.io | bash -s stable --rails

install postgres  
> sudo apt-get install postgresql libpq-dev

create the usergoeshere role in postgres
>sudo su postgres  
>psql  
>create role usergoeshere with createdb login password 'passgoeshere';  
>\q
>exit

edit postgres config to allow md5 auth for local
> sudo nano /etc/postgresql/9.X/main/pg_hba.conf

change
> \#"local" is for Unix domain socket connections only  
> local   all             all                                     peer

to
> \#"local" is for Unix domain socket connections only  
> local   all             all                                     md5

>sudo service postgresql restart

create default gemset and bundle install
> cd ~/Development/byoc.ninja  
> rvm gemset create byoc.ninja  
> rvm use ruby-2.X.X@byoc.ninja --default
> gem install bundler  
> bundle install

create environment variables
>sudo nano ~/.profile

>export STEAM_WEB_API_KEY="steam web api key"  
>export SECRET_KEY_BASE="passenger secret key base"  
>export HOSTNAME="localhost"  
>export DATABASE="database name"  
>export USERNAME="database user"  
>export PASSWORD="database pass"  
>export SMTP_SERVER="smtp.gmail.com"  
>export EMAIL_DOMAIN="gmail.com"  
>export EMAIL_USERNAME="gmail username"  
>export EMAIL_PASSWORD="gmail password"  
>export GA_CODE="google analytics code"   

source the file to enable the new environment variables  
>source ~/.profile

edit db/seeds.rb and add your admin users and groups  
the group_list array needs group steam id, group steam name and group url  
the user_list array needs user steamid, name, url, avatar, and admin bool  

setup the database
> cd ~/Development/byoc.ninja  
> rake db:setup

run rake update:servers to see if it works  
run rails server, navigate to localhost:3000 and see if it works

run whenever and copy into cron
>cd ~/Development/byoc.ninja
>whenever  
>crontab -e

nginx / passenger instructions

install nginx
>sudo apt-get install nginx

install passenger
>sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7    
>sudo nano /etc/apt/sources.list.d/passenger.list  

paste & save this:   
>deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main

>sudo chown root: /etc/apt/sources.list.d/passenger.list  
>sudo chmod 600 /etc/apt/sources.list.d/passenger.list

>sudo apt-get install nginx-extras passenger

>sudo nano /etc/nginx/nginx.conf

uncomment passenger_root and passenger_ruby  
passenger_root should be the output of passenger-config --root  
passenger_ruby should be the output of which ruby   

setup vhosts file
> nano /etc/nginx/sites-available/byoc.ninja

>server {  
>  listen 80;  
>  server_name byoc.ninja www.byoc.ninja;  
>  
>	 passenger_enabled on;  
>	 rails_env	development;  
>	 root		/home/user/Development/byoc.ninja/public;  
>}  

>sudo ln -s /etc/nginx/sites-available/byoc.ninja /etc/nginx/sites-enabled/byoc.ninja  

edit /etc/hosts  
>sudo nano /etc/hosts  

add and save  
>127.0.0.1	byoc.ninja www.byoc.ninja

>sudo service nginx restart  
>rake assets:clobber  
>rake assets:precompile  

Once everything is set up, you should be able to navigate to http://byoc.ninja  
You will see the admin options in the drop down menu once you sign in through steam with the user you put in the seeds.rb file.
