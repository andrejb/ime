##############################################################################
# MAC0448 - Programação para Redes de Computadores
# 1o. semestre de 2009
# Prof.: Manoel Marcilio Sanches
#
# EP 1 - Servidor HTTP e Servidor de Mensagens
# André Jucovsky Bianchi - 3682247
##############################################################################


# portas para rodar os testes
HTTP_PORT = 8080
MSG_SERVER_PORT = 8888


# variaveis de ambiente
JAVA = /usr/bin/java
JAVAC = /usr/bin/javac
JAR = /usr/bin/jar
PKG_NAME = mac448-andre.bianchi-ep1


# regras
all: HTTPServer.jar RandomClient.class

HTTPServer.jar: HTTPServer.java
	$(JAVAC) HTTPServer.java
	$(JAR) cvfm HTTPServer.jar manifest.txt *.class

RandomClient.class: RandomClient.java
	$(JAVAC) RandomClient.java

run: all
	$(JAVA) -jar HTTPServer.jar $(HTTP_PORT) $(MSG_SERVER_PORT)

test: all
	$(JAVA) RandomClient $(MSG_SERVER_PORT)

edit:
	vim -p *.java Makefile LEIAME.txt

partial-clean:
	rm -f *.class

clean: partial-clean
	rm -f *.jar

pkg: all partial-clean
	mkdir -p $(PKG_NAME)
	cp *.java *.jar LEIAME.txt Makefile $(PKG_NAME)/
	cp Posicao.txt.default $(PKG_NAME)/Posicao.txt
	tar cjf $(PKG_NAME).tar.bz2 $(PKG_NAME)/
	rm -rf $(PKG_NAME)/

.PHONY: all test edit clean pkg partial-clean
