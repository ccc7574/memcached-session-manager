# Generated by Buildr 1.3.3, change to your liking
# Standard maven2 repository
require 'etc/checkstyle'

repositories.remote << 'http://repo2.maven.org/maven2'
repositories.remote << 'http://www.ibiblio.org/maven2'
repositories.remote << 'http://thimbleware.com/maven'
repositories.remote << 'http://repository.jboss.com/maven2'
#repositories.remote << 'http://powermock.googlecode.com/svn/repo'

SERVLET_API = 'javax.servlet:servlet-api:jar:2.5'
CATALINA = 'org.apache.tomcat:catalina:jar:6.0.18'
CATALINA_HA = 'org.apache.tomcat:catalina-ha:jar:6.0.18'
MEMCACHED = artifact('spy.memcached:spymemcached:jar:2.4.2').from(file('lib/memcached-2.4.2.jar'))
TC_COYOTE = transitive( 'org.apache.tomcat:coyote:jar:6.0.18' )
JAVOLUTION = artifact('javolution:javolution:jar:5.4.3.1').from(file('lib/javolution-5.4.3.1.jar'))
XSTREAM = transitive( 'com.thoughtworks.xstream:xstream:jar:1.3.1' )
JODA_TIME = 'joda-time:joda-time:jar:1.6'

# Testing
JMEMCACHED = transitive( 'com.thimbleware.jmemcached:jmemcached-core:jar:0.6' ).reject { |a| a.group == 'org.slf4j' }
HTTP_CLIENT = transitive( 'commons-httpclient:commons-httpclient:jar:3.1' )
SLF4J = transitive( 'org.slf4j:slf4j-simple:jar:1.5.6' )
JMOCK_CGLIB = transitive( 'jmock:jmock-cglib:jar:1.2.0' )
CLANG = 'commons-lang:commons-lang:jar:2.4' # tests of javolution-serializer, xstream-serializer
MOCKITO = transitive( 'org.mockito:mockito-core:jar:1.8.1' )
#POWERMOCK_CORE = 'org.powermock:powermock-core:jar:1.3.5'
#POWERMOCK_JUNIT = 'org.powermock.modules:powermock-module-junit4:jar:1.3.5'
#POWERMOCK_JUNIT_COMMON = 'org.powermock.modules:powermock-module-junit4-common:jar:1.3.5'
#POWERMOCK_MOCKITO = 'org.powermock.api:powermock-api-mockito:jar:1.3.5'

# Dependencies
require 'etc/tools'

LIBS = [ CATALINA, CATALINA_HA, MEMCACHED, JMEMCACHED, TC_COYOTE, HTTP_CLIENT, SLF4J, XSTREAM ]
task("check-deps") do |task|
  checkdeps LIBS      
end                         

task("dep-tree") do |task|
  deptree LIBS
end

desc 'memcached-session-manager (msm for short): memcached based session failover for Apache Tomcat'
define 'msm' do
  project.group = 'de.javakaffee.web.msm'
  project.version = '1.2-SNAPSHOT'

  compile.using :source=>'1.5', :target=>'1.5'
  package :sources

  checkstyle.config 'etc/checkstyle-checks.xml'
  checkstyle.style 'etc/checkstyle.xsl'
  
  desc 'The core module of memcached-session-manager'
  define 'core' do |project|
    compile.with( SERVLET_API, CATALINA, CATALINA_HA, TC_COYOTE, MEMCACHED )
    test.with( JMEMCACHED, HTTP_CLIENT, SLF4J, JMOCK_CGLIB, MOCKITO )
    package :jar, :javadoc, :id => 'memcached-session-manager'
  end

  desc 'Javolution/xml based serialization strategy'
  define 'javolution-serializer' do |project|
    compile.with( projects('core'), project('core').compile.dependencies, JAVOLUTION )
    test.with( compile.dependencies, CLANG, JMOCK_CGLIB )
    test.using :testng
    package :jar, :javadoc, :id => 'msm-javolution-serializer'
  end

  desc 'Converter for Joda DateTime instances for javolution serialization strategy'
  define 'javolution-serializer-jodatime' do |project|
    compile.with( projects('javolution-serializer'), project('javolution-serializer').compile.dependencies, JODA_TIME )
    test.with( compile.dependencies, MOCKITO )
    #test.with( compile.dependencies, MOCKITO, POWERMOCK_CORE, POWERMOCK_MOCKITO, POWERMOCK_JUNIT, POWERMOCK_JUNIT_COMMON )
    test.using :testng
    package :jar, :javadoc, :id => 'msm-javolution-serializer-jodatime'
  end

  desc 'XStream/xml based serialization strategy'
  define 'xstream-serializer' do |project|
    compile.with( projects('core'), project('core').compile.dependencies, XSTREAM )
    test.with( compile.dependencies, CLANG )
    test.using :testng
    package :jar, :javadoc, :id => 'msm-xstream-serializer'
  end

end
