{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
{% set n = data.archive.split('/')[-1] %}
download:
  cmd.run:
    - use_vt: true
    - require_in:
      - cmd: postops
    - name: |
        set -ex
        wget -c "{{data.archive}}" -P "{{cfg.data_root}}"
        unzip "{{cfg.data_root}}/{{n}}" -d "{{cfg.data_root}}/birt-runtime"
    - unless: test -e "{{cfg.data_root}}/birt-runtime/runtime_readme.txt"

viewer:
  cmd.run:
    - use_vt: true
    - require_in:
      - cmd: postops
    - name: |
        set -ex
        rsync -av "{{cfg.data_root}}/birt-runtime/WebViewerExample/" "/var/lib/tomcat7/webapps/birt/"
    - unless: test -e "/var/lib/tomcat7/webapps/birt/WEB-INF/web.xml"

download-jarp:
  cmd.run:
    - use_vt: true
    - require:
      - cmd: viewer
    - require_in:
      - cmd: postops
    - name: |
        set -ex
        wget -c  "https://jdbc.postgresql.org/download/postgresql-9.4-1201.jdbc41.jar" \
          -P "/var/lib/tomcat7/webapps/birt/WEB-INF/lib"
    - unless: test -e /var/lib/tomcat7/webapps/birt/WEB-INF/lib/postgresql-9.4-1201.jdbc41.jar

download-jar-mail:
  cmd.run:
    - use_vt: true
    - require:
      - cmd: viewer
    - require_in:
      - cmd: postops
    - name: |
        set -ex
        wget -c "https://maven.java.net/content/repositories/releases/com/sun/mail/javax.mail/1.5.6/javax.mail-1.5.6.jar" \
          -P "/var/lib/tomcat7/webapps/birt/WEB-INF/lib"
    - unless: test -e /var/lib/tomcat7/webapps/birt/WEB-INF/lib/javax.mail-1.5.6.jar

download-jar-activation:
  cmd.run:
    - use_vt: true
    - require:
      - cmd: viewer
    - require_in:
      - cmd: postops
    - name: |
        set -ex
        cp {{cfg.project_root}}/activation.jar /var/lib/tomcat7/webapps/birt/WEB-INF/lib/
    - unless: test -e /var/lib/tomcat7/webapps/birt/WEB-INF/lib/activation.jar

download-jarm:
  cmd.run:
    - use_vt: true
    - require:
      - cmd: viewer
    - require_in:
      - cmd: postops
    - name: |
        set -ex
        wget -c "http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.0.8.tar.gz" \
          -P /var/lib/tomcat7/webapps/birt/WEB-INF/lib
        tar -xf "/var/lib/tomcat7/webapps/birt/WEB-INF/lib/mysql-connector-java-5.0.8.tar.gz" \
          -C /var/lib/tomcat7/webapps/birt/WEB-INF/lib/ \
          --strip-components=1 \
          mysql-connector-java-5.0.8/mysql-connector-java-5.0.8-bin.jar
    - unless: test -e /var/lib/tomcat7/webapps/birt/WEB-INF/lib/mysql-connector-java-5.0.8-bin.jar

repack-2:
  cmd.run:
    - require:
      - cmd: viewer
    - require_in:
      - cmd: postops
    - onlyif: unzip -l org.eclipse.datatools.connectivity.oda_3.5.0.201603142002.jar | grep -q ECLIPSE_.SF
    - cwd: /var/lib/tomcat7/webapps/birt/WEB-INF/lib
    - name: |
        jar=org.eclipse.datatools.connectivity.oda_3.5.0.201603142002.jar
        unzip -d repack-$jar $jar
        rm -f repack-$jar/META-INF/ECLIPSE_.SF repack-$jar/META-INF/ECLIPSE_.RSA $jar
        cd repack-$jar
        zip -r ../$jar .
        cd ..
        rm -rf repack-$jar

repack-1:
  cmd.run:
    - require:
      - cmd: viewer
    - require_in:
      - cmd: postops
    - onlyif: unzip -l org.eclipse.birt.runtime_4.6.0-20160607.jar | grep -q ECLIPSE_.SF
    - cwd: /var/lib/tomcat7/webapps/birt/WEB-INF/lib
    - name: |
        jar=org.eclipse.birt.runtime_4.6.0-20160607.jar
        unzip -d repack-$jar $jar
        rm -f repack-$jar/META-INF/ECLIPSE_.SF repack-$jar/META-INF/ECLIPSE_.RSA $jar
        cd repack-$jar
        zip -r ../$jar .
        cd ..
        rm -rf repack-$jar

postops:
  cmd.run:
    - name: |
         perl -i -p0e "s/BIRT_VIEWER_WORKING_FOLDER<\/param-name>\n\t\t<param-value>/BIRT_VIEWER_WORKING_FOLDER<\/param-name>\n\t\t<param-value>\/var\/lib\/tomcat7\/webapps\/birt\//smg" /var/lib/tomcat7/webapps/birt/WEB-INF/web.xml
         chown -Rf tomcat7:tomcat7 /var/lib/tomcat7/webapps/birt




