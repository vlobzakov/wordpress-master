[Bind custom domain](https://docs.jelastic.com/ssh-access) and issue valid [SSL](https://docs.jelastic.com/jelastic-ssl) certificate or get platform’s SSL for your environment.

Use the following credentials to access the admin panel:

**Admin Panel**: [${globals.PROTOCOL}://${settings.envName}.${globals.REGION-0}/wp-admin/](${globals.PROTOCOL}://${settings.envName}.${globals.REGION-0}/wp-admin/)  
**Login**: admin  
**Password**: ${globals.WP_ADMIN_PASS}  

Check whether application traffic is served through CDN by [${globals.CDN_URL}](${globals.CDN_URL}), it may take up to 1 hour to propagate static assets across PoPs, so be patient.

A bunch of emails with credentials and relevant links was sent to your mailbox.

The instructions below can help you with further managing your WordPress:

* [Share access to the environment](http://docs.jelastic.com/share-environment)
* [Adjust automatic vertical scaling settings](http://docs.jelastic.com/automatic-vertical-scaling)
* [Configure automatic horizontal scaling](http://docs.jelastic.com/automatic-horizontal-scaling)
* [Monitor the statistics](http://docs.jelastic.com/view-app-statistics) & [view log files](https://docs.jelastic.com/view-log-files)
* [Attach Public IP](https://docs.jelastic.com/public-ip)
* [Access environment via SSH](https://docs.jelastic.com/ssh-access)
