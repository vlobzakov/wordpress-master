**Standalone Environments

[${globals.PROTOCOL}://${settings.envName}.${globals.REGION-0}/](${globals.PROTOCOL}://${settings.envName}.${globals.REGION-0}/)

[${globals.PROTOCOL}://${settings.envName}-1.${globals.REGION-1}/](${globals.PROTOCOL}://${settings.envName}-1.${globals.REGION-1}/)

**Wordpress credentinal

**Admin Panel**: [${globals.PROTOCOL}://${settings.envName}.${globals.REGION-0}/wp-admin/](${globals.PROTOCOL}://${settings.envName}.${globals.REGION-0}/wp-admin/)  
**Login**: admin  
**Password**: ${globals.WP_ADMIN_PASS}  

**DataBase credentinal

**User**: ${globals.DB_USER}    
**Password**: ${globals.DB_PASS}  

Asynchronous Master-master Replication successfully deployed between database servers

Files synchronization successfully deployed between local storages

To add custom domain name follow the steps described in the [documentation](http://docs.jelastic.com/custom-domains).
