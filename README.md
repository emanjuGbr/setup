# setup_live.sh
Zum einrichten eines neuen Servers
* erzeugt eine odoo config auf Basis des Templates odoo/odoo.conf.template
* generiert die Passwörter für odoo & postgresql user
* setzt die Zugriffsrechte der per bind mount eingebundenen Ordner
* startet die 3 services
** odoo
** nginx
** postgresql

# create_domain.sh
Zum Einrichten einer neuen Domain
* erzeugt eine neue nginx config auf Basis des Templates nginx/conf.d/odoo.template
* holt ein Let's Encrypt Zertifikat für die Domain
